/// Model for individual invitation
class Invitation {
  final int id;
  final String recipientName;
  final String linkType;
  final String status;
  final String platform;
  final bool emailOpened;
  final String? emailOpenedAt;
  final bool linkClicked;
  final String? linkClickedAt;
  final String sentAt;

  Invitation({
    required this.id,
    required this.recipientName,
    required this.linkType,
    required this.status,
    required this.platform,
    required this.emailOpened,
    this.emailOpenedAt,
    required this.linkClicked,
    this.linkClickedAt,
    required this.sentAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] ?? 0,
      recipientName: json['recipientName'] ?? '',
      linkType: json['linkType'] ?? '',
      status: json['status'] ?? '',
      platform: json['platform'] ?? '',
      emailOpened: json['emailOpened'] ?? false,
      emailOpenedAt: json['emailOpenedAt'],
      linkClicked: json['linkClicked'] ?? false,
      linkClickedAt: json['linkClickedAt'],
      sentAt: json['sentAt'] ?? '',
    );
  }

  /// Get status color based on status
  String get statusColor {
    switch (status.toUpperCase()) {
      case 'SENT':
        return 'blue';
      case 'CLICKED':
        return 'orange';
      case 'OPENED':
        return 'green';
      case 'REGISTERED':
        return 'success';
      default:
        return 'grey';
    }
  }

  /// Format sent date
  String get formattedSentAt {
    try {
      final date = DateTime.parse(sentAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return sentAt;
    }
  }
}

