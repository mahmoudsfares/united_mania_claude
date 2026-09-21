import 'package:equatable/equatable.dart';

import '../../../core/networking/state_resource.dart';
import '../models/article.dart';

class NewsFeedState extends Equatable {
  const NewsFeedState({
    required this.resource,
    this.isLoadingNextPage = false,
    this.hasReachedMax = false,
  });

  const NewsFeedState.init()
    : resource = const StateResource<List<Article>>.init(),
      isLoadingNextPage = false,
      hasReachedMax = false;

  final StateResource<List<Article>> resource;
  final bool isLoadingNextPage;
  final bool hasReachedMax;

  bool get isInit => resource.isInit;

  bool get isLoading => resource.isLoading;

  bool get isSuccess => resource.isSuccess;

  bool get isError => resource.isError;

  List<Article>? get data => resource.data;

  String? get error => resource.error;

  NewsFeedState copyWith({
    StateResource<List<Article>>? resource,
    bool? isLoadingNextPage,
    bool? hasReachedMax,
  }) {
    return NewsFeedState(
      resource: resource ?? this.resource,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => <Object?>[resource, isLoadingNextPage, hasReachedMax];
}
