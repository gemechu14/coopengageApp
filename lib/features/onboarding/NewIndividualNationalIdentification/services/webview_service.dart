import 'dart:async';
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
    return url.contains('callback') || 
           url.contains('code=') || 
           url.contains('state=');
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