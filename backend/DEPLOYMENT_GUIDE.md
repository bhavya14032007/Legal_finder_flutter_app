# Legal Helper Backend - Deployment & Operations Guide

This guide walks through deploying the complete Legal Helper backend infrastructure to Supabase (Local, Staging, or Production).

---

## 1. Prerequisites

* [Supabase CLI](https://supabase.com/docs/guides/cli) installed (`npm install -g supabase` or `brew install supabase/tap/supabase` or `scoop install supabase`).
* An active [Supabase Account](https://supabase.com) and a created project.
* An API key for your chosen AI provider (Google Gemini, OpenAI, Anthropic, or Groq).

---

## 2. Local Development & Testing

### 2.1 Start Local Supabase Stack
```bash
# Start Docker-based local Supabase services (PostgreSQL, Storage, Auth, Functions)
supabase start
```

### 2.2 Apply Migrations & Seed Data
```bash
# Reset local DB and execute all migrations 001 through 010 in order
supabase db reset

# Alternatively run seed manually if not run automatically:
supabase db execute --file ./supabase/seed.sql
```

### 2.3 Serve Edge Functions Locally
```bash
# Serve all functions with local environment variables
supabase functions serve --env-file .env.example --no-verify-jwt
```

---

## 3. Production Deployment

### 3.1 Authenticate and Link Project
```bash
# Log in to Supabase CLI
supabase login

# Link local repository to your remote Supabase project
# (Find project reference ID in Supabase Project Settings > General)
supabase link --project-ref <your-project-id>
```

### 3.2 Deploy Database Migrations
```bash
# Push all SQL migrations to remote database
supabase db push
```

Alternatively, if deploying via the Supabase Web Dashboard SQL Editor:
1. Open **Supabase Dashboard > SQL Editor**.
2. Run migration scripts sequentially:
   - `001_create_profiles.sql`
   - `002_create_chat_tables.sql`
   - `003_create_documents.sql`
   - `004_create_drafts.sql`
   - `005_create_saved_items.sql`
   - `006_create_research_history.sql`
   - `007_create_evidence_tables.sql`
   - `008_create_user_settings.sql`
   - `009_create_rls_policies.sql`
   - `010_create_indexes.sql`
3. Run `seed.sql` to populate verified Legal Aid Authorities.

### 3.3 Set Edge Function Secrets
Set your production environment secrets on Supabase:
```bash
# Set AI Provider and API keys
supabase secrets set AI_PROVIDER=gemini
supabase secrets set GEMINI_API_KEY="AIzaSy..."
supabase secrets set GEMINI_MODEL="gemini-1.5-flash"

# If using OpenAI:
# supabase secrets set AI_PROVIDER=openai
# supabase secrets set OPENAI_API_KEY="sk-..."
# supabase secrets set OPENAI_MODEL="gpt-4o-mini"

# If using Anthropic:
# supabase secrets set AI_PROVIDER=anthropic
# supabase secrets set ANTHROPIC_API_KEY="sk-ant-..."
```

Verify secrets are successfully registered:
```bash
supabase secrets list
```

### 3.4 Deploy Edge Functions
Deploy all 8 functions to the edge network:
```bash
supabase functions deploy legal-advisor
supabase functions deploy legal-research
supabase functions deploy document-simplifier
supabase functions deploy drafting-assistant
supabase functions deploy notice-reply
supabase functions deploy scam-detector
supabase functions deploy document-processing
supabase functions deploy lawyer-prep
```

---

## 4. Verification Checklist

1. **Auth Settings:**
   - Go to **Authentication > URL Configuration**.
   - Add your frontend URLs to **Redirect URLs**:
     - React Web: `https://your-react-domain.com/**`
     - Flutter Android: `legalhelper://auth-callback/**`
2. **Storage Buckets:**
   - Go to **Storage > Buckets**.
   - Verify that `legal-documents`, `evidence-files`, `user-uploads`, and `generated-documents` exist and have **Public** set to **OFF**.
3. **Database Health:**
   - Execute `tests/sql/rls_isolation_test.sql` in the SQL editor to confirm that all 10 RLS isolation checks pass.

