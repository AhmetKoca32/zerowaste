import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 4. sekme: Puan toplama sayfası (dolap / yemek anı / artıklardan ne yaptım).
/// Şu aşamada sadece tasarım; gönderi ve giriş sonraki aşamada.
class PointsPage extends StatelessWidget {
  const PointsPage({super.key, this.inTabs = false});

  final bool inTabs;

  @override
  Widget build(BuildContext context) {
    final bodyContent = SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, inTabs ? 120 : 32),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildPointsCard(context),
              const SizedBox(height: 28),
              _buildSectionTitle(context, 'Nasıl puan kazanırım?'),
              const SizedBox(height: 12),
              _buildHowToCard(
                context,
                icon: Icons.kitchen,
                title: 'Dolabını paylaş',
                subtitle: 'Buzdolabı veya kiler fotoğrafı yükle, sıfır atık alışkanlığına puan kazan.',
              ),
              const SizedBox(height: 12),
              _buildHowToCard(
                context,
                icon: Icons.restaurant,
                title: 'Yemek anını paylaş',
                subtitle: 'Malzemelerinle yemek yaparken çektiğin fotoğrafı gönder.',
              ),
              const SizedBox(height: 12),
              _buildHowToCard(
                context,
                icon: Icons.recycling,
                title: 'Artıklardan ne yaptın?',
                subtitle: 'Kalan malzemelerden yaptığın tarifi veya değerlendirmeyi anlat, puan kazan.',
              ),
              const SizedBox(height: 28),
              _buildCtaButton(context),
              const SizedBox(height: 24),
              _buildRecentSection(context),
            ],
        ),
    );
    if (inTabs) return bodyContent;
    return Scaffold(
      body: bodyContent,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.brandCream.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.emoji_events_outlined, color: AppColors.brandOrange, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Puanlarım',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandOrange,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Katkılarınla puan topla',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkLight,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandCream.withOpacity(0.6),
            AppColors.brandCream.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandOrange.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandOrange.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Toplam puan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.brandOrange,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '0',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandOrange,
                  letterSpacing: -1,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gönderi ekleyerek puan kazanmaya başla',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.inkLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.brandOrange,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildHowToCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandCream.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandCream.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.brandOrange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandOrange,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkLight,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gönderi özelliği yakında eklenecek.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.brandOrange,
          ),
        );
      },
      icon: const Icon(Icons.add_photo_alternate_outlined, size: 22),
      label: const Text('Gönderi ekle'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brandOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son gönderilerin',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.brandOrange,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cream.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.stone.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Icon(Icons.photo_library_outlined, size: 48, color: AppColors.inkLight.withOpacity(0.5)),
              const SizedBox(height: 12),
              Text(
                'Henüz gönderi yok',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkLight,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'İlk gönderini ekleyerek puan kazanmaya başla',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.inkLight,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
