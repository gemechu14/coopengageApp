import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/national_id_models.dart';
import '../services/simple_fayda_service.dart';
import 'package:coopengageplus/constants/config/config.dart';

class SimpleNationalIdNotifier extends StateNotifier<NationalIdState> {
  SimpleNationalIdNotifier() : super(const NationalIdState());
  
  SimpleFaydaService? _service;
  
  /// Complete authentication flow
  Future<void> startAuthentication() async {
    try {
      print('🚀 Starting National ID authentication...');
      state = state.copyWith(isLoading: true, error: null);
      
      _service = SimpleFaydaService();
      
      // Step 1: Connect to WebSocket
      await _service!.connectWebSocket();
      state = state.copyWith(isConnected: true);
      
      // Step 2: Register client (keep open)
      await _service!.registerClient();
      state = state.copyWith(isRegistered: true);
      
      // Step 3: Get auth URL (keep open)
      final authUrl = await _service!.getAuthUrl(AppConstants.baseURL);
      state = state.copyWith(authUrl: authUrl, isLoading: false);
      
      // Step 4 will be called when callback is detected
      _waitForResult();
      
    } catch (e) {
      print('❌ Authentication error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isConnected: false,
      );
      _service?.close();
    }
  }
  
  /// Wait for authentication result (Step 4)
  void _waitForResult() async {
    try {
      print('⏳ Waiting for authentication result...');
      final userData = await _service!.waitForAuthResult();
      
      state = state.copyWith(
        userData: userData,
        isCompleted: true,
        isLoading: false,
        error: null,
        isConnected: false, // WebSocket closed after completion
      );
      
      print('✅ Authentication completed for: ${userData.name}');
      
    } catch (e) {
      print('❌ Error waiting for result: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isConnected: false, // WebSocket closed on error
      );
    }
  }
  
  /// Check if WebSocket is connected
  bool get isWebSocketConnected {
    return _service?.isConnected ?? false;
  }
  
  /// Reset state
  void reset() {
    _service?.close();
    _service = null;
    state = const NationalIdState();
  }

  /// Restore user data from stepper provider
  void restoreUserData(FaydaUserData userData) {
    print('🔄 [Provider] Restoring user data: ${userData.name}');
    state = state.copyWith(
      userData: userData,
      isCompleted: true,
      isLoading: false,
      error: null,
      isConnected: false,
    );
    print('🔄 [Provider] User data restored successfully');
  }
  
  @override
  void dispose() {
    _service?.close();
    super.dispose();
  }
}

// Provider
final simpleNationalIdProvider = StateNotifierProvider<SimpleNationalIdNotifier, NationalIdState>((ref) {
  return SimpleNationalIdNotifier();
}); 