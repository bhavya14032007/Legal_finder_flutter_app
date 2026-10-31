-- Migration: 010_create_indexes.sql
-- Description: Create performance indexes, foreign key lookup indexes, and full-text search indexes

-- 1. Profiles Indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles(created_at DESC);

-- 2. Chat Sessions & Messages Indexes
CREATE INDEX IF NOT EXISTS idx_chat_sessions_user_id ON public.chat_sessions(user_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON public.chat_messages(session_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON public.chat_messages(user_id);

-- 3. Documents & Document Results Indexes
CREATE INDEX IF NOT EXISTS idx_documents_user_id ON public.documents(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_documents_status ON public.documents(processing_status);
CREATE INDEX IF NOT EXISTS idx_documents_file_hash ON public.documents(file_hash);
CREATE INDEX IF NOT EXISTS idx_document_results_doc_id ON public.document_results(document_id);
CREATE INDEX IF NOT EXISTS idx_document_results_user_id ON public.document_results(user_id);

-- 4. Drafts Indexes
CREATE INDEX IF NOT EXISTS idx_drafts_user_id ON public.drafts(user_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_drafts_type ON public.drafts(draft_type);
CREATE INDEX IF NOT EXISTS idx_drafts_status ON public.drafts(status);

-- 5. Saved Items Indexes
CREATE INDEX IF NOT EXISTS idx_saved_items_user_type ON public.saved_items(user_id, item_type);
CREATE INDEX IF NOT EXISTS idx_saved_items_created ON public.saved_items(user_id, created_at DESC);

-- 6. Research History Indexes
CREATE INDEX IF NOT EXISTS idx_research_history_user ON public.research_history(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_research_history_jurisdiction ON public.research_history(jurisdiction);

-- 7. Evidence Items & Case Preparations Indexes
CREATE INDEX IF NOT EXISTS idx_evidence_items_user_date ON public.evidence_items(user_id, event_date DESC);
CREATE INDEX IF NOT EXISTS idx_evidence_items_type ON public.evidence_items(user_id, evidence_type);
CREATE INDEX IF NOT EXISTS idx_evidence_items_hash ON public.evidence_items(file_hash);
CREATE INDEX IF NOT EXISTS idx_case_prep_user ON public.case_preparations(user_id, created_at DESC);

-- 8. Legal Aid Directory Indexes
CREATE INDEX IF NOT EXISTS idx_legal_aid_state ON public.legal_aid_directory(jurisdiction_state, authority_level);
CREATE INDEX IF NOT EXISTS idx_legal_aid_district ON public.legal_aid_directory(district) WHERE district IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_legal_aid_active ON public.legal_aid_directory(is_active) WHERE is_active = true;

-- 9. User Settings Index
CREATE INDEX IF NOT EXISTS idx_user_settings_user ON public.user_settings(user_id);

-- 10. Full-Text Search (GIN) Indexes for Instant In-App Search
CREATE INDEX IF NOT EXISTS idx_documents_fts ON public.documents USING GIN (to_tsvector('english', title || ' ' || original_filename));
CREATE INDEX IF NOT EXISTS idx_drafts_fts ON public.drafts USING GIN (to_tsvector('english', title || ' ' || generated_content));
CREATE INDEX IF NOT EXISTS idx_research_fts ON public.research_history USING GIN (to_tsvector('english', query || ' ' || COALESCE(summary, '')));
CREATE INDEX IF NOT EXISTS idx_evidence_fts ON public.evidence_items USING GIN (to_tsvector('english', title || ' ' || COALESCE(description, '')));

