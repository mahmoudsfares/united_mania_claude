import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/networking/state_resource.dart';
import '../../../core/utils/app_error_messages.dart';
import 'news_details_state.dart';

class NewsDetailsCubit extends Cubit<NewsDetailsState> {
  NewsDetailsCubit(this._launch) : super(const StateResource<void>.init());

  final Future<bool> Function(String url, {required LaunchMode mode}) _launch;

  Future<void> openArticle(String? url) async {
    if (url == null || url.isEmpty) {
      emit(const StateResource<void>.error(AppErrorMessages.noArticleLink));
      return;
    }
    try {
      final bool launched = await _launch(
        url,
        mode: LaunchMode.externalApplication,
      );
      emit(
        launched
            ? const StateResource<void>.success(null)
            : const StateResource<void>.error(AppErrorMessages.couldNotOpenLink),
      );
    } catch (_) {
      emit(const StateResource<void>.error(AppErrorMessages.couldNotOpenLink));
    }
  }
}
