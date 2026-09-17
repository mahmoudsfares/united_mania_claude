class AppErrorMessages {
  AppErrorMessages._();

  static const String noInternet =
      'No internet connection. Please check your connection and try again.';
  static const String timeout = 'The request timed out. Please try again.';
  static const String invalidApiKey =
      'We could not connect to the news service. Please try again later.';
  static const String rateLimited =
      'Too many requests. Please try again later.';
  static const String serverError =
      'Something went wrong on the server. Please try again later.';
  static const String generic = 'Something went wrong. Please try again.';
  static const String noArticleLink = 'This article has no link to open.';
  static const String couldNotOpenLink = 'Could not open the article link.';
}
