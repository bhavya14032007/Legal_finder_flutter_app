// Standardized Response utilities for Legal Helper Edge Functions
import { corsHeaders } from "./cors.ts";

export interface StandardSuccessResponse<T> {
  success: true;
  data: T;
  error: null;
}

export interface StandardErrorPayload {
  code: string;
  message: string;
  details?: unknown;
}

export interface StandardErrorResponse {
  success: false;
  data: null;
  error: StandardErrorPayload;
}

export function createSuccessResponse<T>(data: T, status = 200): Response {
  const body: StandardSuccessResponse<T> = {
    success: true,
    data,
    error: null,
  };

  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

export function createErrorResponse(
  message: string,
  status = 400,
  code = "BAD_REQUEST",
  details: unknown = null
): Response {
  const body: StandardErrorResponse = {
    success: false,
    data: null,
    error: {
      code,
      message,
      ...(details !== null && details !== undefined ? { details } : {}),
    },
  };

  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

