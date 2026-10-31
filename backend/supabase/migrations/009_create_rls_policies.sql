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

