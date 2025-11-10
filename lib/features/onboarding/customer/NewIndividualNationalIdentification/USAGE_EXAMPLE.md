# Using Stored FAN and OTP for Registration

The `UltraSimpleNationalIdWidget` automatically extracts and stores FAN (Federal Account Number) and OTP from URL parameters during the authentication process. Here's how to use them for registration:

## How It Works

When users input their FAN and OTP in the embedded authentication page, the widget intercepts URL changes and automatically extracts these parameters, looking for various common parameter names:

**FAN Parameters:**
- `fan`
- `FAN` 
- `fanNumber`
- `fan_number`
- `nationalId`
- `national_id`

**OTP Parameters:**
- `otp`
- `OTP`
- `otpCode`
- `otp_code`
- `code`

## Usage Examples

### 1. Access Individual Values

```dart
// Create a widget key to access the methods
final GlobalKey<ConsumerState<UltraSimpleNationalIdWidget>> _widgetKey = 
    GlobalKey<ConsumerState<UltraSimpleNationalIdWidget>>();

// Build the widget with the key
UltraSimpleNationalIdWidget(key: _widgetKey)

// Later, access the stored values
String? storedFan = _widgetKey.currentState?.getStoredFanNumber();
String? storedOtp = _widgetKey.currentState?.getStoredOtpCode();

if (storedFan != null && storedOtp != null) {
  // Use for registration
  await registerUser(fan: storedFan, otp: storedOtp);
}
```

### 2. Access Both Values as a Map

```dart
Map<String, String?> credentials = _widgetKey.currentState?.getStoredCredentials() ?? {};
String? fan = credentials['fan'];
String? otp = credentials['otp'];

if (fan != null && otp != null) {
  // Proceed with registration
  final registrationData = {
    'fan': fan,
    'otp': otp,
    'fullName': stepperState.fullName,
    'email': stepperState.email,
    // ... other data
  };
  
  await performRegistration(registrationData);
}
```

### 3. Using in a Consumer Widget

```dart
class RegistrationStep extends ConsumerWidget {
  final GlobalKey<ConsumerState<UltraSimpleNationalIdWidget>> nationalIdWidgetKey;
  
  const RegistrationStep({required this.nationalIdWidgetKey, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepperState = ref.watch(stepperProvider);
    
    return Column(
      children: [
        // Show stored credentials
        if (stepperState.fanNumber.isNotEmpty)
          Text('FAN: ${stepperState.fanNumber}'),
        if (stepperState.otpCode.isNotEmpty)
          Text('OTP: ${stepperState.otpCode}'),
        
        ElevatedButton(
          onPressed: () async {
            // Get credentials from the widget
            final credentials = nationalIdWidgetKey.currentState?.getStoredCredentials();
            
            if (credentials?['fan'] != null && credentials?['otp'] != null) {
              await _performRegistration(credentials!);
            } else {
              // Handle missing credentials
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('FAN and OTP are required for registration')),
              );
            }
          },
          child: Text('Register with Stored Credentials'),
        ),
      ],
    );
  }
  
  Future<void> _performRegistration(Map<String, String?> credentials) async {
    // Your registration logic here
    print('Registering with FAN: ${credentials['fan']} and OTP: ${credentials['otp']}');
  }
}
```

### 4. Alternative: Direct Access from Stepper Provider

```dart
class MyRegistrationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepperState = ref.watch(stepperProvider);
    
    return Column(
      children: [
        Text('Stored FAN: ${stepperState.fanNumber}'),
        Text('Stored OTP: ${stepperState.otpCode}'),
        
        ElevatedButton(
          onPressed: stepperState.fanNumber.isNotEmpty && stepperState.otpCode.isNotEmpty
              ? () => _register(stepperState.fanNumber, stepperState.otpCode)
              : null,
          child: Text('Register'),
        ),
      ],
    );
  }
  
  void _register(String fan, String otp) {
    // Registration logic
    print('Registering with FAN: $fan, OTP: $otp');
  }
}
```

### 5. Clearing Stored Credentials

```dart
// Clear credentials when done or when starting fresh
_widgetKey.currentState?.clearStoredCredentials();

// Or clear directly from stepper provider
ref.read(stepperProvider.notifier).updateFanNumber('');
ref.read(stepperProvider.notifier).updateOtpCode('');
```

## Important Notes

1. **Automatic Extraction**: The FAN and OTP are extracted automatically when they appear in URL parameters during WebView navigation.

2. **Multiple Parameter Names**: The widget checks for various common parameter names to ensure compatibility with different authentication systems.

3. **Persistence**: The extracted values are stored in the stepper provider and will persist across navigation within the stepper.

4. **Debug Logging**: The widget logs all URL parameters and extraction attempts for debugging purposes.

5. **Validation**: Always check if the values exist before using them for registration.

6. **Security**: The extracted credentials are stored in memory only and are cleared when the stepper is reset.

## Debug Information

The widget logs detailed information about URL parameter extraction:

```
🌐 [WebView] Navigation request: https://example.com/auth?fan=123456789&otp=987654
🔍 [Widget] URL parameters found:
   - fan: 123456789
   - otp: 987654
📱 [Widget] FAN extracted from URL: 123456789
🔐 [Widget] OTP extracted from URL: 987654
```

This information appears in the console and can help debug parameter extraction issues. 