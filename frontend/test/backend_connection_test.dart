import 'package:flutter_test/flutter_test.dart';
import 'package:legal_helper/core/models/backend_models.dart';
import 'package:legal_helper/core/services/legal_api_service.dart';
import 'package:legal_helper/features/saved/models/saved_item.dart';

void main() {
  group('Backend Models & Contract Serialization Tests', () {
    test('UserProfile parses from Supabase profiles table JSON', () {
      final json = {
        'id': 'u-1234-uuid',
        'full_name': 'Advocate Sharma',
        'email': 'sharma@example.com',
        'avatar_url': 'https://example.com/avatar.png',
        'preferred_language': 'en',
        'phone_number': '+919876543210',
        'created_at': '2026-10-31T12:00:00Z',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, 'u-1234-uuid');
      expect(profile.fullName, 'Advocate Sharma');
      expect(profile.email, 'sharma@example.com');
      expect(profile.preferredLanguage, 'en');
      expect(profile.createdAt, isA<DateTime>());
    });

    test('ChatSessionModel and ChatMessageModel parse properly', () {
      final sessionJson = {
        'id': 'sess-1',
        'user_id': 'u-1234',
        'title': 'Tenant Dispute Consultation',
        'created_at': '2026-10-31T12:00:00Z',
        'updated_at': '2026-10-31T12:05:00Z',
      };

      final session = ChatSessionModel.fromJson(sessionJson);
      expect(session.id, 'sess-1');
      expect(session.title, 'Tenant Dispute Consultation');

      final messageJson = {
        'id': 'msg-1',
        'session_id': 'sess-1',
        'role': 'assistant',
        'content': 'A 15-day notice is required before initiating proceedings.',
        'created_at': '2026-10-31T12:01:00Z',
      };

      final message = ChatMessageModel.fromJson(messageJson);
      expect(message.id, 'msg-1');
      expect(message.isUser, isFalse);
      expect(message.content, contains('15-day notice'));
    });

    test('ScamDetectionModel decodes correctly with risk metrics', () {
      final scamJson = {
        'risk_score': 85,
        'risk_level': 'HIGH',
        'scam_type': 'Phishing / Impersonation',
        'is_scam_likely': true,
        'suspicious_indicators': ['Unverified payment request', 'Urgency trigger'],
        'detailed_analysis': 'High probability of malicious intent.',
        'recommended_actions': ['Cease contact immediately', 'Report to cyber crime portal'],
      };

      final model = ScamDetectionModel.fromJson(scamJson);
      expect(model.riskScore, 85);
      expect(model.riskLevel, 'HIGH');
      expect(model.isScamLikely, isTrue);
      expect(model.suspiciousIndicators.length, 2);
    });

    test('SavedItem converts bi-directionally with Supabase saved_items schema', () {
      final item = SavedItem(
        id: 'saved-99',
        title: 'Non-Disclosure Agreement',
        subtitle: 'Bilateral trade secret protection draft',
        content: 'Confidential information shall be preserved for 3 years.',
        type: SavedItemType.draft,
        createdAt: DateTime.parse('2026-10-31T12:00:00Z'),
      );

      final supabasePayload = item.toSupabaseJson('test-user-id');
      expect(supabasePayload['user_id'], 'test-user-id');
      expect(supabasePayload['item_type'], 'draft');
      expect(supabasePayload['title'], 'Non-Disclosure Agreement');
      expect(supabasePayload['metadata'], isA<Map>());

      // Deserializing Supabase row format
      final reconstructed = SavedItem.fromJson(supabasePayload);
      expect(reconstructed.id, 'saved-99');
      expect(reconstructed.title, 'Non-Disclosure Agreement');
      expect(reconstructed.type, SavedItemType.draft);
      expect(reconstructed.content, 'Confidential information shall be preserved for 3 years.');
    });
  });

  group('LegalApiService Integration Endpoints & Offline Fallbacks', () {
    test('LegalAdvisor endpoint returns actionable legal response', () async {
      final res = await LegalApiService.sendAdvisorMessage(
        message: 'How to handle an unlawful rent eviction?',
      );
      expect(res, isNotEmpty);
      final reply = (res['message'] ?? res['reply'])?.toString() ?? '';
      expect(reply.toLowerCase(), anyOf(contains('notice'), contains('rent'), contains('tenancy')));
    });

    test('LegalResearch endpoint returns statutory citations and precedents', () async {
      final res = await LegalApiService.searchLegalResearch(
        query: 'cheque bounce notice requirements',
      );
      expect(res, isNotEmpty);
      final precedents = (res['precedents'] ?? res['results']) as List<dynamic>;
      expect(precedents, isNotEmpty);
      expect(precedents.first['citation'], isNotEmpty);
    });

    test('DraftingAssistant generates full legal agreement text', () async {
      final draft = await LegalApiService.generateDraft(
        draftType: 'lease_agreement',
        title: 'Residential Lease',
        inputData: {
          'landlord_name': 'Arjun Mehta',
          'tenant_name': 'Pooja Verma',
          'rent_amount': '25000',
        },
      );

      expect(draft['title'], 'Residential Lease');
      expect(draft['generated_content'], isNotNull);
      expect(draft['generated_content'].toString(), contains('Arjun Mehta'));
      expect(draft['generated_content'].toString(), contains('Pooja Verma'));
    });

    test('NoticeReply generates legal defense rebuttal', () async {
      final reply = await LegalApiService.generateNoticeReply(
        noticeText: 'You are hereby directed to pay Rs 50,000 within 48 hours.',
        userFacts: 'All invoice amounts were already paid on 15th October via NEFT.',
        strategy: 'factual_clarification',
      );

      expect(reply['generated_reply'], isNotNull);
      expect(reply['generated_reply'].toString(), anyOf(contains('REPLY TO LEGAL NOTICE'), contains('REPLY TO STATUTORY LEGAL NOTICE')));
      expect(reply['notice_analysis'], isNotNull);
    });

    test('ScamDetector detects critical indicators in fraudulent messages', () async {
      final scamReport = await LegalApiService.scanForScam(
        content: 'URGENT: Your arrest warrant is issued. Pay 20,000 crypto immediately or police will arrive!',
      );

      expect(scamReport.isScamLikely, isTrue);
      expect(scamReport.riskScore, greaterThan(70));
      expect(scamReport.suspiciousIndicators, isNotEmpty);
    });

    test('LawyerPrep generates comprehensive case dossier and legal aid directory', () async {
      final dossier = await LegalApiService.generateLawyerPrepDossier(
        title: 'Property boundary dispute',
        caseType: 'Civil Litigation',
        factsSummary: 'Neighbor extended wall beyond registered plot demarcations.',
      );

      expect(dossier['dossier'], isNotNull);
      expect(dossier['dossier']['suggested_questions'], isNotEmpty);

      final legalAid = await LegalApiService.getLegalAidDirectory();
      expect(legalAid, isNotEmpty);
      expect(legalAid.first['title'], contains('NALSA'));
    });

    test('DocumentSimplifier processes plain English summary and risk notes', () async {
      final simplified = await LegalApiService.simplifyDocument(
        rawText: 'The tenant shall forfeit entire deposit upon giving less than 90 days notice.',
        title: 'Rental Clause',
        mode: 'riskHighlights',
      );

      expect(simplified['summary_en'], isNotNull);
      expect(simplified['important_clauses'], isNotNull);
      expect(simplified['risk_notes'], isNotNull);
    });
  });
}
