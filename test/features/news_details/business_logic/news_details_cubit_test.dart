import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united_mania_claude/core/apis/url_launcher_api.dart';
import 'package:united_mania_claude/core/networking/state_resource.dart';
import 'package:united_mania_claude/core/utils/app_error_messages.dart';
import 'package:united_mania_claude/features/news_details/business_logic/news_details_cubit.dart';
import 'package:united_mania_claude/features/news_details/business_logic/news_details_state.dart';
import 'package:url_launcher/url_launcher.dart';

class MockUrlLauncherApi extends Mock implements UrlLauncherApi {}

void main() {
  const String url = 'https://www.bbc.co.uk/sport/football/man-utd-shirt-sponsor-extension';

  group('NewsDetailsCubit.openArticle', () {
    late MockUrlLauncherApi api;

    setUp(() {
      api = MockUrlLauncherApi();
    });

    blocTest<NewsDetailsCubit, NewsDetailsState>(
      'a valid url calls the api once with LaunchMode.externalApplication and emits success',
      setUp: () => when(
        () => api.launch(url, mode: LaunchMode.externalApplication),
      ).thenAnswer((_) async => true),
      build: () => NewsDetailsCubit(api.launch),
      act: (NewsDetailsCubit cubit) => cubit.openArticle(url),
      expect: () => <NewsDetailsState>[const StateResource<void>.success(null)],
      verify: (NewsDetailsCubit _) => verify(
        () => api.launch(url, mode: LaunchMode.externalApplication),
      ).called(1),
    );

    blocTest<NewsDetailsCubit, NewsDetailsState>(
      'a null url emits an error and never calls the api',
      build: () => NewsDetailsCubit(api.launch),
      act: (NewsDetailsCubit cubit) => cubit.openArticle(null),
      expect: () => <NewsDetailsState>[
        const StateResource<void>.error(AppErrorMessages.noArticleLink),
      ],
      verify: (NewsDetailsCubit _) => verifyNever(
        () => api.launch(any(), mode: LaunchMode.externalApplication),
      ),
    );

    blocTest<NewsDetailsCubit, NewsDetailsState>(
      'an empty url emits an error and never calls the api',
      build: () => NewsDetailsCubit(api.launch),
      act: (NewsDetailsCubit cubit) => cubit.openArticle(''),
      expect: () => <NewsDetailsState>[
        const StateResource<void>.error(AppErrorMessages.noArticleLink),
      ],
      verify: (NewsDetailsCubit _) => verifyNever(
        () => api.launch(any(), mode: LaunchMode.externalApplication),
      ),
    );

    blocTest<NewsDetailsCubit, NewsDetailsState>(
      'emits an error when the api throws',
      setUp: () => when(
        () => api.launch(url, mode: LaunchMode.externalApplication),
      ).thenThrow(Exception('boom')),
      build: () => NewsDetailsCubit(api.launch),
      act: (NewsDetailsCubit cubit) => cubit.openArticle(url),
      expect: () => <NewsDetailsState>[
        const StateResource<void>.error(AppErrorMessages.couldNotOpenLink),
      ],
    );

    blocTest<NewsDetailsCubit, NewsDetailsState>(
      'emits an error when the api returns false',
      setUp: () => when(
        () => api.launch(url, mode: LaunchMode.externalApplication),
      ).thenAnswer((_) async => false),
      build: () => NewsDetailsCubit(api.launch),
      act: (NewsDetailsCubit cubit) => cubit.openArticle(url),
      expect: () => <NewsDetailsState>[
        const StateResource<void>.error(AppErrorMessages.couldNotOpenLink),
      ],
    );
  });
}
