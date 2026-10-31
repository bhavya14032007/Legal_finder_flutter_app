// Edge Function: scam-detector
// Description: Multi-vector fraud detection for digital arrests, fake legal summons, phishing links, and KYC extortion

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { handleCors } from "../shared/cors.ts";
import { authenticateRequest } from "../shared/auth.ts";
import { createSuccessResponse, createErrorResponse } from "../shared/response.ts";
import { checkRateLimit } from "../shared/rate-limiter.ts";
import { validateRequiredString, sanitizeText } from "../shared/validator.ts";
import { AIProviderService } from "../shared/ai-provider.ts";
import { SCAM_DETECTOR_SYSTEM_PROMPT } from "../shared/legal-prompts.ts";

interface UrlHeuristicResult {
  url: string;
  is_suspicious_url: boolean;
  warnings: string[];
}

// Static, safe heuristic analysis of URL without visiting or executing it
function analyzeUrlSafely(rawUrl: string): UrlHeuristicResult {
  const warnings: string[] = [];
  let isSuspicious = false;

  try {
    let normalized = rawUrl.trim();
    if (!normalized.startsWith("http://") && !normalized.startsWith("https://")) {
      normalized = "https://" + normalized;
    }
    const parsed = new URL(normalized);
    const host = parsed.hostname.toLowerCase();

    // Check for raw IP addresses
    if (/^(\d{1,3}\.){3}\d{1,3}$/.test(host)) {
      warnings.push("URL uses a raw IP address instead of a legitimate registered domain name.");
      isSuspicious = true;
    }

    // Check for high-risk TLDs
    const highRiskTlds = [".xyz", ".top", ".tk", ".ml", ".ga", ".cf", ".work", ".click", ".buzz", ".fit", ".rest"];
    if (highRiskTlds.some((tld) => host.endsWith(tld))) {
      warnings.push(`URL uses a high-abuse top-level domain (${host.slice(host.lastIndexOf("."))}).`);
      isSuspicious = true;
    }

    // Check for brand/government typosquatting
    const deceptiveKeywords = [
      "kyc", "sbi", "hdfc", "icici", "rbi", "police", "court", "cbi", "tax-refund", "epfo", "digilocker", "parivahan"
    ];
    for (const kw of deceptiveKeywords) {
      if (host.includes(kw) && !host.endsWith(".gov.in") && !host.endsWith(".nic.in") && !host.endsWith(".bank.in") && !host.endsWith(".com")) {
        warnings.push(`Domain contains authority/banking keyword '${kw}' on an unofficial non-government or non-bank domain.`);
        isSuspicious = true;
      }
    }

    // Check for URL shorteners
    const shorteners = ["bit.ly", "tinyurl.com", "t.co", "goo.gl", "is.gd", "rb.gy", "cutt.ly"];
    if (shorteners.includes(host)) {
      warnings.push("URL uses a link shortener that masks the true destination website.");
      isSuspicious = true;
    }

    return {
      url: rawUrl,
      is_suspicious_url: isSuspicious,
      warnings,
    };
  } catch (_e) {
    return {
      url: rawUrl,
      is_suspicious_url: true,
      warnings: ["Malformed or invalid URL string format."],
    };
  }
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return createErrorResponse("Method not allowed. Use POST.", 405, "METHOD_NOT_ALLOWED");
  }

  try {
    // 1. Authenticate Request
    const { user } = await authenticateRequest(req);

    // 2. Rate Limiting Check (25 scam checks/min per user)
    const rateCheck = checkRateLimit(`scam_${user.id}`, { windowMs: 60000, maxRequests: 25 });
    if (!rateCheck.allowed) {
      return createErrorResponse(
        `Rate limit exceeded. Try again in ${Math.ceil(rateCheck.resetMs / 1000)} seconds.`,
        429,
        "RATE_LIMIT_EXCEEDED"
      );
    }

    // 3. Parse and Validate Request Body
    const body = await req.json().catch(() => ({}));
    const messageContent = body.content ? sanitizeText(validateRequiredString(body.content, "content", 3, 20_000)) : "";
    const suspiciousUrl = body.url ? sanitizeText(body.url) : "";
    const channel = body.source_channel || "message";

    if (!messageContent && !suspiciousUrl) {
      return createErrorResponse("Either 'content' (text) or 'url' must be provided for scam detection.", 400, "INVALID_INPUT");
    }

    // 4. Run Safe URL Heuristics (if URL provided)
    let urlAnalysis: UrlHeuristicResult | null = null;
    if (suspiciousUrl) {
      urlAnalysis = analyzeUrlSafely(suspiciousUrl);
    }

    // 5. Invoke AI Fraud Analysis
    const promptMessage = `
Analyze the following item for fraud, cyber extortion, or impersonation:
Channel: ${channel}

${messageContent ? `MESSAGE / DOCUMENT CONTENT:\n"${messageContent}"\n` : ""}
${suspiciousUrl ? `EXTRACTED URL:\n"${suspiciousUrl}"\n` : ""}
${urlAnalysis && urlAnalysis.warnings.length > 0 ? `STATIC URL WARNINGS:\n- ${urlAnalysis.warnings.join("\n- ")}\n` : ""}

Evaluate under Indian cybercrime patterns (Digital Arrest, fake CBI/Police video call threats, fake court summons, electricity bill SMS, APK downloads, investment frauds).
Provide risk score (0-100), risk level (LOW/MEDIUM/HIGH/CRITICAL), indicators, and urgent protective actions.
`;

    const aiService = new AIProviderService();
    const completion = await aiService.generateCompletion({
      systemPrompt: SCAM_DETECTOR_SYSTEM_PROMPT,
      messages: [{ role: "user", content: promptMessage }],
      temperature: 0.1,
      maxTokens: 2000,
      jsonMode: true,
    });

    let result: Record<string, unknown> = {};
    try {
      result = JSON.parse(completion.text);
    } catch (_e) {
      const cleanJson = completion.text.replace(/```json/g, "").replace(/```/g, "").trim();
      result = JSON.parse(cleanJson);
    }

    const indicators = Array.isArray(result.suspicious_indicators) ? result.suspicious_indicators : [];
    if (urlAnalysis && urlAnalysis.warnings.length > 0) {
      for (const w of urlAnalysis.warnings) {
        if (!indicators.includes(w)) {
          indicators.push(`URL Warning: ${w}`);
        }
      }
    }

    const recommendedActions = Array.isArray(result.recommended_actions)
      ? result.recommended_actions
      : [
          "Do not send money, OTP, or UPI PIN under any circumstances.",
          "If money was lost, immediately dial 1930 (National Cyber Crime Reporting Helpline) to freeze fraudulent transactions.",
          "File a formal grievance at https://cybercrime.gov.in.",
        ];

    // Ensure 1930 helpline is always highlighted if risk is high/critical
    const riskLevel = (result.risk_level as string) || "MEDIUM";
    if (["HIGH", "CRITICAL"].includes(riskLevel.toUpperCase())) {
      if (!recommendedActions.some((a) => String(a).includes("1930"))) {
        recommendedActions.unshift("IMMEDIATE ACTION: Dial 1930 (Citizen Financial Cyber Fraud Reporting System) or visit https://cybercrime.gov.in");
      }
    }

    // 6. Return Structured Response
    return createSuccessResponse({
      risk_score: result.risk_score ?? 50,
      risk_level: riskLevel,
      scam_type: result.scam_type || "Unknown / Suspicious Inquiry",
      is_scam_likely: result.is_scam_likely ?? (riskLevel === "HIGH" || riskLevel === "CRITICAL"),
      suspicious_indicators: indicators,
      detailed_analysis: result.detailed_analysis || "Analysis complete.",
      recommended_actions: recommendedActions,
      url_heuristics: urlAnalysis,
      emergency_helplines: {
        cyber_crime: "1930",
        cyber_portal: "https://cybercrime.gov.in",
        national_consumer_helpline: "1915",
      },
      disclaimer: "This automated risk assessment is based on identifiable threat indicators. Absence of warnings does not guarantee safety. Do not execute untrusted files or share credentials.",
    });
  } catch (error: unknown) {
    const err = error as Error;
    console.error("Error in scam-detector Edge Function:", err.message);
    return createErrorResponse(
      err.message || "An unexpected error occurred while analyzing the scam indicator.",
      500,
      "INTERNAL_ERROR"
    );
  }
});

