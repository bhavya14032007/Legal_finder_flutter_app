// Edge Function: drafting-assistant
// Description: Generates, updates, and manages structured legal drafts, notices, complaints, and agreements

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { handleCors } from "../shared/cors.ts";
import { authenticateRequest } from "../shared/auth.ts";
import { createSuccessResponse, createErrorResponse } from "../shared/response.ts";
import { checkRateLimit } from "../shared/rate-limiter.ts";
import { isValidUUID, validateRequiredString, sanitizeText, validateEnum } from "../shared/validator.ts";
import { AIProviderService } from "../shared/ai-provider.ts";
import { DRAFTING_ASSISTANT_SYSTEM_PROMPT, LEGAL_DISCLAIMER_EN } from "../shared/legal-prompts.ts";

const ALLOWED_DRAFT_TYPES = [
  "legal_notice",
  "notice_reply",
  "complaint_consumer",
  "complaint_cyber",
  "complaint_police",
  "rti_application",
  "rent_agreement",
  "formal_application",
  "affidavit",
  "general_agreement",
  "other",
] as const;

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return createErrorResponse("Method not allowed. Use POST.", 405, "METHOD_NOT_ALLOWED");
  }

  try {
    // 1. Authenticate Request
    const { user, client } = await authenticateRequest(req);

    // 2. Parse Request
    const body = await req.json().catch(() => ({}));
    const action = body.action || "generate"; // generate | update | get | list

    // Handle 'list' action
    if (action === "list") {
      const { data: drafts, error: listErr } = await client
        .from("drafts")
        .select("id, title, draft_type, status, created_at, updated_at")
        .eq("user_id", user.id)
        .order("updated_at", { ascending: false });

      if (listErr) {
        return createErrorResponse(`Failed to fetch drafts: ${listErr.message}`, 500, "DB_ERROR");
      }
      return createSuccessResponse({ drafts });
    }

    // Handle 'get' action
    if (action === "get") {
      const draftId = body.draft_id;
      if (!draftId || !isValidUUID(draftId)) {
        return createErrorResponse("Valid 'draft_id' required for get action.", 400, "INVALID_INPUT");
      }

      const { data: draft, error: getErr } = await client
        .from("drafts")
        .select("*")
        .eq("id", draftId)
        .eq("user_id", user.id)
        .single();

      if (getErr || !draft) {
        return createErrorResponse("Draft not found or access denied.", 404, "DRAFT_NOT_FOUND");
      }
      return createSuccessResponse({ draft });
    }

    // Handle 'update' action (e.g. user edited text or changed status)
    if (action === "update") {
      const draftId = body.draft_id;
      if (!draftId || !isValidUUID(draftId)) {
        return createErrorResponse("Valid 'draft_id' required for update action.", 400, "INVALID_INPUT");
      }

      const updatePayload: Record<string, unknown> = {};
      if (body.generated_content) {
        updatePayload.generated_content = sanitizeText(body.generated_content);
      }
      if (body.title) {
        updatePayload.title = sanitizeText(body.title);
      }
      if (body.status) {
        updatePayload.status = validateEnum(body.status, "status", ["draft", "review_pending", "finalized", "archived"]);
      }

      const { data: updatedDraft, error: updateErr } = await client
        .from("drafts")
        .update(updatePayload)
        .eq("id", draftId)
        .eq("user_id", user.id)
        .select()
        .single();

      if (updateErr || !updatedDraft) {
        return createErrorResponse(`Failed to update draft: ${updateErr?.message}`, 500, "DB_ERROR");
      }
      return createSuccessResponse({ draft: updatedDraft });
    }

    // Default Action: 'generate'
    // Rate Limiting Check (20 generation requests/min)
    const rateCheck = checkRateLimit(`drafting_${user.id}`, { windowMs: 60000, maxRequests: 20 });
    if (!rateCheck.allowed) {
      return createErrorResponse(
        `Rate limit exceeded. Try again in ${Math.ceil(rateCheck.resetMs / 1000)} seconds.`,
        429,
        "RATE_LIMIT_EXCEEDED"
      );
    }

    const draftType = validateEnum(body.draft_type, "draft_type", ALLOWED_DRAFT_TYPES);
    const title = sanitizeText(validateRequiredString(body.title, "title", 3, 200));
    const inputData = body.input_data && typeof body.input_data === "object" ? body.input_data : {};

    // Build the AI prompt from user input parameters
    const promptMessage = `
Draft Type: ${draftType}
Title: ${title}

Provided User Data & Parameters:
${JSON.stringify(inputData, null, 2)}

Instructions:
1. Generate a complete, professionally formatted legal draft suitable for Indian legal requirements.
2. Include formal standard clauses: Date, Sender/Complainant details, Opposite Party details, Factual Background numbered paragraph-by-paragraph, Legal Violations/Grounds, Relief/Demands, and Verification.
3. Mark any missing details with clear square brackets [LIKE THIS].
4. Do NOT automatically send or submit. Append a prominent review warning for advocate verification.
`;

    const aiService = new AIProviderService();
    const completion = await aiService.generateCompletion({
      systemPrompt: DRAFTING_ASSISTANT_SYSTEM_PROMPT,
      messages: [{ role: "user", content: promptMessage }],
      temperature: 0.2,
      maxTokens: 3500,
      jsonMode: false,
    });

    const generatedContent = completion.text;

    // Save newly generated draft to database
    const { data: newDraftRecord, error: saveErr } = await client
      .from("drafts")
      .insert({
        user_id: user.id,
        title,
        draft_type: draftType,
        input_data: inputData,
        generated_content: generatedContent,
        status: "draft",
        metadata: {
          provider: completion.provider,
          model: completion.model,
          usage: completion.usage,
        },
      })
      .select("*")
      .single();

    if (saveErr || !newDraftRecord) {
      return createErrorResponse(`Failed to persist draft to database: ${saveErr?.message}`, 500, "DB_ERROR");
    }

    return createSuccessResponse({
      draft_id: newDraftRecord.id,
      title: newDraftRecord.title,
      draft_type: newDraftRecord.draft_type,
      generated_content: newDraftRecord.generated_content,
      status: newDraftRecord.status,
      disclaimer: LEGAL_DISCLAIMER_EN,
      created_at: newDraftRecord.created_at,
    });
  } catch (error: unknown) {
    const err = error as Error;
    console.error("Error in drafting-assistant Edge Function:", err.message);
    return createErrorResponse(
      err.message || "An unexpected error occurred while generating the legal draft.",
      500,
      "INTERNAL_ERROR"
    );
  }
});

