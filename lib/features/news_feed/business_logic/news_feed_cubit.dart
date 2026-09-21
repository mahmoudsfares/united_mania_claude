import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/networking/state_resource.dart';
import '../models/article.dart';
import 'news_feed_state.dart';

class NewsFeedCubit extends Cubit<NewsFeedState> {
  NewsFeedCubit(this._getNews) : super(const NewsFeedState.init());

  final Future<StateResource<List<Article>>> Function({int page}) _getNews;

  int _currentPage = 1;

  Future<void> getNews() async {
    _currentPage = 1;
    emit(const NewsFeedState(resource: StateResource<List<Article>>.loading()));
    emit(NewsFeedState(resource: await _getNews(page: _currentPage)));
  }

  Future<void> getNextPage() async {
    if (state.isLoadingNextPage || state.hasReachedMax || !state.isSuccess) {
      return;
    }

    emit(state.copyWith(isLoadingNextPage: true));

    final int nextPage = _currentPage + 1;
    final StateResource<List<Article>> resource = await _getNews(page: nextPage);

    if (!resource.isSuccess) {
      emit(state.copyWith(isLoadingNextPage: false));
      return;
    }

    final List<Article> newArticles = resource.data!;
    if (newArticles.isEmpty) {
      emit(state.copyWith(isLoadingNextPage: false, hasReachedMax: true));
      return;
    }

    // Only advance the tracked page on success, so a failed request is retried
    // rather than skipped on the next scroll.
    _currentPage = nextPage;
    emit(
      state.copyWith(
        resource: StateResource<List<Article>>.success(<Article>[
          ...?state.data,
          ...newArticles,
        ]),
        isLoadingNextPage: false,
      ),
    );
  }
}
