import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_di.dart';
import '../../core/shared_widgets/app_error_view.dart';
import '../../core/shared_widgets/app_loader.dart';
import '../../core/shared_widgets/app_network_image.dart';
import '../../core/utils/app_error_messages.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import 'business_logic/news_feed_cubit.dart';
import 'business_logic/news_feed_state.dart';
import 'models/article.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key, required this.cubit});

  final NewsFeedCubit cubit;

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  static const double _loadMoreThreshold = 200.0;

  final ScrollController _scrollController = ScrollController();
  int _lastCheckedArticleCount = 0;

  @override
  void initState() {
    super.initState();
    widget.cubit.getNews();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final ScrollPosition position = _scrollController.position;
    final bool hasScrolled = position.pixels > 0;
    final bool isNearTheEnd =
        position.pixels >= position.maxScrollExtent - _loadMoreThreshold;
    if (hasScrolled && isNearTheEnd) {
      widget.cubit.getNextPage();
    }
  }

  // A screen tall enough to show a whole page without scrolling would
  // otherwise never reach _onScroll - there is nothing to scroll. So each
  // time a page finishes loading successfully, check after that frame
  // whether the list still fits the screen; if it does, ask for the next
  // page too. Only a page that actually grew the list re-triggers this, so a
  // failed next page is not retried automatically.
  void _fillScreenIfNeeded(NewsFeedState state) {
    if (!state.isSuccess || state.isLoadingNextPage || state.hasReachedMax) {
      return;
    }
    final int articleCount = state.data?.length ?? 0;
    if (articleCount <= _lastCheckedArticleCount) {
      return;
    }
    _lastCheckedArticleCount = articleCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      if (_scrollController.position.maxScrollExtent <= 0) {
        widget.cubit.getNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    AppDi.disposeNewsFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeTitle)),
      body: BlocConsumer<NewsFeedCubit, NewsFeedState>(
        bloc: widget.cubit,
        listener: (BuildContext context, NewsFeedState state) =>
            _fillScreenIfNeeded(state),
        builder: (BuildContext context, NewsFeedState state) {
          if (state.isInit) {
            return const SizedBox.shrink();
          }
          if (state.isLoading) {
            return const AppLoader();
          }
          if (state.isError) {
            return AppErrorView(
              message: state.error ?? AppErrorMessages.generic,
              onRetry: widget.cubit.getNews,
            );
          }
          final List<Article> articles = state.data ?? <Article>[];
          if (articles.isEmpty) {
            return const Center(child: Text(AppStrings.noArticles));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: articles.length + (state.isLoadingNextPage ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if (index >= articles.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: AppLoader(),
                );
              }
              return _ArticleCard(article: articles[index]);
            },
          );
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  static const double _imageSize = 80.0;

  final Article article;

  String get _subtitle {
    final String? sourceName = article.source?.name;
    final String formattedDate = DateFormatter.format(article.publishedAt);
    return <String>[
      if (sourceName != null && sourceName.isNotEmpty) sourceName,
      if (formattedDate.isNotEmpty) formattedDate,
    ].join(AppStrings.sourceDateSeparator);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String subtitle = _subtitle;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: _imageSize,
                  height: _imageSize,
                  child: AppNetworkImage(url: article.urlToImage),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      article.title ?? '',
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4.0),
                      Text(subtitle, style: textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
