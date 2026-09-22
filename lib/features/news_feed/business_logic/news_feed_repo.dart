import 'package:dio/dio.dart';

import '../../../core/networking/api_endpoints.dart';
import '../../../core/networking/app_dio_client.dart';
import '../../../core/networking/network_error_handler.dart';
import '../../../core/networking/state_resource.dart';
import '../../../core/utils/json_keys.dart';
import '../models/article.dart';
import 'removed_articles_filter.dart';

class NewsFeedRepo {
  NewsFeedRepo(this._dioClient);

  final AppDioClient _dioClient;

  static const int pageSize = 10;

  Future<StateResource<List<Article>>> getNews({int page = 1}) async {
    try {
      final Response<dynamic> response = await _dioClient.get(
        ApiEndpoints.everything,
        queryParameters: <String, dynamic>{
          ApiEndpoints.qQueryParam: ApiEndpoints.q,
          ApiEndpoints.sortByQueryParam: ApiEndpoints.sortBy,
          ApiEndpoints.languageQueryParam: ApiEndpoints.language,
          ApiEndpoints.pageQueryParam: page,
          ApiEndpoints.pageSizeQueryParam: pageSize,
        },
      );
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final List<dynamic> articlesJson = body[JsonKeys.articles] as List<dynamic>;
      final List<Article> articles = articlesJson
          .map(
            (dynamic articleJson) =>
                Article.fromJson(articleJson as Map<String, dynamic>),
          )
          .toList();
      return StateResource<List<Article>>.success(
        RemovedArticlesFilter.dropRemoved(articles),
      );
    } catch (error) {
      return networkErrorHandler<List<Article>>(error);
    }
  }
}
