import 'package:url_launcher/url_launcher.dart';

class UrlLauncherApi {
  const UrlLauncherApi();

  Future<bool> launch(String url, {required LaunchMode mode}) {
    return launchUrl(Uri.parse(url), mode: mode);
  }
}
