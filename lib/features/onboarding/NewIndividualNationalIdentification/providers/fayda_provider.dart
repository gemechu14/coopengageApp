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
  
  // Step 4: Process callback after user completes authentication
  Future<void> processCallback(String baseUrl, String code, String stateParam) async {
    print('📞 [FaydaProvider] STEP 4: Processing callback...');
    print('📞 [FaydaProvider] Base URL: $baseUrl');
    print('📞 [FaydaProvider] Code: $code');
    print('📞 [FaydaProvider] State param: $stateParam');
    print('📞 [FaydaProvider] Service exists: ${_service != null}');
    print('📞 [FaydaProvider] WebSocket connected: ${_service?.isConnected}');
    print('📞 [FaydaProvider] Current provider state: isLoading=${state.isLoading}, error=${state.error}');
    
    try {
      if (_service == null) {
        print('❌ [FaydaProvider] Service is null - cannot process callback');
        throw Exception('Service not initialized');
      }
      
      print('📞 [FaydaProvider] WebSocket status BEFORE processing callback: ${_service!.isConnected}');
      state = state.copyWith(isLoading: true, error: null);
      print('📞 [FaydaProvider] State set to loading');
      
      // Call the callback API - WebSocket must stay open for this
      print('📞 [FaydaProvider] Calling service.processCallback...');
      await _service!.processCallback(baseUrl, code, stateParam);
      print('📞 [FaydaProvider] Service.processCallback completed successfully');
      print('📞 [FaydaProvider] WebSocket status AFTER callback API: ${_service!.isConnected}');
      
      // Update state to show callback processing is complete
      state = state.copyWith(isLoading: false);
      print('📞 [FaydaProvider] Callback processing complete, loading=false');
      print('📞 [FaydaProvider] WebSocket status after state update: ${_service!.isConnected}');
      
      // WebSocket stays open to receive authentication_result
      print('📞 [FaydaProvider] WebSocket kept open for authentication_result');
      print('📞 [FaydaProvider] Service NOT disposed - waiting for authentication_result');
      
    } catch (e) {
      print('❌ [FaydaProvider] Error in processCallback: $e');
      print('❌ [FaydaProvider] WebSocket status during callback error: ${_service?.isConnected}');
      // If callback API fails (like 400 error), keep WebSocket open for retry
      state = state.copyWith(
        isLoading: false, 
        error: 'Callback API failed: ${e.toString()}. WebSocket kept open for retry.',
      );
      print('❌ [FaydaProvider] Error state set, WebSocket kept open');
      print('❌ [FaydaProvider] Service NOT disposed - allowing retry');
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
  
  // Manual retry method for when callback API fails
  Future<void> retryCallback(String baseUrl, String code, String stateParam) async {
    print('🔄 [FaydaProvider] Retrying callback...');
    print('🔄 [FaydaProvider] Service exists: ${_service != null}');
    print('🔄 [FaydaProvider] WebSocket connected: ${_service?.isConnected}');
    
    if (_service != null && _service!.isConnected) {
      print('🔄 [FaydaProvider] WebSocket still connected, retrying callback');
      await processCallback(baseUrl, code, stateParam);
    } else {
      print('❌ [FaydaProvider] WebSocket connection lost, cannot retry');
      state = state.copyWith(
        error: 'WebSocket connection lost. Please restart authentication.',
      );
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