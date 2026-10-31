# Legal Helper Backend - API Contracts Specification

This document provides the standardized API contracts for all Supabase Edge Functions in the Legal Helper backend.

All Edge Functions accept **JSON** payloads over **HTTPS POST**, require a valid Supabase user JWT in the `Authorization: Bearer <token>` header, and return uniform JSON responses.

---

## 1. Global Response Standards

### Success Response Format (HTTP 200 / 201)
```json
{
  "success": true,
  "data": { ... },
  "error": null
}
```

### Error Response Format (HTTP 400 / 401 / 403 / 404 / 429 / 500)
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "ERROR_CODE_STRING",
    "message": "Human-readable description of error",
    "details": null
  }
}
```

### Standard Error Codes
| HTTP Status | Error Code | Description |
| :--- | :--- | :--- |
| `401` | `UNAUTHORIZED` | Missing, malformed, or expired Bearer token |
| `403` | `FORBIDDEN` | Requesting a resource owned by another user |
| `400` | `INVALID_INPUT` | Missing required fields, schema validation failure |
| `404` | `NOT_FOUND` | Referenced entity (session, document, draft) does not exist |
| `429` | `RATE_LIMIT_EXCEEDED` | Exceeded per-minute quota for AI operations |
| `500` | `INTERNAL_ERROR` | Upstream AI provider failure or unhandled exception |

---

## 2. Edge Function Contracts

### 2.1 Legal AI Advisor (`legal-advisor`)
*Endpoint:* `POST /functions/v1/legal-advisor`  
*Rate Limit:* 30 requests / minute per user

#### Request Body
```json
{
  "message": "Can a landlord deduct my security deposit without showing repair bills in Bangalore?",
  "session_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d", // Optional. If omitted, a new session is created.
  "language": "en" // "en" | "hi"
}
```

#### Response Body (200 OK)
```json
{
  "success": true,
  "data": {
    "session_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "user_message_id": "e3b0c442-98fc-1c14-9afb-4c8996fb9242",
    "assistant_message_id": "f4c1d553-09ad-2d25-0bec-5d9aa70ca353",
    "response": "Under the Karnataka Rent Control Act and the Model Tenancy Act principles, security deposits are held in trust and deductions require itemized invoices demonstrating genuine damage beyond normal wear and tear...",
    "disclaimer": "DISCLAIMER: Legal Helper is an AI-assisted legal information platform. The information provided is for general educational and informational purposes only...",
    "language": "en",
    "provider": "google-gemini",
    "model": "gemini-1.5-flash"
  },
  "error": null
}
```

---

### 2.2 Legal Research (`legal-research`)
*Endpoint:* `POST /functions/v1/legal-research`  
*Rate Limit:* 20 requests / minute per user

#### Request Body
```json
{
  "query": "Limitation period for dishonour of cheque under Section 138 of Negotiable Instruments Act",
  "jurisdiction": "IN"
}
```

#### Response Body (200 OK)
```json
{
  "success": true,
  "data": {
    "research_id": "1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed",
    "query": "Limitation period for dishonour of cheque under Section 138 of Negotiable Instruments Act",
    "jurisdiction": "IN",
    "summary": "Under Section 138 read with Section 142 of the Negotiable Instruments Act, 1881, the legal notice must be issued within 30 days of receiving the memo of dishonour...",
    "statutory_provisions": [
      {
        "act": "Negotiable Instruments Act, 1881",
        "section": "Section 138",
        "title": "Dishonour of cheque for insufficiency of funds",
        "explanation": "Makes dishonour of cheque a criminal offence punishable with imprisonment up to 2 years or fine up to twice the cheque amount."
      },
      {
        "act": "Negotiable Instruments Act, 1881",
        "section": "Section 142",
        "title": "Cognizance of Offences",
        "explanation": "Requires complaint to be filed before Judicial Magistrate within 1 month from cause of action arising."
      }
    ],
    "landmark_precedents": [
      {
        "case_name": "Dashrath Rupsingh Rathod v. State of Maharashtra",
        "court": "Supreme Court of India",
        "year": "2014",
        "principle": "Territorial jurisdiction lies with the court where payee bank branch is situated (codified by 2015 amendment)."
      }
    ],
    "procedural_remedies": [
      "Obtain original cheque return memo from bank.",
      "Send formal statutory demand notice via Registered Post AD within 30 days.",
      "Wait 15 days for payment.",
      "File criminal complaint under Section 138 within 30 days of the 15-day expiry."
    ],
    "official_sources": [
      {
        "title": "India Code - Negotiable Instruments Act, 1881",
        "url": "https://www.indiacode.nic.in"
      }
    ],
    "disclaimer": "DISCLAIMER: Legal Helper is an AI-assisted legal information platform..."
  },
  "error": null
}
```

---

### 2.3 Document Simplifier (`document-simplifier`)
*Endpoint:* `POST /functions/v1/document-simplifier`  
*Rate Limit:* 15 requests / minute per user

#### Request Body (Option A: Using Vault Document ID)
```json
{
  "document_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7"
}
```

#### Request Body (Option B: Direct Raw Text)
```json
{
  "title": "Vendor Non-Disclosure Agreement",
  "raw_text": "The Receiving Party agrees to indemnify the Disclosing Party against any and all claims without cap or limitation...",
  "document_type": "contract"
}
```

#### Response Body (200 OK)
```json
{
  "success": true,
  "data": {
    "document_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
    "result_id": "3d4f5e6a-7b8c-9d0e-1f2a-3b4c5d6e7f8a",
    "title": "Vendor Non-Disclosure Agreement",
    "summary_en": "This agreement binds the vendor to strict confidentiality regarding trade secrets, customer databases, and pricing...",
    "summary_hi": "यह अनुबंध विक्रेता को व्यापार रहस्यों, ग्राहक सूचियों और मूल्य निर्धारण से संबंधित जानकारी को गोपनीय रखने के लिए बाध्य करता है...",
    "key_obligations": [
      {
        "party": "Vendor (Receiving Party)",
        "obligation": "Maintain confidentiality of proprietary code and technical blueprints",
        "timeline": "For 3 years following termination of services"
      }
    ],
    "important_clauses": [
      {
        "clause_title": "Indemnity without limitation",
        "original_context": "Party agrees to indemnify against any and all claims without cap...",
        "plain_meaning": "You could be forced to pay unlimited damages for any breach, even if caused by minor negligence."
      }
    ],
    "risk_notes": [
      {
        "risk_level": "HIGH",
        "issue": "Uncapped indemnity liability",
        "explanation": "No monetary ceiling exists, leaving you exposed to catastrophic claims.",
        "recommendation": "Request a liability cap equal to total fees paid under the contract in the preceding 12 months."
      }
    ],
    "disclaimer": "DISCLAIMER: Legal Helper is an AI-assisted legal information platform..."
  },
  "error": null
}
```

---

### 2.4 Drafting Assistant (`drafting-assistant`)
*Endpoint:* `POST /functions/v1/drafting-assistant`  
*Rate Limit:* 20 requests / minute per user

#### Request Body (Action: `generate`)
```json
{
  "action": "generate",
  "draft_type": "legal_notice", // "legal_notice" | "complaint_consumer" | "complaint_cyber" | "rti_application" | "rent_agreement" | "formal_application"
  "title": "Demand Notice for Unpaid Professional Dues",
  "input_data": {
    "sender_name": "Rohan Sharma",
    "sender_address": "Indiranagar, Bangalore - 560038",
    "recipient_name": "Apex Digital Pvt Ltd",
    "recipient_address": "Whitefield, Bangalore - 560066",
    "principal_amount": "₹1,50,000",
    "due_date": "15th January 2026",
    "invoice_number": "INV-2025-089",
    "cure_period_days": 15
  }
}
```

#### Response Body (200 OK)
```json
{
  "success": true,
  "data": {
    "draft_id": "4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d",
    "title": "Demand Notice for Unpaid Professional Dues",
    "draft_type": "legal_notice",
    "generated_content": "# LEGAL NOTICE\n\nTo,\nApex Digital Pvt Ltd...\n\nUnder instructions from my client, Mr. Rohan Sharma...\n\n1. That my client rendered professional software engineering services...\n2. That invoice INV-2025-089 for principal sum of ₹1,50,000 remains unpaid...\n\nTHEREFORE, TAKE NOTICE that you are called upon to remit the sum of ₹1,50,000 along with 18% p.a. interest within 15 days...",
    "status": "draft",
    "disclaimer": "DISCLAIMER: Legal Helper is an AI-assisted legal information platform...",
    "created_at": "2026-10-31T12:00:00Z"
  },
  "error": null
}
```

---

### 2.5 Notice Reply (`notice-reply`)
*Endpoint:* `POST /functions/v1/notice-reply`  
*Rate Limit:* 15 requests / minute per user

#### Request Body
```json
{
  "title": "Reply to Alleged Breach of Contract Notice",
  "notice_text": "We hereby notify you that you have failed to deliver Project Alpha by milestone 2 and we demand forfeit of security deposit...",
  "user_facts": "The delay was caused because the client failed to provide server credentials and API access for 45 days despite repeated emails on Jan 5 and Jan 18.",
  "strategy": "counter_claim" // "deny_all" | "settlement_offer" | "factual_clarification" | "counter_claim"
}
```

#### Response Body (200 OK)
```json
{
  "success": true,
  "data": {
    "draft_id": "7f8e9d0c-1b2a-3c4d-5e6f-7a8b9c0d1e2f",
    "title": "Reply to Alleged Breach of Contract Notice",
    "allegations_identified": [
      "Failure to deliver Project Alpha by Milestone 2",
      "Demand to forfeit security deposit"
    ],
    "sender_demands": [
      "Forfeiture of security deposit",
      "Termination of service contract"
    ],
    "limitation_or_deadline": "Immediate compliance demanded",
    "missing_context_questions": [
      "Do you have email delivery receipts proving server credentials were requested on Jan 5?",
      "Was there a formal written amendment modifying the delivery timeline?"
    ],
    "defense_strategy_summary": "Invoke doctrine of prevention (Contract Act Section 67) where performance was hindered by the promisee's own failure to provide access.",
    "draft_reply_text": "# REPLY TO LEGAL NOTICE\n\nWITHOUT PREJUDICE\n\nTo,\n[Counsel / Sender Name]...\n\nUnder instructions from my client...\n\n1. Each and every allegation, contention, and insinuation is denied in toto...\n2. The delay, if any, is attributable solely to your client's deliberate omission in supplying essential API credentials...",
    "disclaimer": "DISCLAIMER: Legal Helper is an AI-assisted legal information platform..."
  },
  "error": null
}
```

---

### 2.6 Scam Detector (`scam-detector`)
*Endpoint:* `POST /functions/v1/scam-detector`  
*Rate Limit:* 25 requests / minute per user

#### Request Body
```json
{
  "content": "URGENT: This is Inspector Sharma from CBI Cyber Cell. An illegal package in your name was seized at Mumbai airport containing narcotics. A digital arrest order has been issued. Join Skype call immediately or police will raid your address within 2 hours.",
  "url": "https://mumbaipolice-digital-verification.xyz/fine-pay",
  "source_channel": "whatsapp" // "whatsapp" | "sms" | "email" | "phone_call" | "letter"
}
```

#### Response Body (200 OK)
```json
{
  "success": true,
  "data": {
    "risk_score": 98,
    "risk_level": "CRITICAL",
    "scam_type": "Digital Arrest Impersonation",
    "is_scam_likely": true,
    "suspicious_indicators": [
      "Indian law and police procedures contain NO concept of 'Digital Arrest' via video calls.",
      "Law enforcement agencies never ask citizens to pay fines or transfer money to 'verification accounts'.",
      "URL Warning: Domain uses high-risk top-level domain (.xyz) and deceives using 'mumbaipolice' keyword on an unofficial server.",
      "High psychological pressure with artificial 2-hour deadline."
    ],
    "detailed_analysis": "This matches the widely documented 'Digital Arrest' cyber extortion fraud investigated by the Indian Cyber Crime Coordination Centre (I4C). Fraudsters impersonate law enforcement officers on video calls using forged logos and background sets to extort money into mule bank accounts.",
    "recommended_actions": [
      "IMMEDIATE ACTION: Dial 1930 (Citizen Financial Cyber Fraud Reporting System) or visit https://cybercrime.gov.in",
      "Do NOT pay any money, share OTP, bank account numbers, or Aadhaar details.",
      "Immediately disconnect the video call and block the caller on WhatsApp.",
      "Report the telephone number on Chakshu portal (sancharsaathi.gov.in)."
    ],
    "url_heuristics": {
      "url": "https://mumbaipolice-digital-verification.xyz/fine-pay",
      "is_suspicious_url": true,
      "warnings": [
        "URL uses a high-abuse top-level domain (.xyz).",
        "Domain contains authority keyword 'police' on an unofficial non-government domain."
      ]
    },
    "emergency_helplines": {
      "cyber_crime": "1930",
      "cyber_portal": "https://cybercrime.gov.in",
      "national_consumer_helpline": "1915"
    },
    "disclaimer": "This automated risk assessment is based on identifiable threat indicators. Absence of warnings does not guarantee safety."
  },
  "error": null
}
```

---

### 2.7 Document Processing & Signed URLs (`document-processing`)
*Endpoint:* `POST /functions/v1/document-processing`

#### Action: `register` (Post-Upload Integrity Hash & DB Record)
```json
{
  "action": "register",
  "title": "Residential Tenancy Agreement",
  "original_filename": "rent_agreement_2026.pdf",
  "storage_path": "00000000-0000-0000-0000-000000000001/1730000000000_rent_agreement.pdf",
  "bucket_id": "legal-documents",
  "mime_type": "application/pdf",
  "document_type": "lease_agreement"
}
```

#### Response Body (200 OK)
```json
{
  "success": true,
  "data": {
    "document": {
      "id": "e2f1a0b3-4c5d-6e7f-8a9b-0c1d2e3f4a5b",
      "title": "Residential Tenancy Agreement",
      "file_hash": "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e",
      "file_size": 245760,
      "processing_status": "pending"
    },
    "integrity_hash": "a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e",
    "verified_size": 245760
  },
  "error": null
}
```

#### Action: `get_signed_url` (Secure Download Link)
```json
{
  "action": "get_signed_url",
  "document_id": "e2f1a0b3-4c5d-6e7f-8a9b-0c1d2e3f4a5b",
  "expires_in": 900 // seconds (default: 15 min, max: 3600)
}
```

#### Response Body (200 OK)
```json
{
  "success": true,
  "data": {
    "signed_url": "https://your-project.supabase.co/storage/v1/object/sign/legal-documents/000.../file.pdf?token=eyJhbG...",
    "expires_in_seconds": 900,
    "expires_at": "2026-10-31T12:15:00.000Z"
  },
  "error": null
}
```

---

### 2.8 Lawyer Preparation & Legal Aid (`lawyer-prep`)
*Endpoint:* `POST /functions/v1/lawyer-prep`

#### Action: `generate_dossier`
```json
{
  "action": "generate_dossier",
  "title": "Builder Delay in Flat Possession Consultation",
  "case_type": "Real Estate / Consumer",
  "facts_summary": "Booked flat with XYZ Developers in July 2021. Agreement promised possession by December 2023 with 6-month grace period. As of October 2026, project structure is incomplete. Paid ₹45 Lakhs (85% of total cost). Builder offering only ₹5,000/month delay compensation.",
  "include_evidence_timeline": true,
  "notes": "Want to know if RERA complaint is faster than NCDRC Consumer Commission."
}
```

#### Response Body (200 OK)
```json
{
  "success": true,
  "data": {
    "preparation_id": "9c8b7a6f-5e4d-3c2b-1a0f-9e8d7c6b5a4f",
    "title": "Builder Delay in Flat Possession Consultation",
    "case_type": "Real Estate / Consumer",
    "executive_summary": "Grievance against XYZ Developers regarding a 2.5-year delay in delivering flat possession despite 85% payment disbursement...",
    "timeline_events": [
      {
        "date": "July 2021",
        "event": "Execution of Builder-Buyer Agreement; payment of initial booking amount",
        "supporting_evidence": "Signed Allotment Letter & Agreement"
      },
      {
        "date": "June 2024",
        "event": "Expiration of promised possession date and 6-month grace period",
        "supporting_evidence": "Clause 14 of Agreement"
      }
    ],
    "questions_for_lawyer": [
      "Whether filing under Section 18 of RERA (Karnataka/Maharashtra RERA) for refund with interest or approaching the Consumer Commission under CPA 2019 offers faster execution?",
      "Can we obtain an interim injunction restraining the builder from creating third-party rights on unsold inventory?",
      "What is the prevailing interest rate awarded by High Courts for commercial possession delays (typically SBI MCLR + 2%)?"
    ],
    "checklist": [
      {
        "item": "Original Builder-Buyer Agreement",
        "importance": "Mandatory",
        "purpose": "To verify possession clause, penalty provisions, and arbitration agreements."
      },
      {
        "item": "All Bank Account Statements and Payment Receipts",
        "importance": "Mandatory",
        "purpose": "To quantify the exact principal amount disbursed."
      }
    ],
    "potential_relief_sought": [
      "Immediate refund of ₹45,00,000 along with interest under RERA Section 18",
      "Compensation for mental agony and litigation expenses"
    ],
    "disclaimer": "DISCLAIMER: Legal Helper is an AI-assisted legal information platform..."
  },
  "error": null
}
```

#### Action: `get_legal_aid`
```json
{
  "action": "get_legal_aid",
  "state": "Delhi"
}
```

#### Response Body (200 OK)
```json
{
  "success": true,
  "data": {
    "legal_aid_authorities": [
      {
        "organization_name": "National Legal Services Authority (NALSA)",
        "authority_level": "national",
        "jurisdiction_state": "All India",
        "eligibility_criteria": "Section 12 of Legal Services Authorities Act, 1987...",
        "helpline_number": "15100",
        "website_url": "https://nalsa.gov.in"
      },
      {
        "organization_name": "Delhi State Legal Services Authority (DSLSA)",
        "authority_level": "state",
        "jurisdiction_state": "Delhi",
        "district": "All Districts",
        "helpline_number": "1516",
        "website_url": "https://dslsa.org"
      }
    ],
    "statutory_basis": "Section 12 of the Legal Services Authorities Act, 1987",
    "national_helplines": [
      { "service": "NALSA Free Legal Aid Helpline", "number": "15100" },
      { "service": "Tele-Law Portal Assistance", "number": "14430" },
      { "service": "National Consumer Helpline", "number": "1915" },
      { "service": "National Cyber Fraud Helpline", "number": "1930" }
    ]
  },
  "error": null
}
```

