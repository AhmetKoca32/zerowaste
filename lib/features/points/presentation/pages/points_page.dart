import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/mission_cards.dart';
import '../widgets/points_hero_card.dart';
import '../widgets/recent_posts_grid.dart';

/// 4. sekme: Puan toplama sayfası (dolap / yemek anı / artıklardan ne yaptım).
/// Sayfa açıldığında fade-in + slide animasyonu, sağ altta nabız animasyonlu FAB.
class PointsPage extends StatefulWidget {
  const PointsPage({super.key, this.inTabs = false});

  final bool inTabs;

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> with TickerProviderStateMixin {
  // ── Page entrance animation ──
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ── FAB pulse animation ──
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  /// Mock missions — will be driven by backend later.
  static const _missions = [
    Mission(
      icon: Icons.kitchen_rounded,
      title: 'Dolabını paylaş',
      subtitle:
          'Buzdolabı veya kiler fotoğrafı yükle, sıfır atık alışkanlığına puan kazan.',
      points: 15,
      completed: true,
    ),
    Mission(
      icon: Icons.restaurant_rounded,
      title: 'Yemek anını paylaş',
      subtitle: 'Malzemelerinle yemek yaparken çektiğin fotoğrafı gönder.',
      points: 20,
    ),
    Mission(
      icon: Icons.recycling_rounded,
      title: 'Artıklardan ne yaptın?',
      subtitle:
          'Kalan malzemelerden yaptığın tarifi veya değerlendirmeyi anlat.',
      points: 25,
    ),
  ];

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

  /// Mutable posts list — new entries are added via FAB.
  late List<PostEntry> _posts;

  /// Running total for demo.
  int _totalPoints = 160;

  /// Level-up detection for content visibility.
  bool _isLevelUp = false;
  bool _journeyDone = false;
  bool _startHeroAnimation = false;

  /// TEST: set to a value to trigger level-up, set to null for normal mode.
  static const int? _previousPoints = 140;

  @override
  void initState() {
    super.initState();

    // Detect if level-up will happen
    if (_previousPoints != null) {
      _isLevelUp = _getLevelName(_previousPoints!) != _getLevelName(_totalPoints);
    }

    if (_isLevelUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showPointsAddedDialog();
      });
    } else {
      _startHeroAnimation = true;
    }

    _posts = [
      const PostEntry(
        icon: Icons.kitchen_rounded,
        category: 'Dolap',
        points: 15,
        date: '14 Nis',
        imageColor: Color(0xFF8BC34A),
        status: PostStatus.pending,
      ),
      const PostEntry(
        icon: Icons.restaurant_rounded,
        category: 'Yemek Anı',
        points: 20,
        date: '13 Nis',
        imageColor: Color(0xFFFF9800),
        status: PostStatus.approved,
      ),
      const PostEntry(
        icon: Icons.recycling_rounded,
        category: 'Artık Değerlendirme',
        points: 25,
        date: '12 Nis',
        imageColor: Color(0xFF4CAF50),
        status: PostStatus.approved,
      ),
      const PostEntry(
        icon: Icons.more_horiz_rounded,
        category: 'Diğer',
        points: 10,
        date: '11 Nis',
        imageColor: Color(0xFF7E57C2),
        status: PostStatus.rejected,
      ),
      const PostEntry(
        icon: Icons.auto_awesome_rounded,
        category: 'Admin Bonus',
        points: 30,
        date: '10 Nis',
        isAdminBonus: true,
        status: PostStatus.approved,
        adminNote: 'Harika katkı! 🎉',
      ),
    ];

    // ── Page entrance ──
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

  /// Helper to get level name for a given point value.
  String _getLevelName(int pts) {
    if (pts >= 600) return 'Efsane+';
    if (pts >= 300) return 'Efsane';
    if (pts >= 150) return 'Usta';
    if (pts >= 50) return 'Meraklı';
    return 'Çaylak';
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Shows category picker bottom sheet, then adds a new post.
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
                child: const Icon(Icons.add_a_photo_rounded, color: AppColors.brandOrange, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fotoğraf Ekle',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gönderin için fotoğraf kaynağını seç',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkLight.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              // Option 1: Camera
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.stone.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.camera_alt_rounded, color: AppColors.brandOrange, size: 24),
                        SizedBox(width: 14),
                        Text('Kameradan Çek', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        Spacer(),
                        Icon(Icons.chevron_right_rounded, color: AppColors.stone, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Option 2: Gallery
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.stone.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.photo_library_rounded, color: AppColors.brandOrange, size: 24),
                        SizedBox(width: 14),
                        Text('Galeriden Seç', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        Spacer(),
                        Icon(Icons.chevron_right_rounded, color: AppColors.stone, size: 20),
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
      _addNewPost(cat, localImagePath: image.path);
    }
  }

  void _addNewPost(_PostCategory cat, {String? localImagePath}) {
    final now = DateTime.now();
    final months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    final dateStr = '${now.day} ${months[now.month]}';

    setState(() {
      _posts.insert(
        0,
        PostEntry(
          icon: cat.icon,
          category: cat.label,
          points: cat.points,
          date: dateStr,
          localImagePath: localImagePath,
          imageColor: cat.color,
          status: PostStatus.pending,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⏳ ${cat.label} gönderin incelemeye gönderildi!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFFFA726),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPointsAddedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
                  child: const Icon(Icons.verified_rounded, color: AppColors.brandOrange, size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tebrikler! 🎉',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gönderin admin tarafından onaylandı ve kazandığın yeni puanlar hesabına eklendi. Sıfır atık yolculuğunda ilham vermeye devam et!',
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
                      Navigator.pop(context);
                      if (mounted) {
                        setState(() => _startHeroAnimation = true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Harika! Devam Et',
                      style: TextStyle(
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
        );
      },
    );
  }

  /// Whether to show the rest of the page content.
  bool get _showContent => !_isLevelUp || _journeyDone;

  @override
  Widget build(BuildContext context) {
    final bodyContent = FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, widget.inTabs ? 170 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Gamification Hero Card ──
              PointsHeroCard(
                totalPoints: _totalPoints,
                streakDays: 3,
                previousPoints: _previousPoints,
                startAnimation: _startHeroAnimation,
                onJourneyComplete: () {
                  if (mounted) {
                    setState(() => _journeyDone = true);
                  }
                },
              ),
              const SizedBox(height: 28),

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
                      MissionCardsSection(
                        missions: _missions,
                        onMissionTap: (index) {
                          // Handle Diğer logic if index exceeds or just map directly
                          if (index < _categories.length) {
                            _pickImageAndAddPost(_categories[index]);
                          } else {
                            _pickImageAndAddPost(_categories.last); // default fallback
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
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: IgnorePointer(
        ignoring: !_showContent,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20, bottom: bottomPad),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(scale: _pulseAnimation.value, child: child);
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
      return Stack(children: [safeBody, fab]);
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(children: [safeBody, fab]),
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
            const Text(
              'Ne paylaşmak istersin?',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bir kategori seç ve fotoğraf ekle',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: AppColors.inkLight.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ...categories.map((cat) => _CategoryTile(
                  category: cat,
                  onTap: () => onSelect(cat),
                )),
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
                        category.label,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Fotoğraf çek veya galeriden seç',
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
