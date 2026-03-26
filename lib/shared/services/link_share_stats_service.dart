import 'package:shared_preferences/shared_preferences.dart';

/// Local-only stats for MyCard link sharing (this device).
class LinkShareStatsService {
  LinkShareStatsService._();

  static const String _kShareActions = 'mycard_link_share_actions_v1';
  static const String _kOpensFromApp = 'mycard_link_opens_from_app_v1';

  static Future<int> getShareActionCount() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kShareActions) ?? 0;
  }

  static Future<int> getLinkOpenFromAppCount() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kOpensFromApp) ?? 0;
  }

  static Future<void> recordShareAction() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kShareActions, (p.getInt(_kShareActions) ?? 0) + 1);
  }

  /// Counts when the user opens the MyCard URL from this app (browser / in-app).
  static Future<void> recordLinkOpenFromApp() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kOpensFromApp, (p.getInt(_kOpensFromApp) ?? 0) + 1);
  }
}
