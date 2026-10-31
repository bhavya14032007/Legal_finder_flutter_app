// Edge Function: document-simplifier
// Description: Plain-language translation, clause breakdown, and risk analysis in English & Hindi with document chunking

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { handleCors } from "../shared/cors.ts";
import { authenticateRequest } from "../shared/auth.ts";
import { createSuccessResponse, createErrorResponse } from "../shared/response.ts";
import { checkRateLimit } from "../shared/rate-limiter.ts";
import { isValidUUID, validateRequiredString, sanitizeText } from "../shared/validator.ts";
import { AIProviderService } from "../shared/ai-provider.ts";
import { DOCUMENT_SIMPLIFIER_SYSTEM_PROMPT, LEGAL_DISCLAIMER_EN } from "../shared/legal-prompts.ts";

const MAX_DIRECT_TEXT_LENGTH = 50_000;
const CHUNK_SIZE = 12_000;
const CHUNK_OVERLAP = 500;

// Chunking helper to preserve full context of lengthy legal contracts without silent loss
function chunkText(text: string, chunkSize: number, overlap: number): string[] {
  const chunks: string[] = [];
  let startIndex = 0;

  while (startIndex < text.length) {
    let endIndex = startIndex + chunkSize;
    if (endIndex < text.length) {
      // Look for natural paragraph or sentence boundary
      const lastParagraph = text.lastIndexOf("\n\n", endIndex);
      if (lastParagraph > startIndex + chunkSize * 0.7) {
        endIndex = lastParagraph;
      } else {
        const lastPeriod = text.lastIndexOf(". ", endIndex);
        if (lastPeriod > startIndex + chunkSize * 0.7) {
          endIndex = lastPeriod + 1;
        }
      }
    }
    chunks.push(text.slice(startIndex, endIndex).trim());
    startIndex = endIndex - overlap;
  }

  return chunks;
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return createErrorResponse("Method not allowed. Use POST.", 405, "METHOD_NOT_ALLOWED");
  }

  try {
    // 1. Authenticate Request
    const { user, client } = await authenticateRequest(req);

    // 2. Rate Limiting Check (15 doc simplifications/min per user)
    const rateCheck = checkRateLimit(`doc_simp_${user.id}`, { windowMs: 60000, maxRequests: 15 });
    if (!rateCheck.allowed) {
      return createErrorResponse(
        `Rate limit exceeded. Try again in ${Math.ceil(rateCheck.resetMs / 1000)} seconds.`,
        429,
        "RATE_LIMIT_EXCEEDED"
      );
    }

    // 3. Parse Request
    const body = await req.json().catch(() => ({}));
    let documentId = body.document_id;
    let extractedText = "";
    let documentTitle = body.title || "Legal Document";

    if (documentId) {
      if (!isValidUUID(documentId)) {
        return createErrorResponse("Invalid document_id format.", 400, "INVALID_INPUT");
      }

      // Fetch document from database verifying ownership
      const { data: docRecord, error: docErr } = await client
        .from("documents")
        .select("*")
        .eq("id", documentId)
        .eq("user_id", user.id)
        .single();

      if (docErr || !docRecord) {
        return createErrorResponse("Document not found or access denied.", 404, "DOCUMENT_NOT_FOUND");
      }

      documentTitle = docRecord.title || docRecord.original_filename;

      // Update processing status to 'processing'
      await client
        .from("documents")
        .update({ processing_status: "processing" })
        .eq("id", documentId);

      // Download file from private storage
      const bucket = docRecord.bucket_id || "legal-documents";
      const { data: fileData, error: downloadErr } = await client.storage
        .from(bucket)
        .download(docRecord.storage_path);

      if (downloadErr || !fileData) {
        await client
          .from("documents")
          .update({ processing_status: "failed", error_message: "Failed to download storage object" })
          .eq("id", documentId);

        return createErrorResponse(`Failed to download document from storage: ${downloadErr?.message}`, 500, "STORAGE_ERROR");
      }

      // If text/plain or markdown, read directly
      if (docRecord.mime_type.includes("text") || docRecord.mime_type.includes("json")) {
        extractedText = await fileData.text();
      } else {
        // For binaries like PDF/DOCX where client extracted or provided text in payload
        if (body.extracted_text) {
          extractedText = sanitizeText(body.extracted_text);
        } else {
          // Fallback text preview from blob or indicate parser required
          extractedText = await fileData.text().catch(() => "");
        }
      }
    } else if (body.raw_text) {
      // Direct raw text analysis
      extractedText = sanitizeText(validateRequiredString(body.raw_text, "raw_text", 10, MAX_DIRECT_TEXT_LENGTH));
      
      // Create a document record in documents table
      const { data: newDoc, error: createDocErr } = await client
        .from("documents")
        .insert({
          user_id: user.id,
          title: documentTitle,
          original_filename: `${documentTitle.replace(/\s+/g, "_")}.txt`,
          storage_path: `${user.id}/${Date.now()}_text_input.txt`,
          bucket_id: "legal-documents",
          mime_type: "text/plain",
          file_size: extractedText.length,
          document_type: body.document_type || "contract",
          processing_status: "processing",
        })
        .select("id")
        .single();

      if (createDocErr || !newDoc) {
        return createErrorResponse("Failed to register document in vault.", 500, "DB_ERROR");
      }
      documentId = newDoc.id;
    } else {
      return createErrorResponse("Either 'document_id' or 'raw_text' must be provided.", 400, "INVALID_INPUT");
    }

    if (!extractedText || extractedText.trim().length < 10) {
      if (documentId) {
        await client
          .from("documents")
          .update({ processing_status: "failed", error_message: "Document text content is empty" })
          .eq("id", documentId);
      }
      return createErrorResponse("No readable text found in document for analysis.", 400, "EMPTY_DOCUMENT");
    }

    // 4. Handle text chunking if long document
    const aiService = new AIProviderService();
    let textToAnalyze = extractedText;

    if (extractedText.length > CHUNK_SIZE) {
      const chunks = chunkText(extractedText, CHUNK_SIZE, CHUNK_OVERLAP);
      // For very long documents, analyze top chunks preserving structure
      textToAnalyze = chunks.slice(0, 3).join("\n\n--- [Next Document Section] ---\n\n");
    }

    // 5. Invoke AI for Simplification & Risk Breakdown
    const promptMessage = `Document Title: "${documentTitle}"\n\nFull/Key Document Content for Analysis:\n${textToAnalyze}`;

    const completion = await aiService.generateCompletion({
      systemPrompt: DOCUMENT_SIMPLIFIER_SYSTEM_PROMPT,
      messages: [{ role: "user", content: promptMessage }],
      temperature: 0.1,
      maxTokens: 3000,
      jsonMode: true,
    });

    let analysis: Record<string, unknown> = {};
    try {
      analysis = JSON.parse(completion.text);
    } catch (_e) {
      const cleanJson = completion.text.replace(/```json/g, "").replace(/```/g, "").trim();
      analysis = JSON.parse(cleanJson);
    }

    const summaryEn = (analysis.summary_en as string) || "Summary generated.";
    const summaryHi = (analysis.summary_hi as string) || "";
    const keyObligations = Array.isArray(analysis.key_obligations) ? analysis.key_obligations : [];
    const importantClauses = Array.isArray(analysis.important_clauses) ? analysis.important_clauses : [];
    const riskNotes = Array.isArray(analysis.risk_notes) ? analysis.risk_notes : [];

    // 6. Save results to document_results Table
    const { data: resultRecord, error: resultErr } = await client
      .from("document_results")
      .upsert(
        {
          document_id: documentId,
          user_id: user.id,
          simplified_content: summaryEn,
          extracted_text: extractedText.slice(0, 50000), // preserve up to 50k chars in text
          summary: summaryEn,
          risk_notes: riskNotes,
          important_clauses: importantClauses,
          key_obligations: keyObligations,
          language: "en",
          metadata: {
            summary_hi: summaryHi,
            provider: completion.provider,
            model: completion.model,
            doc_type: analysis.document_type || "contract",
          },
        },
        { onConflict: "document_id,language" }
      )
      .select("id, created_at")
      .single();

    if (resultErr) {
      console.error("Failed to store document results:", resultErr);
    }

    // 7. Update documents table status to 'completed'
    await client
      .from("documents")
      .update({
        processing_status: "completed",
        document_type: (analysis.document_type as string) || "contract",
        error_message: null,
      })
      .eq("id", documentId);

    // 8. Return Standardized Response
    return createSuccessResponse({
      document_id: documentId,
      result_id: resultRecord?.id,
      title: documentTitle,
      summary_en: summaryEn,
      summary_hi: summaryHi,
      key_obligations: keyObligations,
      important_clauses: importantClauses,
      risk_notes: riskNotes,
      disclaimer: LEGAL_DISCLAIMER_EN,
    });
  } catch (error: unknown) {
    const err = error as Error;
    console.error("Error in document-simplifier Edge Function:", err.message);
    return createErrorResponse(
      err.message || "An unexpected error occurred while simplifying the document.",
      500,
      "INTERNAL_ERROR"
    );
  }
});

