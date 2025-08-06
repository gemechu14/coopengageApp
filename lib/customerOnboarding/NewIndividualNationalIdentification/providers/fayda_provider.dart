import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/national_id_models.dart';
import '../services/fayda_service.dart';

class FaydaNotifier extends StateNotifier<NationalIdState> {
  FaydaNotifier() : super(const NationalIdState()) {
    print('🏗️ [FaydaProvider] Provider initialized');
  }
  
  FaydaService? _service;
  
  // Main authentication flow
  Future<void> startAuthentication(String baseUrl) async {
    print('🚀 [FaydaProvider] Starting authentication flow...');
    print('🚀 [FaydaProvider] Base URL: $baseUrl');
    print('🚀 [FaydaProvider] Current state: isLoading=${state.isLoading}, isConnected=${state.isConnected}');
    
    try {
      print('🚀 [FaydaProvider] Setting loading state');
      state = state.copyWith(isLoading: true, error: null);
      
      print('🚀 [FaydaProvider] Creating FaydaService instance');
      _service = FaydaService();
      print('🚀 [FaydaProvider] Service created, WebSocket connected: ${_service!.isConnected}');
      
      // Step 1 & 2: Connect and register
      print('🚀 [FaydaProvider] Calling connectAndRegister...');
      await _service!.connectAndRegister();
      print('🚀 [FaydaProvider] Connect and register completed');
      print('🚀 [FaydaProvider] WebSocket status after connect: ${_service!.isConnected}');
      
      state = state.copyWith(isConnected: true, isRegistered: true);
      print('🚀 [FaydaProvider] State updated: isConnected=true, isRegistered=true');
      
      // Step 3: Get auth URL
      print('🚀 [FaydaProvider] Getting auth URL...');
      print('🚀 [FaydaProvider] WebSocket status before auth URL: ${_service!.isConnected}');
      final authUrl = await _service!.getAuthUrl(baseUrl);
      print('🚀 [FaydaProvider] Auth URL received: $authUrl');
      print('🚀 [FaydaProvider] WebSocket status after auth URL: ${_service!.isConnected}');
      
      state = state.copyWith(authUrl: authUrl, isLoading: false);
      print('🚀 [FaydaProvider] State updated with auth URL, loading=false');
      
      // Step 5: Wait for auth result (in background)
      print('🚀 [FaydaProvider] Starting background wait for auth result...');
      print('🚀 [FaydaProvider] WebSocket status before background wait: ${_service!.isConnected}');
      _waitForAuthResult();
      
    } catch (e) {
      print('❌ [FaydaProvider] Error in startAuthentication: $e');
      print('❌ [FaydaProvider] WebSocket status on error: ${_service?.isConnected}');
      state = state.copyWith(
        isLoading: false, 
        error: e.toString(),
        isConnected: false,
        isRegistered: false,
      );
      print('❌ [FaydaProvider] Error state set');
      _service?.dispose();
      _service = null;
      print('❌ [FaydaProvider] Service disposed due to error');
    }
  }
  
  // Wait for authentication result from WebSocket
  void _waitForAuthResult() async {
    print('⏳ [FaydaProvider] Background: Waiting for authentication result...');
    print('⏳ [FaydaProvider] WebSocket status at start of wait: ${_service?.isConnected}');
    
    try {
      final userData = await _service!.waitForAuthResult();
      print('🎉 [FaydaProvider] Authentication result received!');
      print('🎉 [FaydaProvider] User data: ${userData.name}, ${userData.email}');
      print('🎉 [FaydaProvider] WebSocket status when result received: ${_service?.isConnected}');
      
      state = state.copyWith(
        userData: userData,
        isCompleted: true,
        isLoading: false,
        error: null,
      );
      print('🎉 [FaydaProvider] State updated: isCompleted=true');
      
      // NOW we can safely dispose the service and close WebSocket
      print('🔴 [FaydaProvider] NOW disposing service and closing WebSocket');
      print('🔴 [FaydaProvider] WebSocket status before disposal: ${_service?.isConnected}');
      _service?.dispose();
      _service = null;
      print('🔴 [FaydaProvider] Service disposed and set to null');
      
    } catch (e) {
      print('❌ [FaydaProvider] Error waiting for auth result: $e');
      print('❌ [FaydaProvider] WebSocket status during wait error: ${_service?.isConnected}');
      state = state.copyWith(
        error: 'WebSocket error: ${e.toString()}', 
        isLoading: false,
        isCompleted: false,
      );
      print('❌ [FaydaProvider] Error state set for auth result failure');
      // Keep service alive on WebSocket error for potential retry
      print('⚠️ [FaydaProvider] Service kept alive for potential retry');
    }
  }
  
  // Reset state
  void reset() {
    print('🔄 [FaydaProvider] Resetting provider state...');
    print('🔄 [FaydaProvider] Service exists before reset: ${_service != null}');
    print('🔄 [FaydaProvider] WebSocket connected before reset: ${_service?.isConnected}');
    
    // Dispose service and close WebSocket
    _service?.dispose();
    _service = null;
    state = const NationalIdState();
    
    print('🔄 [FaydaProvider] Provider reset complete');
  }
  
  @override
  void dispose() {
    print('🔴 [FaydaProvider] Provider disposing...');
    print('🔴 [FaydaProvider] Service exists: ${_service != null}');
    print('🔴 [FaydaProvider] WebSocket connected: ${_service?.isConnected}');
    
    // Ensure WebSocket is closed when provider is disposed
    _service?.dispose();
    super.dispose();
    
    print('🔴 [FaydaProvider] Provider disposed');
  }
  
  // Get WebSocket connection status
  bool get isWebSocketConnected {
    final connected = _service?.isConnected ?? false;
    print('🔍 [FaydaProvider] WebSocket connection check: $connected');
    return connected;
  }
}

// Provider
final faydaProvider = StateNotifierProvider<FaydaNotifier, NationalIdState>((ref) {
  return FaydaNotifier();
}); 