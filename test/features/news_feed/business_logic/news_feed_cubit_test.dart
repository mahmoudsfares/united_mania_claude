import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united_mania_claude/core/networking/state_resource.dart';
import 'package:united_mania_claude/core/utils/app_error_messages.dart';
import 'package:united_mania_claude/core/utils/json_keys.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_cubit.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_mock_repo.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_repo.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_state.dart';
import 'package:united_mania_claude/features/news_feed/models/article.dart';

class MockNewsFeedRepo extends Mock implements NewsFeedRepo {}

void main() {
  const Article firstPageArticle = Article(
    source: null,
    author: 'First page author',
    title: 'First page article',
    description: null,
    url: null,
    urlToImage: null,
    publishedAt: null,
    content: null,
  );

  const Article secondPageArticle = Article(
    source: null,
    author: 'Second page author',
    title: 'Second page article',
    description: null,
    url: null,
    urlToImage: null,
    publishedAt: null,
    content: null,
  );

  const NewsFeedState firstPageLoaded = NewsFeedState(
    resource: StateResource<List<Article>>.success(<Article>[firstPageArticle]),
  );

  group('NewsFeedCubit.getNews — with a mocked repo', () {
    late MockNewsFeedRepo repo;

    setUp(() {
      repo = MockNewsFeedRepo();
    });

    blocTest<NewsFeedCubit, NewsFeedState>(
      'emits loading then success when the repo succeeds',
      setUp: () => when(() => repo.getNews(page: 1)).thenAnswer(
        (_) async => const StateResource<List<Article>>.success(<Article>[]),
      ),
      build: () => NewsFeedCubit(repo.getNews),
      act: (NewsFeedCubit cubit) => cubit.getNews(),
      expect: () => <NewsFeedState>[
        const NewsFeedState(resource: StateResource<List<Article>>.loading()),
        const NewsFeedState(
          resource: StateResource<List<Article>>.success(<Article>[]),
        ),
      ],
    );

    blocTest<NewsFeedCubit, NewsFeedState>(
      'emits loading then error when the repo fails',
      setUp: () => when(() => repo.getNews(page: 1)).thenAnswer(
        (_) async =>
            const StateResource<List<Article>>.error(AppErrorMessages.generic),
      ),
      build: () => NewsFeedCubit(repo.getNews),
      act: (NewsFeedCubit cubit) => cubit.getNews(),
      expect: () => <NewsFeedState>[
        const NewsFeedState(resource: StateResource<List<Article>>.loading()),
        const NewsFeedState(
          resource: StateResource<List<Article>>.error(AppErrorMessages.generic),
        ),
      ],
    );
  });

  group('NewsFeedCubit.getNextPage — with a mocked repo', () {
    late MockNewsFeedRepo repo;

    setUp(() {
      repo = MockNewsFeedRepo();
    });

    blocTest<NewsFeedCubit, NewsFeedState>(
      'appends the next page and leaves hasReachedMax false',
      setUp: () => when(() => repo.getNews(page: 2)).thenAnswer(
        (_) async => const StateResource<List<Article>>.success(<Article>[
          secondPageArticle,
        ]),
      ),
      seed: () => firstPageLoaded,
      build: () => NewsFeedCubit(repo.getNews),
      act: (NewsFeedCubit cubit) => cubit.getNextPage(),
      expect: () => <NewsFeedState>[
        firstPageLoaded.copyWith(isLoadingNextPage: true),
        const NewsFeedState(
          resource: StateResource<List<Article>>.success(<Article>[
            firstPageArticle,
            secondPageArticle,
          ]),
        ),
      ],
    );

    blocTest<NewsFeedCubit, NewsFeedState>(
      'sets hasReachedMax without changing the list when the next page is empty',
      setUp: () => when(() => repo.getNews(page: 2)).thenAnswer(
        (_) async => const StateResource<List<Article>>.success(<Article>[]),
      ),
      seed: () => firstPageLoaded,
      build: () => NewsFeedCubit(repo.getNews),
      act: (NewsFeedCubit cubit) => cubit.getNextPage(),
      expect: () => <NewsFeedState>[
        firstPageLoaded.copyWith(isLoadingNextPage: true),
        firstPageLoaded.copyWith(hasReachedMax: true),
      ],
    );

    blocTest<NewsFeedCubit, NewsFeedState>(
      'clears the loading flag and keeps the list when the next page fails',
      setUp: () => when(() => repo.getNews(page: 2)).thenAnswer(
        (_) async =>
            const StateResource<List<Article>>.error(AppErrorMessages.generic),
      ),
      seed: () => firstPageLoaded,
      build: () => NewsFeedCubit(repo.getNews),
      act: (NewsFeedCubit cubit) => cubit.getNextPage(),
      expect: () => <NewsFeedState>[
        firstPageLoaded.copyWith(isLoadingNextPage: true),
        firstPageLoaded,
      ],
    );

    blocTest<NewsFeedCubit, NewsFeedState>(
      'is a no-op while a page load is already in flight',
      seed: () => firstPageLoaded.copyWith(isLoadingNextPage: true),
      build: () => NewsFeedCubit(repo.getNews),
      act: (NewsFeedCubit cubit) => cubit.getNextPage(),
      expect: () => <NewsFeedState>[],
      verify: (NewsFeedCubit _) =>
          verifyNever(() => repo.getNews(page: any(named: 'page'))),
    );

    blocTest<NewsFeedCubit, NewsFeedState>(
      'is a no-op once hasReachedMax is already true',
      seed: () => firstPageLoaded.copyWith(hasReachedMax: true),
      build: () => NewsFeedCubit(repo.getNews),
      act: (NewsFeedCubit cubit) => cubit.getNextPage(),
      expect: () => <NewsFeedState>[],
      verify: (NewsFeedCubit _) =>
          verifyNever(() => repo.getNews(page: any(named: 'page'))),
    );

    blocTest<NewsFeedCubit, NewsFeedState>(
      'is a no-op before the first page has loaded successfully',
      build: () => NewsFeedCubit(repo.getNews),
      act: (NewsFeedCubit cubit) => cubit.getNextPage(),
      expect: () => <NewsFeedState>[],
      verify: (NewsFeedCubit _) =>
          verifyNever(() => repo.getNews(page: any(named: 'page'))),
    );
  });

  group('NewsFeedCubit — with the real NewsFeedMockRepo', () {
    blocTest<NewsFeedCubit, NewsFeedState>(
      'getNews emits loading then success carrying the fixture articles',
      build: () => NewsFeedCubit(const NewsFeedMockRepo().getNews),
      act: (NewsFeedCubit cubit) => cubit.getNews(),
      expect: () => <Object>[
        const NewsFeedState(resource: StateResource<List<Article>>.loading()),
        isA<NewsFeedState>()
            .having((NewsFeedState state) => state.isSuccess, 'isSuccess', true)
            .having((NewsFeedState state) => state.data?.length, 'data.length', 10)
            .having(
              (NewsFeedState state) => state.hasReachedMax,
              'hasReachedMax',
              false,
            ),
      ],
    );

    blocTest<NewsFeedCubit, NewsFeedState>(
      'getNews emits loading then error carrying the fixture message',
      build: () =>
          NewsFeedCubit(const NewsFeedMockRepo(returnError: true).getNews),
      act: (NewsFeedCubit cubit) => cubit.getNews(),
      expect: () => <NewsFeedState>[
        const NewsFeedState(resource: StateResource<List<Article>>.loading()),
        NewsFeedState(
          resource: StateResource<List<Article>>.error(
            NewsFeedMockRepo.errorResponseBody[JsonKeys.message] as String,
          ),
        ),
      ],
    );

    blocTest<NewsFeedCubit, NewsFeedState>(
      "getNextPage appends the fixture's second page and leaves hasReachedMax false",
      build: () => NewsFeedCubit(const NewsFeedMockRepo().getNews),
      act: (NewsFeedCubit cubit) async {
        await cubit.getNews();
        await cubit.getNextPage();
      },
      expect: () => <Object>[
        const NewsFeedState(resource: StateResource<List<Article>>.loading()),
        isA<NewsFeedState>()
            .having((NewsFeedState state) => state.data?.length, 'data.length', 10),
        isA<NewsFeedState>()
            .having(
              (NewsFeedState state) => state.isLoadingNextPage,
              'isLoadingNextPage',
              true,
            )
            .having((NewsFeedState state) => state.data?.length, 'data.length', 10),
        isA<NewsFeedState>()
            .having(
              (NewsFeedState state) => state.isLoadingNextPage,
              'isLoadingNextPage',
              false,
            )
            .having(
              (NewsFeedState state) => state.hasReachedMax,
              'hasReachedMax',
              false,
            )
            .having((NewsFeedState state) => state.data?.length, 'data.length', 14),
      ],
    );

    blocTest<NewsFeedCubit, NewsFeedState>(
      "getNextPage sets hasReachedMax once the fixture's pages are exhausted",
      build: () => NewsFeedCubit(const NewsFeedMockRepo().getNews),
      act: (NewsFeedCubit cubit) async {
        await cubit.getNews();
        await cubit.getNextPage();
        await cubit.getNextPage();
      },
      skip: 5,
      expect: () => <Object>[
        isA<NewsFeedState>()
            .having(
              (NewsFeedState state) => state.isLoadingNextPage,
              'isLoadingNextPage',
              false,
            )
            .having(
              (NewsFeedState state) => state.hasReachedMax,
              'hasReachedMax',
              true,
            )
            .having((NewsFeedState state) => state.data?.length, 'data.length', 14),
      ],
    );
  });
}
