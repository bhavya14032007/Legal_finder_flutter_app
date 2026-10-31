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

