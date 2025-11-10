# Link Generator Feature - Complete Index

## 📂 Project Structure

```
lib/customerOnboarding/SendLink/
│
├── 📄 link_generator.dart              # Main export file (use this for imports)
├── 🎨 link_generator_page.dart         # UI/Presentation layer
│
├── 📁 models/
│   └── link_generator_models.dart      # Data models and enums
│       ├── AccountType enum
│       ├── SharePlatform enum
│       ├── LinkGenerationRequest
│       ├── LinkGenerationResponse
│       └── LinkGeneratorState
│
├── 📁 services/
│   └── link_generator_service.dart     # Business logic & API
│       ├── LinkGeneratorService class
│       └── LinkGenerationException class
│
├── 📁 providers/
│   └── link_generator_provider.dart    # State management (Riverpod)
│       ├── dioProvider
│       ├── linkGeneratorServiceProvider
│       ├── linkGeneratorProvider
│       ├── isLoadingProvider
│       ├── errorMessageProvider
│       └── resultProvider
│
├── 📖 README.md                        # Feature documentation
├── 🏗️ ARCHITECTURE.md                  # Architecture details
├── 🚀 QUICKSTART.md                    # Quick start guide
├── 📋 INDEX.md                         # This file
│
└── 📄 ContactSender.dart               # Separate contact support feature
```

## 🎯 File Purposes

| File | Purpose | Layer | Key Exports |
|------|---------|-------|-------------|
| `link_generator.dart` | Barrel export file | - | All feature components |
| `link_generator_page.dart` | UI implementation | Presentation | `LinkGeneratorPage` |
| `models/link_generator_models.dart` | Data structures | Data | Enums, Request/Response models |
| `services/link_generator_service.dart` | API & business logic | Service | `LinkGeneratorService` |
| `providers/link_generator_provider.dart` | State management | State | Riverpod providers |

## 🔍 Quick Reference

### Import the Feature

```dart
// Option 1: Import everything (recommended)
import 'package:coopengageplus/customerOnboarding/SendLink/link_generator.dart';

// Option 2: Import specific components
import 'package:coopengageplus/customerOnboarding/SendLink/link_generator_page.dart';
import 'package:coopengageplus/customerOnboarding/SendLink/models/link_generator_models.dart';
import 'package:coopengageplus/customerOnboarding/SendLink/providers/link_generator_provider.dart';
```

### Navigate to Page

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LinkGeneratorPage(),
  ),
);
```

### Use Provider

```dart
// Watch state
final state = ref.watch(linkGeneratorProvider);

// Call action
await ref.read(linkGeneratorProvider.notifier).generateLink(request);
```

## 📊 Components Overview

### Data Models (5 components)

1. **AccountType** - Enum for account types
   - `individual`, `joint`, `organization`
   - Maps to API values: `INDIVIDUAL`, `JOINT`, `ORGANIZATION`

2. **SharePlatform** - Enum for platforms
   - `whatsapp`, `telegram`, `email`
   - Includes icons and colors for UI

3. **LinkGenerationRequest** - Request DTO
   - `accountType`, `platform`, `recipientName`, `recipientPhone`, `email`
   - `toJson()` method for API serialization

4. **LinkGenerationResponse** - Response DTO
   - `shareableLink`, `platformSpecificUrl`, `qrCodeUrl`, `message`
   - `fromJson()` factory for deserialization

5. **LinkGeneratorState** - UI state
   - `isLoading`, `errorMessage`, `result`
   - `copyWith()` for immutable updates

### Service Layer (2 components)

1. **LinkGeneratorService** - Main service
   - `generateLink(request)` - API call method
   - Error handling and data transformation

2. **LinkGenerationException** - Custom exception
   - `message`, `statusCode`, `originalError`
   - Used for service-layer errors

### Providers (6 components)

1. **dioProvider** - HTTP client provider
2. **linkGeneratorServiceProvider** - Service instance provider
3. **linkGeneratorProvider** - Main state provider (StateNotifier)
4. **isLoadingProvider** - Computed loading state
5. **errorMessageProvider** - Computed error message
6. **resultProvider** - Computed result

### UI Components (3 main widgets)

1. **LinkGeneratorPage** - Main page widget
2. **_buildFormCard** - Form section
3. **_buildResultCard** - Result display section

## 🔄 Data Flow Summary

```
User Input (UI)
    ↓
LinkGeneratorPage validates form
    ↓
LinkGenerationRequest created
    ↓
linkGeneratorProvider.notifier.generateLink()
    ↓
LinkGeneratorService.generateLink()
    ↓
API call via Dio
    ↓
LinkGenerationResponse parsed
    ↓
State updated
    ↓
UI rebuilds
    ↓
Result displayed
```

## 🎨 UI Features

✅ **Material 3 Design** - Modern, clean interface  
✅ **Form Validation** - Context-aware validation  
✅ **Loading States** - Visual feedback during API calls  
✅ **Error Handling** - User-friendly error messages  
✅ **Copy to Clipboard** - One-tap link copying  
✅ **Platform Sharing** - Direct app integration  
✅ **QR Code Display** - Visual link representation  
✅ **Responsive Layout** - Works on all screen sizes  

## 🔧 Key Methods

### LinkGeneratorNotifier Methods

```dart
Future<void> generateLink(LinkGenerationRequest request)  // Generate link
void clearResult()                                        // Clear current result
void clearError()                                         // Clear error message
void reset()                                              // Reset to initial state
```

### LinkGeneratorService Methods

```dart
Future<LinkGenerationResponse> generateLink(LinkGenerationRequest request)
```

### Form Validation Methods

```dart
String? _validatePhone(String? value)  // Phone validation
String? _validateEmail(String? value)  // Email validation
```

## 📱 Platform Support

| Platform | Validation | Features |
|----------|-----------|----------|
| WhatsApp | Phone (09/07 + 8 digits) | Share button, platform URL |
| Telegram | Phone (09/07 + 8 digits) | Share button, platform URL |
| Email | Valid email format | Copy only (no share) |

## 📚 Documentation Files

| File | Purpose | Audience |
|------|---------|----------|
| `README.md` | Feature overview & usage | All developers |
| `ARCHITECTURE.md` | Design patterns & structure | Senior developers, architects |
| `QUICKSTART.md` | Setup & basic examples | New developers |
| `INDEX.md` | Component reference | All developers |

## 🧪 Testing Entry Points

### Unit Tests
- `LinkGeneratorService.generateLink()`
- `LinkGenerationRequest.toJson()`
- `LinkGenerationResponse.fromJson()`

### Widget Tests
- `LinkGeneratorPage` rendering
- Form validation logic
- Button states

### Integration Tests
- Complete link generation flow
- Error handling scenarios
- Platform-specific behaviors

## 📦 Dependencies

```yaml
flutter_riverpod: ^2.4.0  # State management
dio: ^5.4.0               # HTTP client
url_launcher: ^6.2.0      # External app launching
```

## 🎯 API Endpoint

```
POST {baseURL}/api/v1/invitations/social/generate-link
```

Configured in: `lib/constants/config/config.dart`

## 🔑 Key Features by File

### `link_generator_page.dart`
- ✅ Form with validation
- ✅ Dropdown menus with icons
- ✅ Conditional field rendering
- ✅ Loading indicators
- ✅ Result display
- ✅ Copy & share functionality

### `models/link_generator_models.dart`
- ✅ Type-safe enums
- ✅ JSON serialization
- ✅ Immutable state management
- ✅ Extension methods

### `services/link_generator_service.dart`
- ✅ Dio integration
- ✅ Error handling
- ✅ Response parsing
- ✅ Exception hierarchy

### `providers/link_generator_provider.dart`
- ✅ Dependency injection
- ✅ State management
- ✅ Computed providers
- ✅ State transitions

## 🚀 Getting Started Checklist

- [ ] Run `flutter pub get`
- [ ] Wrap app with `ProviderScope`
- [ ] Configure `AppConstants.baseURL`
- [ ] Add platform permissions (Android/iOS)
- [ ] Import the feature
- [ ] Navigate to `LinkGeneratorPage`
- [ ] Test with different platforms

## 📞 Related Features

- `ContactSender.dart` - Support contact feature (separate)

## 🎓 Learning Path

1. **Beginners**: Start with `QUICKSTART.md`
2. **Intermediate**: Read `README.md` + try examples
3. **Advanced**: Study `ARCHITECTURE.md` + extend features

## 🏆 Best Practices Implemented

✅ Clean Architecture  
✅ Separation of Concerns  
✅ Dependency Injection  
✅ Immutable State  
✅ Error Handling  
✅ Type Safety  
✅ Code Documentation  
✅ Consistent Naming  
✅ Material 3 Design  
✅ Accessibility  

---

**Version**: 1.0.0  
**Last Updated**: 2025  
**Maintainer**: CoopEngage Plus Team  

