// Strongly typed data models representing PostgreSQL tables & Edge Function contracts
// defined in the Legal Helper backend.

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String preferredLanguage;
  final String? phoneNumber;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.preferredLanguage,
    this.phoneNumber,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      phoneNumber: json['phone_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'preferred_language': preferredLanguage,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ChatSessionModel {
  final String id;
  final String title;
  final String language;
  final DateTime updatedAt;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.language,
    required this.updatedAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      language: json['language'] as String? ?? 'en',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class ChatMessageModel {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  bool get isUser => role == 'user';

  ChatMessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.metadata,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class LegalDocumentModel {
  final String id;
  final String title;
  final String originalFilename;
  final String storagePath;
  final String bucketId;
  final String mimeType;
  final int fileSize;
  final String? fileHash;
  final String documentType;
  final String processingStatus;
  final DateTime createdAt;

  LegalDocumentModel({
    required this.id,
    required this.title,
    required this.originalFilename,
    required this.storagePath,
    required this.bucketId,
    required this.mimeType,
    required this.fileSize,
    this.fileHash,
    required this.documentType,
    required this.processingStatus,
    required this.createdAt,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      originalFilename: json['original_filename'] as String,
      storagePath: json['storage_path'] as String,
      bucketId: json['bucket_id'] as String? ?? 'legal-documents',
      mimeType: json['mime_type'] as String,
      fileSize: (json['file_size'] as num).toInt(),
      fileHash: json['file_hash'] as String?,
      documentType: json['document_type'] as String? ?? 'contract',
      processingStatus: json['processing_status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ScamDetectionModel {
  final int riskScore;
  final String riskLevel;
  final String scamType;
  final bool isScamLikely;
  final List<String> suspiciousIndicators;
  final String detailedAnalysis;
  final List<String> recommendedActions;

  ScamDetectionModel({
    required this.riskScore,
    required this.riskLevel,
    required this.scamType,
    required this.isScamLikely,
    required this.suspiciousIndicators,
    required this.detailedAnalysis,
    required this.recommendedActions,
  });

  factory ScamDetectionModel.fromJson(Map<String, dynamic> json) {
    return ScamDetectionModel(
      riskScore: (json['risk_score'] as num?)?.toInt() ?? 0,
      riskLevel: json['risk_level'] as String? ?? 'LOW',
      scamType: json['scam_type'] as String? ?? 'None',
      isScamLikely: json['is_scam_likely'] as bool? ?? false,
      suspiciousIndicators: (json['suspicious_indicators'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      detailedAnalysis: json['detailed_analysis'] as String? ?? '',
      recommendedActions: (json['recommended_actions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

