// Flutter / Dart Service Layer for Legal Helper Supabase Backend
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class LegalHelperFlutterApi {
  static final SupabaseClient _client = Supabase.instance.client;

  // -------------------------------------------------------------
  // 1. AUTHENTICATION
  // -------------------------------------------------------------
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String preferredLanguage = 'en',
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'preferred_language': preferredLanguage,
      },
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'legalhelper://auth-callback/reset-password',
    );
  }

  static User? get currentUser => _client.auth.currentUser;

  static Future<UserProfile?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return UserProfile.fromJson(data);
  }

  // -------------------------------------------------------------
  // 2. LEGAL AI ADVISOR
  // -------------------------------------------------------------
  static Future<Map<String, dynamic>> sendAdvisorMessage({
    required String message,
    String? sessionId,
    String language = 'en',
  }) async {
    final response = await _client.functions.invoke(
      'legal-advisor',
      body: {
        'message': message,
        'session_id': sessionId,
        'language': language,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  static Future<List<ChatSessionModel>> getChatSessions() async {
    final data = await _client
        .from('chat_sessions')
        .select()
        .order('updated_at', ascending: false);

    return (data as List).map((e) => ChatSessionModel.fromJson(e)).toList();
  }

  static Future<List<ChatMessageModel>> getChatMessages(String sessionId) async {
    final data = await _client
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);

    return (data as List).map((e) => ChatMessageModel.fromJson(e)).toList();
  }

  // -------------------------------------------------------------
  // 3. LEGAL RESEARCH
  // -------------------------------------------------------------
  static Future<Map<String, dynamic>> searchLegalTopic({
    required String query,
    String jurisdiction = 'IN',
  }) async {
    final response = await _client.functions.invoke(
      'legal-research',
      body: {
        'query': query,
        'jurisdiction': jurisdiction,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  // -------------------------------------------------------------
  // 4. DOCUMENT SIMPLIFICATION & VAULT
  // -------------------------------------------------------------
  static Future<LegalDocumentModel> uploadDocument({
    required Uint8List fileBytes,
    required String filename,
    required String title,
    String documentType = 'contract',
    String mimeType = 'application/pdf',
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Unauthenticated');

    final safeFilename = filename.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$safeFilename';

    // 1. Upload bytes to private storage
    await _client.storage.from('legal-documents').uploadBinary(
          storagePath,
          fileBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    // 2. Register document via document-processing Edge Function
    final response = await _client.functions.invoke(
      'document-processing',
      body: {
        'action': 'register',
        'title': title,
        'original_filename': filename,
        'storage_path': storagePath,
        'bucket_id': 'legal-documents',
        'mime_type': mimeType,
        'document_type': documentType,
      },
    );

    final resData = response.data as Map<String, dynamic>;
    return LegalDocumentModel.fromJson(resData['data']['document']);
  }

  static Future<Map<String, dynamic>> simplifyDocument(String documentId) async {
    final response = await _client.functions.invoke(
      'document-simplifier',
      body: {'document_id': documentId},
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<String> getDocumentSignedUrl(String documentId, {int expiresInSeconds = 900}) async {
    final response = await _client.functions.invoke(
      'document-processing',
      body: {
        'action': 'get_signed_url',
        'document_id': documentId,
        'expires_in': expiresInSeconds,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data']['signed_url'] as String;
  }

  // -------------------------------------------------------------
  // 5. DRAFTING ASSISTANT & NOTICE REPLY
  // -------------------------------------------------------------
  static Future<Map<String, dynamic>> generateDraft({
    required String draftType,
    required String title,
    required Map<String, dynamic> inputData,
  }) async {
    final response = await _client.functions.invoke(
      'drafting-assistant',
      body: {
        'action': 'generate',
        'draft_type': draftType,
        'title': title,
        'input_data': inputData,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> generateNoticeReply({
    required String noticeText,
    String? userFacts,
    String strategy = 'factual_clarification',
    String? title,
  }) async {
    final response = await _client.functions.invoke(
      'notice-reply',
      body: {
        'notice_text': noticeText,
        'user_facts': userFacts,
        'strategy': strategy,
        'title': title,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // -------------------------------------------------------------
  // 6. SCAM DETECTOR
  // -------------------------------------------------------------
  static Future<ScamDetectionModel> scanForScam({
    String? content,
    String? url,
    String sourceChannel = 'message',
  }) async {
    final response = await _client.functions.invoke(
      'scam-detector',
      body: {
        'content': content,
        'url': url,
        'source_channel': sourceChannel,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return ScamDetectionModel.fromJson(data['data']);
  }

  // -------------------------------------------------------------
  // 7. EVIDENCE & LAWYER PREPARATION
  // -------------------------------------------------------------
  static Future<Map<String, dynamic>> generateLawyerPrepDossier({
    required String title,
    required String caseType,
    required String factsSummary,
    String? notes,
  }) async {
    final response = await _client.functions.invoke(
      'lawyer-prep',
      body: {
        'action': 'generate_dossier',
        'title': title,
        'case_type': caseType,
        'facts_summary': factsSummary,
        'notes': notes,
        'include_evidence_timeline': true,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getLegalAidDirectory({String? state, String? district}) async {
    final response = await _client.functions.invoke(
      'lawyer-prep',
      body: {
        'action': 'get_legal_aid',
        'state': state,
        'district': district,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['data']['legal_aid_authorities'] as List<dynamic>;
  }
}

