# Package Setup Guide

## 📦 Required Package

To use the international phone number input, you need to add this package to your `pubspec.yaml`:

```yaml
dependencies:
  intl_phone_number_input: ^0.7.4
```

## 🔧 Installation Steps

### 1. Add to pubspec.yaml

Open `pubspec.yaml` and add under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  dio: ^5.4.0
  url_launcher: ^6.2.0
  flutter_secure_storage: ^9.0.0
  intl_phone_number_input: ^0.7.4  # ← Add this line
```

### 2. Install the package

Run in terminal:

```bash
flutter pub get
```

### 3. Verify installation

Check that there are no errors in terminal output.

## ✨ What's New

### International Phone Number Input

✅ **Default Country**: Ethiopia (ET)  
✅ **Country Selector**: Bottom sheet with country list  
✅ **Auto-formatting**: Phone numbers formatted automatically  
✅ **Validation**: Built-in phone number validation  
✅ **Country List**: Ethiopia, Kenya, US, UK (expandable)  

### Field Locking After Generation

✅ **All fields locked** after successful link generation  
✅ **Generate button disabled** and shows "Link Generated"  
✅ **Visual feedback** - fields turn grey when locked  
✅ **Prevents accidental changes** to generated links  

## 📱 Features Added

### 1. International Phone Input

**Before:**
```dart
TextFormField(
  controller: _phoneController,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],
  // ...
)
```

**After:**
```dart
InternationalPhoneNumberInput(
  initialValue: PhoneNumber(isoCode: 'ET'), // Ethiopia default
  onInputChanged: (PhoneNumber number) {
    // Handles country code automatically
  },
  countries: ['ET', 'KE', 'US', 'GB'],
  // ...
)
```

### 2. Field Locking

**State Management:**
```dart
bool _isLinkGenerated = false; // Track generation state

// After successful generation
setState(() {
  _isLinkGenerated = true; // Lock all fields
});
```

**Applied to all fields:**
- ✅ Account Type dropdown
- ✅ Platform dropdown
- ✅ Recipient Name field
- ✅ Phone Number field
- ✅ Email field
- ✅ Generate button

## 🎯 User Experience

### Before Link Generation
1. User can **select** account type
2. User can **select** platform
3. User can **enter** recipient details
4. User can **change** any field
5. Button shows: **"Generate Link"**

### After Link Generation
1. All fields are **locked** (greyed out)
2. User **cannot** modify any field
3. User can still **copy** and **share** the generated link
4. Button shows: **"Link Generated"** with checkmark
5. Button is **disabled**

### Visual Changes
- 🔒 Locked fields have grey background
- 🔒 Locked fields have grey border
- ✅ Generate button shows checkmark icon
- ✅ Generate button is grey (disabled state)

## 🌍 Country Support

### Default Countries
The phone input supports these countries by default:

1. **🇪🇹 Ethiopia (ET)** - Default
2. **🇰🇪 Kenya (KE)**
3. **🇺🇸 United States (US)**
4. **🇬🇧 United Kingdom (GB)**

### Add More Countries

To add more countries, edit the `countries` parameter:

```dart
InternationalPhoneNumberInput(
  countries: const [
    'ET', // Ethiopia
    'KE', // Kenya
    'SO', // Somalia
    'SD', // Sudan
    'DJ', // Djibouti
    'ER', // Eritrea
    'US', // United States
    'GB', // United Kingdom
  ],
  // ...
)
```

### Remove Country Filter

To allow **all countries**:

```dart
InternationalPhoneNumberInput(
  // Remove the countries parameter or set it to null
  // This will show all available countries
  // ...
)
```

## 📋 Phone Number Format

### Ethiopia Phone Numbers

**Input formats accepted:**
- `0912345678` (local format)
- `+251912345678` (international format)
- `912345678` (without leading zero)

**Output format** (sent to API):
- Automatically formatted based on country code
- Example: `+251912345678` or local format based on parseNumber()

### Validation

The package automatically validates:
- ✅ Correct number of digits for selected country
- ✅ Valid country code
- ✅ Proper formatting

## 🔧 Customization Options

### Change Default Country

To change from Ethiopia to another country:

```dart
PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'KE'); // Kenya
PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US'); // USA
PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'GB'); // UK
```

### Change Selector Style

**Current**: Bottom sheet selector

**Options available:**
```dart
selectorConfig: const SelectorConfig(
  selectorType: PhoneInputSelectorType.BOTTOM_SHEET, // Current
  // Or:
  // selectorType: PhoneInputSelectorType.DROPDOWN,
  // selectorType: PhoneInputSelectorType.DIALOG,
),
```

### Customize Appearance

```dart
InternationalPhoneNumberInput(
  inputDecoration: InputDecoration(
    labelText: 'Phone Number *',
    hintText: 'Enter phone number',
    // Customize as needed
  ),
  selectorTextStyle: const TextStyle(
    color: Colors.black,
    fontSize: 16,
  ),
  // ...
)
```

## 🐛 Troubleshooting

### Issue: Package not found

**Solution**: Run `flutter pub get` again

```bash
flutter clean
flutter pub get
```

### Issue: Phone number not validating

**Solution**: Check that the phone number format matches the selected country

```dart
// For Ethiopia, valid formats:
0912345678
+251912345678
```

### Issue: Fields not locking

**Solution**: Check that `_isLinkGenerated` is being set to `true` after successful generation

```dart
if (state.hasResult && !state.hasError) {
  setState(() {
    _isLinkGenerated = true; // Make sure this is set
  });
}
```

### Issue: Country selector not showing

**Solution**: Ensure you're tapping on the flag/country code area

```dart
selectorConfig: const SelectorConfig(
  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
  useBottomSheetSafeArea: true, // Ensure this is true
),
```

## 📝 Testing Checklist

After adding the package:

- [ ] Run `flutter pub get`
- [ ] Verify app compiles without errors
- [ ] Test phone input with Ethiopia number
- [ ] Test country selector (tap flag icon)
- [ ] Test phone validation with invalid number
- [ ] Test field locking after generation
- [ ] Test WhatsApp platform
- [ ] Test Telegram platform
- [ ] Test Email platform (should not show phone field)

## 🔄 Unlock Fields (Optional Feature)

If you want to add a "Generate New Link" button to unlock fields:

```dart
// Add this button in the result card
ElevatedButton(
  onPressed: () {
    setState(() {
      _isLinkGenerated = false;
      // Optionally clear fields
      _nameController.clear();
      _phoneNumber = PhoneNumber(isoCode: 'ET');
      _emailController.clear();
    });
    // Clear the result
    ref.read(linkGeneratorProvider.notifier).clearResult();
  },
  child: const Text('Generate New Link'),
)
```

## 📚 Package Documentation

For more details, see the official package documentation:
- **Package**: https://pub.dev/packages/intl_phone_number_input
- **GitHub**: https://github.com/natintosh/intl-phone-number-input

---

**Status**: ✅ Ready to use  
**Version**: 0.7.4  
**Platform Support**: Android, iOS, Web

