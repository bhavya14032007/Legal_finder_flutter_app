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

