import '../../features/news_details/business_logic/news_details_cubit.dart';
import '../../features/news_feed/business_logic/news_feed_cubit.dart';
import '../../features/news_feed/business_logic/news_feed_repo.dart';
import '../apis/url_launcher_api.dart';
import '../networking/app_dio_client.dart';

class AppDi {
  AppDi._();

  static NewsFeedCubit? _newsFeedCubit;
  static NewsDetailsCubit? _newsDetailsCubit;

  static NewsFeedCubit get newsFeedCubit {
    return _newsFeedCubit ??= NewsFeedCubit(NewsFeedRepo(AppDioClient()).getNews);
  }

  static NewsDetailsCubit get newsDetailsCubit {
    return _newsDetailsCubit ??= NewsDetailsCubit(const UrlLauncherApi().launch);
  }

  static void disposeNewsFeed() {
    _newsFeedCubit?.close();
    _newsFeedCubit = null;
  }

  static void disposeNewsDetails() {
    _newsDetailsCubit?.close();
    _newsDetailsCubit = null;
  }
}
