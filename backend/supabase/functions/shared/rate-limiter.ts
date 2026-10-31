// Simple in-memory sliding window rate limiter for Edge Functions
interface RateLimitEntry {
  timestamps: number[];
}

const rateLimitMap = new Map<string, RateLimitEntry>();
const CLEANUP_INTERVAL_MS = 60_000;

// Periodic cleanup of expired rate limit entries
setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of rateLimitMap.entries()) {
    entry.timestamps = entry.timestamps.filter((ts) => now - ts < 60_000);
    if (entry.timestamps.length === 0) {
      rateLimitMap.delete(key);
    }
  }
}, CLEANUP_INTERVAL_MS);

export interface RateLimitOptions {
  windowMs?: number;
  maxRequests?: number;
}

export function checkRateLimit(
  identifier: string,
  options: RateLimitOptions = {}
): { allowed: boolean; remaining: number; resetMs: number } {
  const windowMs = options.windowMs || 60_000; // default 1 minute
  const maxRequests = options.maxRequests || 30; // default 30 requests per minute
  const now = Date.now();

  let entry = rateLimitMap.get(identifier);
  if (!entry) {
    entry = { timestamps: [] };
    rateLimitMap.set(identifier, entry);
  }

  // Filter timestamps within current window
  entry.timestamps = entry.timestamps.filter((ts) => now - ts < windowMs);

  if (entry.timestamps.length >= maxRequests) {
    const oldestTimestamp = entry.timestamps[0];
    const resetMs = Math.max(0, windowMs - (now - oldestTimestamp));
    return {
      allowed: false,
      remaining: 0,
      resetMs,
    };
  }

  entry.timestamps.push(now);
  return {
    allowed: true,
    remaining: maxRequests - entry.timestamps.length,
    resetMs: windowMs,
  };
}

