/// Model for invitation statistics
class InvitationStats {
  final int totalInvitationsSent;
  final int totalEmailsOpened;
  final int totalLinksClicked;
  final int totalRegistrations;
  final double openRate;
  final double clickRate;
  final double conversionRate;
  final int currentMonthSent;
  final int currentMonthTarget;
  final double targetProgress;

  InvitationStats({
    required this.totalInvitationsSent,
    required this.totalEmailsOpened,
    required this.totalLinksClicked,
    required this.totalRegistrations,
    required this.openRate,
    required this.clickRate,
    required this.conversionRate,
    required this.currentMonthSent,
    required this.currentMonthTarget,
    required this.targetProgress,
  });

  factory InvitationStats.fromJson(Map<String, dynamic> json) {
    return InvitationStats(
      totalInvitationsSent: json['totalInvitationsSent'] ?? 0,
      totalEmailsOpened: json['totalEmailsOpened'] ?? 0,
      totalLinksClicked: json['totalLinksClicked'] ?? 0,
      totalRegistrations: json['totalRegistrations'] ?? 0,
      openRate: (json['openRate'] ?? 0.0).toDouble(),
      clickRate: (json['clickRate'] ?? 0.0).toDouble(),
      conversionRate: (json['conversionRate'] ?? 0.0).toDouble(),
      currentMonthSent: json['currentMonthSent'] ?? 0,
      currentMonthTarget: json['currentMonthTarget'] ?? 0,
      targetProgress: (json['targetProgress'] ?? 0.0).toDouble(),
    );
  }
}

