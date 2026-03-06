import 'dart:ui';
import 'package:ammentor/screen/leaderboard/provider/leaderboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ammentor/components/theme.dart';
import 'package:ammentor/components/leaderboard_tile.dart';
import 'package:flutter/services.dart';
import 'package:ammentor/screen/leaderboard/model/leaderboard_model.dart';

var overallTrack = Track(id: -1, title: 'Overall');

class _SkeletonTile extends StatefulWidget {
  const _SkeletonTile();
  @override
  State<_SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<_SkeletonTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final shimmer = Color.lerp(
          Colors.white.withOpacity(0.04),
          Colors.white.withOpacity(0.10),
          _ctrl.value,
        )!;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: shimmer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            CircleAvatar(radius: 20, backgroundColor: Colors.white.withOpacity(0.08)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 70,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ],
              ),
            ),
            Container(
              height: 14,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6)),
            ),
          ]),
        );
      },
    );
  }
}

class _TrackChipBar extends ConsumerWidget {
  final List<Track> tracks;
  const _TrackChipBar({required this.tracks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTrack = ref.watch(selectedTrackProvider);
    final fullList = [overallTrack, ...tracks];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fullList.length,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                itemBuilder: (context, index) {
                  final track = fullList[index];
                  final isSelected = selectedTrack?.id == track.id;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(selectedTrackProvider.notifier).state = track;
                    },
                    child: AnimatedScale(
                      scale: isSelected ? 1.0 : 0.95,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.15),
                                    blurRadius: 6,
                                    spreadRadius: 0.4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          track.title,
                          style: AppTextStyles.caption(context).copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardList extends ConsumerStatefulWidget {
  final Track track;
  final AnimationController animationController;

  const _LeaderboardList({
    super.key,
    required this.track,
    required this.animationController,
  });

  @override
  ConsumerState<_LeaderboardList> createState() => _LeaderboardListState();
}

class _LeaderboardListState extends ConsumerState<_LeaderboardList> {
  final ScrollController _scrollController = ScrollController();
  double _topContainerValue = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (current >= maxScroll - 300 && widget.track.id != -1) {
      ref.read(leaderboardProvider(widget.track.id).notifier).loadMore();
    }
    final newVal = current / 120;
    if ((newVal - _topContainerValue).abs() > 0.01) {
      setState(() => _topContainerValue = newVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final async = widget.track.id == -1
        ? ref.watch(overallLeaderboardProvider)
        : ref.watch(leaderboardProvider(widget.track.id));

    return async.when(
      loading: () => Expanded(
        child: ListView.builder(
          itemCount: 8,
          itemBuilder: (_, __) => const _SkeletonTile(),
        ),
      ),
      error: (e, _) => Expanded(child: Center(child: Text('Error: $e'))),
      data: (data) {
        final users = widget.track.id == -1
            ? data as List<LeaderboardUser>
            : (data as LeaderboardPageState).users;
        final isLoadingMore = widget.track.id != -1
            ? (data as LeaderboardPageState).isLoadingMore
            : false;

        if (users.isEmpty) {
          return const Expanded(child: Center(child: Text('No data available.')));
        }

        return Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.01,
              vertical: screenHeight * 0.01,
            ),
            itemCount: users.length + (isLoadingMore ? 3 : 0),
            itemBuilder: (context, index) {
              if (index >= users.length) return const _SkeletonTile();

              final user = users[index];
              final scale = (_topContainerValue > index)
                  ? (1 - (_topContainerValue - index)).clamp(0.7, 1.0)
                  : 1.0;

              final shouldAnimate = index < 20;

              Widget tile = Transform.scale(
                scale: scale,
                alignment: Alignment.center,
                child: LeaderboardTile(
                  rank: index + 1,
                  name: user.name,
                  avatarUrl: user.avatarUrl,
                  points: user.allTimePoints,
                  isCurrentUser: false,
                  onTap: () {},
                ),
              );

              if (shouldAnimate) {
                tile = FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: widget.animationController,
                      curve: Interval(
                          (index * 0.05).clamp(0.0, 1.0), 1.0,
                          curve: Curves.easeIn),
                    ),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.2),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval(
                            (index * 0.05).clamp(0.0, 1.0), 1.0,
                            curve: Curves.easeIn),
                      ),
                    ),
                    child: tile,
                  ),
                );
              }

              return KeyedSubtree(
                key: ValueKey(user.name),
                child: tile,
              );
            },
          ),
        );
      },
    );
  }
}

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTrack = ref.watch(selectedTrackProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Leaderboard',
          style: AppTextStyles.subheading(context)
              .copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          ref.watch(trackListProvider).when(
                loading: () => const SizedBox(
                  height: 54,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => const SizedBox.shrink(),
                data: (trackList) {
                  if (selectedTrack == null && trackList.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(selectedTrackProvider.notifier).state =
                          trackList.first;
                    });
                  }
                  return _TrackChipBar(tracks: trackList);
                },
              ),
          SizedBox(height: screenHeight * 0.01),
          if (selectedTrack != null)
            _LeaderboardList(
              key: ValueKey(selectedTrack.id),
              track: selectedTrack,
              animationController: _animationController,
            ),
        ],
      ),
    );
  }
}