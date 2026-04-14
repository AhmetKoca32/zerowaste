import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/recipe.dart';

void showRecipeDetailSheet(
  BuildContext context, {
  required Recipe recipe,
  String? localImagePath,
  bool showSavePrompt = false,
  VoidCallback? onSave,
  bool canAddPhoto = false,
  bool showPlaceholderImage = true,
  Future<String?> Function(XFile file)? onImagePicked,
  Future<void> Function()? onDelete,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      builder: (context, scrollController) => _RecipeDetailContent(
        recipe: recipe,
        localImagePath: localImagePath,
        showSavePrompt: showSavePrompt,
        onSave: onSave,
        canAddPhoto: canAddPhoto,
        showPlaceholderImage: showPlaceholderImage,
        onImagePicked: onImagePicked,
        onDelete: onDelete,
        scrollController: scrollController,
      ),
    ),
  );
}

class _RecipeDetailContent extends StatefulWidget {
  const _RecipeDetailContent({
    required this.recipe,
    this.localImagePath,
    this.showSavePrompt = false,
    this.onSave,
    this.canAddPhoto = false,
    this.showPlaceholderImage = true,
    this.onImagePicked,
    this.onDelete,
    required this.scrollController,
  });

  final Recipe recipe;
  final String? localImagePath;
  final bool showSavePrompt;
  final VoidCallback? onSave;
  final bool canAddPhoto;
  final bool showPlaceholderImage;
  final Future<String?> Function(XFile file)? onImagePicked;
  final Future<void> Function()? onDelete;
  final ScrollController scrollController;

  @override
  State<_RecipeDetailContent> createState() => _RecipeDetailContentState();
}

class _RecipeDetailContentState extends State<_RecipeDetailContent> {
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _localImagePath = widget.localImagePath;
  }

  @override
  void didUpdateWidget(covariant _RecipeDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.localImagePath != oldWidget.localImagePath) {
      _localImagePath = widget.localImagePath;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null || !mounted || widget.onImagePicked == null) return;
    final path = await widget.onImagePicked!(file);
    if (path != null && mounted) setState(() => _localImagePath = path);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (widget.onDelete == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tarifi sil',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Bu tarifi kaydettiğiniz listeden silmek istediğinize emin misiniz?',
          style: TextStyle(fontFamily: 'Manrope'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'İptal',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.inkLight,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sil',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.onDelete!();
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.brandOrange,
              ),
              title: const Text(
                'Galeriden seç',
                style: TextStyle(fontFamily: 'Manrope'),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.brandOrange,
              ),
              title: const Text(
                'Fotoğraf çek',
                style: TextStyle(fontFamily: 'Manrope'),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final path = _localImagePath;
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        return Stack(
          fit: StackFit.passthrough,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                file,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            if (widget.canAddPhoto && widget.onImagePicked != null)
              Positioned(
                right: 12,
                bottom: 12,
                child: Material(
                  color: AppColors.brandOrange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: _showImageSourcePicker,
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }
    }

    final networkUrl = widget.recipe.imageUrl;
    if (networkUrl != null &&
        networkUrl.isNotEmpty &&
        !networkUrl.startsWith('file')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          networkUrl,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildImageWithAddOption(),
        ),
      );
    }
    return _buildImageWithAddOption();
  }

  Widget _buildImageWithAddOption() {
    if (widget.showPlaceholderImage) {
      final placeholder = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/image/yemek.png',
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
      if (widget.canAddPhoto && widget.onImagePicked != null) {
        return Stack(
          fit: StackFit.passthrough,
          children: [
            placeholder,
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showImageSourcePicker,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Fotoğraf ekle',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
      return placeholder;
    }

    if (widget.canAddPhoto && widget.onImagePicked != null) {
      return GestureDetector(
        onTap: _showImageSourcePicker,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.stone.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, color: AppColors.brandOrange, size: 20),
              SizedBox(width: 8),
              Text(
                'Fotoğraf ekle',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: AppColors.brandOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.stone.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 22),
                    onPressed: () => _confirmDelete(context),
                    color: AppColors.terracotta,
                    tooltip: 'Tarifi sil',
                  ),
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                  color: AppColors.inkLight,
                ),
              ],
            ),
          ),
          if (widget.showSavePrompt && widget.onSave != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.inkLight,
                        side: BorderSide(
                          color: AppColors.stone.withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kapat',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave!();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kaydet',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                _buildImage(),

                // Özet istatistikler
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        icon: Icons.shopping_basket_outlined,
                        value: '${recipe.ingredients.length}',
                        label: 'Malzeme',
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: AppColors.stone.withOpacity(0.3),
                      ),
                      _StatItem(
                        icon: Icons.format_list_numbered,
                        value: '${recipe.instructions.length}',
                        label: 'Adım',
                      ),
                    ],
                  ),
                ),

                // Açıklama
                if (recipe.description != null &&
                    recipe.description!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    recipe.description!,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.inkLight,
                      height: 1.6,
                    ),
                  ),
                ],

                // Malzemeler
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.stone.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/icons/alisveris_icon.png',
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Malzemeler',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${recipe.ingredients.length} adet',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: AppColors.inkLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...recipe.ingredients.asMap().entries.map((e) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: e.key < recipe.ingredients.length - 1
                                ? 10
                                : 0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 7),
                                decoration: const BoxDecoration(
                                  color: AppColors.brandOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  e.value,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.ink,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Yapılış
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.stone.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book_outlined,
                            size: 18,
                            color: AppColors.brandOrange,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Yapılış',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${recipe.instructions.length} adım',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: AppColors.inkLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...recipe.instructions.asMap().entries.map((e) {
                        final isLast = e.key == recipe.instructions.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.brandOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${e.key + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom: isLast ? 0 : 12,
                                  ),
                                  padding: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    border: isLast
                                        ? null
                                        : Border(
                                            bottom: BorderSide(
                                              color: AppColors.stone
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: isLast ? 0 : 12,
                                    ),
                                    child: Text(
                                      e.value,
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.ink,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.brandOrange, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            color: AppColors.inkLight,
          ),
        ),
      ],
    );
  }
}
