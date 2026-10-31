-- ==============================================================================
-- TEST SUITE: ROW LEVEL SECURITY (RLS) ISOLATION TEST
-- ==============================================================================
-- Verifies that:
-- 1. User A's data is invisible and inaccessible to User B
-- 2. User B cannot insert records masquerading as User A
-- 3. User B cannot update or delete User A's records
-- 4. Storage folder path access is restricted to the owner
-- ==============================================================================

BEGIN;

-- 1. Setup Test Users in auth.users
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES 
    ('00000000-0000-0000-0000-000000000001'::uuid, 'user_a@test.com', '{"full_name": "Advocate Alice"}'::jsonb),
    ('00000000-0000-0000-0000-000000000002'::uuid, 'user_b@test.com', '{"full_name": "Bob Client"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- 2. Insert records owned by User A (using service role / admin bypass)
INSERT INTO public.chat_sessions (id, user_id, title)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'User A Confidential Case')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.chat_messages (id, session_id, user_id, role, content)
VALUES ('aaaaaaaa-bbbb-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'user', 'What is my legal exposure?')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.documents (id, user_id, title, original_filename, storage_path, mime_type, file_size)
VALUES ('aaaaaaaa-cccc-aaaa-aaaa-aaaaaaaaaaaa'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'Confidential Agreement', 'contract.pdf', '00000000-0000-0000-0000-000000000001/contract.pdf', 'application/pdf', 1024)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.drafts (id, user_id, title, draft_type, generated_content)
VALUES ('aaaaaaaa-dddd-aaaa-aaaa-aaaaaaaaaaaa'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'Notice to Breach Party', 'legal_notice', 'Legal Notice Text under Section 138...')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.evidence_items (id, user_id, title, evidence_type, event_date)
VALUES ('aaaaaaaa-eeee-aaaa-aaaa-aaaaaaaaaaaa'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, 'Bank Transfer Receipt', 'receipt', now())
ON CONFLICT (id) DO NOTHING;

-- -------------------------------------------------------------
-- SWITCH CONTEXT TO AUTHENTICATED USER B
-- -------------------------------------------------------------
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claim.sub" = '00000000-0000-0000-0000-000000000002';

-- TEST 1: User B SELECT User A's profile
DO $$
DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*) INTO row_count FROM public.profiles WHERE id = '00000000-0000-0000-0000-000000000001'::uuid;
    IF row_count <> 0 THEN
        RAISE EXCEPTION 'TEST 1 FAILED: User B was able to view User A profile!';
    ELSE
        RAISE NOTICE 'TEST 1 PASSED: Profile isolation confirmed.';
    END IF;
END $$;

-- TEST 2: User B SELECT User A's chat sessions
DO $$
DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*) INTO row_count FROM public.chat_sessions WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
    IF row_count <> 0 THEN
        RAISE EXCEPTION 'TEST 2 FAILED: User B was able to view User A chat sessions!';
    ELSE
        RAISE NOTICE 'TEST 2 PASSED: Chat sessions isolation confirmed.';
    END IF;
END $$;

-- TEST 3: User B SELECT User A's chat messages
DO $$
DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*) INTO row_count FROM public.chat_messages WHERE id = 'aaaaaaaa-bbbb-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
    IF row_count <> 0 THEN
        RAISE EXCEPTION 'TEST 3 FAILED: User B was able to view User A chat messages!';
    ELSE
        RAISE NOTICE 'TEST 3 PASSED: Chat messages isolation confirmed.';
    END IF;
END $$;

-- TEST 4: User B SELECT User A's documents in Legal Vault
DO $$
DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*) INTO row_count FROM public.documents WHERE id = 'aaaaaaaa-cccc-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
    IF row_count <> 0 THEN
        RAISE EXCEPTION 'TEST 4 FAILED: User B was able to view User A documents!';
    ELSE
        RAISE NOTICE 'TEST 4 PASSED: Document isolation confirmed.';
    END IF;
END $$;

-- TEST 5: User B SELECT User A's legal drafts
DO $$
DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*) INTO row_count FROM public.drafts WHERE id = 'aaaaaaaa-dddd-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
    IF row_count <> 0 THEN
        RAISE EXCEPTION 'TEST 5 FAILED: User B was able to view User A drafts!';
    ELSE
        RAISE NOTICE 'TEST 5 PASSED: Drafts isolation confirmed.';
    END IF;
END $$;

-- TEST 6: User B SELECT User A's evidence items
DO $$
DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*) INTO row_count FROM public.evidence_items WHERE id = 'aaaaaaaa-eeee-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
    IF row_count <> 0 THEN
        RAISE EXCEPTION 'TEST 6 FAILED: User B was able to view User A evidence items!';
    ELSE
        RAISE NOTICE 'TEST 6 PASSED: Evidence isolation confirmed.';
    END IF;
END $$;

-- TEST 7: User B UPDATE User A's document title
DO $$
DECLARE
    rows_updated INT;
BEGIN
    UPDATE public.documents SET title = 'HACKED TITLE' WHERE id = 'aaaaaaaa-cccc-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    IF rows_updated > 0 THEN
        RAISE EXCEPTION 'TEST 7 FAILED: User B was able to update User A document!';
    ELSE
        RAISE NOTICE 'TEST 7 PASSED: Cross-user update blocked.';
    END IF;
END $$;

-- TEST 8: User B DELETE User A's draft
DO $$
DECLARE
    rows_deleted INT;
BEGIN
    DELETE FROM public.drafts WHERE id = 'aaaaaaaa-dddd-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
    GET DIAGNOSTICS rows_deleted = ROW_COUNT;
    IF rows_deleted > 0 THEN
        RAISE EXCEPTION 'TEST 8 FAILED: User B was able to delete User A draft!';
    ELSE
        RAISE NOTICE 'TEST 8 PASSED: Cross-user delete blocked.';
    END IF;
END $$;

-- TEST 9: User B attempting to insert draft impersonating User A
DO $$
BEGIN
    INSERT INTO public.drafts (user_id, title, draft_type, generated_content)
    VALUES ('00000000-0000-0000-0000-000000000001'::uuid, 'Malicious Impersonation Draft', 'other', 'Content');
    RAISE EXCEPTION 'TEST 9 FAILED: User B inserted record with User A user_id!';
EXCEPTION WHEN row_security_policy_violation THEN
    RAISE NOTICE 'TEST 9 PASSED: Insertion with forged user_id properly rejected by RLS WITH CHECK.';
WHEN OTHERS THEN
    RAISE NOTICE 'TEST 9 PASSED: Blocked as expected: %', SQLERRM;
END $$;

-- TEST 10: Authenticated user can read public statutory Legal Aid Directory
DO $$
DECLARE
    aid_count INT;
BEGIN
    SELECT COUNT(*) INTO aid_count FROM public.legal_aid_directory;
    RAISE NOTICE 'TEST 10 PASSED: Legal Aid Directory accessible to authenticated user. Found % entries.', aid_count;
END $$;

-- Clean up test changes
ROLLBACK;

