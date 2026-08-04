import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zerowaste/l10n/app_localizations.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/leave_contest_service.dart';
import '../../../../core/services/post_image_storage_service.dart';
import '../../../../core/shell/main_tab_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../data/models/leaderboard_doc.dart';
import '../../data/models/post_entry.dart';
import '../../data/models/user_stats.dart';
import '../../data/repositories/points_repository.dart';
import '../widgets/mission_cards.dart';
import '../widgets/points_hero_card.dart';
import '../utils/points_levels.dart';
import '../widgets/recent_posts_grid.dart';

/// 4. sekme: Puan toplama sayfası (dolap / yemek anı / artıklardan ne yaptım).
class PointsPage extends ConsumerStatefulWidget {
  const PointsPage({super.key, this.inTabs = false});

  final bool inTabs;

  @override
  ConsumerState<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends ConsumerState<PointsPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ── Page entrance animation ──
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ── FAB pulse animation ──
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  /// Daily missions loaded from SharedPreferences.
  List<Mission> _missions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      Mission(
        icon: Icons.kitchen_rounded,
        title: l10n.pointsMissionFridge,
        subtitle: l10n.pointsMissionFridgeDesc,
        points: 15,
        completed: _missionCompleted[0],
      ),
      Mission(
        icon: Icons.restaurant_rounded,
        title: l10n.pointsMissionCooking,
        subtitle: l10n.pointsMissionCookingDesc,
        points: 20,
        completed: _missionCompleted[1],
      ),
      Mission(
        icon: Icons.recycling_rounded,
        title: l10n.pointsMissionLeftovers,
        subtitle: l10n.pointsMissionLeftoversDesc,
        points: 25,
        completed: _missionCompleted[2],
      ),
    ];
  }

  /// Load mission completion state from SharedPreferences.
  /// Missions reset daily based on the stored date.
  Future<void> _loadMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('missions_date') ?? '';
    if (savedDate != today) {
      await prefs.setString('missions_date', today);
      await prefs.setStringList('missions_completed', []);
      setState(() => _missionCompleted = [false, false, false]);
    } else {
      final saved = prefs.getStringList('missions_completed') ?? [];
      setState(() {
        _missionCompleted = [
          saved.contains('fridge'),
          saved.contains('cooking'),
          saved.contains('leftovers'),
        ];
      });
    }
  }

  /// Mark a mission as completed in SharedPreferences.
  Future<void> _completeMission(int index) async {
    if (_missionCompleted[index]) return;
    final keys = ['fridge', 'cooking', 'leftovers'];
    final prefs = await SharedPreferences.getInstance();
    final saved = (prefs.getStringList('missions_completed') ?? []);
    if (!saved.contains(keys[index])) {
      saved.add(keys[index]);
      await prefs.setStringList('missions_completed', saved);
    }
    if (mounted) setState(() => _missionCompleted[index] = true);
  }

  /// Clears daily mission completion (e.g. after soft-delete / opt-out restart).
  Future<void> _resetDailyMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString('missions_date', today);
    await prefs.setStringList('missions_completed', []);
    if (mounted) {
      setState(() => _missionCompleted = [false, false, false]);
    }
  }

  /// Check if a submitted post matches a daily mission and mark it completed.
  void _checkAndCompleteMission(_PostCategory cat) {
    switch (cat.label) {
      case 'Dolap':
        _completeMission(0);
      case 'Yemek Anı':
        _completeMission(1);
      case 'Artık Değerlendirme':
        _completeMission(2);
    }
  }

  /// Category definitions for the add-post picker.
  static const _categories = [
    _PostCategory(
      icon: Icons.kitchen_rounded,
      label: 'Dolap',
      points: 15,
      color: Color(0xFF8BC34A),
    ),
    _PostCategory(
      icon: Icons.restaurant_rounded,
      label: 'Yemek Anı',
      points: 20,
      color: Color(0xFFFF9800),
    ),
    _PostCategory(
      icon: Icons.recycling_rounded,
      label: 'Artık Değerlendirme',
      points: 25,
      color: Color(0xFF4CAF50),
    ),
    _PostCategory(
      icon: Icons.more_horiz_rounded,
      label: 'Diğer',
      points: 10,
      color: Color(0xFF7E57C2),
    ),
  ];

  String _localizedCategoryLabel(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context)!;
    switch (label) {
      case 'Dolap':
        return l10n.pointsCategoryFridge;
      case 'Yemek Anı':
        return l10n.pointsCategoryCooking;
      case 'Artık Değerlendirme':
        return l10n.pointsCategoryLeftovers;
      case 'Diğer':
        return l10n.pointsCategoryOther;
      default:
        return label;
    }
  }

  /// User data
  String? _nickname;
  bool _leaderboardOptIn = false;
  /// Bumps to force [_LeaderboardTop3] reload after opt-out / tab revisit.
  int _leaderboardEpoch = 0;
  bool _nicknameLoaded = false;

  /// Posts from Firestore
  List<PostEntry> _posts = [];
  int _totalPoints = 0;
  int _previousPoints = 0;
  bool _isLoading = true;

  /// Level-up / level-down / overlay state
  bool _isLevelUp = false;
  bool _isLevelDown = false;
  bool _journeyDone = false;
  bool _startHeroAnimation = false;
  bool _showPointsAddedOverlay = false;
  bool _showPostRejectedOverlay = false;
  bool _rejectionQueuedAfterApprove = false;
  /// After rejection dialog, run hero countdown / level-down stepper.
  bool _pendingDecreaseAnimation = false;
  PostEntry? _pendingRejectedPost;
  List<String> _pendingNewRejectedIds = [];

  /// Bumps when a new hero-card animation should start (forces widget rebuild).
  int _heroAnimationNonce = 0;

  /// Daily missions
  List<bool> _missionCompleted = [false, false, false];

  /// True while a post photo is uploading to Firebase Storage.
  bool _isUploadingPost = false;

  /// Ignores stale [_loadPosts] responses when a newer load has started.
  int _loadGeneration = 0;

  late PointsRepository _repo;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _repo = PointsRepository();

    _loadNickname();
    _loadMissions();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _entranceController.forward();

    // ── FAB pulse ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    if (_nickname == null) return;
    if (ref.read(tabIndexProvider) != 3) return;
    _loadPosts(allowAnimation: true);
    _loadMissions();
  }

  Future<void> _persistKnownPoints(int total) async {
    if (_nickname == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_known_points_$_nickname', total);
  }

  String _seenRejectedKey(String nickname) => 'seen_rejected_ids_$nickname';

  Future<void> _persistSeenRejectedIds(
    String nickname,
    List<String> ids,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _seenRejectedKey(nickname);
    final existing = prefs.getStringList(key) ?? <String>[];
    final merged = {...existing, ...ids}.toList();
    await prefs.setStringList(key, merged);
  }

  Future<void> _dismissRejectionOverlay() async {
    final nick = _nickname;
    final ids = List<String>.from(_pendingNewRejectedIds);
    if (nick != null && ids.isNotEmpty) {
      await _persistSeenRejectedIds(nick, ids);
    }
    if (!mounted) return;
    final startDecrease = _pendingDecreaseAnimation;
    setState(() {
      _showPostRejectedOverlay = false;
      _pendingNewRejectedIds = [];
      _pendingRejectedPost = null;
      _rejectionQueuedAfterApprove = false;
      _pendingDecreaseAnimation = false;
      if (startDecrease) {
        // Now enter the level-down / countdown journey.
        if (_isLevelDown) {
          _journeyDone = false;
        }
        _heroAnimationNonce++;
        _startHeroAnimation = true;
      }
    });
  }

  /// Plan B load: 1× user_stats + bounded posts (+ rejected overlay query).
  /// Total points come from stats, not by summing all posts.
  Future<void> _loadPosts({bool allowAnimation = false}) async {
    if (_nickname == null) {
      setState(() => _isLoading = false);
      return;
    }

    final generation = ++_loadGeneration;
    final nickname = _nickname!;

    try {
      final user = await ref.read(anonymousAuthServiceProvider).ensureSignedIn();
      if (!mounted || generation != _loadGeneration) return;

      UserStats? stats = await _repo.getUserStats(nickname);
      if (!mounted || generation != _loadGeneration) return;

      // Wipe (admin ban / leaveContest) removes stats. Tell the user, then clear.
      // Do not auto-reclaim from stale prefs.
      if (stats == null) {
        setState(() => _isLoading = false);
        await _showAccountDeletedDialog();
        return;
      }

      if (stats.isDeleted) {
        // Legacy soft-delete docs (pre-wipe ban); treat as gone.
        setState(() => _isLoading = false);
        final localeCode = Localizations.localeOf(context).languageCode;
        await _showAccountDeletedDialog(
          reason: stats.localizedReason(localeCode),
        );
        return;
      }

      if (stats.hasOwner && !stats.isOwnedBy(user.uid)) {
        await _clearLocalUserSession();
        return;
      }

      if (!stats.hasOwner) {
        final outcome = await _repo.claimNickname(
          nickname,
          uid: user.uid,
          optIn: _leaderboardOptIn,
        );
        if (!mounted || generation != _loadGeneration) return;
        if (!outcome.isSuccess || outcome.stats == null) {
          await _clearLocalUserSession();
          return;
        }
        stats = outcome.stats!;
      }

      final posts = await _repo.getPostsByNickname(nickname);
      if (!mounted || generation != _loadGeneration) return;

      List<PostEntry> rejected = [];
      try {
        rejected = await _repo.getRecentRejectedPosts(nickname);
      } catch (e) {
        debugPrint('getRecentRejectedPosts failed: $e');
      }
      // Merge with grid posts so a missing composite index still surfaces rejects.
      final rejectedById = <String, PostEntry>{
        for (final p in rejected)
          if (p.id != null) p.id!: p,
        for (final p in posts)
          if (p.status == PostStatus.rejected && p.id != null) p.id!: p,
      };
      rejected = rejectedById.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted || generation != _loadGeneration) return;

      final total = stats.totalPoints.clamp(0, 999999);

      final prefs = await SharedPreferences.getInstance();
      if (!mounted || generation != _loadGeneration) return;

      final previousPoints =
          prefs.getInt('last_known_points_$nickname') ?? 0;

      final pointsIncreased = total > previousPoints;
      final pointsDecreased = total < previousPoints;
      final shouldAnimateIncrease = allowAnimation && pointsIncreased;
      final shouldAnimateDecrease = allowAnimation && pointsDecreased;
      final isLevelUp = shouldAnimateIncrease &&
          previousPoints > 0 &&
          _getLevelName(previousPoints) != _getLevelName(total);
      final isLevelDown = shouldAnimateDecrease &&
          previousPoints > 0 &&
          _getLevelName(previousPoints) != _getLevelName(total);

      final seenKey = _seenRejectedKey(nickname);
      final hasSeenKey = prefs.containsKey(seenKey);
      final seenIds = prefs.getStringList(seenKey) ?? <String>[];

      List<String> pendingNewRejectedIds = [];
      PostEntry? pendingRejectedPost;
      var showRejectionOverlay = false;
      var queueRejectionAfterApprove = false;
      var pendingDecreaseAnimation = false;

      final rejectedWithId = rejected;

      if (!hasSeenKey) {
        if (allowAnimation && rejectedWithId.isNotEmpty && pointsDecreased) {
          pendingNewRejectedIds =
              rejectedWithId.map((p) => p.id!).toList();
          pendingRejectedPost = rejectedWithId.first;
          showRejectionOverlay = true;
          pendingDecreaseAnimation = shouldAnimateDecrease;
          await prefs.setStringList(seenKey, <String>[]);
        } else if (allowAnimation &&
            rejectedWithId.isNotEmpty &&
            !pointsIncreased) {
          // First open with unseen rejects (no point drop): show latest.
          pendingNewRejectedIds = [rejectedWithId.first.id!];
          pendingRejectedPost = rejectedWithId.first;
          showRejectionOverlay = true;
          await prefs.setStringList(
            seenKey,
            rejectedWithId.skip(1).map((p) => p.id!).toList(),
          );
        } else {
          await prefs.setStringList(
            seenKey,
            rejectedWithId.map((p) => p.id!).toList(),
          );
        }
      } else {
        final newRejected =
            rejectedWithId.where((p) => !seenIds.contains(p.id)).toList();
        if (newRejected.isNotEmpty) {
          pendingNewRejectedIds = newRejected.map((p) => p.id!).toList();
          pendingRejectedPost = newRejected.first;
          if (shouldAnimateIncrease) {
            queueRejectionAfterApprove = true;
          } else if (allowAnimation) {
            showRejectionOverlay = true;
            if (shouldAnimateDecrease) {
              pendingDecreaseAnimation = true;
            }
          }
        }
      }

      // Points dropped: always explain before countdown, even if reject
      // query is empty or ids were already marked seen.
      if (shouldAnimateDecrease) {
        showRejectionOverlay = true;
        pendingDecreaseAnimation = true;
        if (pendingRejectedPost == null && rejectedWithId.isNotEmpty) {
          pendingRejectedPost = rejectedWithId.first;
          pendingNewRejectedIds = [rejectedWithId.first.id!];
        }
      }

      // Defer persist while points changed — even if this load is off-tab
      // (!allowAnimation). Otherwise last_known_points catches up silently and
      // the next Points visit never sees a decrease/rejection to show.
      if (!pointsIncreased && !pointsDecreased) {
        await _persistKnownPoints(total);
      }

      if (!mounted || generation != _loadGeneration) return;

      debugPrint(
        'Points load: allowAnim=$allowAnimation prev=$previousPoints '
        'total=$total rejected=${rejectedWithId.length} '
        'showReject=$showRejectionOverlay decrease=$shouldAnimateDecrease',
      );

      setState(() {
        _posts = posts;
        _totalPoints = total;
        _isLoading = false;
        _previousPoints = previousPoints;
        _isLevelUp = isLevelUp;
        _isLevelDown = isLevelDown;
        _journeyDone = !isLevelUp && !isLevelDown;
        _rejectionQueuedAfterApprove = queueRejectionAfterApprove;

        if (shouldAnimateIncrease) {
          _pendingNewRejectedIds = pendingNewRejectedIds;
          _pendingRejectedPost = pendingRejectedPost;
          _pendingDecreaseAnimation = false;
          _showPointsAddedOverlay = true;
          _showPostRejectedOverlay = false;
          _startHeroAnimation = false;
        } else if (showRejectionOverlay) {
          _pendingNewRejectedIds = pendingNewRejectedIds;
          _pendingRejectedPost = pendingRejectedPost;
          _pendingDecreaseAnimation = pendingDecreaseAnimation;
          _showPointsAddedOverlay = false;
          _showPostRejectedOverlay = true;
          _startHeroAnimation = false;
          // Keep page usable under the dialog; journey starts on dismiss.
          if (pendingDecreaseAnimation) {
            _journeyDone = true;
          }
        } else if (shouldAnimateDecrease) {
          // Fallback — should be rare after the force-show above.
          _pendingDecreaseAnimation = true;
          _showPointsAddedOverlay = false;
          _showPostRejectedOverlay = true;
          _startHeroAnimation = false;
          _journeyDone = true;
        } else {
          // Soft/background reload: refresh data but never dismiss an open
          // rejection dialog the user hasn't acknowledged yet.
          _showPointsAddedOverlay = false;
          if (!_showPostRejectedOverlay) {
            _startHeroAnimation = false;
          }
        }
      });
    } catch (e) {
      if (mounted && generation == _loadGeneration) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getLevelName(int pts) {
    if (pts >= 1200) return '_ikon_';
    if (pts >= 800) return '_champion_';
    if (pts >= 500) return '_legend_';
    if (pts >= 300) return '_expert_';
    if (pts >= 150) return '_master_';
    if (pts >= 50) return '_curious_';
    return '_novice_';
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNickname = prefs.getString('leaderboard_nickname');
    final savedOptIn = prefs.getBool('leaderboard_opt_in');
    setState(() {
      _nickname = savedNickname;
      _leaderboardOptIn = savedOptIn ?? false;
      _nicknameLoaded = true;
    });
    final onPointsTab = ref.read(tabIndexProvider) == 3;
    _loadPosts(allowAnimation: onPointsTab);
  }

  Future<void> _showAccountDeletedDialog({String? reason}) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final reasonText = reason?.trim();
    final hasReason = reasonText != null && reasonText.isNotEmpty;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.orange.shade600, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.accountDeletedTitle,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountDeletedMessage,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            if (hasReason) ...[
              const SizedBox(height: 12),
              Text(
                l10n.accountDeletedReason(reasonText),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.accountDeletedOk,
              style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    await _clearLocalUserSession();
  }

  /// Clears nickname / points prefs so the user can start the contest again.
  Future<void> _clearLocalUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final nick = _nickname;
    if (nick != null) {
      await prefs.remove('last_known_points_$nick');
      await prefs.remove(_seenRejectedKey(nick));
    }
    await prefs.remove('leaderboard_nickname');
    await prefs.remove('leaderboard_opt_in');
    await _resetDailyMissions();
    await ref.read(chatMessagesProvider.notifier).clear();

    if (!mounted) return;
    setState(() {
      _nickname = null;
      _leaderboardOptIn = false;
      _posts = [];
      _totalPoints = 0;
      _previousPoints = 0;
      _isLoading = false;
      _startHeroAnimation = false;
      _isLevelUp = false;
      _isLevelDown = false;
      _journeyDone = true;
      _showPointsAddedOverlay = false;
      _showPostRejectedOverlay = false;
      _rejectionQueuedAfterApprove = false;
      _pendingDecreaseAnimation = false;
      _pendingNewRejectedIds = [];
      _pendingRejectedPost = null;
      _leaderboardEpoch++;
    });
  }

  Future<void> _showOptOutDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.orange.shade600, size: 24),
            const SizedBox(width: 10),
            Text(
              l10n.optOutTitle,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.optOutMessage,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.optOutCancel,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                color: AppColors.inkLight,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.optOutConfirm,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final l10nConfirm = AppLocalizations.of(context)!;
      final nick = _nickname!;
      try {
        await ref.read(anonymousAuthServiceProvider).ensureSignedIn();
        await ref.read(leaveContestServiceProvider).leaveContest(nick);
        await _clearLocalUserSession();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nConfirm.optOutSuccess),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFFFA726),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } on LeaveContestException catch (e) {
        if (!mounted) return;
        final message = e.isBannedNickname
            ? l10nConfirm.optOutBannedError
            : e.isPermissionDenied
                ? l10nConfirm.optOutPermissionError
                : l10nConfirm.optOutGenericError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10nConfirm.optOutGenericError),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<bool> _showNicknameDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final nicknameController = TextEditingController(text: _nickname ?? '');
    bool optIn = false;
    String? optInError;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          l10n.pointsNicknameDialogTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          l10n.pointsNicknameDialogSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            color: AppColors.inkLight.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // ── Uyarı: bir daha değiştirilemez ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.pointsNicknameWarning,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11.5,
                                  height: 1.4,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nicknameController,
                        maxLength: 20,
                        decoration: InputDecoration(
                          hintText: l10n.pointsNicknameHint,
                          hintStyle: TextStyle(
                            color: AppColors.stone.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: AppColors.paper.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.pointsNicknameValidationEmpty;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: optIn,
                              onChanged: (v) {
                                setDialogState(() {
                                  optIn = v ?? false;
                                  if (optIn) optInError = null;
                                });
                              },
                              activeColor: AppColors.brandOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.pointsLeaderboardOptIn,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13,
                                height: 1.4,
                                color: AppColors.inkLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (optInError != null) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: Text(
                            optInError!,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 36),
                        child: Text(
                          l10n.pointsPrivacyDisclaimer,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            height: 1.3,
                            color: AppColors.inkLight.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                l10n.optOutCancel,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.inkLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                final nameOk =
                                    formKey.currentState?.validate() ?? false;
                                if (!optIn) {
                                  setDialogState(() {
                                    optInError = l10n.pointsNicknameOptInRequired;
                                  });
                                }
                                if (nameOk && optIn) {
                                  Navigator.pop(ctx, {
                                    'nickname': nicknameController.text.trim(),
                                    'optIn': true,
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: Text(
                                l10n.pointsSave,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      final chosenNick = result['nickname'] as String;
      final optIn = result['optIn'] as bool;

      final user = await ref.read(anonymousAuthServiceProvider).ensureSignedIn();
      final outcome = await _repo.claimNickname(
        chosenNick,
        uid: user.uid,
        optIn: optIn,
      );

      if (!outcome.isSuccess) {
        if (mounted) {
          final message = outcome.status == NicknameClaimStatus.deleted
              ? l10n.pointsNicknameUnavailable
              : l10n.pointsNicknameTaken;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return false;
      }

      if (outcome.stats != null && outcome.stats!.optIn != optIn) {
        try {
          await _repo.updateOptIn(chosenNick, optIn, uid: user.uid);
        } catch (_) {}
      }

      if (!mounted) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('leaderboard_nickname', chosenNick);
      await prefs.setBool(
        'leaderboard_opt_in',
        optIn,
      );
      if (!mounted) return false;
      setState(() {
        _nickname = chosenNick;
        _leaderboardOptIn = optIn;
      });
      _loadPosts(allowAnimation: ref.read(tabIndexProvider) == 3);
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onAddPost() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CategoryPickerSheet(
        categories: _categories,
        onSelect: (cat) {
          Navigator.pop(ctx);
          _pickImageAndAddPost(cat);
        },
      ),
    );
  }

  Future<void> _pickImageAndAddPost(_PostCategory cat) async {
    final l10n = AppLocalizations.of(context)!;
    if (_nicknameLoaded && _nickname == null) {
      final saved = await _showNicknameDialog();
      if (!saved) return;
    }

    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brandOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo_rounded,
                  color: AppColors.brandOrange,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.pointsAddPhoto,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.pointsPhotoSource,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkLight.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.stone.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.brandOrange,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          l10n.pointsCamera,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.stone,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.stone.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.photo_library_rounded,
                          color: AppColors.brandOrange,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          l10n.pointsGallery,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.stone,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      await _addNewPost(cat, imageBytes: bytes);
    }
  }

  Future<void> _addNewPost(_PostCategory cat, {required Uint8List imageBytes}) async {
    final l10n = AppLocalizations.of(context)!;
    if (_isUploadingPost) return;

    setState(() => _isUploadingPost = true);

    try {
      await ref.read(anonymousAuthServiceProvider).ensureSignedIn();

      final postId = _repo.newPostId();
      final imageUrl = await ref.read(postImageStorageServiceProvider).uploadPostImage(
        bytes: imageBytes,
        postId: postId,
      );

      final owner = await ref.read(anonymousAuthServiceProvider).ensureSignedIn();
      final post = PostEntry(
        id: postId,
        nickname: _nickname ?? l10n.pointsAnonymous,
        category: cat.label,
        points: cat.points,
        imageUrl: imageUrl,
        imageColor: cat.color.value,
        status: PostStatus.pending,
        leaderboardOptIn: _leaderboardOptIn,
      );

      await _repo.submitPost(post, id: postId, ownerUid: owner.uid);

      if (!mounted) return;

      setState(() {
        _posts.insert(0, post);
      });

      _checkAndCompleteMission(cat);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pointsPostSent(_localizedCategoryLabel(context, cat.label))),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFFFA726),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } on PostImageStorageException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pointsPhotoUploadError),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
        debugPrint('Post image upload failed: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pointsPhotoUploadError),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
        debugPrint('Post submit failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isUploadingPost = false);
    }
  }

  Widget _buildPointsAddedOverlay() {
    final l10n = AppLocalizations.of(context)!;
    return IgnorePointer(
      ignoring: !_showPointsAddedOverlay,
      child: AnimatedOpacity(
        opacity: _showPointsAddedOverlay ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.brandOrange,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pointsLevelUpTitle,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.pointsLevelUpDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.inkLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              _showPointsAddedOverlay = false;
                              _heroAnimationNonce++;
                              _startHeroAnimation = true;
                              if (_rejectionQueuedAfterApprove &&
                                  _pendingNewRejectedIds.isNotEmpty) {
                                _showPostRejectedOverlay = true;
                                _rejectionQueuedAfterApprove = false;
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.pointsKeepGoing,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostRejectedOverlay() {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final reason =
        _pendingRejectedPost?.localizedAdminNote(localeCode)?.trim();
    final hasReason = reason != null && reason.isNotEmpty;
    const red = Color(0xFFEF5350);
    final isPointsRemoved = _pendingDecreaseAnimation &&
        _previousPoints > _totalPoints;
    final removed = (_previousPoints - _totalPoints).clamp(0, 999999);

    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPointsRemoved
                            ? Icons.remove_circle_rounded
                            : Icons.cancel_rounded,
                        color: red,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPointsRemoved
                          ? l10n.pointsRemovedTitle
                          : l10n.pointsRejectedTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPointsRemoved
                          ? l10n.pointsRemovedDesc(removed, _totalPoints)
                          : l10n.pointsRejectedDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.inkLight,
                      ),
                    ),
                    if (hasReason) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: red.withOpacity(0.25)),
                        ),
                        child: Text(
                          l10n.pointsRejectedReason(reason),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _dismissRejectionOverlay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.pointsRejectedOk,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _showContent => (!_isLevelUp && !_isLevelDown) || _journeyDone;

  @override
  Widget build(BuildContext context) {
    // ── Tab switch listener: reload posts when user returns to this tab ──
    ref.listen<int>(tabIndexProvider, (int? prev, int next) {
      if (prev != null && prev != next && next == 3 && mounted) {
        _loadPosts(allowAnimation: true);
        _loadMissions();
        setState(() => _leaderboardEpoch++);
      }
    });

    final bodyContent = FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, widget.inTabs ? 170 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Gamification Hero Card ──
                    PointsHeroCard(
                      key: ValueKey('hero_${_totalPoints}_$_heroAnimationNonce'),
                      totalPoints:
                          (_pendingDecreaseAnimation && !_startHeroAnimation)
                              ? _previousPoints
                              : _totalPoints,
                      previousPoints: _previousPoints,
                      startAnimation: _startHeroAnimation,
                      // Show nick only after at least one post (photo upload done).
                      nickname: _posts.isNotEmpty ? _nickname : null,
                      onAnimationComplete: () => _persistKnownPoints(_totalPoints),
                      onJourneyComplete: () async {
                        await _persistKnownPoints(_totalPoints);
                        if (mounted) {
                          setState(() => _journeyDone = true);
                        }
                      },
                      onOptOut: (_leaderboardOptIn && _posts.isNotEmpty)
                          ? () => _showOptOutDialog()
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Below content: hidden during level-up journey ──
                    AnimatedOpacity(
                      opacity: _showContent ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      child: IgnorePointer(
                        ignoring: !_showContent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Leaderboard top 3 ──
                            _LeaderboardTop3(
                              key: ValueKey(_leaderboardEpoch),
                              repo: _repo,
                            ),
                            const SizedBox(height: 28),
                            MissionCardsSection(
                              missions: _missions(context),
                              onMissionTap: (index) {
                                if (index < _categories.length) {
                                  _pickImageAndAddPost(_categories[index]);
                                } else {
                                  _pickImageAndAddPost(_categories.last);
                                }
                              },
                            ),
                            const SizedBox(height: 28),
                            RecentPostsGrid(posts: _posts, onAddPost: _onAddPost),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );

    final safeBody = SafeArea(top: true, bottom: false, child: bodyContent);

    // ── Pulsing FAB (also hidden during level-up) ──
    final bottomPad = widget.inTabs ? 140.0 : 24.0;

    final fab = AnimatedOpacity(
      opacity: _showContent && !_isUploadingPost ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: IgnorePointer(
        ignoring: !_showContent || _isUploadingPost,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20, bottom: bottomPad),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandOrange.withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _onAddPost,
                  backgroundColor: AppColors.brandOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add_a_photo_rounded, size: 24),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.inTabs) {
      return Stack(children: [
        safeBody,
        fab,
        if (_showPointsAddedOverlay) _buildPointsAddedOverlay(),
        if (_showPostRejectedOverlay) _buildPostRejectedOverlay(),
        if (_isUploadingPost) _buildUploadOverlay(),
      ]);
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(children: [
        safeBody,
        fab,
        if (_showPointsAddedOverlay) _buildPointsAddedOverlay(),
        if (_showPostRejectedOverlay) _buildPostRejectedOverlay(),
        if (_isUploadingPost) _buildUploadOverlay(),
      ]),
    );
  }

  Widget _buildUploadOverlay() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.brandOrange),
              const SizedBox(height: 16),
              Text(
                l10n.pointsPhotoUploading,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category definition for the post picker.
class _PostCategory {
  const _PostCategory({
    required this.icon,
    required this.label,
    required this.points,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int points;
  final Color color;
}

/// Bottom sheet to pick a post category.
class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.onSelect,
  });

  final List<_PostCategory> categories;
  final ValueChanged<_PostCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.stone.withOpacity(0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.pointsShareTitle,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.pointsShareSubtitle,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: AppColors.inkLight.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ...categories.map(
              (cat) => _CategoryTile(category: cat, onTap: () => onSelect(cat)),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final _PostCategory category;
  final VoidCallback onTap;

  String _localizedCategoryLabel(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context)!;
    switch (label) {
      case 'Dolap':
        return l10n.pointsCategoryFridge;
      case 'Yemek Anı':
        return l10n.pointsCategoryCooking;
      case 'Artık Değerlendirme':
        return l10n.pointsCategoryLeftovers;
      case 'Diğer':
        return l10n.pointsCategoryOther;
      default:
        return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: category.color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category.icon, color: category.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localizedCategoryLabel(context, category.label),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!.pointsShareHint,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          color: AppColors.inkLight.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '+${category.points} 🌟',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline leaderboard showing the top 3 approved opt-in users.
class _LeaderboardTop3 extends StatefulWidget {
  const _LeaderboardTop3({super.key, required this.repo});

  final PointsRepository repo;

  @override
  State<_LeaderboardTop3> createState() => _LeaderboardTop3State();
}

class _LeaderboardTop3State extends State<_LeaderboardTop3> {
  List<LeaderboardEntry>? _entries;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await widget.repo.getLeaderboard();
    if (mounted) {
      setState(() {
      _entries = entries;
      _loading = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
    if (_entries == null || _entries!.isEmpty) return const SizedBox.shrink();

    final top3 = _entries!.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandOrange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brandOrange.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.leaderboard_rounded,
                size: 16,
                color: AppColors.brandOrange,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.pointsLeaderboardTitle,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(top3.length, (i) => _Top3Tile(
            rank: i + 1,
            nickname: top3[i].nickname,
            points: top3[i].points,
          )),
        ],
      ),
    );
  }
}

/// Single top-3 row.
class _Top3Tile extends StatelessWidget {
  const _Top3Tile({
    required this.rank,
    required this.nickname,
    required this.points,
  });

  final int rank;
  final String nickname;
  final int points;

  @override
  Widget build(BuildContext context) {
    final medalColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final level = pointsLevelForPoints(points);
    final levelName = localizedPointsLevelName(context, level.name);
    final initial = nickname.isNotEmpty ? nickname[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            rank == 1
                ? Icons.emoji_events_rounded
                : rank == 2
                    ? Icons.workspace_premium_rounded
                    : Icons.military_tech_rounded,
            size: 22,
            color: medalColors[rank - 1],
          ),
          const SizedBox(width: 10),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: medalColors[rank - 1].withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: medalColors[rank - 1],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${level.emoji} $levelName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: level.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brandOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  size: 14,
                  color: AppColors.brandOrange,
                ),
                const SizedBox(width: 3),
                Text(
                  '${points.clamp(0, 999999)}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandOrange,
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
