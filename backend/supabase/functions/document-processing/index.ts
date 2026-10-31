// Edge Function: document-processing
// Description: Secure document registration, SHA-256 cryptographic hashing, MIME validation, and signed URL generation

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { handleCors } from "../shared/cors.ts";
import { authenticateRequest } from "../shared/auth.ts";
import { createSuccessResponse, createErrorResponse } from "../shared/response.ts";
import { isValidUUID, validateRequiredString, sanitizeText } from "../shared/validator.ts";

// Cryptographic SHA-256 hash calculation using Web Crypto API
async function calculateSha256(data: ArrayBuffer): Promise<string> {
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

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
    const action = body.action || "register"; // "register" | "get_signed_url" | "verify_hash"

    // Action: Generate Secure Signed Download URL
    if (action === "get_signed_url") {
      const documentId = body.document_id;
      const evidenceId = body.evidence_id;
      const expiresIn = typeof body.expires_in === "number" ? Math.min(body.expires_in, 3600) : 900; // default 15 min

      let bucket = "legal-documents";
      let storagePath = "";
      let filename = "document";

      if (documentId) {
        if (!isValidUUID(documentId)) {
          return createErrorResponse("Invalid document_id.", 400, "INVALID_INPUT");
        }
        const { data: doc, error: docErr } = await client
          .from("documents")
          .select("bucket_id, storage_path, original_filename")
          .eq("id", documentId)
          .eq("user_id", user.id)
          .single();

        if (docErr || !doc) {
          return createErrorResponse("Document not found or access denied.", 404, "NOT_FOUND");
        }
        bucket = doc.bucket_id;
        storagePath = doc.storage_path;
        filename = doc.original_filename;
      } else if (evidenceId) {
        if (!isValidUUID(evidenceId)) {
          return createErrorResponse("Invalid evidence_id.", 400, "INVALID_INPUT");
        }
        const { data: ev, error: evErr } = await client
          .from("evidence_items")
          .select("bucket_id, storage_path, title")
          .eq("id", evidenceId)
          .eq("user_id", user.id)
          .single();

        if (evErr || !ev) {
          return createErrorResponse("Evidence item not found or access denied.", 404, "NOT_FOUND");
        }
        bucket = ev.bucket_id;
        storagePath = ev.storage_path;
        filename = ev.title;
      } else {
        return createErrorResponse("Either 'document_id' or 'evidence_id' is required.", 400, "INVALID_INPUT");
      }

      const { data: signedData, error: signErr } = await client.storage
        .from(bucket)
        .createSignedUrl(storagePath, expiresIn, {
          download: filename,
        });

      if (signErr || !signedData) {
        return createErrorResponse(`Failed to create signed URL: ${signErr?.message}`, 500, "STORAGE_ERROR");
      }

      return createSuccessResponse({
        signed_url: signedData.signedUrl,
        expires_in_seconds: expiresIn,
        expires_at: new Date(Date.now() + expiresIn * 1000).toISOString(),
      });
    }

    // Action: Register & Hash Document post-upload
    if (action === "register") {
      const title = sanitizeText(validateRequiredString(body.title, "title", 2, 200));
      const originalFilename = sanitizeText(validateRequiredString(body.original_filename, "original_filename", 3, 255));
      const storagePath = sanitizeText(validateRequiredString(body.storage_path, "storage_path", 3, 500));
      const bucketId = body.bucket_id || "legal-documents";
      const mimeType = sanitizeText(validateRequiredString(body.mime_type, "mime_type", 3, 100));
      const documentType = body.document_type || "other";

      // Verify that the storagePath begins with the authenticated user's ID
      if (!storagePath.startsWith(`${user.id}/`)) {
        return createErrorResponse(
          "Access denied: Storage path must strictly reside within the authenticated user's directory.",
          403,
          "UNAUTHORIZED_PATH"
        );
      }

      // Download file to compute cryptographic SHA-256 hash and exact file size
      const { data: fileBlob, error: downloadErr } = await client.storage
        .from(bucketId)
        .download(storagePath);

      if (downloadErr || !fileBlob) {
        return createErrorResponse(
          `Could not verify file in storage bucket '${bucketId}': ${downloadErr?.message}`,
          400,
          "FILE_NOT_FOUND_IN_STORAGE"
        );
      }

      const arrayBuffer = await fileBlob.arrayBuffer();
      const fileSize = arrayBuffer.byteLength;
      const sha256Hash = await calculateSha256(arrayBuffer);

      // Insert record into documents table
      const { data: docRecord, error: insertErr } = await client
        .from("documents")
        .insert({
          user_id: user.id,
          title,
          original_filename: originalFilename,
          storage_path: storagePath,
          bucket_id: bucketId,
          mime_type: mimeType,
          file_size: fileSize,
          file_hash: sha256Hash,
          document_type: documentType,
          processing_status: "pending",
        })
        .select()
        .single();

      if (insertErr || !docRecord) {
        return createErrorResponse(`Failed to insert document record: ${insertErr?.message}`, 500, "DB_ERROR");
      }

      return createSuccessResponse({
        document: docRecord,
        integrity_hash: sha256Hash,
        verified_size: fileSize,
      });
    }

    return createErrorResponse(`Unknown action '${action}'. Allowed: register, get_signed_url.`, 400, "INVALID_ACTION");
  } catch (error: unknown) {
    const err = error as Error;
    console.error("Error in document-processing Edge Function:", err.message);
    return createErrorResponse(
      err.message || "An unexpected error occurred while processing the document.",
      500,
      "INTERNAL_ERROR"
    );
  }
});

