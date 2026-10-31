// Edge Function: lawyer-prep
// Description: Prepares structured lawyer consultation dossiers, chronological evidence timelines, and verified legal aid queries

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { handleCors } from "../shared/cors.ts";
import { authenticateRequest } from "../shared/auth.ts";
import { createSuccessResponse, createErrorResponse } from "../shared/response.ts";
import { checkRateLimit } from "../shared/rate-limiter.ts";
import { validateRequiredString, sanitizeText } from "../shared/validator.ts";
import { AIProviderService } from "../shared/ai-provider.ts";
import { LEGAL_DISCLAIMER_EN } from "../shared/legal-prompts.ts";

const LAWYER_PREP_PROMPT = `
You are an expert Legal Case Preparation Assistant.
Your task is to organize an aggrieved individual's facts and evidence into a structured, highly professional case briefing dossier for their meeting with an Advocate/Lawyer.

FORMAT YOUR RESPONSE AS A VALID JSON OBJECT:
{
  "executive_summary": "Concise summary of the dispute/grievance, parties, and central legal injury",
  "timeline_events": [
    {
      "date": "Date or timeframe",
      "event": "Clear factual incident",
      "supporting_evidence": "Title or description of relevant receipt, email, or document"
    }
  ],
  "questions_for_lawyer": [
    "Targeted question 1 (e.g. regarding limitation period, civil vs criminal recourse)",
    "Targeted question 2 (e.g. interim relief or injunction prospects)",
    "Targeted question 3 (e.g. estimated court fee and duration)"
  ],
  "document_checklist": [
    {
      "item": "Document name (e.g. Original Agreement / Bank Statement / Demand Notice)",
      "importance": "Mandatory | Recommended | Optional",
      "purpose": "Why the advocate will need this document"
    }
  ],
  "potential_relief_sought": [
    "Specific remedy (e.g., Refund of principal amount with 18% interest, Compensation for harassment)"
  ]
}
`;

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
    const action = body.action || "generate_dossier"; // generate_dossier | get_timeline | get_legal_aid | list_preparations

    // Action: Get Chronological Timeline from Evidence Items
    if (action === "get_timeline") {
      const { data: timelineItems, error: timelineErr } = await client
        .from("evidence_items")
        .select("id, title, description, evidence_type, storage_path, file_hash, event_date, tags, created_at")
        .eq("user_id", user.id)
        .order("event_date", { ascending: true });

      if (timelineErr) {
        return createErrorResponse(`Failed to fetch timeline: ${timelineErr.message}`, 500, "DB_ERROR");
      }

      return createSuccessResponse({
        timeline: timelineItems || [],
        total_items: timelineItems?.length || 0,
      });
    }

    // Action: Query Verified Statutory Legal Aid Directory
    if (action === "get_legal_aid") {
      const state = body.state ? sanitizeText(body.state) : null;
      const district = body.district ? sanitizeText(body.district) : null;

      let query = client
        .from("legal_aid_directory")
        .select("*")
        .eq("is_active", true);

      if (state && state.toLowerCase() !== "all india") {
        query = query.or(`jurisdiction_state.ilike.%${state}%,jurisdiction_state.eq.All India`);
      }

      if (district) {
        query = query.or(`district.ilike.%${district}%,district.is.null`);
      }

      const { data: legalAidResources, error: aidErr } = await query.order("authority_level", { ascending: true });

      if (aidErr) {
        return createErrorResponse(`Failed to fetch legal aid directory: ${aidErr.message}`, 500, "DB_ERROR");
      }

      return createSuccessResponse({
        legal_aid_authorities: legalAidResources || [],
        statutory_basis: "Section 12 of the Legal Services Authorities Act, 1987",
        national_helplines: [
          { service: "NALSA Free Legal Aid Helpline", number: "15100" },
          { service: "Tele-Law Portal Assistance", number: "14430" },
          { service: "National Consumer Helpline", number: "1915" },
          { service: "National Cyber Fraud Helpline", number: "1930" },
        ],
      });
    }

    // Action: List User's Saved Dossiers
    if (action === "list_preparations") {
      const { data: preps, error: listErr } = await client
        .from("case_preparations")
        .select("id, title, case_type, created_at, updated_at")
        .eq("user_id", user.id)
        .order("updated_at", { ascending: false });

      if (listErr) {
        return createErrorResponse(`Failed to list case preparations: ${listErr.message}`, 500, "DB_ERROR");
      }
      return createSuccessResponse({ case_preparations: preps || [] });
    }

    // Default Action: Generate Case Consultation Dossier
    const rateCheck = checkRateLimit(`prep_${user.id}`, { windowMs: 60000, maxRequests: 20 });
    if (!rateCheck.allowed) {
      return createErrorResponse(
        `Rate limit exceeded. Try again in ${Math.ceil(rateCheck.resetMs / 1000)} seconds.`,
        429,
        "RATE_LIMIT_EXCEEDED"
      );
    }

    const title = sanitizeText(validateRequiredString(body.title, "title", 3, 200));
    const caseType = sanitizeText(validateRequiredString(body.case_type, "case_type", 2, 100));
    const factsSummary = sanitizeText(validateRequiredString(body.facts_summary, "facts_summary", 10, 20_000));
    const userNotes = body.notes ? sanitizeText(body.notes) : "";

    // Fetch user's registered evidence items if requested to auto-link timeline
    let evidenceContext = "";
    if (body.include_evidence_timeline) {
      const { data: evidenceList } = await client
        .from("evidence_items")
        .select("title, description, event_date, evidence_type")
        .eq("user_id", user.id)
        .order("event_date", { ascending: true })
        .limit(20);

      if (evidenceList && evidenceList.length > 0) {
        evidenceContext = "\nATTACHED EVIDENCE ITEMS:\n" + evidenceList.map((e) => `- [${e.event_date}] ${e.title} (${e.evidence_type}): ${e.description || ""}`).join("\n");
      }
    }

    const promptMessage = `
Case Title: ${title}
Case Type: ${caseType}
Client Facts & Narrative:
${factsSummary}
${evidenceContext}
${userNotes ? `Client Notes: ${userNotes}` : ""}
`;

    const aiService = new AIProviderService();
    const completion = await aiService.generateCompletion({
      systemPrompt: LAWYER_PREP_PROMPT,
      messages: [{ role: "user", content: promptMessage }],
      temperature: 0.1,
      maxTokens: 3000,
      jsonMode: true,
    });

    let result: Record<string, unknown> = {};
    try {
      result = JSON.parse(completion.text);
    } catch (_e) {
      const cleanJson = completion.text.replace(/```json/g, "").replace(/```/g, "").trim();
      result = JSON.parse(cleanJson);
    }

    const execSummary = (result.executive_summary as string) || factsSummary;
    const timeline = Array.isArray(result.timeline_events) ? result.timeline_events : [];
    const questions = Array.isArray(result.questions_for_lawyer) ? result.questions_for_lawyer : [];
    const checklist = Array.isArray(result.document_checklist) ? result.document_checklist : [];

    // Save to case_preparations table
    const { data: prepRecord, error: prepErr } = await client
      .from("case_preparations")
      .insert({
        user_id: user.id,
        title,
        case_type: caseType,
        facts_summary: execSummary,
        timeline_events: timeline,
        questions_for_lawyer: questions,
        checklist,
        notes: userNotes,
        metadata: {
          potential_relief: result.potential_relief_sought,
          provider: completion.provider,
          model: completion.model,
        },
      })
      .select("*")
      .single();

    if (prepErr || !prepRecord) {
      return createErrorResponse(`Failed to persist case preparation dossier: ${prepErr?.message}`, 500, "DB_ERROR");
    }

    return createSuccessResponse({
      preparation_id: prepRecord.id,
      title: prepRecord.title,
      case_type: prepRecord.case_type,
      executive_summary: execSummary,
      timeline_events: timeline,
      questions_for_lawyer: questions,
      checklist,
      potential_relief_sought: result.potential_relief_sought || [],
      disclaimer: LEGAL_DISCLAIMER_EN,
      created_at: prepRecord.created_at,
    });
  } catch (error: unknown) {
    const err = error as Error;
    console.error("Error in lawyer-prep Edge Function:", err.message);
    return createErrorResponse(
      err.message || "An unexpected error occurred while preparing case dossier.",
      500,
      "INTERNAL_ERROR"
    );
  }
});

