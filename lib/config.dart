import 'env.dart';

class AppConfig {
  // Target web app URL
  static String get webAppUrl => Env.webAppUrl;

  // Firebase config
  static const bool enableFirebaseLogging = true;

  // WebView config
  static const Duration webviewCacheMaxAge = Duration(days: 7);
  static const String tokenStorageKey = 'authToken';
  static const String tokenInjectScript = '''
    (async function() {
      try {
        // Store Firebase token and Google access token in localStorage
        localStorage.setItem('authToken', '{TOKEN}');
        localStorage.setItem('googleAccessToken', '{ACCESS_TOKEN}');
        
        // Wait for page to load fully
        if (document.readyState !== 'complete') {
          await new Promise(resolve => window.addEventListener('load', resolve));
        }

        // Let web app handle Firebase auth with provided tokens
        window.dispatchEvent(new CustomEvent('authTokenUpdated', { 
          detail: { 
            token: '{TOKEN}',
            accessToken: '{ACCESS_TOKEN}'
          }
        }));
        console.log('Tokens injected successfully');
      } catch (error) {
        console.error('Token injection error:', error);
      }
    })();
  ''';
}
