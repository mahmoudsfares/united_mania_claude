class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://newsapi.org/v2/';
  static const String everything = 'everything';

  static const String apiKeyQueryParam = 'apiKey';
  static const String apiKey = '47ba773d0f1147438a3d6244bc7f1e5e';

  static const String qQueryParam = 'q';
  static const String q =
      'manchester united|man utd|man united|manchester utd';
  static const String sortByQueryParam = 'sortBy';
  static const String sortBy = 'publishedAt';
  static const String languageQueryParam = 'language';
  static const String language = 'en';

  static const String pageQueryParam = 'page';
  static const String pageSizeQueryParam = 'pageSize';
}
