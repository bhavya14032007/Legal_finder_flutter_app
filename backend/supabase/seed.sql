-- Supabase Seed Data: Verified Statutory Legal Aid Authorities & Reference Metadata
-- Legal Services Authorities Act, 1987 & Government of India Statutory Portals

INSERT INTO public.legal_aid_directory (
    organization_name,
    authority_level,
    jurisdiction_state,
    district,
    eligibility_criteria,
    contact_phone,
    helpline_number,
    contact_email,
    website_url,
    address,
    services_offered
) VALUES
(
    'National Legal Services Authority (NALSA)',
    'national',
    'All India',
    NULL,
    'Section 12 of Legal Services Authorities Act, 1987: Women, children, SC/ST members, industrial workmen, persons with disabilities, custody victims, human trafficking victims, and citizens with annual income below prescribed state ceiling (typically ₹1,00,000 to ₹3,00,000 depending on state).',
    '+91-11-23382778',
    '15100',
    'nalsa-dla@nic.in',
    'https://nalsa.gov.in',
    'B-Block, Additional Office Complex, Supreme Court of India, New Delhi - 110001',
    ARRAY['Free Legal Representation', 'Lok Adalat Dispute Resolution', 'Legal Literacy & Clinics', 'Victim Compensation Assistance', 'Legal Aid in Custody']
),
(
    'Tele-Law: Department of Justice',
    'tele_law',
    'All India',
    NULL,
    'Marginalized sections eligible under Section 12 of Legal Services Authorities Act 1987 receive free consultation via video conferencing at Common Service Centres (CSCs); nominal fee for others.',
    '+91-11-23386000',
    '14430',
    'telelaw-support@gov.in',
    'https://www.tele-law.in',
    'Department of Justice, Jaisalmer House, 26 Mansingh Road, New Delhi - 110011',
    ARRAY['Pre-litigation Advice', 'Panel Lawyer Video Consultation', 'Common Service Centre Access', 'Document Review Assistance']
),
(
    'Delhi State Legal Services Authority (DSLSA)',
    'state',
    'Delhi',
    'All Districts',
    'Income below ₹3,00,000 per annum, or eligible category under Sec 12 (Women, Minors, SC/ST, Custody).',
    '+91-11-23384781',
    '1516',
    'dslsa-phc@nic.in',
    'https://dslsa.org',
    'Central Office, Pre-Fab Building, Patiala House Courts, New Delhi - 110001',
    ARRAY['Free Panel Advocate Appointment', 'Counselling & Mediation', 'Lok Adalats', 'Legal Aid Clinics at Tihar & Rohini Jails']
),
(
    'Maharashtra State Legal Services Authority (MSLSA)',
    'state',
    'Maharashtra',
    'All Districts',
    'Income below ₹3,00,000 per annum, or eligible category under Sec 12.',
    '+91-22-22691358',
    '15100',
    'mslsa-bhc@nic.in',
    'https://legalservices.maharashtra.gov.in',
    '105, High Court P.W.D. Building, Fort, Mumbai - 400032',
    ARRAY['Free Legal Aid & Advice', 'Permanent Lok Adalats', 'Prison Legal Aid', 'Dispute Conciliation']
),
(
    'Karnataka State Legal Services Authority (KSLSA)',
    'state',
    'Karnataka',
    'All Districts',
    'Income below ₹3,00,000 per annum, or eligible category under Sec 12.',
    '+91-80-22111725',
    '15100',
    'kslsa-hc@karnataka.gov.in',
    'https://kslsa.kar.nic.in',
    'Nyaya Degula, 1st Floor, Siddaiah Road, Bangalore - 560027',
    ARRAY['Free Legal Representation', 'High Court Legal Services Committee', 'Lok Adalat', 'Mediation Centre']
),
(
    'National Consumer Helpline (NCH) - Department of Consumer Affairs',
    'specialized',
    'All India',
    NULL,
    'Any aggrieved consumer under the Consumer Protection Act, 2019 facing unfair trade practices, deficiency in service, or counterfeit goods.',
    '+91-11-23381667',
    '1915',
    'consumer-helpline@nic.in',
    'https://consumerhelpline.gov.in',
    'Krishi Bhawan, New Delhi - 110001',
    ARRAY['Consumer Grievance Registration', 'Mediation with Registered Companies', 'National Consumer Commission E-Daakhil Guidance']
),
(
    'National Cyber Crime Reporting Portal (I4C - MHA)',
    'specialized',
    'All India',
    NULL,
    'Victims of financial fraud, cyber stalking, identity theft, phishing, extortion, and cyber crimes under IT Act 2000.',
    '+91-11-23438207',
    '1930',
    'cybercrime-support@mha.gov.in',
    'https://cybercrime.gov.in',
    'Indian Cyber Crime Coordination Centre (I4C), CIS Division, MHA, New Delhi',
    ARRAY['Financial Fraud Immediate Freezing (Helpline 1930)', 'FIR Facilitation', 'Online Cyber Complaint Filing']
)
ON CONFLICT DO NOTHING;

