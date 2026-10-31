// Deno Unit Test Suite for Legal Helper Edge Function Components
// Run with: deno test tests/deno/edge_functions_test.ts

import { assertEquals, assertNotEquals } from "https://deno.land/std@0.177.0/testing/asserts.ts";
import { isValidUUID, validateRequiredString, validateEnum, sanitizeText } from "../../supabase/functions/shared/validator.ts";
import { checkRateLimit } from "../../supabase/functions/shared/rate-limiter.ts";
import { handleCors, corsHeaders } from "../../supabase/functions/shared/cors.ts";
import { createSuccessResponse, createErrorResponse } from "../../supabase/functions/shared/response.ts";

// -------------------------------------------------------------
// 1. Input Validation Tests
// -------------------------------------------------------------
Deno.test("Validation - Validates RFC-4122 UUID correctly", () => {
  const validUUID = "123e4567-e89b-12d3-a456-426614174000";
  const invalidUUID = "not-a-valid-uuid";

  assertEquals(isValidUUID(validUUID), true);
  assertEquals(isValidUUID(invalidUUID), false);
  assertEquals(isValidUUID(null), false);
  assertEquals(isValidUUID(12345), false);
});

Deno.test("Validation - Enforces string length boundaries", () => {
  const text = "  Legal notice summary  ";
  const validated = validateRequiredString(text, "test_field", 5, 50);
  assertEquals(validated, "Legal notice summary");

  let threw = false;
  try {
    validateRequiredString("hi", "test_field", 5, 50);
  } catch (_e) {
    threw = true;
  }
  assertEquals(threw, true);
});

Deno.test("Validation - Enforces enum values strictly", () => {
  const allowed = ["contract", "notice", "petition"] as const;
  const val = validateEnum("notice", "type", allowed);
  assertEquals(val, "notice");

  let threw = false;
  try {
    validateEnum("hacked_type", "type", allowed);
  } catch (_e) {
    threw = true;
  }
  assertEquals(threw, true);
});

Deno.test("Validation - Sanitizes null bytes and Windows line endings", () => {
  const malicious = "Dangerous\0Text\r\nWith\r\nNewlines";
  const sanitized = sanitizeText(malicious);
  assertEquals(sanitized.includes("\0"), false);
  assertEquals(sanitized.includes("\r\n"), false);
  assertEquals(sanitized.includes("\n"), true);
});

// -------------------------------------------------------------
// 2. CORS Handling Tests
// -------------------------------------------------------------
Deno.test("CORS - Responds to OPTIONS preflight correctly", () => {
  const optionsReq = new Request("http://localhost:54321/functions/v1/legal-advisor", {
    method: "OPTIONS",
  });
  const res = handleCors(optionsReq);
  assertNotEquals(res, null);
  assertEquals(res?.status, 200);
  assertEquals(res?.headers.get("Access-Control-Allow-Origin"), "*");
});

Deno.test("CORS - Passes through regular POST requests", () => {
  const postReq = new Request("http://localhost:54321/functions/v1/legal-advisor", {
    method: "POST",
  });
  const res = handleCors(postReq);
  assertEquals(res, null);
});

// -------------------------------------------------------------
// 3. Rate Limiter Tests
// -------------------------------------------------------------
Deno.test("RateLimiter - Allows requests within quota and throttles excessive calls", () => {
  const testId = "test_user_rate_limit_" + Date.now();
  const maxReq = 3;

  for (let i = 0; i < maxReq; i++) {
    const check = checkRateLimit(testId, { maxRequests: maxReq, windowMs: 1000 });
    assertEquals(check.allowed, true);
  }

  // 4th request must be blocked
  const blockedCheck = checkRateLimit(testId, { maxRequests: maxReq, windowMs: 1000 });
  assertEquals(blockedCheck.allowed, false);
  assertEquals(blockedCheck.remaining, 0);
});

// -------------------------------------------------------------
// 4. Standard Response Wrapper Tests
// -------------------------------------------------------------
Deno.test("Response - Creates uniform success response", async () => {
  const payload = { result: "Success Data" };
  const res = createSuccessResponse(payload, 200);

  assertEquals(res.status, 200);
  const json = await res.json();
  assertEquals(json.success, true);
  assertEquals(json.data.result, "Success Data");
  assertEquals(json.error, null);
});

Deno.test("Response - Creates uniform structured error response", async () => {
  const res = createErrorResponse("Unauthorized access attempt", 401, "UNAUTHORIZED");

  assertEquals(res.status, 401);
  const json = await res.json();
  assertEquals(json.success, false);
  assertEquals(json.data, null);
  assertEquals(json.error.code, "UNAUTHORIZED");
  assertEquals(json.error.message, "Unauthorized access attempt");
});

