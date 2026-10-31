// React Client Unified Service Layer for Legal Helper Backend
import { supabase } from "../supabaseClient";
import {
  UserProfile,
  ChatSession,
  ChatMessage,
  LegalDocument,
  DocumentResult,
  Draft,
  ResearchHistoryItem,
  EvidenceItem,
  CasePreparation,
  LegalAidResource,
  ScamDetectionResult,
  ApiResponse,
} from "../types";

export const LegalHelperApi = {
  // -------------------------------------------------------------
  // 1. AUTHENTICATION SERVICES
  // -------------------------------------------------------------
  auth: {
    async signUp(email: string, password: string, fullName: string, preferredLanguage = "en") {
      return await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName,
            preferred_language: preferredLanguage,
          },
        },
      });
    },

    async signIn(email: string, password: string) {
      return await supabase.auth.signInWithPassword({ email, password });
    },

    async signOut() {
      return await supabase.auth.signOut();
    },

    async resetPassword(email: string) {
      return await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      });
    },

    async getCurrentUser() {
      const { data: { user }, error } = await supabase.auth.getUser();
      if (error || !user) return null;
      return user;
    },

    async getProfile(): Promise<UserProfile | null> {
      const user = await LegalHelperApi.auth.getCurrentUser();
      if (!user) return null;

      const { data, error } = await supabase
        .from("profiles")
        .select("*")
        .eq("id", user.id)
        .single();

      if (error) throw error;
      return data;
    },

    async updateProfile(updates: Partial<UserProfile>) {
      const user = await LegalHelperApi.auth.getCurrentUser();
      if (!user) throw new Error("Unauthenticated");

      const { data, error } = await supabase
        .from("profiles")
        .update(updates)
        .eq("id", user.id)
        .select()
        .single();

      if (error) throw error;
      return data;
    },
  },

  // -------------------------------------------------------------
  // 2. LEGAL AI ADVISOR (Edge Function: legal-advisor)
  // -------------------------------------------------------------
  advisor: {
    async sendMessage(
      message: string,
      sessionId?: string,
      language: "en" | "hi" = "en"
    ): Promise<ApiResponse<{
      session_id: string;
      user_message_id: string;
      assistant_message_id: string;
      response: string;
      disclaimer: string;
    }>> {
      const { data, error } = await supabase.functions.invoke("legal-advisor", {
        body: { message, session_id: sessionId, language },
      });
      if (error) throw error;
      return data;
    },

    async getSessions(): Promise<ChatSession[]> {
      const { data, error } = await supabase
        .from("chat_sessions")
        .select("*")
        .order("updated_at", { ascending: false });

      if (error) throw error;
      return data || [];
    },

    async getMessages(sessionId: string): Promise<ChatMessage[]> {
      const { data, error } = await supabase
        .from("chat_messages")
        .select("*")
        .eq("session_id", sessionId)
        .order("created_at", { ascending: true });

      if (error) throw error;
      return data || [];
    },

    async deleteSession(sessionId: string): Promise<void> {
      const { error } = await supabase
        .from("chat_sessions")
        .delete()
        .eq("id", sessionId);

      if (error) throw error;
    },
  },

  // -------------------------------------------------------------
  // 3. LEGAL RESEARCH (Edge Function: legal-research)
  // -------------------------------------------------------------
  research: {
    async search(query: string, jurisdiction = "IN"): Promise<ApiResponse<ResearchHistoryItem>> {
      const { data, error } = await supabase.functions.invoke("legal-research", {
        body: { query, jurisdiction },
      });
      if (error) throw error;
      return data;
    },

    async getHistory(): Promise<ResearchHistoryItem[]> {
      const { data, error } = await supabase
        .from("research_history")
        .select("*")
        .order("created_at", { ascending: false });

      if (error) throw error;
      return data || [];
    },
  },

  // -------------------------------------------------------------
  // 4. LEGAL VAULT & DOCUMENT SIMPLIFIER
  // -------------------------------------------------------------
  vault: {
    async uploadAndRegisterDocument(
      file: File,
      title: string,
      documentType = "contract"
    ): Promise<LegalDocument> {
      const user = await LegalHelperApi.auth.getCurrentUser();
      if (!user) throw new Error("Unauthenticated");

      // 1. Upload to private storage: {user_id}/{timestamp}_{filename}
      const safeFilename = file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
      const storagePath = `${user.id}/${Date.now()}_${safeFilename}`;

      const { error: uploadError } = await supabase.storage
        .from("legal-documents")
        .upload(storagePath, file, {
          cacheControl: "3600",
          upsert: false,
        });

      if (uploadError) throw uploadError;

      // 2. Call document-processing to compute SHA-256 and register record
      const { data: regResult, error: regError } = await supabase.functions.invoke(
        "document-processing",
        {
          body: {
            action: "register",
            title,
            original_filename: file.name,
            storage_path: storagePath,
            bucket_id: "legal-documents",
            mime_type: file.type || "application/pdf",
            document_type: documentType,
          },
        }
      );

      if (regError) throw regError;
      return regResult.data.document;
    },

    async simplifyDocument(documentId: string): Promise<ApiResponse<DocumentResult>> {
      const { data, error } = await supabase.functions.invoke("document-simplifier", {
        body: { document_id: documentId },
      });
      if (error) throw error;
      return data;
    },

    async getSignedDownloadUrl(documentId: string, expiresInSeconds = 900): Promise<string> {
      const { data, error } = await supabase.functions.invoke("document-processing", {
        body: {
          action: "get_signed_url",
          document_id: documentId,
          expires_in: expiresInSeconds,
        },
      });
      if (error) throw error;
      return data.data.signed_url;
    },

    async listDocuments(): Promise<LegalDocument[]> {
      const { data, error } = await supabase
        .from("documents")
        .select("*")
        .order("created_at", { ascending: false });

      if (error) throw error;
      return data || [];
    },

    async deleteDocument(documentId: string): Promise<void> {
      const { error } = await supabase.from("documents").delete().eq("id", documentId);
      if (error) throw error;
    },
  },

  // -------------------------------------------------------------
  // 5. DRAFTING ASSISTANT (Edge Function: drafting-assistant)
  // -------------------------------------------------------------
  drafting: {
    async generateDraft(
      draftType: string,
      title: string,
      inputData: Record<string, unknown>
    ): Promise<ApiResponse<Draft>> {
      const { data, error } = await supabase.functions.invoke("drafting-assistant", {
        body: { action: "generate", draft_type: draftType, title, input_data: inputData },
      });
      if (error) throw error;
      return data;
    },

    async updateDraft(draftId: string, updates: Partial<Draft>): Promise<ApiResponse<{ draft: Draft }>> {
      const { data, error } = await supabase.functions.invoke("drafting-assistant", {
        body: { action: "update", draft_id: draftId, ...updates },
      });
      if (error) throw error;
      return data;
    },

    async listDrafts(): Promise<Draft[]> {
      const { data, error } = await supabase
        .from("drafts")
        .select("*")
        .order("updated_at", { ascending: false });

      if (error) throw error;
      return data || [];
    },
  },

  // -------------------------------------------------------------
  // 6. NOTICE REPLY (Edge Function: notice-reply)
  // -------------------------------------------------------------
  noticeReply: {
    async generateReply(
      noticeText: string,
      userFacts?: string,
      strategy = "factual_clarification",
      title?: string
    ) {
      const { data, error } = await supabase.functions.invoke("notice-reply", {
        body: { notice_text: noticeText, user_facts: userFacts, strategy, title },
      });
      if (error) throw error;
      return data;
    },
  },

  // -------------------------------------------------------------
  // 7. SCAM DETECTOR (Edge Function: scam-detector)
  // -------------------------------------------------------------
  scamDetector: {
    async scan(content?: string, url?: string, sourceChannel = "message"): Promise<ApiResponse<ScamDetectionResult>> {
      const { data, error } = await supabase.functions.invoke("scam-detector", {
        body: { content, url, source_channel: sourceChannel },
      });
      if (error) throw error;
      return data;
    },
  },

  // -------------------------------------------------------------
  // 8. EVIDENCE, TIMELINE & LAWYER PREP (Edge Function: lawyer-prep)
  // -------------------------------------------------------------
  evidence: {
    async addEvidenceItem(item: {
      title: string;
      description?: string;
      evidence_type: string;
      event_date: string;
      storage_path?: string;
      file_hash?: string;
      tags?: string[];
    }): Promise<EvidenceItem> {
      const user = await LegalHelperApi.auth.getCurrentUser();
      if (!user) throw new Error("Unauthenticated");

      const { data, error } = await supabase
        .from("evidence_items")
        .insert({
          ...item,
          user_id: user.id,
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },

    async getTimeline(): Promise<EvidenceItem[]> {
      const { data, error } = await supabase.functions.invoke("lawyer-prep", {
        body: { action: "get_timeline" },
      });
      if (error) throw error;
      return data.data.timeline;
    },

    async generateLawyerPrepDossier(
      title: string,
      caseType: string,
      factsSummary: string,
      notes?: string,
      includeEvidenceTimeline = true
    ): Promise<ApiResponse<CasePreparation>> {
      const { data, error } = await supabase.functions.invoke("lawyer-prep", {
        body: {
          action: "generate_dossier",
          title,
          case_type: caseType,
          facts_summary: factsSummary,
          notes,
          include_evidence_timeline: includeEvidenceTimeline,
        },
      });
      if (error) throw error;
      return data;
    },

    async getLegalAidDirectory(state?: string, district?: string): Promise<ApiResponse<{ legal_aid_authorities: LegalAidResource[] }>> {
      const { data, error } = await supabase.functions.invoke("lawyer-prep", {
        body: { action: "get_legal_aid", state, district },
      });
      if (error) throw error;
      return data;
    },
  },
};

