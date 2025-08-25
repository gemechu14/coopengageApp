# SSL Certificate Setup for CoopEngagePlus

This document explains how to set up and use SSL certificates in your Flutter mobile application.

## Overview

Your app now supports SSL certificates for secure connections to different environments:
- **MTD Environment**: Uses `mtd_cert.p12` certificate
- **RELID Environment**: Uses `relid_cert.p12` certificate

## Certificate Files

The following certificate files are included in your project:
- `assets/certificates/mtd_cert.p12` - Certificate for MTD environment
- `assets/certificates/relid_cert.p12` - Certificate for RELID environment

## Certificate Details

- **Alias**: `coopid`
- **Password**: `Coop@1234`
- **Format**: PKCS#12 (.p12)

## How It Works

### 1. Certificate Service (`lib/service/certificate_service.dart`)
- Manages SSL certificates for different environments
- Creates secure HttpClient instances
- Handles certificate validation
- Provides fallback mechanisms

### 2. Network Handler (`lib/NetworkHandler.dart`)
- Automatically uses the appropriate certificate based on current environment
- Falls back to development mode if certificate loading fails
- Maintains backward compatibility

### 3. Environment Configuration (`lib/constants/config/environment_config.dart`)
- Centralized configuration for different environments
- Easy to add new environments
- Configurable base URLs and certificate paths

## Usage

### Automatic Usage
The certificates are automatically used when making HTTP requests through your `NetworkHandler`. No code changes are required for existing functionality.

### Manual Environment Switching
You can manually switch between environments using the `EnvironmentSelector` widget:

```dart
import 'package:coopengageplus/common_widgets/environment_selector.dart';

// Add this widget to any screen
const EnvironmentSelector()
```

### Programmatic Environment Switching
```dart
import 'package:coopengageplus/service/certificate_service.dart';

// Switch to MTD environment
await CertificateService.setEnvironment('mtd');

// Switch to RELID environment
await CertificateService.setEnvironment('relid');

// Get current environment
String currentEnv = await CertificateService.getCurrentEnvironment();
```

## Configuration

### Update Base URLs
Edit `lib/constants/config/environment_config.dart` to set your actual server URLs:

```dart
static const Map<String, String> BASE_URLS = {
  MTD: 'https://your-actual-mtd-server.com',
  RELID: 'https://your-actual-relid-server.com',
};
```

### Add New Environments
To add a new environment:

1. Add the certificate file to `assets/certificates/`
2. Update `EnvironmentConfig.CERTIFICATE_CONFIG`
3. Update `EnvironmentConfig.BASE_URLS`
4. Add the environment to the `EnvironmentSelector` widget

## Security Considerations

### Development vs Production
- **Development**: The app allows all certificates for easier testing
- **Production**: Implement proper certificate validation in `CertificateService.validateCertificate()`

### Certificate Validation
The current implementation includes basic validation:
- Certificate expiration check
- Hostname matching
- Custom validation logic can be added

### Secure Storage
Environment settings are stored securely using `flutter_secure_storage`.

## Troubleshooting

### Certificate Loading Errors
If you see certificate loading errors:
1. Check that certificate files are in the correct location
2. Verify the alias and password are correct
3. Ensure the certificate format is valid (.p12)

### Network Connection Issues
If HTTPS connections fail:
1. Verify the server is using the correct certificate
2. Check that the environment is set correctly
3. Review the certificate validation logic

### Fallback Behavior
The app automatically falls back to development mode if certificate loading fails, ensuring your app continues to work.

## Testing

### Test Certificate Loading
```dart
import 'package:coopengageplus/service/certificate_service.dart';

// Test certificate loading
try {
  HttpClient client = await CertificateService.createSecureHttpClient(environment: 'mtd');
  print('Certificate loaded successfully');
} catch (e) {
  print('Certificate loading failed: $e');
}
```

### Test Environment Switching
```dart
// Test environment switching
await CertificateService.setEnvironment('relid');
String env = await CertificateService.getCurrentEnvironment();
print('Current environment: $env'); // Should print 'relid'
```

## Support

For issues related to:
- Certificate loading: Check the console logs for detailed error messages
- Network connections: Verify server configuration and certificate validity
- Environment switching: Ensure the environment selector is properly integrated

## Notes

- The app automatically handles certificate loading and validation
- No manual certificate management is required for normal operation
- Environment switching affects all subsequent network requests
- Certificates are loaded from the app bundle and cannot be modified at runtime 