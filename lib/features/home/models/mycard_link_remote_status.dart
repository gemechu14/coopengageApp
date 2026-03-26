/// Response from backend for MyCard public link analytics / health.
/// Adjust field names to match your API contract.
class MycardLinkRemoteStatus {
  const MycardLinkRemoteStatus({
    this.linkActive,
    this.statusLabel,
    this.totalOpens,
    this.totalShares,
    this.lastUpdatedIso,
    this.message,
  });

  final bool? linkActive;
  final String? statusLabel;
  final int? totalOpens;
  final int? totalShares;
  final String? lastUpdatedIso;
  final String? message;

  factory MycardLinkRemoteStatus.fromJson(Map<String, dynamic> json) {
    final inner = json['data'];
    final Map<String, dynamic> data = inner is Map<String, dynamic>
        ? inner
        : json;

    int? readInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.round();
      return int.tryParse(v.toString());
    }

    return MycardLinkRemoteStatus(
      linkActive: data['linkActive'] as bool? ?? data['active'] as bool?,
      statusLabel: data['status'] as String? ??
          data['statusLabel'] as String? ??
          data['state'] as String?,
      totalOpens: readInt(data['totalOpens'] ?? data['opens'] ?? data['clicks']),
      totalShares: readInt(data['totalShares'] ?? data['shares']),
      lastUpdatedIso: data['lastUpdated'] as String? ??
          data['updatedAt'] as String? ??
          data['timestamp'] as String?,
      message: data['message'] as String? ?? data['description'] as String?,
    );
  }

  bool get hasAnyMetric =>
      totalOpens != null || totalShares != null || statusLabel != null;

  /// Placeholder until `MycardLinkStatusService.fetchLinkStatus()` is wired.
  static const MycardLinkRemoteStatus mockFromApi = MycardLinkRemoteStatus(
    linkActive: true,
    statusLabel: 'ACTIVE',
    totalOpens: 1280,
    totalShares: 342,
    lastUpdatedIso: '2025-03-20T14:30:00.000Z',
    message: 'MyCard signup link is live.',
  );
}
