import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/national_id_models.dart';
import '../services/simple_fayda_service.dart';
import 'package:coopengageplus/core/config/config.dart';

/// Clean provider for National ID authentication
/// Manages state and ensures WebSocket stays open until data arrives
class SimpleNationalIdNotifier extends StateNotifier<NationalIdState> {
  SimpleNationalIdNotifier() : super(const NationalIdState());
  
  SimpleFaydaService? _service;
  
  /// Start authentication flow (4 steps)
  Future<void> startAuthentication() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _service = SimpleFaydaService();
      
      // Step 1: Connect
      await _service!.connectWebSocket();
      state = state.copyWith(isConnected: true);
      
      // Step 2: Register
      await _service!.registerClient();
      state = state.copyWith(isRegistered: true);
      
      // Step 3: Get auth URL
      final authUrl = await _service!.getAuthUrl(AppConstants.baseURL);
      state = state.copyWith(authUrl: authUrl, isLoading: false);
      
      // Step 4: Wait for result (WebSocket stays open)
      _waitForResult();
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isConnected: true, // Keep WebSocket connected even on error
      );
      // DON'T close service - keep WebSocket alive
    }
  }
  
  /// Wait for authentication result (WebSocket remains open until data arrives)
  void _waitForResult() async {
    try {
      print('⏳ Waiting for authentication result...');
      final userData = await _service!.waitForAuthResult();
      
      print('✅ Received user data: ${userData.name}');
      
      // Only update state if we haven't already completed
      if (!state.isCompleted) {
        state = state.copyWith(
          userData: userData,
          isCompleted: true,
          isLoading: false,
          error: null,
          isConnected: true, // Keep WebSocket connected
        );
        print('✅ Authentication completed: ${userData.name}');
      }
    } catch (e) {
      print('❌ Error waiting for result: $e');
      
      // Only set error if we haven't already completed successfully
      if (!state.isCompleted) {
        state = state.copyWith(
          error: e.toString(),
          isLoading: false,
          isConnected: true, // Keep WebSocket connected even on error
        );
      }
    }
  }
  
  /// Restore user data (for navigation back)
  void restoreUserData(FaydaUserData userData) {
    state = state.copyWith(
      userData: userData,
      isCompleted: true,
      isLoading: false,
      error: null,
      isConnected: false,
    );
  }
  
  /// Reset state
  void reset() {
    _service?.close();
    _service = null;
    state = const NationalIdState();
  }
  
  /// Close WebSocket (only when absolutely necessary)
  void closeWebSocket() {
    print('⚠️ Manual WebSocket close requested - this should be avoided');
    _service?.close();
  }
  
  @override
  void dispose() {
    _service?.close();
    super.dispose();
  }
}

final simpleNationalIdProvider = 
    StateNotifierProvider<SimpleNationalIdNotifier, NationalIdState>((ref) {
  return SimpleNationalIdNotifier();
}); 