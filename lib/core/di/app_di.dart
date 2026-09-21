import '../../features/news_feed/business_logic/news_feed_cubit.dart';
import '../../features/news_feed/business_logic/news_feed_mock_repo.dart';

class AppDi {
  AppDi._();

  static NewsFeedCubit? _newsFeedCubit;

  static NewsFeedCubit get newsFeedCubit {
    return _newsFeedCubit ??= NewsFeedCubit(const NewsFeedMockRepo().getNews);
  }

  static void disposeNewsFeed() {
    _newsFeedCubit?.close();
    _newsFeedCubit = null;
  }
}
