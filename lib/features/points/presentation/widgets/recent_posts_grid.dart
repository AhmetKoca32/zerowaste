import 'package:flutter/material.dart';

import 'package:zerowaste/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/post_entry.dart';
import 'post_image_lightbox.dart';
import 'post_image_thumbnail.dart';

/// Instagram-style 2-column grid showing recent posts.
/// Supports loading (shimmer), empty, and populated states.
class RecentPostsGrid extends StatefulWidget {
  const RecentPostsGrid({
    super.key,
    required this.posts,
    this.isLoading = false,
    this.onAddPost,
  });

  final List<PostEntry> posts;
  final bool isLoading;
  final VoidCallback? onAddPost;

  @override
  State<RecentPostsGrid> createState() => _RecentPostsGridState();
}

class _RecentPostsGridState extends State<RecentPostsGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──
        Row(
          children: [
            const Icon(Icons.grid_view_rounded, color: AppColors.brandOrange, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.pointsRecentTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Manrope',
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            if (widget.posts.isNotEmpty)
              Text(
                AppLocalizations.of(context)!.pointsPostCount(widget.posts.length),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkLight.withOpacity(0.6),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Content ──
        if (widget.isLoading)
          _buildShimmerGrid()
        else if (widget.posts.isEmpty)
          _buildEmptyState(context)
        else
          _buildPostsGrid(),
      ],
    );
  }

  /// Shimmer loading placeholders (2x2 grid).
  Widget _buildShimmerGrid() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(4, (index) {
            return _ShimmerCard(animation: _shimmerController);
          }),
        );
      },
    );
  }

  /// Empty state with motivational CTA.
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.brandOrange.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brandOrange.withOpacity(0.1),
                  AppColors.brandOrange.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_a_photo_rounded,
              size: 30,
              color: AppColors.brandOrange.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.pointsEmptyTitle,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.pointsEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.inkLight.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: widget.onAddPost,
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: Text(AppLocalizations.of(context)!.pointsAddPost),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2-column grid with actual posts.
  Widget _buildPostsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.78,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: widget.posts.map((post) => _PostCard(post: post)).toList(),
    );
  }
}

/// Individual post card in the grid.
class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final PostEntry post;

  /// Derive icon from category.
  IconData _categoryIcon() {
    switch (post.category) {
      case 'Dolap':
        return Icons.kitchen_rounded;
      case 'Yemek Anı':
        return Icons.restaurant_rounded;
      case 'Artık Değerlendirme':
        return Icons.recycling_rounded;
      case 'Admin Bonusu':
      case 'Admin Bonus':
        return Icons.auto_awesome_rounded;
      case 'Puan Kesintisi':
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  /// Localized category name for display.
  String _localizedCategory(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (post.category) {
      case 'Dolap':
        return l10n.pointsCategoryFridge;
      case 'Yemek Anı':
        return l10n.pointsCategoryCooking;
      case 'Artık Değerlendirme':
        return l10n.pointsCategoryLeftovers;
      case 'Puan Kesintisi':
        return 'Puan Kesintisi';
      default:
        return l10n.pointsCategoryOther;
    }
  }

  Color? get _imageColor {
    if (post.imageColor == null) return null;
    return Color(post.imageColor!);
  }

  String _formattedDate(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final months = [
      '', l10n.monthAbbrJan, l10n.monthAbbrFeb, l10n.monthAbbrMar, l10n.monthAbbrApr, l10n.monthAbbrMay, l10n.monthAbbrJun,
      l10n.monthAbbrJul, l10n.monthAbbrAug, l10n.monthAbbrSep, l10n.monthAbbrOct, l10n.monthAbbrNov, l10n.monthAbbrDec,
    ];
    return '${post.createdAt.day} ${months[post.createdAt.month]}';
  }

  /// Status-specific styling.
  Color get _statusColor => switch (post.status) {
        PostStatus.pending => const Color(0xFFFFA726),
        PostStatus.approved => const Color(0xFF4CAF50),
        PostStatus.rejected => const Color(0xFFEF5350),
      };

  IconData get _statusIcon => switch (post.status) {
        PostStatus.pending => Icons.schedule_rounded,
        PostStatus.approved => Icons.check_circle_rounded,
        PostStatus.rejected => Icons.cancel_rounded,
      };

  String _statusLabel(BuildContext context) => switch (post.status) {
        PostStatus.pending => AppLocalizations.of(context)!.pointsStatusPending,
        PostStatus.approved => AppLocalizations.of(context)!.pointsStatusApproved,
        PostStatus.rejected => AppLocalizations.of(context)!.pointsStatusRejected,
      };

  @override
  Widget build(BuildContext context) {
    // ── Admin Bonus: completely different card design ──
    if (post.isAdminBonus) {
      return GestureDetector(
        onTap: () => _showPostDetails(context),
        child: _buildAdminBonusCard(context),
      );
    }

    // ── Admin Penalty: deduction card ──
    if (post.isAdminPenalty) {
      return GestureDetector(
        onTap: () => _showPostDetails(context),
        child: _buildAdminPenaltyCard(context),
      );
    }

    final isPending = post.status == PostStatus.pending;
    final isRejected = post.status == PostStatus.rejected;

    return GestureDetector(
      onTap: () => _showPostDetails(context),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isRejected
            ? Border.all(color: const Color(0xFFEF5350).withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PostImageThumbnail(
                    imageUrl: post.imageUrl,
                    localPreviewPath: post.localPreviewPath,
                    placeholderColor:
                        _imageColor ?? AppColors.brandOrange.withOpacity(0.08),
                    placeholderIcon: _categoryIcon(),
                    placeholderIconColor: _imageColor != null
                        ? Colors.white
                        : AppColors.brandOrange,
                    placeholderIconOpacity: isPending ? 0.3 : 0.4,
                  ),
                  // Category icon overlay when no photo
                  if (post.imageUrl == null && post.localPreviewPath == null)
                    Center(
                      child: Opacity(
                        opacity: isPending ? 0.3 : 0.4,
                        child: Icon(
                          _categoryIcon(),
                          size: 36,
                          color: _imageColor != null
                              ? Colors.white
                              : AppColors.brandOrange,
                        ),
                      ),
                    ),
                  // Points badge or status badge - top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: post.status == PostStatus.approved
                        ? _buildPointsBadge()
                        : _buildStatusBadge(context),
                  ),
                  // Pending overlay
                  if (isPending)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.08),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // ── Info bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_categoryIcon(), size: 13, color: AppColors.brandOrange),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _localizedCategory(context),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isRejected
                              ? AppColors.inkLight
                              : AppColors.ink,
                          decoration: isRejected
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formattedDate(context),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.inkLight.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Status row
                Row(
                  children: [
                    Icon(_statusIcon, size: 12, color: _statusColor),
                    const SizedBox(width: 4),
                    Text(
                      _statusLabel(context),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                    if (post.status == PostStatus.approved) ...[
                      const Spacer(),
                      Text(
                        '+${post.points} 🌟',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showPostDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header Image Section ──
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    final hasPhoto =
                        (post.imageUrl != null && post.imageUrl!.isNotEmpty) ||
                        (post.localPreviewPath != null &&
                            post.localPreviewPath!.isNotEmpty);
                    if (!hasPhoto) return;
                    showPostImageLightbox(
                      context,
                      imageUrl: post.imageUrl,
                      localPreviewPath: post.localPreviewPath,
                    );
                  },
                  child: SizedBox(
                    height: 320,
                    width: double.infinity,
                    child: PostImageThumbnail(
                      imageUrl: post.imageUrl,
                      localPreviewPath: post.localPreviewPath,
                      placeholderColor: post.isAdminBonus
                          ? const Color(0xFFFFD54F)
                          : (post.isAdminPenalty
                              ? const Color(0xFFEF9A9A)
                              : (_imageColor ??
                                  AppColors.brandOrange.withOpacity(0.08))),
                      placeholderIcon: post.isAdminBonus
                          ? Icons.auto_awesome_rounded
                          : post.isAdminPenalty
                              ? Icons.remove_circle_outline_rounded
                              : _categoryIcon(),
                      placeholderIconColor: Colors.white,
                      placeholderIconOpacity: 0.8,
                    ),
                  ),
                ),
                // Gradient Overlay for better contrast on top icons
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Floating Close Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                if ((post.imageUrl != null && post.imageUrl!.isNotEmpty) ||
                    (post.localPreviewPath != null &&
                        post.localPreviewPath!.isNotEmpty))
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.zoom_out_map_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.pointsPhotoExpand,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // ── Content Area ──
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildDetailStatusBadge(context),
                      const Spacer(),
                      Text(
                        _formattedDate(context),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkLight.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _localizedCategory(context),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (post.status == PostStatus.approved)
                    Row(
                      children: [
                        Text(
                          post.isAdminPenalty ? 'Kesinti' : AppLocalizations.of(context)!.pointsEarned,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          post.isAdminPenalty ? '${post.points}' : '+${post.points} ${post.isAdminBonus ? '⭐' : '🌟'}',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: post.isAdminPenalty
                                ? const Color(0xFFD32F2F)
                                : post.isAdminBonus
                                    ? const Color(0xFFE8A817)
                                    : const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  
                  if (post.adminNote != null || post.adminNoteEn != null) ...[
                    const SizedBox(height: 20),
                    _buildAdminNoteBox(context),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // ── Action ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.recipeDetailClose,
                        style: const TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon, size: 16, color: _statusColor),
          const SizedBox(width: 6),
          Text(
            _statusLabel(context).toUpperCase(),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _statusColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminNoteBox(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final note = post.localizedAdminNote(localeCode);
    if (note == null || note.isEmpty) return const SizedBox.shrink();

    final isPenalty = post.isAdminPenalty;
    final isRejected = post.status == PostStatus.rejected;
    final accentColor = isPenalty || isRejected
        ? const Color(0xFFD32F2F)
        : const Color(0xFFE8A817);
    final bgColor = (isPenalty || isRejected)
        ? const Color(0xFFD32F2F).withOpacity(0.08)
        : const Color(0xFFFFC107).withOpacity(0.08);
    final borderColor = (isPenalty || isRejected)
        ? const Color(0xFFD32F2F).withOpacity(0.3)
        : const Color(0xFFFFC107).withOpacity(0.3);
    final icon = isPenalty || isRejected
        ? Icons.warning_amber_rounded
        : Icons.stars_rounded;
    final title = isPenalty
        ? l10n.pointsPenaltyNoteTitle
        : l10n.pointsTeamNoteTitle;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accentColor.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+${post.points}',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 2),
          const Text('🌟', style: TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            _statusLabel(context),
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Special card for admin penalty (point deduction).
  Widget _buildAdminPenaltyCard(BuildContext context) {
    const redDark = Color(0xFFD32F2F);
    const redLight = Color(0xFFEF9A9A);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
        ),
        border: Border.all(color: redLight.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: redDark.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Red top area ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEF9A9A), Color(0xFFE57373)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.remove_circle_outline_rounded,
                      size: 40,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  // Points badge - top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: redDark,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: redDark.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${post.points}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Text('💔', style: TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  // Penalty badge - top left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 10, color: redDark),
                          SizedBox(width: 3),
                          Text(
                            'Kesinti',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: redDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Info bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.remove_circle_outline_rounded, size: 13, color: redDark),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        post.localizedAdminNote(Localizations.localeOf(context).languageCode) ??
                            AppLocalizations.of(context)!.pointsPenaltyFallback,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB71C1C),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 11, color: redDark),
                    const SizedBox(width: 4),
                    const Text(
                      'Puan Kesintisi',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: redDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formattedDate(context),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.inkLight.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Special card for admin-awarded bonus points.
  Widget _buildAdminBonusCard(BuildContext context) {
    const goldDark = Color(0xFFE8A817);
    const goldLight = Color(0xFFFFC947);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
        ),
        border: Border.all(color: goldLight.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: goldDark.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gold top area ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Stack(
                children: [
                  // Star pattern
                  Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 40,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  // Points badge - top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: goldDark,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: goldDark.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '+${post.points}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Text('⭐', style: TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  // Admin badge - top left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, size: 10, color: goldDark),
                          SizedBox(width: 3),
                          Text(
                            'Admin',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: goldDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Info bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.card_giftcard_rounded, size: 13, color: goldDark),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        post.localizedAdminNote(Localizations.localeOf(context).languageCode) ??
                            AppLocalizations.of(context)!.pointsBonusFallback,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5D4037),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 11, color: goldDark),
                    const SizedBox(width: 4),
                    const Text(
                      'Admin Bonus',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: goldDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formattedDate(context),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.inkLight.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer placeholder card for loading state.
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final shimmerValue = animation.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * shimmerValue, 0),
              end: Alignment(1.0 + 2.0 * shimmerValue, 0),
              colors: [
                AppColors.cream,
                AppColors.cream.withOpacity(0.4),
                AppColors.cream,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.stone.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.stone.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 30,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.stone.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
