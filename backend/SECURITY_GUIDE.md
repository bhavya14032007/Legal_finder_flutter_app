# Legal Helper Backend - Security & Threat Mitigation Guide

Security and confidentiality are primary architectural requirements for the Legal Helper platform. Legal documents, consultations, and evidence items contain sensitive and legally privileged data.

---

## 1. Row Level Security (RLS) Architecture

Row Level Security is enabled on **every user-owned table** in the database.

### 1.1 Strict User Ownership Isolation
All user-owned tables enforce `auth.uid() = user_id` (or `auth.uid() = id` on `profiles`).

```sql
CREATE POLICY "Users can view their own documents"
    ON public.documents FOR SELECT
    USING (auth.uid() = user_id);
```

### 1.2 Parent-Child Relation Verification
For child tables such as `chat_messages` and `document_results`, the policies enforce both direct user ownership **and** parent entity ownership. This prevents malicious users from injecting messages into or viewing results of a parent session/document owned by another user:

```sql
CREATE POLICY "Users can insert messages into their own sessions"
    ON public.chat_messages FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.chat_sessions s
            WHERE s.id = session_id AND s.user_id = auth.uid()
        )
    );
```

### 1.3 Read-Only Reference Directory
The `legal_aid_directory` table is accessible for `SELECT` by verified authenticated users (`auth.role() = 'authenticated'`). All mutation operations (`INSERT`, `UPDATE`, `DELETE`) are prohibited for general users and restricted exclusively to the Supabase Service Role.

---

## 2. Storage Security & Path Conventions

### 2.1 Private Buckets by Default
All 4 storage buckets are private (`public = false`):
1. `legal-documents` (Max 50MB, restricted MIME types)
2. `evidence-files` (Max 100MB, media + document MIME types)
3. `user-uploads` (Max 50MB)
4. `generated-documents` (Max 50MB)

### 2.2 Strict Folder Path Partitioning
Storage objects are organized strictly by user ID:
```
{bucket_name}/{user_id}/{timestamp}_{filename}
```
Supabase Storage RLS policies enforce that users can only upload, read, update, or delete files inside their own directory using the `storage.foldername(name)[1] = auth.uid()::text` check:

```sql
CREATE POLICY "Users can view their own storage files"
    ON storage.objects FOR SELECT
    USING (
        auth.role() = 'authenticated' AND
        bucket_id IN ('legal-documents', 'evidence-files', 'user-uploads', 'generated-documents') AND
        (storage.foldername(name))[1] = auth.uid()::text
    );
```

### 2.3 Signed URLs for Temporary File Access
Direct public URLs to storage objects are blocked. The `document-processing` Edge Function generates time-limited cryptographically signed URLs (default: 15 minutes / 900 seconds) only after verifying that the requesting user owns the document record in PostgreSQL.

---

## 3. Cryptographic Data Integrity

To track file integrity without claiming forensic chain-of-custody, every document uploaded to the Legal Vault or Evidence timeline undergoes SHA-256 cryptographic hashing:
1. When a document is registered via `document-processing`, the server downloads the raw array buffer.
2. Web Crypto API computes the SHA-256 digest: `crypto.subtle.digest("SHA-256", arrayBuffer)`.
3. The resulting 64-character hexadecimal checksum is permanently recorded in `documents.file_hash` and `evidence_items.file_hash`.
4. Any subsequent tampering or alteration in storage can be detected by recalculating the hash.

---

## 4. AI Provider Security & Secret Hygiene

### 4.1 Server-Side Key Isolation
* All LLM API keys (`GEMINI_API_KEY`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GROQ_API_KEY`) reside exclusively in Supabase Edge Function Secrets.
* Neither the React web client nor the Flutter mobile application has access to LLM API keys.

### 4.2 Error Sanitization
In the `AIProviderService` module, all raw error strings from upstream AI providers are sanitized before propagating to the client:
```typescript
private sanitizeError(raw: string): string {
  return raw
    .replace(new RegExp(this.apiKey, "gi"), "[REDACTED_API_KEY]")
    .slice(0, 500);
}
```

---

## 5. Rate Limiting & Denial of Service Protection

To prevent cost overruns and API abuse on compute-heavy LLM endpoints, the `rate-limiter.ts` module enforces per-user sliding-window throttling:
* `legal-advisor`: 30 requests / min
* `legal-research`: 20 requests / min
* `document-simplifier`: 15 requests / min
* `drafting-assistant`: 20 requests / min
* `notice-reply`: 15 requests / min
* `scam-detector`: 25 requests / min

Exceeding the quota triggers a `429 RATE_LIMIT_EXCEEDED` HTTP response with a `Retry-After` reset duration.

---

## 6. Input Validation & Prompt Injection Defense

* Every Edge Function uses strict validators (`validateRequiredString`, `isValidUUID`, `validateEnum`, `sanitizeText`).
* Text inputs are sanitized by removing null bytes (`\0`) and normalizing whitespace.
* Length boundaries prevent denial-of-service via oversized payloads (e.g. max 50,000 characters for documents, max 8,000 for chat queries).
* Model prompts isolate user-supplied content within distinct delimiters, instruct the LLM to ignore instructions attempting to override system guardrails, and mandate structured JSON schema enforcement (`jsonMode: true`).

