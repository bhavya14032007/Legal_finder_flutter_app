// Edge Function: notice-reply
// Description: Analyzes incoming legal notices, identifies allegations/demands, asks for missing facts, and drafts structured replies

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { handleCors } from "../shared/cors.ts";
import { authenticateRequest } from "../shared/auth.ts";
import { createSuccessResponse, createErrorResponse } from "../shared/response.ts";
import { checkRateLimit } from "../shared/rate-limiter.ts";
import { isValidUUID, validateRequiredString, sanitizeText } from "../shared/validator.ts";
import { AIProviderService } from "../shared/ai-provider.ts";
import { NOTICE_REPLY_SYSTEM_PROMPT, LEGAL_DISCLAIMER_EN } from "../shared/legal-prompts.ts";

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return createErrorResponse("Method not allowed. Use POST.", 405, "METHOD_NOT_ALLOWED");
  }

  try {
    // 1. Authenticate Request
    const { user, client } = await authenticateRequest(req);

    // 2. Rate Limiting Check (15 requests/min per user)
    const rateCheck = checkRateLimit(`notice_reply_${user.id}`, { windowMs: 60000, maxRequests: 15 });
    if (!rateCheck.allowed) {
      return createErrorResponse(
        `Rate limit exceeded. Try again in ${Math.ceil(rateCheck.resetMs / 1000)} seconds.`,
        429,
        "RATE_LIMIT_EXCEEDED"
      );
    }

    // 3. Parse Request
    const body = await req.json().catch(() => ({}));
    let noticeText = "";
    const userFacts = body.user_facts ? sanitizeText(body.user_facts) : "";
    const strategy = body.strategy || "factual_clarification"; // deny_all | settlement_offer | factual_clarification | counter_claim
    const title = body.title ? sanitizeText(body.title) : "Reply to Legal Notice";

    if (body.document_id) {
      if (!isValidUUID(body.document_id)) {
        return createErrorResponse("Invalid document_id format.", 400, "INVALID_INPUT");
      }

      // Fetch document from database
      const { data: docRecord, error: docErr } = await client
        .from("documents")
        .select("*")
        .eq("id", body.document_id)
        .eq("user_id", user.id)
        .single();

      if (docErr || !docRecord) {
        return createErrorResponse("Referenced notice document not found or access denied.", 404, "DOCUMENT_NOT_FOUND");
      }

      // Fetch text or document result
      const { data: resRecord } = await client
        .from("document_results")
        .select("extracted_text, simplified_content")
        .eq("document_id", body.document_id)
        .single();

      if (resRecord?.extracted_text) {
        noticeText = resRecord.extracted_text;
      } else {
        // Download from storage
        const { data: fileBlob } = await client.storage
          .from(docRecord.bucket_id)
          .download(docRecord.storage_path);
        if (fileBlob) {
          noticeText = await fileBlob.text().catch(() => "");
        }
      }
    } else if (body.notice_text) {
      noticeText = sanitizeText(validateRequiredString(body.notice_text, "notice_text", 10, 50_000));
    } else {
      return createErrorResponse("Either 'notice_text' or 'document_id' must be provided.", 400, "INVALID_INPUT");
    }

    if (!noticeText) {
      return createErrorResponse("Could not retrieve text content from the notice.", 400, "EMPTY_NOTICE");
    }

    // 4. Send to AI Provider
    const promptMessage = `
INCOMING NOTICE TEXT:
${noticeText.slice(0, 20_000)}

CLIENT'S FACTUAL REBUTTAL & CONTEXT:
${userFacts || "No additional facts provided by user yet."}

DEFENSE STRATEGY PREFERRED:
${strategy}

Generate a JSON response containing:
{
  "allegations_identified": ["Allegation 1", "Allegation 2"],
  "sender_demands": ["Demand 1", "Demand 2"],
  "limitation_or_deadline": "E.g., 15 days from receipt",
  "missing_context_questions": [
    "Question 1 (information the user needs to confirm or documents to locate)",
    "Question 2"
  ],
  "defense_strategy_summary": "Recommended legal position to safeguard the client",
  "draft_reply_text": "Complete, formal, without-prejudice reply to the legal notice in standard Indian legal draft format. Use clear placeholders [LIKE THIS] for dates, postal registry numbers, and counsel signatures.",
  "disclaimer": "${LEGAL_DISCLAIMER_EN}"
}
`;

    const aiService = new AIProviderService();
    const completion = await aiService.generateCompletion({
      systemPrompt: NOTICE_REPLY_SYSTEM_PROMPT,
      messages: [{ role: "user", content: promptMessage }],
      temperature: 0.1,
      maxTokens: 3500,
      jsonMode: true,
    });

    let result: Record<string, unknown> = {};
    try {
      result = JSON.parse(completion.text);
    } catch (_err) {
      const cleanJson = completion.text.replace(/```json/g, "").replace(/```/g, "").trim();
      result = JSON.parse(cleanJson);
    }

    const draftReplyText = (result.draft_reply_text as string) || "Draft reply could not be generated.";

    // 5. Save generated reply in drafts table
    const { data: draftRecord, error: draftErr } = await client
      .from("drafts")
      .insert({
        user_id: user.id,
        title,
        draft_type: "notice_reply",
        input_data: {
          notice_snippet: noticeText.slice(0, 500),
          user_facts: userFacts,
          strategy,
        },
        generated_content: draftReplyText,
        status: "draft",
        metadata: {
          allegations: result.allegations_identified,
          demands: result.sender_demands,
          questions: result.missing_context_questions,
          provider: completion.provider,
          model: completion.model,
        },
      })
      .select("id, created_at")
      .single();

    if (draftErr) {
      console.error("Failed to save notice reply draft:", draftErr);
    }

    // 6. Return Structured Output
    return createSuccessResponse({
      draft_id: draftRecord?.id,
      title,
      allegations_identified: result.allegations_identified || [],
      sender_demands: result.sender_demands || [],
      limitation_or_deadline: result.limitation_or_deadline || "Not specified",
      missing_context_questions: result.missing_context_questions || [],
      defense_strategy_summary: result.defense_strategy_summary || "",
      draft_reply_text: draftReplyText,
      disclaimer: LEGAL_DISCLAIMER_EN,
    });
  } catch (error: unknown) {
    const err = error as Error;
    console.error("Error in notice-reply Edge Function:", err.message);
    return createErrorResponse(
      err.message || "An unexpected error occurred while analyzing the legal notice.",
      500,
      "INTERNAL_ERROR"
    );
  }
});

