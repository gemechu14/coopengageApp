// ignore_for_file: use_build_context_synchronously

// import 'package:coopengageplus/constants/kconstant.dart';
import 'package:flutter/material.dart';
// import 'package:coopengageplus/features/onboarding/pages/userInfoList/registration_service.dart';
// import 'package:coopengageplus/common_widgets/AlertDialog/dialog_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class JointAccountDetailPage extends StatelessWidget {
  final Map jointAccount;
  final BuildContext parentContext;
  // print("dkfdfhdfhdfhdfdhhkfkdhhkf");
  // print(jointAccount);

  const JointAccountDetailPage(
      {Key? key, required this.jointAccount, required this.parentContext})
      : super(key: key);

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    print("=== JOINT ACCOUNT DATA DEBUG ===");
    print("Full joint account data: $jointAccount");
    
    final List customers = (jointAccount['customersInfo'] != null &&
            jointAccount['customersInfo'] is List)
        ? List<Map<String, dynamic>>.from(jointAccount['customersInfo'])
        : [];
    
    print("Number of customers: ${customers.length}");
    
    // Check each customer for residence card data
    for (int i = 0; i < customers.length; i++) {
      var customer = customers[i];
      print("Customer $i (${customer['fullName']}):");
      print("  - Has residenceCard: ${customer['residenceCard'] != null}");
      print("  - Has residenceCardBack: ${customer['residenceCardBack'] != null}");
      print("  - residenceCard value: ${customer['residenceCard']}");
      print("  - residenceCardBack value: ${customer['residenceCardBack']}");
      print("  - All keys: ${customer.keys.toList()}");
    }
    print("=== END DEBUG ===");
    
    // Test: Check if any customer has residence card data
    bool hasResidenceCard = false;
    for (var customer in customers) {
      if (customer['residenceCard'] != null || customer['residenceCardBack'] != null) {
        hasResidenceCard = true;
        print("🎯 FOUND RESIDENCE CARD DATA in customer: ${customer['fullName']}");
        print("   residenceCard: ${customer['residenceCard']}");
        print("   residenceCardBack: ${customer['residenceCardBack']}");
      }
    }
    if (!hasResidenceCard) {
      print("🚫 NO RESIDENCE CARD DATA FOUND IN ANY CUSTOMER");
    }
    
    final String accountId = jointAccount['id']?.toString() ?? '';
    final String jointAccountType = jointAccount['jointAccountType'] ?? '';

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.98,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Joint Account #$accountId',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              // Account Information
              _infoRow('Account Type', jointAccount['accountType']),
              _infoRow('Joint Account Type', jointAccountType),
              _infoRow('Branch', jointAccount['branch']),
              _infoRow('Currency', jointAccount['currency']),
              _infoRow('Initial Deposit',
                  'ETB ${jointAccount['initialDeposit']?.toString() ?? '0.00'}'),
              _infoRow('Status', jointAccount['status']),
              _infoRow('Added By', jointAccount['addedByFullName']),
              _infoRow('Added By Role', jointAccount['addedByRole']),

              const SizedBox(height: 24),
              Text(
                'Joint Account Holders (${customers.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),

              if (customers.isEmpty)
                const Text('No joint account holders found')
              else
                ...customers.asMap().entries.map<Widget>((entry) {
                  int index = entry.key;
                  var customer = entry.value;
                  return _customerInfoCard(customer, index + 1);
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty)
      return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.toString())),
        ],
      ),
    );
  }

  Widget _customerInfoCard(Map customer, int holderNumber) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Text(
                    holderNumber.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Holder $holderNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Personal Information
            _infoRow("Full Name", customer['fullName']),
            _infoRow('Surname', customer['surname']),
            _infoRow('Mother Name', customer['motherName']),
            _infoRow('Email', customer['email']),
            _infoRow('Phone', customer['phone']),
            _infoRow('Date of Birth', customer['dateOfBirth']),
            _infoRow('Sex', customer['sex']),
            _infoRow('Title', customer['title']),
            _infoRow('Country', customer['country']),
            _infoRow('State', customer['state']),
            _infoRow('City', customer['city']),
            _infoRow('Street Address', customer['streetAddress']),
            _infoRow('Zip Code', customer['zipCode']),
            _infoRow('Occupation', customer['occupation']),
            _infoRow('Zone/SubCity', customer['zoneSubCity']),
            _infoRow('House No', customer['houseNo']),
            _infoRow('Issue Authority', customer['issueAuthority']),
            _infoRow('Sector', customer['sector']),
            _infoRow('Industry', customer['industry']),
            _infoRow('Employer Name', customer['employerName']),
            _infoRow('Legal ID', customer['legalId']),

            // File Attachments
            if (customer['signature'] != null &&
                customer['signature'].toString().isNotEmpty)
              _fileRow('Signature', customer['signature']),
            if (customer['residenceCard'] != null &&
                customer['residenceCard'].toString().isNotEmpty)
              _fileRow('Residence Card (Front)', customer['residenceCard']),
            if (customer['residenceCardBack'] != null &&
                customer['residenceCardBack'].toString().isNotEmpty)
              _fileRow('Residence Card (Back)', customer['residenceCardBack']),
            
            // Alternative field names that might contain residence card data
            if (customer['residenceCardFront'] != null &&
                customer['residenceCardFront'].toString().isNotEmpty)
              _fileRow(
                  'Residence Card (Front)', customer['residenceCardFront']),
            if (customer['idCard'] != null &&
                customer['idCard'].toString().isNotEmpty)
              _fileRow('ID Card', customer['idCard']),
            if (customer['idCardBack'] != null &&
                customer['idCardBack'].toString().isNotEmpty)
              _fileRow('ID Card (Back)', customer['idCardBack']),
          ],
        ),
      ),
    );
  }

  Widget _fileRow(String label, String fileUrl) {
    bool isImage = fileUrl.toLowerCase().endsWith('.png') ||
        fileUrl.toLowerCase().endsWith('.jpg') ||
        fileUrl.toLowerCase().endsWith('.jpeg') ||
        fileUrl.toLowerCase().endsWith('.gif');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (isImage)
            GestureDetector(
              onTap: () => _showImageDialog(fileUrl, label),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    fileUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 4),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          else
            InkWell(
              onTap: () => _launchURL(fileUrl),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'View File',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl, String label) {
    showDialog(
      context: parentContext,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 400,
                      maxWidth: 300,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image,
                                    size: 60, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
