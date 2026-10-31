// Edge Function: legal-advisor
// Description: Multi-turn Legal AI Advisor with context persistence, language support, and anti-hallucination guardrails

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { handleCors, corsHeaders } from "../shared/cors.ts";
import { authenticateRequest } from "../shared/auth.ts";
import { createSuccessResponse, createErrorResponse } from "../shared/response.ts";
import { checkRateLimit } from "../shared/rate-limiter.ts";
import { isValidUUID, validateRequiredString, sanitizeText } from "../shared/validator.ts";
import { AIProviderService, ChatMessage } from "../shared/ai-provider.ts";
import {
  LEGAL_ADVISOR_SYSTEM_PROMPT,
  LEGAL_DISCLAIMER_EN,
  LEGAL_DISCLAIMER_HI,
} from "../shared/legal-prompts.ts";

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return createErrorResponse("Method not allowed. Use POST.", 405, "METHOD_NOT_ALLOWED");
  }

  try {
    // 1. Authenticate Request
    const { user, client } = await authenticateRequest(req);

    // 2. Rate Limiting Check (30 requests/min per user)
    const rateCheck = checkRateLimit(user.id, { windowMs: 60000, maxRequests: 30 });
    if (!rateCheck.allowed) {
      return createErrorResponse(
        `Rate limit exceeded. Try again in ${Math.ceil(rateCheck.resetMs / 1000)} seconds.`,
        429,
        "RATE_LIMIT_EXCEEDED"
      );
    }

    // 3. Parse and Validate Request Body
    const body = await req.json().catch(() => ({}));
    const message = sanitizeText(validateRequiredString(body.message, "message", 2, 8000));
    const language = body.language === "hi" ? "hi" : "en";
    let sessionId = body.session_id;

    if (sessionId && !isValidUUID(sessionId)) {
      return createErrorResponse("Invalid session_id format. Must be a valid UUID.", 400, "INVALID_INPUT");
    }

    // 4. Session Management
    if (sessionId) {
      // Validate session ownership
      const { data: session, error: sessionErr } = await client
        .from("chat_sessions")
        .select("id, user_id, title")
        .eq("id", sessionId)
        .eq("user_id", user.id)
        .single();

      if (sessionErr || !session) {
        return createErrorResponse("Chat session not found or access denied.", 404, "SESSION_NOT_FOUND");
      }
    } else {
      // Auto-create new session with title derived from user question
      const sessionTitle = message.slice(0, 60).replace(/\n/g, " ") + (message.length > 60 ? "..." : "");
      const { data: newSession, error: createErr } = await client
        .from("chat_sessions")
        .insert({
          user_id: user.id,
          title: sessionTitle,
          language,
        })
        .select("id")
        .single();

      if (createErr || !newSession) {
        return createErrorResponse(`Failed to create chat session: ${createErr?.message}`, 500, "DB_ERROR");
      }
      sessionId = newSession.id;
    }

    // 5. Store User Message
    const { data: userMsgRecord, error: userMsgErr } = await client
      .from("chat_messages")
      .insert({
        session_id: sessionId,
        user_id: user.id,
        role: "user",
        content: message,
        metadata: { language },
      })
      .select("id, created_at")
      .single();

    if (userMsgErr || !userMsgRecord) {
      return createErrorResponse(`Failed to store message: ${userMsgErr?.message}`, 500, "DB_ERROR");
    }

    // 6. Fetch Conversation History (last 8 messages for context window)
    const { data: historyRecords } = await client
      .from("chat_messages")
      .select("role, content")
      .eq("session_id", sessionId)
      .order("created_at", { ascending: true })
      .limit(8);

    const contextMessages: ChatMessage[] = (historyRecords || []).map((msg) => ({
      role: msg.role as "user" | "assistant" | "system",
      content: msg.content,
    }));

    // If context doesn't have the latest message, add it
    if (contextMessages.length === 0 || contextMessages[contextMessages.length - 1].content !== message) {
      contextMessages.push({ role: "user", content: message });
    }

    // 7. Invoke AI Provider
    const aiService = new AIProviderService();
    const systemPrompt = `${LEGAL_ADVISOR_SYSTEM_PROMPT}\nTarget Output Language: ${
      language === "hi" ? "Hindi (हिंदी)" : "English"
    }`;

    const completion = await aiService.generateCompletion({
      systemPrompt,
      messages: contextMessages,
      temperature: 0.2,
      maxTokens: 2500,
      jsonMode: false,
    });

    const disclaimer = language === "hi" ? LEGAL_DISCLAIMER_HI : LEGAL_DISCLAIMER_EN;
    const finalAnswer = completion.text;

    // 8. Store Assistant Response in Database
    const { data: assistantMsgRecord, error: assistantMsgErr } = await client
      .from("chat_messages")
      .insert({
        session_id: sessionId,
        user_id: user.id,
        role: "assistant",
        content: finalAnswer,
        metadata: {
          provider: completion.provider,
          model: completion.model,
          language,
          disclaimer,
          usage: completion.usage,
        },
      })
      .select("id, created_at")
      .single();

    if (assistantMsgErr) {
      console.error("Failed to save assistant response:", assistantMsgErr);
    }

    // 9. Return Structured Response
    return createSuccessResponse({
      session_id: sessionId,
      user_message_id: userMsgRecord.id,
      assistant_message_id: assistantMsgRecord?.id,
      response: finalAnswer,
      disclaimer,
      language,
      provider: completion.provider,
      model: completion.model,
    });
  } catch (error: unknown) {
    const err = error as Error;
    console.error("Error in legal-advisor Edge Function:", err.message);
    return createErrorResponse(
      err.message || "An unexpected error occurred while processing your legal consultation.",
      500,
      "INTERNAL_ERROR"
    );
  }
});

