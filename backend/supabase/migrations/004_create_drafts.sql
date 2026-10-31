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

