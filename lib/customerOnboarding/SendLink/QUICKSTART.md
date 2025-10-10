# Link Generator - Quick Start Guide

## 🚀 Setup (5 minutes)

### Step 1: Add Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  dio: ^5.4.0
  url_launcher: ^6.2.0
```

Run:
```bash
flutter pub get
```

### Step 2: Configure API Endpoint

Verify your API endpoint in `lib/constants/config/config.dart`:

```dart
class AppConstants {
  static const baseURL = 'https://your-api-url.com';
}
```

### Step 3: Wrap Your App with ProviderScope

In `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(  // ← Important!
      child: MyApp(),
    ),
  );
}
```

### Step 4: Navigate to Link Generator Page

```dart
import 'package:flutter/material.dart';
import 'package:coopengageplus/customerOnboarding/SendLink/link_generator.dart';

// Navigate from anywhere in your app
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LinkGeneratorPage(),
  ),
);
```

## 🎯 Basic Usage

### Generate a WhatsApp Link

1. Open the Link Generator page
2. Select **Account Type**: INDIVIDUAL
3. Select **Platform**: WHATSAPP
4. Enter **Recipient Name** (optional): "John Doe"
5. Enter **Phone Number**: 0947539988
6. Tap **Generate Link**
7. Copy or share the generated link

### Generate an Email Link

1. Select **Platform**: EMAIL
2. Enter **Email Address**: john@example.com
3. Tap **Generate Link**
4. Copy the generated link

## 📱 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/customerOnboarding/SendLink/link_generator.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Link Generator Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LinkGeneratorPage(),
              ),
            );
          },
          child: const Text('Generate Invitation Link'),
        ),
      ),
    );
  }
}
```

## 🔧 Advanced Usage

### Programmatically Generate Link

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/customerOnboarding/SendLink/link_generator.dart';

class MyWidget extends ConsumerWidget {
  const MyWidget({Key? key}) : super(key: key);

  Future<void> generateLink(WidgetRef ref) async {
    final request = LinkGenerationRequest(
      accountType: AccountType.individual,
      platform: SharePlatform.whatsapp,
      recipientName: 'John Doe',
      recipientPhone: '0947539988',
    );

    await ref.read(linkGeneratorProvider.notifier).generateLink(request);

    final state = ref.read(linkGeneratorProvider);
    if (state.hasResult) {
      print('Link: ${state.result!.shareableLink}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => generateLink(ref),
      child: const Text('Generate'),
    );
  }
}
```

### Watch State Changes

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the entire state
    final state = ref.watch(linkGeneratorProvider);

    // Or watch specific parts
    final isLoading = ref.watch(isLoadingProvider);
    final error = ref.watch(errorMessageProvider);
    final result = ref.watch(resultProvider);

    return Column(
      children: [
        if (isLoading) const CircularProgressIndicator(),
        if (error != null) Text(error, style: TextStyle(color: Colors.red)),
        if (result != null) Text('Link: ${result.shareableLink}'),
      ],
    );
  }
}
```

### Custom Error Handling

```dart
Future<void> generateWithCustomError(WidgetRef ref) async {
  try {
    final request = LinkGenerationRequest(
      accountType: AccountType.individual,
      platform: SharePlatform.whatsapp,
      recipientPhone: '0947539988',
    );

    await ref.read(linkGeneratorProvider.notifier).generateLink(request);

    final state = ref.read(linkGeneratorProvider);
    if (state.hasError) {
      // Handle error your way
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(state.errorMessage!),
        ),
      );
    }
  } catch (e) {
    print('Unexpected error: $e');
  }
}
```

## 🎨 Customization Examples

### Custom Theme Colors

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  ),
)
```

### Add Custom Platform

Edit `models/link_generator_models.dart`:

```dart
enum SharePlatform {
  whatsapp,
  telegram,
  email,
  sms; // ← Add new platform

  String get apiValue {
    switch (this) {
      case SharePlatform.whatsapp:
        return 'WHATSAPP';
      case SharePlatform.telegram:
        return 'TELEGRAM';
      case SharePlatform.email:
        return 'EMAIL';
      case SharePlatform.sms:
        return 'SMS'; // ← Add mapping
    }
  }

  IconData get iconData {
    switch (this) {
      // ... existing cases
      case SharePlatform.sms:
        return Icons.sms; // ← Add icon
    }
  }

  Color get color {
    switch (this) {
      // ... existing cases
      case SharePlatform.sms:
        return Colors.green; // ← Add color
    }
  }
}
```

## 🐛 Troubleshooting

### Issue: "ProviderScope not found"
**Solution**: Wrap your app with `ProviderScope` in `main.dart`

### Issue: "Dio connection error"
**Solution**: Check your internet connection and API endpoint URL

### Issue: "Validation error"
**Solution**: Ensure phone number is 10 digits starting with 09/07, or email is valid

### Issue: "Can't launch URL"
**Solution**: Add permissions to Android/iOS manifest files:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="http" />
  </intent>
</queries>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>https</string>
  <string>http</string>
  <string>whatsapp</string>
  <string>tg</string>
</array>
```

## 📚 Next Steps

1. ✅ Read the [README.md](./README.md) for full feature documentation
2. ✅ Review [ARCHITECTURE.md](./ARCHITECTURE.md) to understand the clean architecture
3. ✅ Check the [models](./models/), [services](./services/), and [providers](./providers/) folders
4. ✅ Run the app and test different scenarios

## 💡 Tips

- Use **INDIVIDUAL** as default account type (most common)
- **Phone validation** only triggers for WhatsApp/Telegram
- **Email validation** only triggers for Email platform
- **QR codes** appear automatically if provided by API
- **Share button** only shows for WhatsApp/Telegram (not Email)
- **Loading state** prevents duplicate submissions

## 🎓 Learning Resources

- [Riverpod Documentation](https://riverpod.dev/)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Flutter Material 3](https://m3.material.io/)
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 📞 Support

For issues or questions:
1. Check this Quick Start guide
2. Review the README.md
3. Check the ARCHITECTURE.md for design decisions
4. Review the code comments in source files

---

**Happy Coding! 🚀**

