/// Riverpod providers for Link Generator feature
/// Manages state and dependencies

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/config/config.dart';
import '../models/link_generator_models.dart';
import '../services/link_generator_service.dart';

/// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  // Add interceptors for logging (optional)
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: false,
    ),
  );

  return dio;
});

/// Provider for LinkGeneratorService
final linkGeneratorServiceProvider = Provider<LinkGeneratorService>((ref) {
  final dio = ref.watch(dioProvider);
  return LinkGeneratorService(
    dio: dio,
    baseUrl: AppConstants.baseURL,
  );
});

/// State Notifier for Link Generator
class LinkGeneratorNotifier extends StateNotifier<LinkGeneratorState> {
  LinkGeneratorNotifier(this._service) : super(const LinkGeneratorState());

  final LinkGeneratorService _service;

  /// Send email invitation
  Future<void> sendEmailInvitation(EmailInvitationRequest request) async {
    // Set loading state
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearResult: true,
    );

    try {
      await _service.sendEmailInvitation(request);
      
      // Set success state (no result, just success)
      state = state.copyWith(
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      // Set error state
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearResult: true,
      );
    }
  }

  /// Generate shareable link (WhatsApp/Telegram)
  Future<void> generateLink(LinkGenerationRequest request) async {
    // Set loading state
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearResult: true,
    );

    try {
      final response = await _service.generateLink(request);
      
      // Set success state
      state = state.copyWith(
        isLoading: false,
        result: response,
        clearError: true,
      );
    } catch (e) {
      // Set error state
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearResult: true,
      );
    }
  }

  /// Clear the current result
  void clearResult() {
    state = state.copyWith(clearResult: true, clearError: true);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset to initial state
  void reset() {
    state = const LinkGeneratorState();
  }
}

/// Provider for LinkGeneratorNotifier
final linkGeneratorProvider =
    StateNotifierProvider<LinkGeneratorNotifier, LinkGeneratorState>((ref) {
  final service = ref.watch(linkGeneratorServiceProvider);
  return LinkGeneratorNotifier(service);
});

/// Provider for loading state (convenience)
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(linkGeneratorProvider).isLoading;
});

/// Provider for error message (convenience)
final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(linkGeneratorProvider).errorMessage;
});

/// Provider for result (convenience)
final resultProvider = Provider<LinkGenerationResponse?>((ref) {
  return ref.watch(linkGeneratorProvider).result;
});

