import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const authorization = req.headers.get("Authorization");

  if (!authorization?.startsWith("Bearer ")) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    console.error("Required environment configuration is missing");
    return jsonResponse({ error: "Server configuration error" }, 500);
  }

  const token = authorization.substring("Bearer ".length);

  const supabaseAuth = createClient(supabaseUrl, anonKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  // Verify the actual access token with Supabase Auth.
  const {
    data: { user },
    error: authError,
  } = await supabaseAuth.auth.getUser(token);

  if (authError || !user) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  const supabaseAdmin = createClient(
    supabaseUrl,
    serviceRoleKey,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    },
  );

  try {
    // Anonymize personal data and remove the profile/device tokens.
    const { error: anonymizeError } = await supabaseAdmin.rpc(
      "anonymize_user_data",
      { target_user_id: user.id },
    );

    if (anonymizeError) {
      console.error("Account anonymization failed");
      return jsonResponse(
        { error: "Account deletion could not be completed" },
        500,
      );
    }

    // Delete only the authenticated caller's account.
    const { error: deleteError } =
      await supabaseAdmin.auth.admin.deleteUser(user.id);

    if (deleteError) {
      console.error("Auth account deletion failed");
      return jsonResponse(
        { error: "Account deletion could not be completed" },
        500,
      );
    }

    return jsonResponse({ success: true });
  } catch {
    console.error("Unexpected account deletion failure");
    return jsonResponse(
      { error: "Account deletion could not be completed" },
      500,
    );
  }
});