# Link Generator Feature

A production-ready Flutter feature for generating and sharing invitation links for a bank system through social media platforms.

## 🏗️ Architecture

This feature follows **Clean Architecture** principles with clear separation of concerns:

```
SendLink/
├── models/                    # Data models and enums
│   └── link_generator_models.dart
├── services/                  # Business logic and API calls
│   └── link_generator_service.dart
├── providers/                 # State management (Riverpod)
│   └── link_generator_provider.dart
├── link_generator_page.dart  # UI/Presentation layer
├── link_generator.dart       # Barrel export file
└── README.md                 # Documentation
```

## 📦 Dependencies

Required packages (add to `pubspec.yaml`):

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  dio: ^5.4.0
  url_launcher: ^6.2.0
```

## 🚀 Features

✅ **State Management**: Riverpod for reactive state management  
✅ **API Integration**: Dio for HTTP requests with proper error handling  
✅ **Material 3 Design**: Modern, clean UI with rounded corners and proper spacing  
✅ **Platform Support**: WhatsApp, Telegram, and Email  
✅ **Smart Validation**: Context-aware validation based on selected platform  
✅ **Share Functionality**: Direct sharing via platform-specific URLs  
✅ **QR Code Display**: Shows QR code when provided by API  
✅ **Copy to Clipboard**: Easy link copying with user feedback  
✅ **Error Handling**: Comprehensive error handling with user-friendly messages  

## 📱 Usage

### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/customerOnboarding/SendLink/link_generator.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LinkGeneratorPage(),
    );
  }
}
```

### Navigation

```dart
// Navigate to Link Generator page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LinkGeneratorPage(),
  ),
);
```

## 🔧 API Configuration

The feature uses the API endpoint defined in `AppConstants.baseURL`:

**Endpoint**: `POST {baseURL}/api/v1/invitations/social/generate-link`

### Request Format

```json
{
  "linkType": "INDIVIDUAL",
  "platform": "WHATSAPP",
  "recipientName": "John Doe",
  "recipientPhone": "0947539988"
}
```

### Response Format

```json
{
  "shareableLink": "https://example.com/invite/abc123",
  "platformSpecificUrl": "https://wa.me/251947539988?text=...",
  "qrCodeUrl": "https://example.com/qr/abc123.png",
  "message": "Link generated successfully"
}
```

## 📋 Account Types

- **INDIVIDUAL** - Personal bank account (default)
- **JOINT** - Joint bank account
- **ORGANIZATION** - Organization/business account

## 📱 Supported Platforms

### WhatsApp
- **Icon**: Green WhatsApp icon
- **Required**: Phone number (09/07 + 8 digits)
- **Features**: Direct share button with platform-specific URL

### Telegram
- **Icon**: Blue Telegram icon
- **Required**: Phone number (09/07 + 8 digits)
- **Features**: Direct share button with platform-specific URL

### Email
- **Icon**: Red/primary email icon
- **Required**: Valid email address
- **Features**: Copy link only (no share button)

## ✅ Validation Rules

### Phone Number (WhatsApp & Telegram)
- Must start with `09` or `07`
- Must be exactly 10 digits
- Only digits allowed
- **Example**: `0947539988`, `0712345678`

### Email
- Must be a valid email format
- Required when Email platform is selected
- **Example**: `john.doe@example.com`

### Recipient Name
- Optional for all platforms
- Auto-capitalized words

## 🎨 UI Components

### Form Card
- Account Type dropdown
- Platform dropdown with colored icons
- Recipient Name field (optional)
- Phone/Email field (conditional, based on platform)
- Generate Link button with loading state

### Result Card
- Success message with green check icon
- Shareable link (selectable text)
- Copy Link button
- Share button (conditional - WhatsApp/Telegram only)
- QR Code display (if provided by API)
- Additional message (if provided by API)

## 🔄 State Management

### Providers

```dart
// Main state provider
final linkGeneratorProvider = StateNotifierProvider<LinkGeneratorNotifier, LinkGeneratorState>

// Convenience providers
final isLoadingProvider = Provider<bool>
final errorMessageProvider = Provider<String?>
final resultProvider = Provider<LinkGenerationResponse?>
```

### Using the Provider

```dart
// In your widget
final state = ref.watch(linkGeneratorProvider);

// Generate link
await ref.read(linkGeneratorProvider.notifier).generateLink(request);

// Clear result
ref.read(linkGeneratorProvider.notifier).clearResult();

// Reset state
ref.read(linkGeneratorProvider.notifier).reset();
```

## 🛠️ Customization

### Changing API Endpoint

Edit `lib/constants/config/config.dart`:

```dart
class AppConstants {
  static const baseURL = 'https://your-api-url.com';
}
```

### Modifying Timeouts

Edit `lib/customerOnboarding/SendLink/providers/link_generator_provider.dart`:

```dart
final dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 30), // Change here
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ),
);
```

### Custom Theme

The UI automatically adapts to your app's Material 3 theme. Customize in `MaterialApp`:

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.yourColor),
    useMaterial3: true,
  ),
  // ...
)
```

## 🐛 Error Handling

The service layer provides comprehensive error handling:

- **Network errors** (timeout, no connection)
- **HTTP errors** (400, 401, 403, 404, 5xx)
- **Validation errors** (form validation)
- **Parse errors** (invalid response format)
- **User-friendly messages** for all error types

### Example Error Messages

- "Request timeout. Please check your internet connection."
- "Unauthorized. Please login again."
- "Invalid request. Please check your input."
- "No internet connection. Please check your network."

## 📝 Best Practices

1. **Always wrap with ProviderScope**: The app must be wrapped with `ProviderScope` at the root
2. **Error handling**: The service layer handles all errors gracefully
3. **Loading states**: UI automatically shows loading indicators
4. **Validation**: Form validation is context-aware based on selected platform
5. **Clean state**: Results are cleared when switching platforms

## 🧪 Testing

### Example Unit Test for Service

```dart
test('generateLink returns response on success', () async {
  // Arrange
  final mockDio = MockDio();
  final service = LinkGeneratorService(dio: mockDio, baseUrl: 'https://test.com');
  
  // Act
  final result = await service.generateLink(request);
  
  // Assert
  expect(result.shareableLink, isNotEmpty);
});
```

### Example Widget Test

```dart
testWidgets('LinkGeneratorPage shows form fields', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: LinkGeneratorPage(),
      ),
    ),
  );
  
  expect(find.text('Account Type'), findsOneWidget);
  expect(find.text('Platform'), findsOneWidget);
});
```

## 📄 License

Part of CoopEngage Plus application - Cooperative Bank of Oromia S.C.

## 👥 Contributors

Developed following clean architecture and Flutter best practices.

---

**Note**: This feature requires proper backend API configuration and authentication setup.

