import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_di.dart';
import '../../core/shared_widgets/app_network_image.dart';
import '../../core/utils/app_error_messages.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../news_feed/models/article.dart';
import 'business_logic/news_details_cubit.dart';
import 'business_logic/news_details_state.dart';

class NewsDetailsScreen extends StatefulWidget {
  const NewsDetailsScreen({super.key, required this.article, required this.cubit});

  final Article article;
  final NewsDetailsCubit cubit;

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  static const double _imageAspectRatio = 16 / 9;
  static final RegExp _truncationCounterPattern = RegExp(
    r'[.…]*\s*\[\+\d+\s*chars\]\s*$',
  );

  Article get _article => widget.article;

  String? get _byline {
    final String? author = _article.author;
    final String? sourceName = _article.source?.name;
    final List<String> parts = <String>[
      if (author != null && author.isNotEmpty) author,
      if (sourceName != null && sourceName.isNotEmpty) sourceName,
    ];
    return parts.isEmpty ? null : parts.join(AppStrings.sourceDateSeparator);
  }

  String? get _content {
    final String? raw = _article.content;
    if (raw == null) {
      return null;
    }
    return raw.replaceFirst(_truncationCounterPattern, '').trimRight();
  }

  @override
  void dispose() {
    AppDi.disposeNewsDetails();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? byline = _byline;
    final String date = DateFormatter.format(_article.publishedAt);
    final String? description = _article.description;
    final String? content = _content;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          AspectRatio(
            aspectRatio: _imageAspectRatio,
            child: AppNetworkImage(url: _article.urlToImage),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_article.title ?? '', style: textTheme.headlineSmall),
                if (byline != null) ...<Widget>[
                  const SizedBox(height: 8.0),
                  Text(byline, style: textTheme.bodyMedium),
                ],
                if (date.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4.0),
                  Text(date, style: textTheme.bodySmall),
                ],
                if (description != null) ...<Widget>[
                  const SizedBox(height: 16.0),
                  Text(description, style: textTheme.bodyLarge),
                ],
                if (content != null) ...<Widget>[
                  const SizedBox(height: 16.0),
                  Text(content, style: textTheme.bodyMedium),
                ],
                const SizedBox(height: 16.0),
                BlocListener<NewsDetailsCubit, NewsDetailsState>(
                  bloc: widget.cubit,
                  listener: (BuildContext context, NewsDetailsState state) {
                    if (state.isError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.error ?? AppErrorMessages.couldNotOpenLink,
                          ),
                        ),
                      );
                    }
                  },
                  child: InkWell(
                    onTap: () => widget.cubit.openArticle(_article.url),
                    child: Text(
                      AppStrings.readFullArticle,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
