// Input validation and sanitization helpers for Legal Helper Edge Functions

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function isValidUUID(id: unknown): boolean {
  return typeof id === "string" && UUID_REGEX.test(id);
}

export function validateRequiredString(
  value: unknown,
  fieldName: string,
  minLength = 1,
  maxLength = 100_000
): string {
  if (typeof value !== "string") {
    throw new Error(`Field '${fieldName}' must be a string`);
  }
  const trimmed = value.trim();
  if (trimmed.length < minLength) {
    throw new Error(`Field '${fieldName}' must have at least ${minLength} characters`);
  }
  if (trimmed.length > maxLength) {
    throw new Error(`Field '${fieldName}' exceeds maximum allowed length of ${maxLength} characters`);
  }
  return trimmed;
}

export function validateEnum<T extends string>(
  value: unknown,
  fieldName: string,
  allowedValues: readonly T[]
): T {
  if (typeof value !== "string" || !allowedValues.includes(value as T)) {
    throw new Error(
      `Field '${fieldName}' has invalid value. Allowed: ${allowedValues.join(", ")}`
    );
  }
  return value as T;
}

export function sanitizeText(text: string): string {
  if (!text) return "";
  // Strip null bytes and normalize line endings
  return text.replace(/\0/g, "").replace(/\r\n/g, "\n").trim();
}

