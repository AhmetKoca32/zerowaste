import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:zerowaste/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../points/data/models/post_entry.dart';
import '../../../points/presentation/providers/points_providers.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_guard.dart';
import '../widgets/admin_sidebar.dart';

class AdminPostsPage extends ConsumerStatefulWidget {
  const AdminPostsPage({super.key});

  @override
  ConsumerState<AdminPostsPage> createState() => _AdminPostsPageState();
}

class _AdminPostsPageState extends ConsumerState<AdminPostsPage> {
  List<PostEntry>? _posts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(pointsRepositoryProvider);
      final posts = await repo.getPendingPosts();
      if (mounted) setState(() => _posts = posts);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(PostEntry post, {String? note}) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = ref.read(pointsRepositoryProvider);
      await repo.approvePost(post.id!, adminNote: note);
      if (mounted) {
        setState(() => _posts?.removeWhere((p) => p.id == post.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${post.nickname} icin +${post.points} puan onaylandi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeError(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _reject(PostEntry post) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = ref.read(pointsRepositoryProvider);
      await repo.rejectPost(post.id!);
      if (mounted) {
        setState(() => _posts?.removeWhere((p) => p.id == post.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${post.nickname} gonderisi reddedildi'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeError(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdminGuard(
      child: Consumer(
        builder: (context, ref, _) {
          return AdminShell(
            title: l10n.adminPostsTitle,
            currentPath: GoRouterState.of(context).uri.path,
            onLogout: () async {
              await ref.read(adminAuthServiceProvider).signOut();
              if (context.mounted) context.go('/admin/login');
            },
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadPosts,
              ),
            ],
            body: _buildBody(),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(l10n.homeError(_error!)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadPosts, child: Text(l10n.homeRetry)),
          ],
        ),
      );
    }
    if (_posts == null || _posts!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              l10n.adminPostsEmpty,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(l10n.adminPostsEmptySubtitle),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts!.length,
        itemBuilder: (context, index) {
          final post = _posts![index];
          return _PostCard(
            post: post,
            onApprove: () => _showApproveDialog(post),
            onReject: () => _showRejectConfirm(post),
          );
        },
      ),
    );
  }

  void _showApproveDialog(PostEntry post) {
    final l10n = AppLocalizations.of(context)!;
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminPostsApproveDialog),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${post.nickname} - ${post.category} (+${post.points} puan)'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: l10n.adminPostsAdminNote,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.recipeDetailCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _approve(post, note: noteController.text.isEmpty ? null : noteController.text);
            },
            child: Text(l10n.adminSidebarApprove),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirm(PostEntry post) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminPostsRejectDialog),
        content: Text(l10n.adminPostsRejectConfirm(post.nickname)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.recipeDetailCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _reject(post);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.adminSidebarReject),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onApprove,
    required this.onReject,
  });

  final PostEntry post;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoryColors = {
      'Dolap': const Color(0xFF8BC34A),
      'Yemek Anı': const Color(0xFFFF9800),
      'Artık Değerlendirme': const Color(0xFF4CAF50),
      'Diğer': const Color(0xFF7E57C2),
    };
    final color = categoryColors[post.category] ?? AppColors.brandOrange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      post.nickname[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.nickname,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${post.category} - ${post.createdAt.toString().substring(0, 10)}',
                        style: TextStyle(
                          color: AppColors.inkLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '+${post.points}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 16),
                  label: Text(l10n.adminSidebarReject),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 16),
                  label: Text('+${post.points} ${l10n.adminSidebarApprove}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
