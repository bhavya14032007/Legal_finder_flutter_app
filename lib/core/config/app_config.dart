/// Global Application Configuration
class AppConfig {
  AppConfig._();

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  // Maximum upload size for documents (15 MB)
  static const int maxUploadSizeBytes = 15 * 1024 * 1024;

  // Supported file extensions
  static const List<String> supportedDocumentExtensions = [
    'pdf',
    'docx',
    'doc',
    'txt',
    'png',
    'jpg',
    'jpeg',
  ];
}
