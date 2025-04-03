import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config.dart';

class WebViewService {
  late final WebViewController controller;
  Function(String?)? onLoginCallback;

  Future<void> initWebView(
    String url,
    String token,
    String accessToken, {
    Function(String?)? onLogin,
  }) async {
    onLoginCallback = onLogin;
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                _injectTokens(token, accessToken);
                _setupLogoutObserver();
              },
              onWebResourceError: (WebResourceError error) {
                print('WebView error: ${error.description}');
              },
            ),
          )
          ..addJavaScriptChannel(
            'Login',
            onMessageReceived: (JavaScriptMessage message) {
              if (onLoginCallback != null) {
                onLoginCallback!(message.message);
              }
            },
          )
          ..addJavaScriptChannel(
            'FlutterApp',
            onMessageReceived: (JavaScriptMessage message) {
              if (message.message == 'logout') {
                logout();
              }
            },
          )
          ..loadRequest(Uri.parse(url));
  }

  Future<void> _setupLogoutObserver() async {
    try {
      await controller.runJavaScript('''
        (function() {
          function setupLogoutListener(button) {
            if (button && !button.hasAttribute('flutter-logout-attached')) {
              button.setAttribute('flutter-logout-attached', 'true');
              button.addEventListener('click', function() {
                FlutterApp.postMessage('logout');
              });
              console.log('Logout listener attached');
            }
          }

          // Initial check for the logout button
          let logoutButton = document.querySelector('[data-testid="logout-button"]') || 
                           document.querySelector('button[aria-label="Logout"]') ||
                           Array.from(document.querySelectorAll('button')).find(btn => 
                             btn.textContent.toLowerCase().includes('logout') || 
                             btn.textContent.toLowerCase().includes('sign out')
                           );
          
          if (logoutButton) {
            setupLogoutListener(logoutButton);
          }

          // Watch for future logout button additions
          const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
              mutation.addedNodes.forEach(function(node) {
                if (node.nodeType === 1) { // Element node
                  const button = node.matches('[data-testid="logout-button"], button[aria-label="Logout"]') 
                    ? node 
                    : node.querySelector('[data-testid="logout-button"], button[aria-label="Logout"]');
                  
                  if (button) {
                    setupLogoutListener(button);
                  }
                }
              });
            });
          });

          observer.observe(document.body, {
            childList: true,
            subtree: true
          });
        })();
      ''');
      print('Logout observer setup complete');
    } catch (e) {
      print('Error setting up logout observer: $e');
    }
  }

  Future<void> _injectTokens(String token, String accessToken) async {
    print('Injecting tokens');
    final script = AppConfig.tokenInjectScript
        .replaceAll('{TOKEN}', token)
        .replaceAll('{ACCESS_TOKEN}', accessToken);
    try {
      await controller.runJavaScript(script);
      print('Tokens injected successfully');
    } catch (e) {
      print('Error injecting tokens: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Clear tokens from localStorage and notify web app
      await controller.runJavaScript('''
        (function() {
          try {
            localStorage.removeItem('authToken');
            localStorage.removeItem('googleAccessToken');
            window.dispatchEvent(new CustomEvent('authTokenUpdated', { 
              detail: { token: null, accessToken: null }
            }));
            console.log('Tokens cleared successfully');
          } catch (error) {
            console.error('Logout error:', error);
          }
        })();
      ''');

      // Notify Flutter app
      if (onLoginCallback != null) {
        onLoginCallback!(null);
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> reload() async {
    await controller.reload();
  }

  Future<void> clearCache() async {
    await controller.clearCache();
    await controller.clearLocalStorage();
  }
}
