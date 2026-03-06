import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ammentor/screen/leaderboard/model/leaderboard_model.dart';

final baseUrl = dotenv.env['BACKEND_URL'];

final trackListProvider = FutureProvider<List<Track>>((ref) async {
  final response = await http.get(Uri.parse('$baseUrl/tracks/'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((t) => Track.fromJson(t)).toList();
    
  }
  throw Exception('Failed to fetch tracks');
});

final selectedTrackProvider = StateProvider<Track?>((ref) => null);

class LeaderboardPageState {
  final List<LeaderboardUser> users;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;

  const LeaderboardPageState({
    this.users = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
  });

  LeaderboardPageState copyWith({
    List<LeaderboardUser>? users,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
  }) =>
      LeaderboardPageState(
        users: users ?? this.users,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
      );
}

const _pageSize = 20;

class LeaderboardNotifier
    extends AutoDisposeFamilyAsyncNotifier<LeaderboardPageState, int> {
  @override
  Future<LeaderboardPageState> build(int trackId) async {
    return _fetchPage(1, []);
  }

  Future<LeaderboardPageState> _fetchPage(
      int page, List<LeaderboardUser> existing) async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard/$arg?page=$page&limit=$_pageSize'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch leaderboard');
    }
    final data = json.decode(response.body);
    final List<dynamic> raw = data['leaderboard'];
    final newUsers = raw.map((u) => LeaderboardUser.fromJson(u)).toList();
    return LeaderboardPageState(
      users: [...existing, ...newUsers],
      page: page,
      hasMore: newUsers.length >= _pageSize,
      isLoadingMore: false,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await _fetchPage(current.page + 1, current.users);
      state = AsyncData(next);
    } catch (e, st) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final leaderboardProvider = AsyncNotifierProvider.autoDispose
    .family<LeaderboardNotifier, LeaderboardPageState, int>(
  LeaderboardNotifier.new,
);

final overallLeaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardUser>>((ref) async {
  final tracks = await ref.watch(trackListProvider.future);

  final results = await Future.wait(
    tracks.map((t) => ref.watch(leaderboardProvider(t.id).future)),
  );

  final Map<String, LeaderboardUser> userMap = {};
  for (final users in results) {
    for (final user in users.users) {
      final existing = userMap[user.name];
      userMap[user.name] = existing == null
          ? user
          : LeaderboardUser(
              name: existing.name,
              avatarUrl: existing.avatarUrl,
              allTimePoints: existing.allTimePoints + user.allTimePoints,
              tasksCompleted: existing.tasksCompleted + user.tasksCompleted,
            );
    }
  }

  return userMap.values.toList()
    ..sort((a, b) => b.allTimePoints.compareTo(a.allTimePoints));
});