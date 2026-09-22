import '../models/article.dart';

class RemovedArticlesFilter {
  RemovedArticlesFilter._();

  static const String removedPlaceholder = '[Removed]';

  static List<Article> dropRemoved(List<Article> articles) {
    return articles
        .where((Article article) => article.title != removedPlaceholder)
        .toList();
  }
}
