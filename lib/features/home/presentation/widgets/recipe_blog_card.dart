import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/recipe.dart';

class RecipeBlogCard extends StatelessWidget {
  const RecipeBlogCard({
    super.key,
    required this.recipe,
    this.matchCount,
    this.totalSelected,
  });

  final Recipe recipe;
  final int? matchCount;
  final int? totalSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.stone.withOpacity(0.3)),
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildImage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (totalSelected != null && totalSelected! > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: matchCount != null && matchCount! > 0
                              ? AppColors.brandOrange
                              : AppColors.inkLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$matchCount/${recipe.ingredients.length} malzeme elinizde',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: matchCount != null && matchCount! > 0
                                ? AppColors.brandOrange
                                : AppColors.inkLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${recipe.ingredients.length} malzeme · ${recipe.instructions.length} adım',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: AppColors.inkLight,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/icons/alisveris_icon.png',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Malzemeler',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: recipe.ingredients.map((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.brandOrange),
                      ),
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandOrange,
                        disabledBackgroundColor: AppColors.brandOrange,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Center(
                        child: Text(
                          'Tarifi İncele',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      return Image.network(
        recipe.imageUrl!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/images/image/yemek.png',
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
