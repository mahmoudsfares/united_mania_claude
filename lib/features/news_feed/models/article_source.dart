import '../../../core/utils/json_keys.dart';

class ArticleSource {
  const ArticleSource({required this.id, required this.name});

  factory ArticleSource.fromJson(Map<String, dynamic> json) {
    return ArticleSource(
      id: json[JsonKeys.id] as String?,
      name: json[JsonKeys.name] as String?,
    );
  }

  final String? id;
  final String? name;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{JsonKeys.id: id, JsonKeys.name: name};
  }
}
