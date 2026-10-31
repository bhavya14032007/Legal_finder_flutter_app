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

