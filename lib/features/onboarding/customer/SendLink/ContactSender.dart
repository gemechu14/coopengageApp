import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSender extends StatefulWidget {
  const ContactSender({Key? key}) : super(key: key);

  @override
  State<ContactSender> createState() => _ContactSenderState();
}

class _ContactSenderState extends State<ContactSender> {
  final TextEditingController _inputController = TextEditingController();

  String? _selectedAccountType;
  String? _selectedMethod;

  final List<String> accountTypes = ['INDIVIDUAL', 'JOINT', 'ORGANIZATION'];
  final List<String> methods = ['Telegram', 'WhatsApp', 'Email'];

  Future<void> _sendMessage() async {
    if (_selectedMethod == null || _inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select method and enter details')),
      );
      return;
    }

    final input = _inputController.text.trim();
    final String message =
        'Hello, I need assistance with $_selectedAccountType account onboarding.';

    Uri uri;

    switch (_selectedMethod) {
      case 'WhatsApp':
        uri = Uri.parse(
            'https://wa.me/$input?text=${Uri.encodeComponent(message)}');
        break;
      case 'Telegram':
        uri = Uri.parse('https://t.me/$input');
        break;
      case 'Email':
        uri = Uri(
          scheme: 'mailto',
          path: input,
          query:
              Uri.encodeFull('subject=Account Onboarding Help&body=$message'),
        );
        break;
      default:
        return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Support',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF06B6D4), // cyan blue
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Account Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: accountTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              value: _selectedAccountType,
              onChanged: (value) =>
                  setState(() => _selectedAccountType = value),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Contact Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: methods
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              value: _selectedMethod,
              onChanged: (value) => setState(() => _selectedMethod = value),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _inputController,
              keyboardType: _selectedMethod == 'Email'
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              decoration: InputDecoration(
                labelText: _selectedMethod == 'Email'
                    ? 'Enter Email Address'
                    : 'Enter Phone Number',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316), // orange
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'Send',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
