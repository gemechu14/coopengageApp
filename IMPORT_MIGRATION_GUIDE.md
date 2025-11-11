# Import Migration Guide

## Overview
The project structure has been reorganized to follow Flutter Riverpod best practices. All imports need to be updated to reflect the new folder structure.

## Folder Structure Changes

### Before → After

```
OLD STRUCTURE                              NEW STRUCTURE
=====================================      =====================================
lib/
├── constants/                         →   lib/core/constants/
├── Constant/                          →   lib/core/constants/ (merged)
├── constants/config/                  →   lib/core/config/
├── l10n/                              →   lib/core/l10n/
├── HttpOverrides.dart                 →   lib/core/network/http_overrides.dart
├── NetworkHandler.dart                →   lib/core/network/network_handler.dart
├── helper/databaseHelper.dart         →   lib/core/database/database_helper.dart
├── utils/                             →   lib/core/utils/
├── helper/                            →   lib/core/utils/ (merged, non-db)
├── models/                            →   lib/shared/models/
├── features/providers/                →   lib/shared/providers/
├── service/                           →   lib/shared/services/ (merged)
├── services/                          →   lib/shared/services/ (merged)
├── common_widgets/                    →   lib/shared/widgets/
├── widget/                            →   lib/shared/widgets/ (merged)
├── widgets/                           →   lib/shared/widgets/ (merged)
├── customerOnboarding/                →   lib/features/onboarding/customer/
├── HomePage/                          →   lib/features/home/
├── pages/MainPage.dart                →   lib/features/home/main_page.dart
├── Screen/                            →   lib/features/screens/
├── webview_test.dart                  →   test/webview_test.dart
└── features/ (auth, crm, hpc, onboarding) → lib/features/ (unchanged)
```

## Import Replacement Patterns

### Core Imports

```dart
// OLD
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/Constant/SliderImage.dart';

// NEW
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/constants/listConstants.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/constants/SliderImage.dart';
```

```dart
// OLD
import 'package:coopengageplus/constants/config/config.dart';

// NEW
import 'package:coopengageplus/core/config/config.dart';
```

```dart
// OLD
import 'package:coopengageplus/l10n/app_localizations.dart';

// NEW
import 'package:coopengageplus/core/l10n/app_localizations.dart';
```

```dart
// OLD
import 'package:coopengageplus/HttpOverrides.dart';
import 'package:coopengageplus/NetworkHandler.dart';

// NEW
import 'package:coopengageplus/core/network/http_overrides.dart';
import 'package:coopengageplus/core/network/network_handler.dart';
```

```dart
// OLD
import 'package:coopengageplus/helper/databaseHelper.dart';

// NEW
import 'package:coopengageplus/core/database/database_helper.dart';
```

```dart
// OLD
import 'package:coopengageplus/utils/checkToken.dart';
import 'package:coopengageplus/utils/language_store.dart';

// NEW
import 'package:coopengageplus/core/utils/checkToken.dart';
import 'package:coopengageplus/core/utils/language_store.dart';
```

### Shared Imports

```dart
// OLD
import 'package:coopengageplus/models/user.dart';

// NEW
import 'package:coopengageplus/shared/models/user.dart';
```

```dart
// OLD
import 'package:coopengageplus/features/providers/token_provider.dart';

// NEW
import 'package:coopengageplus/shared/providers/token_provider.dart';
```

```dart
// OLD
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/services/token_service.dart';

// NEW
import 'package:coopengageplus/shared/services/GlobalData.dart';
import 'package:coopengageplus/shared/services/token_service.dart';
```

```dart
// OLD
import 'package:coopengageplus/common_widgets/dropDown/branch_selector.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/widgets/token_monitor_widget.dart';

// NEW
import 'package:coopengageplus/shared/widgets/dropDown/branch_selector.dart';
import 'package:coopengageplus/shared/widgets/ReusableTextFormField.dart';
import 'package:coopengageplus/shared/widgets/token_monitor_widget.dart';
```

### Features Imports

```dart
// OLD
import 'package:coopengageplus/customerOnboarding/.../some_file.dart';

// NEW
import 'package:coopengageplus/features/onboarding/customer/.../some_file.dart';
```

```dart
// OLD
import 'package:coopengageplus/HomePage/homepage.dart';
import 'package:coopengageplus/pages/MainPage.dart';

// NEW
import 'package:coopengageplus/features/home/homepage.dart';
import 'package:coopengageplus/features/home/main_page.dart';
```

```dart
// OLD
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/Screen/SplashScreen.dart';

// NEW
import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:coopengageplus/features/screens/SplashScreen.dart';
```

## How to Update Imports

### Option 1: Find and Replace (Recommended)

Use your IDE's "Find in Files" feature and replace patterns:

1. **Core Constants:**
   - Find: `package:coopengageplus/constants/`
   - Replace: `package:coopengageplus/core/constants/`
   
   - Find: `package:coopengageplus/Constant/`
   - Replace: `package:coopengageplus/core/constants/`

2. **Core Config:**
   - Find: `package:coopengageplus/constants/config/`
   - Replace: `package:coopengageplus/core/config/`

3. **Core L10n:**
   - Find: `package:coopengageplus/l10n/`
   - Replace: `package:coopengageplus/core/l10n/`

4. **Core Network:**
   - Find: `package:coopengageplus/HttpOverrides.dart`
   - Replace: `package:coopengageplus/core/network/http_overrides.dart`
   
   - Find: `package:coopengageplus/NetworkHandler.dart`
   - Replace: `package:coopengageplus/core/network/network_handler.dart`

5. **Core Database:**
   - Find: `package:coopengageplus/helper/databaseHelper.dart`
   - Replace: `package:coopengageplus/core/database/database_helper.dart`

6. **Core Utils:**
   - Find: `package:coopengageplus/utils/`
   - Replace: `package:coopengageplus/core/utils/`

7. **Shared Models:**
   - Find: `package:coopengageplus/models/`
   - Replace: `package:coopengageplus/shared/models/`

8. **Shared Providers:**
   - Find: `package:coopengageplus/features/providers/`
   - Replace: `package:coopengageplus/shared/providers/`

9. **Shared Services:**
   - Find: `package:coopengageplus/service/`
   - Replace: `package:coopengageplus/shared/services/`
   
   - Find: `package:coopengageplus/services/`
   - Replace: `package:coopengageplus/shared/services/`

10. **Shared Widgets:**
    - Find: `package:coopengageplus/common_widgets/`
    - Replace: `package:coopengageplus/shared/widgets/`
    
    - Find: `package:coopengageplus/widget/`
    - Replace: `package:coopengageplus/shared/widgets/`
    
    - Find: `package:coopengageplus/widgets/`
    - Replace: `package:coopengageplus/shared/widgets/`

11. **Features - Customer Onboarding:**
    - Find: `package:coopengageplus/customerOnboarding/`
    - Replace: `package:coopengageplus/features/onboarding/customer/`

12. **Features - Home:**
    - Find: `package:coopengageplus/HomePage/`
    - Replace: `package:coopengageplus/features/home/`
    
    - Find: `package:coopengageplus/pages/MainPage.dart`
    - Replace: `package:coopengageplus/features/home/main_page.dart`
    
    - Find: `package:coopengageplus/pages/`
    - Replace: `package:coopengageplus/features/home/`

13. **Features - Screens:**
    - Find: `package:coopengageplus/Screen/`
    - Replace: `package:coopengageplus/features/screens/`

### Option 2: Automated Script

Run this PowerShell script to update all imports automatically:

```powershell
# Save as update_imports.ps1
$replacements = @{
    'package:coopengageplus/constants/config/' = 'package:coopengageplus/core/config/'
    'package:coopengageplus/constants/' = 'package:coopengageplus/core/constants/'
    'package:coopengageplus/Constant/' = 'package:coopengageplus/core/constants/'
    'package:coopengageplus/l10n/' = 'package:coopengageplus/core/l10n/'
    'package:coopengageplus/HttpOverrides.dart' = 'package:coopengageplus/core/network/http_overrides.dart'
    'package:coopengageplus/NetworkHandler.dart' = 'package:coopengageplus/core/network/network_handler.dart'
    'package:coopengageplus/helper/databaseHelper.dart' = 'package:coopengageplus/core/database/database_helper.dart'
    'package:coopengageplus/utils/' = 'package:coopengageplus/core/utils/'
    'package:coopengageplus/models/' = 'package:coopengageplus/shared/models/'
    'package:coopengageplus/features/providers/' = 'package:coopengageplus/shared/providers/'
    'package:coopengageplus/services/' = 'package:coopengageplus/shared/services/'
    'package:coopengageplus/service/' = 'package:coopengageplus/shared/services/'
    'package:coopengageplus/common_widgets/' = 'package:coopengageplus/shared/widgets/'
    'package:coopengageplus/widget/' = 'package:coopengageplus/shared/widgets/'
    'package:coopengageplus/widgets/' = 'package:coopengageplus/shared/widgets/'
    'package:coopengageplus/customerOnboarding/' = 'package:coopengageplus/features/onboarding/customer/'
    'package:coopengageplus/HomePage/' = 'package:coopengageplus/features/home/'
    'package:coopengageplus/pages/MainPage.dart' = 'package:coopengageplus/features/home/main_page.dart'
    'package:coopengageplus/pages/' = 'package:coopengageplus/features/home/'
    'package:coopengageplus/Screen/' = 'package:coopengageplus/features/screens/'
}

Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $modified = $false
    
    foreach ($old in $replacements.Keys) {
        if ($content -like "*$old*") {
            $content = $content -replace [regex]::Escape($old), $replacements[$old]
            $modified = $true
        }
    }
    
    if ($modified) {
        Set-Content -Path $_.FullName -Value $content -NoNewline
        Write-Host "Updated: $($_.FullName)"
    }
}

Write-Host "`nImport update complete!"
```

## Verification Steps

After updating imports:

1. **Run Flutter commands:**
   ```bash
   flutter clean
   flutter pub get
   flutter analyze
   ```

2. **Check for errors:**
   - Look for import errors in `flutter analyze` output
   - Fix any remaining manual imports

3. **Test the application:**
   ```bash
   flutter run
   ```

## Common Issues & Solutions

### Issue: Cannot find package imports

**Solution:** Make sure you ran the find and replace in the correct order. Some paths are subsets of others, so order matters.

### Issue: Duplicate widget definitions

**Solution:** Check `shared/widgets/` for any duplicate files (e.g., `ButtonUploadTakePhoto.dart` and `ButtonUploadTakePhoto .dart`). Remove duplicates.

### Issue: Analysis errors after migration

**Solution:** Run `flutter clean` and `flutter pub get`, then `flutter analyze` again.

## New Structure Benefits

✅ **Clear separation of concerns**
- `core/` - Core framework functionality
- `shared/` - Reusable across features
- `features/` - Business logic by feature

✅ **Consistent naming**
- All lowercase with underscores
- No mixed case folders

✅ **No duplicates**
- Single location for each type of code
- Easier to maintain

✅ **Flutter/Riverpod standards**
- Follows community best practices
- Easier for new developers to understand

## Need Help?

If you encounter any issues during migration:
1. Check this guide for the correct import path
2. Use your IDE's "Go to Definition" to find moved files
3. Run `flutter analyze` to identify remaining issues


