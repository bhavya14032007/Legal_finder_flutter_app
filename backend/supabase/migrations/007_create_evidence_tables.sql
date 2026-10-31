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

