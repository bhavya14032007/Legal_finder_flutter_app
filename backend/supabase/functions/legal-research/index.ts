// Edge Function: legal-research
// Description: Structured legal research engine with statutory citations, verified official portals, and research audit history

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { handleCors } from "../shared/cors.ts";
import { authenticateRequest } from "../shared/auth.ts";
import { createSuccessResponse, createErrorResponse } from "../shared/response.ts";
import { checkRateLimit } from "../shared/rate-limiter.ts";
import { validateRequiredString, sanitizeText } from "../shared/validator.ts";
import { AIProviderService } from "../shared/ai-provider.ts";
import { LEGAL_RESEARCH_SYSTEM_PROMPT, LEGAL_DISCLAIMER_EN } from "../shared/legal-prompts.ts";

// Curated verified legal authorities and government portals
const VERIFIED_OFFICIAL_PORTALS: Record<string, { title: string; url: string; description: string }> = {
  indiacode: {
    title: "India Code - Digital Repository of All Central and State Acts",
    url: "https://www.indiacode.nic.in",
    description: "Official legislative portal published by Ministry of Law and Justice, Government of India.",
  },
  sci: {
    title: "Supreme Court of India Official Portal",
    url: "https://main.sci.gov.in",
    description: "Judgments, orders, and daily cause lists of the Supreme Court of India.",
  },
  edaakhil: {
    title: "e-Daakhil Portal - Consumer Grievance Redressal",
    url: "https://edaakhil.nic.in",
    description: "National Consumer Disputes Redressal Commission official e-filing portal.",
  },
  cybercrime: {
    title: "National Cyber Crime Reporting Portal",
    url: "https://cybercrime.gov.in",
    description: "Ministry of Home Affairs portal for financial cyber fraud (Helpline 1930) and cyber crimes.",
  },
  nalsa: {
    title: "National Legal Services Authority (NALSA)",
    url: "https://nalsa.gov.in",
    description: "Statutory authority providing free legal services under Legal Services Authorities Act, 1987.",
  },
};

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return createErrorResponse("Method not allowed. Use POST.", 405, "METHOD_NOT_ALLOWED");
  }

  try {
    // 1. Authenticate Request
    const { user, client } = await authenticateRequest(req);

    // 2. Rate Limiting Check (20 requests/min per user for research)
    const rateCheck = checkRateLimit(`research_${user.id}`, { windowMs: 60000, maxRequests: 20 });
    if (!rateCheck.allowed) {
      return createErrorResponse(
        `Rate limit exceeded. Try again in ${Math.ceil(rateCheck.resetMs / 1000)} seconds.`,
        429,
        "RATE_LIMIT_EXCEEDED"
      );
    }

    // 3. Parse and Validate Request Body
    const body = await req.json().catch(() => ({}));
    const query = sanitizeText(validateRequiredString(body.query, "query", 3, 2000));
    const jurisdiction = body.jurisdiction ? sanitizeText(body.jurisdiction) : "IN";

    // 4. Execute AI Research Query
    const aiService = new AIProviderService();
    const promptMessage = `Legal Research Query: "${query}"\nTarget Jurisdiction: ${jurisdiction}\nProvide authentic statutory provisions, landmark judgments, procedural recourse, and verified government sources.`;

    const completion = await aiService.generateCompletion({
      systemPrompt: LEGAL_RESEARCH_SYSTEM_PROMPT,
      messages: [{ role: "user", content: promptMessage }],
      temperature: 0.1, // Low temperature to maximize factual accuracy
      maxTokens: 2500,
      jsonMode: true,
    });

    let parsedResult: Record<string, unknown> = {};
    try {
      parsedResult = JSON.parse(completion.text);
    } catch (_parseErr) {
      // In case the model returns markdown JSON backticks
      const cleanJson = completion.text.replace(/```json/g, "").replace(/```/g, "").trim();
      parsedResult = JSON.parse(cleanJson);
    }

    // Append relevant verified government portals
    const sources = Array.isArray(parsedResult.official_sources) ? parsedResult.official_sources : [];
    if (sources.length === 0) {
      sources.push(VERIFIED_OFFICIAL_PORTALS.indiacode);
    }

    const summary = typeof parsedResult.summary === "string" ? parsedResult.summary : "Legal research completed.";
    const provisions = Array.isArray(parsedResult.statutory_provisions) ? parsedResult.statutory_provisions : [];
    const precedents = Array.isArray(parsedResult.landmark_precedents) ? parsedResult.landmark_precedents : [];
    const remedies = Array.isArray(parsedResult.procedural_remedies) ? parsedResult.procedural_remedies : [];

    // 5. Store in research_history Table
    const { data: historyRecord, error: historyErr } = await client
      .from("research_history")
      .insert({
        user_id: user.id,
        query,
        jurisdiction,
        summary,
        results: {
          statutory_provisions: provisions,
          landmark_precedents: precedents,
          procedural_remedies: remedies,
        },
        sources,
        metadata: {
          provider: completion.provider,
          model: completion.model,
          usage: completion.usage,
        },
      })
      .select("id, created_at")
      .single();

    if (historyErr) {
      console.error("Failed to store research history:", historyErr);
    }

    // 6. Return Structured Legal Research Result
    return createSuccessResponse({
      research_id: historyRecord?.id,
      query,
      jurisdiction,
      summary,
      statutory_provisions: provisions,
      landmark_precedents: precedents,
      procedural_remedies: remedies,
      official_sources: sources,
      disclaimer: LEGAL_DISCLAIMER_EN,
      created_at: historyRecord?.created_at || new Date().toISOString(),
    });
  } catch (error: unknown) {
    const err = error as Error;
    console.error("Error in legal-research Edge Function:", err.message);
    return createErrorResponse(
      err.message || "An unexpected error occurred while executing legal research.",
      500,
      "INTERNAL_ERROR"
    );
  }
});

