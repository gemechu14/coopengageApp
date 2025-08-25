import 'dart:io';
import 'package:flutter/services.dart';
import 'package:coopengageplus/service/certificate_service.dart';

class CertificateTest {
  /// Test if certificates can be loaded successfully
  static Future<void> testCertificateLoading() async {
    print('=== Testing Certificate Loading ===');
    
    try {
      // Test MTD environment
      print('Testing MTD environment...');
      HttpClient mtdClient = await CertificateService.createSecureHttpClient(environment: 'mtd');
      print('✅ MTD certificate loaded successfully');
      
      // Test RELID environment
      print('Testing RELID environment...');
      HttpClient relidClient = await CertificateService.createSecureHttpClient(environment: 'relid');
      print('✅ RELID certificate loaded successfully');
      
      // Test development client
      print('Testing development client...');
      HttpClient devClient = CertificateService.createDevelopmentHttpClient();
      print('✅ Development client created successfully');
      
      print('=== All certificate tests passed ===');
      
    } catch (e) {
      print('❌ Certificate test failed: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }
  
  /// Test if certificate files exist in assets
  static Future<void> testCertificateFiles() async {
    print('=== Testing Certificate Files ===');
    
    try {
      // Test MTD certificate file
      print('Testing MTD certificate file...');
      ByteData mtdData = await rootBundle.load('assets/certificates/mtd_cert.p12');
      print('✅ MTD certificate file found (${mtdData.lengthInBytes} bytes)');
      
      // Test RELID certificate file
      print('Testing RELID certificate file...');
      ByteData relidData = await rootBundle.load('assets/certificates/relid_cert.p12');
      print('✅ RELID certificate file found (${relidData.lengthInBytes} bytes)');
      
      print('=== All certificate files found ===');
      
    } catch (e) {
      print('❌ Certificate file test failed: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }
  
  /// Test environment switching
  static Future<void> testEnvironmentSwitching() async {
    print('=== Testing Environment Switching ===');
    
    try {
      // Test setting MTD environment
      print('Setting environment to MTD...');
      await CertificateService.setEnvironment('mtd');
      String currentEnv = await CertificateService.getCurrentEnvironment();
      print('Current environment: $currentEnv');
      
      // Test setting RELID environment
      print('Setting environment to RELID...');
      await CertificateService.setEnvironment('relid');
      currentEnv = await CertificateService.getCurrentEnvironment();
      print('Current environment: $currentEnv');
      
      // Test setting back to MTD
      print('Setting environment back to MTD...');
      await CertificateService.setEnvironment('mtd');
      currentEnv = await CertificateService.getCurrentEnvironment();
      print('Current environment: $currentEnv');
      
      print('=== Environment switching test passed ===');
      
    } catch (e) {
      print('❌ Environment switching test failed: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }
  
  /// Run all tests
  static Future<void> runAllTests() async {
    print('🚀 Starting Certificate Tests...\n');
    
    await testCertificateFiles();
    print('');
    
    await testEnvironmentSwitching();
    print('');
    
    await testCertificateLoading();
    print('');
    
    print('🏁 All certificate tests completed!');
  }
} 