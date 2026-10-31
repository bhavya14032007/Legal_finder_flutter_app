// Supabase Authentication & Client helper for Edge Functions
import { createClient, SupabaseClient, User } from "https://esm.sh/@supabase/supabase-js@2.45.4";

export interface AuthenticatedContext {
  user: User;
  client: SupabaseClient;
  token: string;
}

export function getServiceRoleClient(): SupabaseClient {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !supabaseServiceKey) {
    throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables");
  }

  return createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
}

export function getUserClient(token: string): SupabaseClient {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error("Missing SUPABASE_URL or SUPABASE_ANON_KEY environment variables");
  }

  return createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
}

export async function authenticateRequest(req: Request): Promise<AuthenticatedContext> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new Error("Missing or invalid Authorization header");
  }

  const token = authHeader.replace("Bearer ", "").trim();
  if (!token) {
    throw new Error("Empty Bearer token provided");
  }

  const userClient = getUserClient(token);
  const { data: { user }, error } = await userClient.auth.getUser();

  if (error || !user) {
    throw new Error(`Authentication failed: ${error?.message || "Invalid or expired token"}`);
  }

  return {
    user,
    client: userClient,
    token,
  };
}

