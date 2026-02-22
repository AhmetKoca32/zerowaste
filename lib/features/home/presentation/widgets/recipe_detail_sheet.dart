import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/recipe.dart';

/// Modal bottom sheet: alttan açılır, ekranın tamamını kapatmaz (DraggableScrollableSheet).
void showRecipeDetailSheet(
  BuildContext context, {
  required Recipe recipe,
  String? localImagePath,
  bool showSavePrompt = false,
  VoidCallback? onSave,
  bool canAddPhoto = false,
  Future<String?> Function(XFile file)? onImagePicked,
  /// When set, shows a delete button (for saved recipes). Callback should remove and then pop.
  Future<void> Function()? onDelete,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) => _RecipeDetailContent(
        recipe: recipe,
        localImagePath: localImagePath,
        showSavePrompt: showSavePrompt,
        onSave: onSave,
        canAddPhoto: canAddPhoto,
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
    this.onImagePicked,
    this.onDelete,
    required this.scrollController,
  });

  final Recipe recipe;
  final String? localImagePath;
  final bool showSavePrompt;
  final VoidCallback? onSave;
  final bool canAddPhoto;
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
    final file = await picker.pickImage(source: source, maxWidth: 1200, imageQuality: 85);
    if (file == null || !mounted || widget.onImagePicked == null) return;
    final path = await widget.onImagePicked!(file);
    if (path != null && mounted) setState(() => _localImagePath = path);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (widget.onDelete == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tarifi sil'),
        content: const Text(
          'Bu tarifi kaydettiğiniz listeden silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.terracotta,
            ),
            child: const Text('Sil'),
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
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden seç'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Fotoğraf çek'),
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

  Widget _buildImage(BuildContext context) {
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
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            if (widget.canAddPhoto && widget.onImagePicked != null)
              Positioned(
                right: 12,
                bottom: 12,
                child: Material(
                  color: AppColors.fern.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: _showImageSourcePicker,
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.add_a_photo, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        );
      }
    }
    final networkUrl = widget.recipe.imageUrl;
    if (networkUrl != null && networkUrl.isNotEmpty && !networkUrl.startsWith('file')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          networkUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImageBlock(context),
        ),
      );
    }
    return _buildImageBlock(context);
  }

  Widget _buildImageBlock(BuildContext context) {
    final placeholder = _buildImagePlaceholder(context);
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 48, color: AppColors.fern.withOpacity(0.8)),
                      const SizedBox(height: 8),
                      Text(
                        'Fotoğraf ekle veya çek',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.forest,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
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

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest,
            blurRadius: 20,
            offset: Offset(0, -4),
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
              color: AppColors.stone,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: AppColors.fern, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.forest,
                        ),
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context),
                    color: AppColors.terracotta,
                    tooltip: 'Tarifi sil',
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: AppColors.inkLight,
                ),
              ],
            ),
          ),
          if (widget.showSavePrompt && widget.onSave != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('Kapat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.inkLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        widget.onSave!();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.save, size: 20),
                      label: const Text('Kaydet'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.fern,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _buildImage(context),
                if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      recipe.description!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.inkLight,
                            height: 1.5,
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _SectionBlock(
                  icon: Icons.shopping_basket_outlined,
                  label: 'Malzemeler',
                  color: AppColors.fern,
                  children: recipe.ingredients
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppColors.fern),
                              ),
                              Expanded(
                                child: Text(
                                  e,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: AppColors.ink),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                _SectionBlock(
                  icon: Icons.menu_book_outlined,
                  label: 'Yapılış',
                  color: AppColors.fern,
                  children: recipe.instructions.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.sage,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${e.key + 1}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.ink,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildImagePlaceholder(BuildContext context) {
  return Container(
    height: 200,
    width: double.infinity,
    color: AppColors.mint.withOpacity(0.4),
    child: Icon(
      Icons.restaurant,
      size: 64,
      color: AppColors.fern.withOpacity(0.6),
    ),
  );
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.icon,
    required this.label,
    required this.color,
    required this.children,
  });

  final IconData icon;
  final String label;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
