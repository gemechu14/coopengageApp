// ignore_for_file: use_build_context_synchronously
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/constants/mycard_link_constants.dart';
import 'package:coopengageplus/shared/services/link_share_stats_service.dart';
import 'package:coopengageplus/shared/widgets/text/custom_nav_heading.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// MyCard link stats: links sent + opens (recorded on this device).
class MycardLinkStatsPage extends StatefulWidget {
  const MycardLinkStatsPage({super.key});

  @override
  State<MycardLinkStatsPage> createState() => _MycardLinkStatsPageState();
}

class _MycardLinkStatsPageState extends State<MycardLinkStatsPage> {
  int _linksSent = 0;
  int _opens = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sent = await LinkShareStatsService.getShareActionCount();
    final opened = await LinkShareStatsService.getLinkOpenFromAppCount();
    if (mounted) {
      setState(() {
        _linksSent = sent;
        _opens = opened;
        _loading = false;
      });
    }
  }

  Future<void> _openLink() async {
    final uri = Uri.parse(MycardLinkConstants.newCardUrl);
    await LinkShareStatsService.recordLinkOpenFromApp();
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          title: CustomNavHeading(text: 'MyCard link stats'),
        ),
      ),
      body: RefreshIndicator(
        color: primaryBlue,
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  ),
                )
              else ...[
                // Main stats panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: whiteColor,
                    border: Border.all(color: primaryBlue.withOpacity(0.10)),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [primaryBlue, secondaryBlue],
                              ),
                            ),
                            child: Icon(
                              Icons.insert_link_rounded,
                              color: Colors.white.withOpacity(0.98),
                              size: narrow ? 20 : 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'MyCard link activity',
                              style: TextStyle(
                                color: blackColor,
                                fontSize: narrow ? 14 : 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _StatBlock(
                              icon: Icons.ios_share_rounded,
                              value: '$_linksSent',
                              label: 'Links sent',
                              gradientColors: [primaryBlue, darkBlue],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBlock(
                              icon: Icons.open_in_browser_rounded,
                              value: '$_opens',
                              label: 'Opens',
                              gradientColors: [secondaryBlue, primaryBlue],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Recorded from your share actions and link opens inside this app.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: narrow ? 11 : 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Quick action
                Material(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 0,
                  child: InkWell(
                    onTap: _openLink,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.link_rounded,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Open MyCard link',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: blackColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  MycardLinkConstants.newCardUrl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradientColors,
  });

  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.98),
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: blackColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
