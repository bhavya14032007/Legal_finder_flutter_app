
-- ==========================================================
-- MIGRATION: 001_create_profiles.sql
-- ==========================================================

-- Migration: 001_create_profiles.sql
-- Description: Create profiles table, updated_at trigger, and automatic auth user signup hook

-- Ensure pgcrypto extension is available for UUID operations
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Common utility function for updating updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Profiles table: Stores extended user profile information
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    email TEXT,
    avatar_url TEXT,
    preferred_language VARCHAR(10) NOT NULL DEFAULT 'en',
    phone_number TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger to maintain updated_at on profiles
DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Automatic profile creation on new user signup in auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, avatar_url, preferred_language)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', ''),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', ''),
        COALESCE(NEW.raw_user_meta_data->>'preferred_language', 'en')
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        email = EXCLUDED.email,
        avatar_url = CASE WHEN public.profiles.avatar_url IS NULL OR public.profiles.avatar_url = '' THEN EXCLUDED.avatar_url ELSE public.profiles.avatar_url END,
        updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger attached to auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Comment on table and columns for documentation
COMMENT ON TABLE public.profiles IS 'User profiles extending Supabase auth.users with app-specific preferences';
COMMENT ON COLUMN public.profiles.id IS 'References auth.users.id primary key';
COMMENT ON COLUMN public.profiles.preferred_language IS 'User preferred language code (en, hi, etc.)';



-- ==========================================================
-- MIGRATION: 002_create_chat_tables.sql
-- ==========================================================

-- Migration: 002_create_chat_tables.sql
-- Description: Create chat_sessions and chat_messages tables for Legal AI Advisor conversations

-- Chat Sessions Table
CREATE TABLE IF NOT EXISTS public.chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'New Legal Consultation',
    language VARCHAR(10) NOT NULL DEFAULT 'en',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Chat Messages Table
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger to maintain updated_at on chat_sessions
DROP TRIGGER IF EXISTS set_chat_sessions_updated_at ON public.chat_sessions;
CREATE TRIGGER set_chat_sessions_updated_at
    BEFORE UPDATE ON public.chat_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Trigger to touch chat_sessions.updated_at when a new message is added
CREATE OR REPLACE FUNCTION public.handle_new_chat_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.chat_sessions
    SET updated_at = timezone('utc'::text, now())
    WHERE id = NEW.session_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_chat_message_inserted ON public.chat_messages;
CREATE TRIGGER on_chat_message_inserted
    AFTER INSERT ON public.chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_chat_message();

-- Comments for documentation
COMMENT ON TABLE public.chat_sessions IS 'Conversations between users and the Legal AI Advisor';
COMMENT ON TABLE public.chat_messages IS 'Individual messages within a legal consultation session';
COMMENT ON COLUMN public.chat_messages.role IS 'Message sender role: user, assistant, or system';
COMMENT ON COLUMN public.chat_messages.metadata IS 'Structured metadata including legal citations, disclaimers, and model identifiers';



-- ==========================================================
-- MIGRATION: 003_create_documents.sql
-- ==========================================================

-- Migration: 003_create_documents.sql
-- Description: Create documents and document_results tables for Legal Vault and Document Simplifier

-- Documents Table
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    original_filename TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    bucket_id VARCHAR(50) NOT NULL DEFAULT 'legal-documents',
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL CHECK (file_size > 0),
    file_hash VARCHAR(64), -- SHA-256 checksum for tamper-evidence and integrity
    document_type VARCHAR(50) NOT NULL DEFAULT 'other',
    processing_status VARCHAR(20) NOT NULL CHECK (processing_status IN ('pending', 'processing', 'completed', 'failed')) DEFAULT 'pending',
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger to maintain updated_at on documents
DROP TRIGGER IF EXISTS set_documents_updated_at ON public.documents;
CREATE TRIGGER set_documents_updated_at
    BEFORE UPDATE ON public.documents
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Document Results Table: Stores extracted text, AI simplification, clause breakdown, and risk notes
CREATE TABLE IF NOT EXISTS public.document_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES public.documents(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    simplified_content TEXT,
    extracted_text TEXT,
    summary TEXT,
    risk_notes JSONB NOT NULL DEFAULT '[]'::jsonb,
    important_clauses JSONB NOT NULL DEFAULT '[]'::jsonb,
    key_obligations JSONB NOT NULL DEFAULT '[]'::jsonb,
    language VARCHAR(10) NOT NULL DEFAULT 'en',
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_document_results_doc_lang UNIQUE (document_id, language)
);

-- Trigger to maintain updated_at on document_results
DROP TRIGGER IF EXISTS set_document_results_updated_at ON public.document_results;
CREATE TRIGGER set_document_results_updated_at
    BEFORE UPDATE ON public.document_results
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Comments for documentation
COMMENT ON TABLE public.documents IS 'Legal vault documents uploaded by users for storage, analysis, and simplification';
COMMENT ON TABLE public.document_results IS 'Analysis, text extraction, plain-language simplification, and risk flags generated for a document';
COMMENT ON COLUMN public.documents.file_hash IS 'SHA-256 cryptographic hash of the uploaded file for integrity verification';
COMMENT ON COLUMN public.document_results.risk_notes IS 'Identified legal risks, liabilities, and concerning clauses with severity ratings';



-- ==========================================================
-- MIGRATION: 004_create_drafts.sql
-- ==========================================================

-- Migration: 004_create_drafts.sql
-- Description: Create drafts table for Drafting Assistant and Notice Reply generators

CREATE TABLE IF NOT EXISTS public.drafts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    draft_type VARCHAR(50) NOT NULL,
    input_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    generated_content TEXT NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'review_pending', 'finalized', 'archived')) DEFAULT 'draft',
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger to maintain updated_at on drafts
DROP TRIGGER IF EXISTS set_drafts_updated_at ON public.drafts;
CREATE TRIGGER set_drafts_updated_at
    BEFORE UPDATE ON public.drafts
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Comments for documentation
COMMENT ON TABLE public.drafts IS 'Legal drafts, formal notices, complaint applications, agreements, and notice replies';
COMMENT ON COLUMN public.drafts.draft_type IS 'Type of legal draft (e.g. legal_notice, notice_reply, rti_application, complaint_consumer)';
COMMENT ON COLUMN public.drafts.input_data IS 'Structured form parameters and user inputs used to generate the draft';
COMMENT ON COLUMN public.drafts.generated_content IS 'Full structured legal document text in markdown/plain format';



-- ==========================================================
-- MIGRATION: 005_create_saved_items.sql
-- ==========================================================

-- Migration: 005_create_saved_items.sql
-- Description: Create saved_items table for bookmarks and quick-access saved content

CREATE TABLE IF NOT EXISTS public.saved_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    item_type VARCHAR(50) NOT NULL CHECK (item_type IN ('document', 'draft', 'research', 'chat_session', 'legal_aid_resource', 'evidence', 'other')),
    item_reference TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_user_saved_item UNIQUE (user_id, item_type, item_reference)
);

-- Comments for documentation
COMMENT ON TABLE public.saved_items IS 'Bookmarked items across documents, drafts, legal research citations, and consultations';
COMMENT ON COLUMN public.saved_items.item_type IS 'Category of saved entity';
COMMENT ON COLUMN public.saved_items.item_reference IS 'Primary key or external identifier of referenced record';



-- ==========================================================
-- MIGRATION: 006_create_research_history.sql
-- ==========================================================

-- Migration: 006_create_research_history.sql
-- Description: Create research_history table for storing legal queries, verified sources, and research results

CREATE TABLE IF NOT EXISTS public.research_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    query TEXT NOT NULL,
    jurisdiction VARCHAR(50) NOT NULL DEFAULT 'IN',
    summary TEXT,
    results JSONB NOT NULL DEFAULT '[]'::jsonb,
    sources JSONB NOT NULL DEFAULT '[]'::jsonb,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger to maintain updated_at on research_history
DROP TRIGGER IF EXISTS set_research_history_updated_at ON public.research_history;
CREATE TRIGGER set_research_history_updated_at
    BEFORE UPDATE ON public.research_history
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Comments for documentation
COMMENT ON TABLE public.research_history IS 'Audit trail and library of user legal research queries, statutory citations, and verified judgments';
COMMENT ON COLUMN public.research_history.sources IS 'List of verified legal sources, Acts, Sections, and official court citations with URLs';
COMMENT ON COLUMN public.research_history.results IS 'Structured legal analysis, relevant precedents, and legal provisions';



-- ==========================================================
-- MIGRATION: 007_create_evidence_tables.sql
-- ==========================================================

-- Migration: 007_create_evidence_tables.sql
-- Description: Create evidence_items, case_preparations, and legal_aid_directory tables

-- Evidence Items Table: Supports timeline tracking and integrity verification
CREATE TABLE IF NOT EXISTS public.evidence_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    evidence_type VARCHAR(50) NOT NULL CHECK (evidence_type IN ('document', 'image', 'audio', 'video', 'message_screenshot', 'receipt', 'email', 'bank_statement', 'contract', 'other')),
    storage_path TEXT,
    bucket_id VARCHAR(50) NOT NULL DEFAULT 'evidence-files',
    file_hash VARCHAR(64), -- SHA-256 cryptographic hash of evidence file to record data integrity
    mime_type VARCHAR(100),
    file_size BIGINT,
    event_date TIMESTAMPTZ NOT NULL, -- Date/Time the evidence incident occurred
    tags TEXT[] NOT NULL DEFAULT '{}',
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger to maintain updated_at on evidence_items
DROP TRIGGER IF EXISTS set_evidence_items_updated_at ON public.evidence_items;
CREATE TRIGGER set_evidence_items_updated_at
    BEFORE UPDATE ON public.evidence_items
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Case Preparations Table: Structured dossiers for consulting lawyers
CREATE TABLE IF NOT EXISTS public.case_preparations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    case_type VARCHAR(100) NOT NULL,
    facts_summary TEXT NOT NULL,
    timeline_events JSONB NOT NULL DEFAULT '[]'::jsonb, -- Chronologically ordered events
    questions_for_lawyer JSONB NOT NULL DEFAULT '[]'::jsonb, -- Targeted questions
    checklist JSONB NOT NULL DEFAULT '[]'::jsonb, -- Action items and required documents
    notes TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger to maintain updated_at on case_preparations
DROP TRIGGER IF EXISTS set_case_preparations_updated_at ON public.case_preparations;
CREATE TRIGGER set_case_preparations_updated_at
    BEFORE UPDATE ON public.case_preparations
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Legal Aid Directory: Verified government and statutory legal aid authorities
-- This is a reference table maintained by system administrators; authenticated users can read it.
CREATE TABLE IF NOT EXISTS public.legal_aid_directory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_name TEXT NOT NULL,
    authority_level VARCHAR(50) NOT NULL CHECK (authority_level IN ('national', 'state', 'district', 'taluk', 'tele_law', 'specialized')),
    jurisdiction_state TEXT NOT NULL DEFAULT 'All India',
    district TEXT,
    eligibility_criteria TEXT NOT NULL,
    contact_phone TEXT,
    helpline_number TEXT,
    contact_email TEXT,
    website_url TEXT NOT NULL,
    address TEXT,
    services_offered TEXT[] NOT NULL DEFAULT '{}',
    is_active BOOLEAN NOT NULL DEFAULT true,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger to maintain updated_at on legal_aid_directory
DROP TRIGGER IF EXISTS set_legal_aid_directory_updated_at ON public.legal_aid_directory;
CREATE TRIGGER set_legal_aid_directory_updated_at
    BEFORE UPDATE ON public.legal_aid_directory
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Comments for documentation
COMMENT ON TABLE public.evidence_items IS 'Chronological evidence registry with SHA-256 hashes and event timestamps for timeline reconstruction';
COMMENT ON COLUMN public.evidence_items.file_hash IS 'SHA-256 hash of original file recorded at upload time for integrity tracking (not a substitute for forensic chain of custody)';
COMMENT ON TABLE public.case_preparations IS 'Structured case summaries, checklists, and targeted questions prepared before meeting a legal professional';
COMMENT ON TABLE public.legal_aid_directory IS 'Verified directory of statutory legal aid authorities (NALSA, SLSA, DLSA, Tele-Law) under Legal Services Authorities Act, 1987';



-- ==========================================================
-- MIGRATION: 008_create_user_settings.sql
-- ==========================================================

-- Migration: 008_create_user_settings.sql
-- Description: Create user_settings table and automatic initialization on user signup

CREATE TABLE IF NOT EXISTS public.user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    preferred_language VARCHAR(10) NOT NULL DEFAULT 'en',
    theme_mode VARCHAR(20) NOT NULL CHECK (theme_mode IN ('light', 'dark', 'system')) DEFAULT 'system',
    notifications_enabled BOOLEAN NOT NULL DEFAULT true,
    email_notifications BOOLEAN NOT NULL DEFAULT false,
    ai_disclaimer_acknowledged BOOLEAN NOT NULL DEFAULT false,
    disclaimer_acknowledged_at TIMESTAMPTZ,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger to maintain updated_at on user_settings
DROP TRIGGER IF EXISTS set_user_settings_updated_at ON public.user_settings;
CREATE TRIGGER set_user_settings_updated_at
    BEFORE UPDATE ON public.user_settings
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Function to automatically seed default user_settings upon new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user_settings()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_settings (user_id, preferred_language, theme_mode, notifications_enabled)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'preferred_language', 'en'),
        'system',
        true
    )
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger attached to auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created_settings ON auth.users;
CREATE TRIGGER on_auth_user_created_settings
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user_settings();

-- Comments for documentation
COMMENT ON TABLE public.user_settings IS 'User application preferences including language, theme, and legal disclaimer status';
COMMENT ON COLUMN public.user_settings.ai_disclaimer_acknowledged IS 'Records whether user acknowledged that AI generated outputs do not substitute certified legal counsel';



-- ==========================================================
-- MIGRATION: 009_create_rls_policies.sql
-- ==========================================================

-- Migration: 009_create_rls_policies.sql
-- Description: Enforce Row Level Security (RLS) across all tables and configure secure storage policies

-- Enable RLS on every user-owned table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.document_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drafts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.research_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evidence_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.case_preparations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_aid_directory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- -------------------------------------------------------------
-- 1. Profiles Table Policies
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can delete their own profile" ON public.profiles;
CREATE POLICY "Users can delete their own profile"
    ON public.profiles FOR DELETE
    USING (auth.uid() = id);

-- -------------------------------------------------------------
-- 2. Chat Sessions Table Policies
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view their own chat sessions" ON public.chat_sessions;
CREATE POLICY "Users can view their own chat sessions"
    ON public.chat_sessions FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create their own chat sessions" ON public.chat_sessions;
CREATE POLICY "Users can create their own chat sessions"
    ON public.chat_sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own chat sessions" ON public.chat_sessions;
CREATE POLICY "Users can update their own chat sessions"
    ON public.chat_sessions FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own chat sessions" ON public.chat_sessions;
CREATE POLICY "Users can delete their own chat sessions"
    ON public.chat_sessions FOR DELETE
    USING (auth.uid() = user_id);

-- -------------------------------------------------------------
-- 3. Chat Messages Table Policies (Validates session ownership)
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view messages from their own sessions" ON public.chat_messages;
CREATE POLICY "Users can view messages from their own sessions"
    ON public.chat_messages FOR SELECT
    USING (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.chat_sessions s
            WHERE s.id = session_id AND s.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can insert messages into their own sessions" ON public.chat_messages;
CREATE POLICY "Users can insert messages into their own sessions"
    ON public.chat_messages FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.chat_sessions s
            WHERE s.id = session_id AND s.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can update their own messages" ON public.chat_messages;
CREATE POLICY "Users can update their own messages"
    ON public.chat_messages FOR UPDATE
    USING (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.chat_sessions s
            WHERE s.id = session_id AND s.user_id = auth.uid()
        )
    )
    WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.chat_sessions s
            WHERE s.id = session_id AND s.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can delete their own messages" ON public.chat_messages;
CREATE POLICY "Users can delete their own messages"
    ON public.chat_messages FOR DELETE
    USING (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.chat_sessions s
            WHERE s.id = session_id AND s.user_id = auth.uid()
        )
    );

-- -------------------------------------------------------------
-- 4. Documents Table Policies
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view their own documents" ON public.documents;
CREATE POLICY "Users can view their own documents"
    ON public.documents FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own documents" ON public.documents;
CREATE POLICY "Users can insert their own documents"
    ON public.documents FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own documents" ON public.documents;
CREATE POLICY "Users can update their own documents"
    ON public.documents FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own documents" ON public.documents;
CREATE POLICY "Users can delete their own documents"
    ON public.documents FOR DELETE
    USING (auth.uid() = user_id);

-- -------------------------------------------------------------
-- 5. Document Results Table Policies (Validates document ownership)
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view results of their own documents" ON public.document_results;
CREATE POLICY "Users can view results of their own documents"
    ON public.document_results FOR SELECT
    USING (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.documents d
            WHERE d.id = document_id AND d.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can insert results for their own documents" ON public.document_results;
CREATE POLICY "Users can insert results for their own documents"
    ON public.document_results FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.documents d
            WHERE d.id = document_id AND d.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can update results of their own documents" ON public.document_results;
CREATE POLICY "Users can update results of their own documents"
    ON public.document_results FOR UPDATE
    USING (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.documents d
            WHERE d.id = document_id AND d.user_id = auth.uid()
        )
    )
    WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.documents d
            WHERE d.id = document_id AND d.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can delete results of their own documents" ON public.document_results;
CREATE POLICY "Users can delete results of their own documents"
    ON public.document_results FOR DELETE
    USING (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.documents d
            WHERE d.id = document_id AND d.user_id = auth.uid()
        )
    );

-- -------------------------------------------------------------
-- 6. Drafts Table Policies
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view their own drafts" ON public.drafts;
CREATE POLICY "Users can view their own drafts"
    ON public.drafts FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create their own drafts" ON public.drafts;
CREATE POLICY "Users can create their own drafts"
    ON public.drafts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own drafts" ON public.drafts;
CREATE POLICY "Users can update their own drafts"
    ON public.drafts FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own drafts" ON public.drafts;
CREATE POLICY "Users can delete their own drafts"
    ON public.drafts FOR DELETE
    USING (auth.uid() = user_id);

-- -------------------------------------------------------------
-- 7. Saved Items Table Policies
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view their own saved items" ON public.saved_items;
CREATE POLICY "Users can view their own saved items"
    ON public.saved_items FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own saved items" ON public.saved_items;
CREATE POLICY "Users can insert their own saved items"
    ON public.saved_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own saved items" ON public.saved_items;
CREATE POLICY "Users can update their own saved items"
    ON public.saved_items FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own saved items" ON public.saved_items;
CREATE POLICY "Users can delete their own saved items"
    ON public.saved_items FOR DELETE
    USING (auth.uid() = user_id);

-- -------------------------------------------------------------
-- 8. Research History Table Policies
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view their own research history" ON public.research_history;
CREATE POLICY "Users can view their own research history"
    ON public.research_history FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own research records" ON public.research_history;
CREATE POLICY "Users can insert their own research records"
    ON public.research_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own research records" ON public.research_history;
CREATE POLICY "Users can update their own research records"
    ON public.research_history FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own research records" ON public.research_history;
CREATE POLICY "Users can delete their own research records"
    ON public.research_history FOR DELETE
    USING (auth.uid() = user_id);

-- -------------------------------------------------------------
-- 9. Evidence Items Table Policies
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view their own evidence items" ON public.evidence_items;
CREATE POLICY "Users can view their own evidence items"
    ON public.evidence_items FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own evidence items" ON public.evidence_items;
CREATE POLICY "Users can insert their own evidence items"
    ON public.evidence_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own evidence items" ON public.evidence_items;
CREATE POLICY "Users can update their own evidence items"
    ON public.evidence_items FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own evidence items" ON public.evidence_items;
CREATE POLICY "Users can delete their own evidence items"
    ON public.evidence_items FOR DELETE
    USING (auth.uid() = user_id);

-- -------------------------------------------------------------
-- 10. Case Preparations Table Policies
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view their own case preparations" ON public.case_preparations;
CREATE POLICY "Users can view their own case preparations"
    ON public.case_preparations FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create their own case preparations" ON public.case_preparations;
CREATE POLICY "Users can create their own case preparations"
    ON public.case_preparations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own case preparations" ON public.case_preparations;
CREATE POLICY "Users can update their own case preparations"
    ON public.case_preparations FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own case preparations" ON public.case_preparations;
CREATE POLICY "Users can delete their own case preparations"
    ON public.case_preparations FOR DELETE
    USING (auth.uid() = user_id);

-- -------------------------------------------------------------
-- 11. Legal Aid Directory Table Policies
-- -------------------------------------------------------------
-- Verified directory is accessible for read by all authenticated users
DROP POLICY IF EXISTS "Authenticated users can read legal aid directory" ON public.legal_aid_directory;
CREATE POLICY "Authenticated users can read legal aid directory"
    ON public.legal_aid_directory FOR SELECT
    USING (auth.role() = 'authenticated');

-- -------------------------------------------------------------
-- 12. User Settings Table Policies
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "Users can view their own settings" ON public.user_settings;
CREATE POLICY "Users can view their own settings"
    ON public.user_settings FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own settings" ON public.user_settings;
CREATE POLICY "Users can insert their own settings"
    ON public.user_settings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own settings" ON public.user_settings;
CREATE POLICY "Users can update their own settings"
    ON public.user_settings FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own settings" ON public.user_settings;
CREATE POLICY "Users can delete their own settings"
    ON public.user_settings FOR DELETE
    USING (auth.uid() = user_id);

-- =============================================================
-- STORAGE BUCKETS & STORAGE RLS POLICIES
-- =============================================================

-- Ensure private storage buckets exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    (
        'legal-documents',
        'legal-documents',
        false,
        52428800, -- 50 MB
        ARRAY[
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'image/jpeg',
            'image/png',
            'text/plain'
        ]::text[]
    ),
    (
        'evidence-files',
        'evidence-files',
        false,
        104857600, -- 100 MB
        ARRAY[
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'image/jpeg',
            'image/png',
            'image/webp',
            'audio/mpeg',
            'audio/wav',
            'audio/ogg',
            'video/mp4',
            'text/plain'
        ]::text[]
    ),
    (
        'user-uploads',
        'user-uploads',
        false,
        52428800, -- 50 MB
        ARRAY[
            'application/pdf',
            'image/jpeg',
            'image/png'
        ]::text[]
    ),
    (
        'generated-documents',
        'generated-documents',
        false,
        52428800, -- 50 MB
        ARRAY[
            'application/pdf',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'text/plain',
            'text/markdown'
        ]::text[]
    )
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Storage Objects Row Level Security Policies
-- Folder naming convention strictly enforced: {bucket}/{user_id}/{filename}

DROP POLICY IF EXISTS "Users can view their own storage files" ON storage.objects;
CREATE POLICY "Users can view their own storage files"
    ON storage.objects FOR SELECT
    USING (
        auth.role() = 'authenticated' AND
        bucket_id IN ('legal-documents', 'evidence-files', 'user-uploads', 'generated-documents') AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

DROP POLICY IF EXISTS "Users can upload to their own storage folder" ON storage.objects;
CREATE POLICY "Users can upload to their own storage folder"
    ON storage.objects FOR INSERT
    WITH CHECK (
        auth.role() = 'authenticated' AND
        bucket_id IN ('legal-documents', 'evidence-files', 'user-uploads', 'generated-documents') AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

DROP POLICY IF EXISTS "Users can update their own storage files" ON storage.objects;
CREATE POLICY "Users can update their own storage files"
    ON storage.objects FOR UPDATE
    USING (
        auth.role() = 'authenticated' AND
        bucket_id IN ('legal-documents', 'evidence-files', 'user-uploads', 'generated-documents') AND
        (storage.foldername(name))[1] = auth.uid()::text
    )
    WITH CHECK (
        auth.role() = 'authenticated' AND
        bucket_id IN ('legal-documents', 'evidence-files', 'user-uploads', 'generated-documents') AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

DROP POLICY IF EXISTS "Users can delete their own storage files" ON storage.objects;
CREATE POLICY "Users can delete their own storage files"
    ON storage.objects FOR DELETE
    USING (
        auth.role() = 'authenticated' AND
        bucket_id IN ('legal-documents', 'evidence-files', 'user-uploads', 'generated-documents') AND
        (storage.foldername(name))[1] = auth.uid()::text
    );



-- ==========================================================
-- MIGRATION: 010_create_indexes.sql
-- ==========================================================

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


