import '../../../core/utils/json_keys.dart';
import 'article_source.dart';

class Article {
  const Article({
    required this.source,
    required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final Object? sourceJson = json[JsonKeys.source];
    return Article(
      source: sourceJson is Map<String, dynamic>
          ? ArticleSource.fromJson(sourceJson)
          : null,
      author: json[JsonKeys.author] as String?,
      title: json[JsonKeys.title] as String?,
      description: json[JsonKeys.description] as String?,
      url: json[JsonKeys.url] as String?,
      urlToImage: json[JsonKeys.urlToImage] as String?,
      publishedAt: json[JsonKeys.publishedAt] as String?,
      content: json[JsonKeys.content] as String?,
    );
  }

  final ArticleSource? source;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      JsonKeys.source: source?.toJson(),
      JsonKeys.author: author,
      JsonKeys.title: title,
      JsonKeys.description: description,
      JsonKeys.url: url,
      JsonKeys.urlToImage: urlToImage,
      JsonKeys.publishedAt: publishedAt,
      JsonKeys.content: content,
    };
  }
}
