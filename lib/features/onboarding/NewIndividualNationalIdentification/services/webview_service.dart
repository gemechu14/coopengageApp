import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Service to handle WebView creation and management
class WebViewService {
  static const String _userAgent = 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';
  
  /// Creates a configured WebView controller
  static WebViewController createController({
    required String url,
    required Function(String) onNavigationRequest,
    required VoidCallback onPageStarted,
    required VoidCallback onPageFinished,
    required Function(String) onWebResourceError,
    Function(String, String)? onCallbackDetected,
  }) {
    late final WebViewController controller;
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setUserAgent(_userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            onNavigationRequest(request.url);
            
            final isCallback = _isCallbackUrl(request.url);
            return isCallback 
                ? NavigationDecision.prevent 
                : NavigationDecision.navigate;
          },
          onPageStarted: (String url) => onPageStarted(),
          onPageFinished: (String url) {
            onPageFinished();
            _injectOptimizations(controller);
            _injectCallbackDetection(controller, onCallbackDetected);
          },
          onWebResourceError: (WebResourceError error) => 
              onWebResourceError(error.description),
        ),
      )
      ..loadRequest(Uri.parse(url));

    return controller;
  }

  /// Checks if a URL is a callback URL
  static bool _isCallbackUrl(String url) {
    // Check for the specific callback URL pattern from your flow
    return url.contains('10.8.100.210/api/v1/callback') || 
           url.contains('/api/v1/callback') ||
           (url.contains('callback') && url.contains('code=') && url.contains('state=')) ||
           (url.contains('code=') && url.contains('state='));
  }

  /// Extracts callback parameters from URL
  static Map<String, String>? extractCallbackParams(String callbackUrl) {
    try {
      final uri = Uri.parse(callbackUrl);
      final queryParameters = uri.queryParameters;

      if (queryParameters.containsKey('code') && 
          queryParameters.containsKey('state')) {
        return {
          'code': queryParameters['code']!,
          'state': queryParameters['state']!,
        };
      }
    } catch (e) {
      debugPrint('Error parsing callback URL: $e');
    }
    return null;
  }

  /// Inject JavaScript to detect JSON callback responses in page content
  static void _injectCallbackDetection(WebViewController controller, Function(String, String)? onCallbackDetected) {
    if (onCallbackDetected == null) return;
    
    // Add JavaScript channel to receive callback data
    controller.addJavaScriptChannel(
      'FlutterCallback',
      onMessageReceived: (JavaScriptMessage message) {
        try {
          final data = jsonDecode(message.message);
          if (data['code'] != null && data['state'] != null) {
            final code = data['code'].toString();
            final state = data['state'].toString();
            debugPrint('Callback detected via JavaScript: code=$code, state=$state');
            onCallbackDetected(code, state);
          }
        } catch (e) {
          debugPrint('Error processing JavaScript callback: $e');
        }
      },
    );
    
    controller.runJavaScript('''
      // Function to check for JSON callback response
      function checkForCallbackResponse() {
        try {
          var bodyText = document.body.innerText || document.body.textContent || '';
          
          // Check if the page contains JSON with code and state
          if (bodyText.includes('"code"') && bodyText.includes('"state"')) {
            console.log('Found potential callback response in page content');
            
            // Try to parse as JSON
            try {
              var jsonMatch = bodyText.match(/\\{[^{}]*"code"[^{}]*"state"[^{}]*\\}/);
              if (jsonMatch) {
                var jsonStr = jsonMatch[0];
                var data = JSON.parse(jsonStr);
                
                if (data.code && data.state) {
                  console.log('Parsed callback data:', data);
                  FlutterCallback.postMessage(JSON.stringify(data));
                  return true;
                }
              }
            } catch (parseError) {
              console.log('Error parsing JSON, trying regex fallback:', parseError);
            }
            
            // Fallback: try to extract code and state with regex
            var codeMatch = bodyText.match(/"code"\\s*:\\s*"([^"]+)"/);
            var stateMatch = bodyText.match(/"state"\\s*:\\s*"([^"]+)"/);
            
            if (codeMatch && stateMatch) {
              var data = { code: codeMatch[1], state: stateMatch[1] };
              console.log('Extracted callback data via regex:', data);
              FlutterCallback.postMessage(JSON.stringify(data));
              return true;
            }
          }
        } catch (error) {
          console.log('Error in checkForCallbackResponse:', error);
        }
        return false;
      }
      
      // Check immediately when script loads
      setTimeout(function() {
        if (checkForCallbackResponse()) {
          console.log('Callback response detected immediately');
        } else {
          // Set up observer for dynamic content changes
          var observer = new MutationObserver(function(mutations) {
            if (checkForCallbackResponse()) {
              observer.disconnect();
            }
          });
          
          if (document.body) {
            observer.observe(document.body, {
              childList: true,
              subtree: true,
              characterData: true
            });
          }
          
          // Also check periodically as fallback
          var checkInterval = setInterval(function() {
            if (checkForCallbackResponse()) {
              clearInterval(checkInterval);
              if (observer) observer.disconnect();
            }
          }, 500);
          
          // Stop checking after 60 seconds
          setTimeout(function() {
            clearInterval(checkInterval);
            if (observer) observer.disconnect();
          }, 60000);
        }
      }, 1000);
    ''');
  }

  /// Injects performance and UX optimizations into the WebView
  static void _injectOptimizations(WebViewController controller) {
    controller.runJavaScript('''
      // Viewport configuration
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
      document.getElementsByTagName('head')[0].appendChild(meta);

      // Prevent double-tap zoom
      document.addEventListener('touchstart', function(event) {
        if (event.touches.length > 1) {
          event.preventDefault();
        }
      }, { passive: false });

      // Prevent pinch zoom
      document.addEventListener('gesturestart', function(event) {
        event.preventDefault();
      }, { passive: false });

      // Improve input field experience
      var inputs = document.querySelectorAll('input, textarea, select');
      inputs.forEach(function(input) {
        input.style.fontSize = '16px';
        input.addEventListener('focus', function() {
          setTimeout(function() {
            input.scrollIntoView({ behavior: 'smooth', block: 'center' });
          }, 300);
        });
      });

      // Disable animations for better performance
      document.addEventListener('DOMContentLoaded', function() {
        var elements = document.querySelectorAll('*');
        elements.forEach(function(el) {
          if (el.style.animation) {
            el.style.animation = 'none';
          }
          if (el.style.transition) {
            el.style.transition = 'none';
          }
        });
      });
    ''');
  }

  /// Clears WebView data
  static Future<void> clearWebViewData(WebViewController? controller) async {
    if (controller != null) {
      await controller.clearCache();
      await controller.clearLocalStorage();
    }
  }
} 