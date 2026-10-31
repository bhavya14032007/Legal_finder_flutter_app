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

