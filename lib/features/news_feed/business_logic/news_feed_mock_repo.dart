import '../../../core/networking/state_resource.dart';
import '../../../core/utils/json_keys.dart';
import '../models/article.dart';
import 'removed_articles_filter.dart';

class NewsFeedMockRepo {
  const NewsFeedMockRepo({this.returnError = false});

  final bool returnError;

  static const Map<String, dynamic> successResponseBody = <String, dynamic>{
    JsonKeys.status: 'ok',
    JsonKeys.articles: <Map<String, dynamic>>[
      <String, dynamic>{
        JsonKeys.source: <String, dynamic>{
          JsonKeys.id: 'bbc-sport',
          JsonKeys.name: 'BBC Sport',
        },
        JsonKeys.author: 'Simon Stone',
        JsonKeys.title:
            'Manchester United confirm shirt sponsor extension through 2030',
        JsonKeys.description:
            'Manchester United have extended their principal partnership deal, securing a new agreement worth a reported 75 million pounds per year.',
        JsonKeys.url:
            'https://www.bbc.co.uk/sport/football/man-utd-shirt-sponsor-extension',
        JsonKeys.urlToImage:
            'https://ichef.bbci.co.uk/live-experience/cps/624/cpsprodpb/1234/production/manutd-shirt.jpg',
        JsonKeys.publishedAt: '2026-09-19T08:30:00Z',
        JsonKeys.content:
            'Manchester United have confirmed a new principal partnership that will run until the end of the 2029-30 season, the club announced on Saturday... [+2114 chars]',
      },
      <String, dynamic>{
        JsonKeys.source: <String, dynamic>{
          JsonKeys.id: 'sky-sports',
          JsonKeys.name: 'Sky Sports',
        },
        JsonKeys.author: 'Melissa Reddy',
        JsonKeys.title:
            'Manchester United close in on deadline day move for young full-back',
        JsonKeys.description:
            'United are in advanced talks to sign a 21-year-old right-back on a five-year deal, sources close to the negotiations say.',
        JsonKeys.url:
            'https://www.skysports.com/football/news/manchester-united-full-back-deal',
        JsonKeys.urlToImage:
            'https://images.sky.com/skysports/manutd-fullback-deal.jpg',
        JsonKeys.publishedAt: '2026-09-18T14:05:22Z',
        JsonKeys.content:
            'Manchester United are closing in on a deadline-day deal for a highly rated young full-back, with the two clubs said to be finalising personal terms... [+1897 chars]',
      },
      <String, dynamic>{
        JsonKeys.source: <String, dynamic>{
          JsonKeys.id: 'reuters',
          JsonKeys.name: 'Reuters',
        },
        JsonKeys.author: 'Reuters Staff',
        JsonKeys.title: '[Removed]',
        JsonKeys.description: '[Removed]',
        JsonKeys.url: 'https://removed.com/article',
        JsonKeys.urlToImage: 'https://removed.com/image.jpg',
        JsonKeys.publishedAt: '2026-09-17T10:00:00Z',
        JsonKeys.content: '[Removed]',
      },
      <String, dynamic>{
        JsonKeys.source: <String, dynamic>{
          JsonKeys.id: 'the-guardian-uk',
          JsonKeys.name: 'The Guardian',
        },
        JsonKeys.author: 'Jamie Jackson',
        JsonKeys.title:
            'Manchester United weigh up loan exit for out-of-favour midfielder',
        JsonKeys.description:
            'The club is willing to sanction a January loan for a midfielder who has fallen down the pecking order under the current manager.',
        JsonKeys.url:
            'https://www.theguardian.com/football/manchester-united-midfielder-loan',
        JsonKeys.urlToImage: null,
        JsonKeys.publishedAt: '2026-09-17T16:45:10Z',
        JsonKeys.content:
            'Manchester United are prepared to let a fringe midfielder leave on loan in January after he was left out of the matchday squad for a third successive game... [+1650 chars]',
      },
      <String, dynamic>{
        JsonKeys.source: <String, dynamic>{
          JsonKeys.id: null,
          JsonKeys.name: 'Manchester Evening News',
        },
        JsonKeys.author: null,
        JsonKeys.title: 'Manchester United injury news ahead of the weekend fixture',
        JsonKeys.description:
            'The latest fitness updates from the club as United prepare for their next Premier League match.',
        JsonKeys.url:
            'https://www.manchestereveningnews.co.uk/sport/football/man-utd-injury-news',
        JsonKeys.urlToImage:
            'https://i2-prod.manchestereveningnews.co.uk/incoming/manutd-training.jpg',
        JsonKeys.publishedAt: '2026-09-16T11:20:00Z',
        JsonKeys.content:
            'Manchester United will assess several players on the training ground this week before naming their squad for the next fixture... [+1420 chars]',
      },
      <String, dynamic>{
        JsonKeys.source: <String, dynamic>{
          JsonKeys.id: 'espn',
          JsonKeys.name: 'ESPN',
        },
        JsonKeys.author: 'Rob Dawson',
        JsonKeys.title:
            'Manchester United target Serie A forward as scouts run the rule over Milan clash',
        JsonKeys.description:
            'United scouts were in attendance as reports link the club with a forward who has scored eight goals this season.',
        JsonKeys.url:
            'https://www.espn.com/football/story/manchester-united-forward-target',
        JsonKeys.urlToImage:
            'https://a.espncdn.com/photo/manutd-scout-report.jpg',
        JsonKeys.publishedAt: '2026-09-16T19:10:35Z',
        JsonKeys.content:
            'Manchester United sent scouts to watch a Serie A fixture at the weekend as the club continues its search for attacking reinforcements in January... [+2245 chars]',
      },
      <String, dynamic>{
        JsonKeys.source: <String, dynamic>{
          JsonKeys.id: 'goal',
          JsonKeys.name: 'Goal.com',
        },
        JsonKeys.author: 'Sam Lee',
        JsonKeys.title:
            'Manchester United set asking price for winger as European clubs circle',
        JsonKeys.description:
            'Two Bundesliga clubs have registered interest in a United winger who has struggled for game time this season.',
        JsonKeys.url:
            'https://www.goal.com/en/news/manchester-united-winger-asking-price',
        JsonKeys.urlToImage:
            'https://images.performgroup.com/manutd-winger.jpg',
        JsonKeys.publishedAt: '2026-09-15T09:40:12Z',
        JsonKeys.content:
            'Manchester United have set an asking price for a winger who has fallen out of favour, with two clubs from Germany monitoring his situation... [+1780 chars]',
      },
      <String, dynamic>{
        JsonKeys.source: <String, dynamic>{
          JsonKeys.id: 'the-athletic',
          JsonKeys.name: 'The Athletic',
        },
        JsonKeys.author: 'Laurie Whitwell',
        JsonKeys.title:
            'Inside Manchester United training ground: what changed under the new fitness coach',
        JsonKeys.description:
            'A look at the methods introduced since the arrival of a new head of performance at Carrington.',
        JsonKeys.url:
            'https://theathletic.com/manchester-united-training-ground-fitness',
        JsonKeys.urlToImage:
            'https://theathletic.com/images/manutd-carrington.jpg',
        JsonKeys.publishedAt: '2026-09-14T07:25:00Z',
        JsonKeys.content:
            'Manchester United players have noticed a marked change in the intensity of training sessions since a new fitness coach joined the backroom staff... [+3012 chars]',
      },
      <String, dynamic>{
        JsonKeys.source: <String, dynamic>{
          JsonKeys.id: 'daily-mail',
          JsonKeys.name: 'Daily Mail',
        },
        JsonKeys.author: 'Chris Wheeler',
        JsonKeys.title:
            'Manchester United considering move for free agent centre-back',
        JsonKeys.description:
            'The club is exploring a short-term deal for a centre-back who has been without a club since the summer.',
        JsonKeys.url:
            'https://www.dailymail.co.uk/sport/manchester-united-free-agent-centre-back',
        JsonKeys.urlToImage:
            'https://i.dailymail.co.uk/manutd-centreback-target.jpg',
        JsonKeys.publishedAt: '2026-09-13T13:55:47Z',
        JsonKeys.content:
            'Manchester United are considering a move for a free agent centre-back as cover following a spate of injuries in defence... [+1523 chars]',
      },
      <String, dynamic>{
        JsonKeys.source: <String, dynamic>{
          JsonKeys.id: 'mirror',
          JsonKeys.name: 'Mirror Football',
        },
        JsonKeys.author: 'David McDonnell',
        JsonKeys.title:
            'Manchester United youngster earns first call-up to senior squad',
        JsonKeys.description:
            'A product of the academy has been included in the first-team squad for the first time this season.',
        JsonKeys.url:
            'https://www.mirror.co.uk/sport/football/manchester-united-youngster-call-up',
        JsonKeys.urlToImage:
            'https://i2-prod.mirror.co.uk/manutd-youngster.jpg',
        JsonKeys.publishedAt: '2026-09-12T18:15:30Z',
        JsonKeys.content:
            'Manchester United have handed a first senior call-up to one of their most highly rated academy graduates ahead of the next fixture... [+1290 chars]',
      },
    ],
  };

  static const Map<String, dynamic> successResponseBodyPageTwo =
      <String, dynamic>{
        JsonKeys.status: 'ok',
        JsonKeys.articles: <Map<String, dynamic>>[
          <String, dynamic>{
            JsonKeys.source: <String, dynamic>{
              JsonKeys.id: 'espn-fc',
              JsonKeys.name: 'ESPN FC',
            },
            JsonKeys.author: 'Julien Laurens',
            JsonKeys.title:
                'Manchester United close in on new contract for academy graduate',
            JsonKeys.description:
                'The club is in advanced talks over a long-term deal for a teenager who has broken into the first-team squad this season.',
            JsonKeys.url:
                'https://www.espn.com/football/story/manchester-united-academy-contract',
            JsonKeys.urlToImage:
                'https://a.espncdn.com/photo/manutd-academy-contract.jpg',
            JsonKeys.publishedAt: '2026-09-11T09:00:00Z',
            JsonKeys.content:
                'Manchester United are in advanced discussions over a new long-term contract for one of their academy graduates... [+1380 chars]',
          },
          <String, dynamic>{
            JsonKeys.source: <String, dynamic>{
              JsonKeys.id: 'talksport',
              JsonKeys.name: 'talkSPORT',
            },
            JsonKeys.author: 'Alex Crook',
            JsonKeys.title:
                'Manchester United handed injury boost ahead of derby clash',
            JsonKeys.description:
                'Two first-team players returned to full training this week, easing the selection headache for the upcoming derby.',
            JsonKeys.url:
                'https://talksport.com/football/manchester-united-injury-boost-derby',
            JsonKeys.urlToImage:
                'https://talksport.com/images/manutd-training-return.jpg',
            JsonKeys.publishedAt: '2026-09-10T15:30:00Z',
            JsonKeys.content:
                'Manchester United have been handed a timely injury boost with two senior players back in full training ahead of the derby... [+1102 chars]',
          },
          <String, dynamic>{
            JsonKeys.source: <String, dynamic>{
              JsonKeys.id: 'metro',
              JsonKeys.name: 'Metro',
            },
            JsonKeys.author: 'Simon Bajkowski',
            JsonKeys.title:
                'Manchester United set to rival Premier League club for teenage sensation',
            JsonKeys.description:
                'Scouts have watched the youngster on multiple occasions as the club considers a move in the January window.',
            JsonKeys.url:
                'https://metro.co.uk/sport/football/manchester-united-teenage-sensation-target',
            JsonKeys.urlToImage:
                'https://metro.co.uk/images/manutd-scout-teenager.jpg',
            JsonKeys.publishedAt: '2026-09-09T12:00:00Z',
            JsonKeys.content:
                'Manchester United are ready to rival a fellow Premier League side for a highly rated teenage forward... [+1567 chars]',
          },
          <String, dynamic>{
            JsonKeys.source: <String, dynamic>{
              JsonKeys.id: 'four-four-two',
              JsonKeys.name: 'FourFourTwo',
            },
            JsonKeys.author: 'Mark White',
            JsonKeys.title:
                'Manchester United player ratings: who impressed in midweek win',
            JsonKeys.description:
                'A closer look at the performances that stood out in a hard-fought midweek victory.',
            JsonKeys.url:
                'https://www.fourfourtwo.com/manchester-united-player-ratings-midweek',
            JsonKeys.urlToImage:
                'https://www.fourfourtwo.com/images/manutd-player-ratings.jpg',
            JsonKeys.publishedAt: '2026-09-08T20:15:00Z',
            JsonKeys.content:
                'Manchester United ground out a hard-fought midweek win, with several players catching the eye... [+1289 chars]',
          },
        ],
      };

  static const Map<String, dynamic> errorResponseBody = <String, dynamic>{
    JsonKeys.status: 'error',
    JsonKeys.message: 'Required parameter q is missing from the request.',
  };

  Future<StateResource<List<Article>>> getNews({int page = 1}) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (returnError) {
      return StateResource<List<Article>>.error(
        errorResponseBody[JsonKeys.message] as String,
      );
    }
    if (page >= 3) {
      return const StateResource<List<Article>>.success(<Article>[]);
    }
    final Map<String, dynamic> pageBody = page == 1
        ? successResponseBody
        : successResponseBodyPageTwo;
    final List<dynamic> articlesJson =
        pageBody[JsonKeys.articles] as List<dynamic>;
    final List<Article> articles = articlesJson
        .map(
          (dynamic articleJson) =>
              Article.fromJson(articleJson as Map<String, dynamic>),
        )
        .toList();
    return StateResource<List<Article>>.success(
      RemovedArticlesFilter.dropRemoved(articles),
    );
  }
}
