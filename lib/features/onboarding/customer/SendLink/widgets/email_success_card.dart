import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import '../models/link_generator_models.dart';

/// Email success card showing confirmation
class EmailSuccessCard extends StatelessWidget {
  final String recipientName;
  final String recipientEmail;
  final AccountType accountType;
  final String? notes;

  const EmailSuccessCard({
    super.key,
    required this.recipientName,
    required this.recipientEmail,
    required this.accountType,
    this.notes,
  });

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: cyanblueColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Email Sent Successfully',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cyanblueColor,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Success Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: cyanblueColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Invitation Email Sent',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'An invitation email has been sent to $recipientEmail',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The recipient will receive the invitation link directly in their inbox.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

            // Recipient Details
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Recipient:', recipientName),
                  const SizedBox(height: 8),
                  _buildDetailRow('Email:', recipientEmail),
                  const SizedBox(height: 8),
                  _buildDetailRow('Account Type:', accountType.displayName),
                  if (notes != null && notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow('Notes:', notes!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

