// Shared Type Definitions for Legal Helper (React Client)

export interface UserProfile {
  id: string;
  full_name: string;
  email: string;
  avatar_url?: string;
  preferred_language: "en" | "hi";
  phone_number?: string;
  created_at: string;
  updated_at: string;
}

export interface UserSettings {
  id: string;
  user_id: string;
  preferred_language: "en" | "hi";
  theme_mode: "light" | "dark" | "system";
  notifications_enabled: boolean;
  email_notifications: boolean;
  ai_disclaimer_acknowledged: boolean;
  disclaimer_acknowledged_at?: string;
}

export interface ChatSession {
  id: string;
  user_id: string;
  title: string;
  language: string;
  created_at: string;
  updated_at: string;
}

export interface ChatMessage {
  id: string;
  session_id: string;
  user_id: string;
  role: "user" | "assistant" | "system";
  content: string;
  metadata?: Record<string, unknown>;
  created_at: string;
}

export interface LegalDocument {
  id: string;
  user_id: string;
  title: string;
  original_filename: string;
  storage_path: string;
  bucket_id: string;
  mime_type: string;
  file_size: number;
  file_hash?: string;
  document_type: string;
  processing_status: "pending" | "processing" | "completed" | "failed";
  error_message?: string;
  created_at: string;
  updated_at: string;
}

export interface DocumentResult {
  id: string;
  document_id: string;
  user_id: string;
  simplified_content: string;
  extracted_text?: string;
  summary: string;
  risk_notes: Array<{
    risk_level: "HIGH" | "MEDIUM" | "LOW";
    issue: string;
    explanation: string;
    recommendation: string;
  }>;
  important_clauses: Array<{
    clause_title: string;
    original_context: string;
    plain_meaning: string;
  }>;
  key_obligations: Array<{
    party: string;
    obligation: string;
    timeline: string;
  }>;
  language: string;
  metadata?: {
    summary_hi?: string;
    provider?: string;
    model?: string;
  };
}

export interface Draft {
  id: string;
  user_id: string;
  title: string;
  draft_type: string;
  input_data: Record<string, unknown>;
  generated_content: string;
  status: "draft" | "review_pending" | "finalized" | "archived";
  created_at: string;
  updated_at: string;
}

export interface ResearchHistoryItem {
  id: string;
  user_id: string;
  query: string;
  jurisdiction: string;
  summary: string;
  results: {
    statutory_provisions?: Array<{
      act: string;
      section: string;
      title: string;
      explanation: string;
    }>;
    landmark_precedents?: Array<{
      case_name: string;
      court: string;
      year: string;
      principle: string;
    }>;
    procedural_remedies?: string[];
  };
  sources: Array<{ title: string; url: string }>;
  created_at: string;
}

export interface EvidenceItem {
  id: string;
  user_id: string;
  title: string;
  description?: string;
  evidence_type: string;
  storage_path?: string;
  file_hash?: string;
  mime_type?: string;
  file_size?: number;
  event_date: string;
  tags: string[];
  created_at: string;
}

export interface CasePreparation {
  id: string;
  user_id: string;
  title: string;
  case_type: string;
  facts_summary: string;
  timeline_events: Array<{ date: string; event: string; supporting_evidence?: string }>;
  questions_for_lawyer: string[];
  checklist: Array<{ item: string; importance: string; purpose: string }>;
  notes?: string;
  created_at: string;
}

export interface LegalAidResource {
  id: string;
  organization_name: string;
  authority_level: "national" | "state" | "district" | "taluk" | "tele_law" | "specialized";
  jurisdiction_state: string;
  district?: string;
  eligibility_criteria: string;
  contact_phone?: string;
  helpline_number?: string;
  contact_email?: string;
  website_url: string;
  address?: string;
  services_offered: string[];
}

export interface ScamDetectionResult {
  risk_score: number;
  risk_level: "LOW" | "MEDIUM" | "HIGH" | "CRITICAL";
  scam_type: string;
  is_scam_likely: boolean;
  suspicious_indicators: string[];
  detailed_analysis: string;
  recommended_actions: string[];
  emergency_helplines: {
    cyber_crime: string;
    cyber_portal: string;
    national_consumer_helpline: string;
  };
  disclaimer: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T | null;
  error: {
    code: string;
    message: string;
    details?: unknown;
  } | null;
}

