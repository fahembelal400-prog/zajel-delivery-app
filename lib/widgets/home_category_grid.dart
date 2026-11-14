import 'package:delevery_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomeCategoryItem {
  const HomeCategoryItem({
    required this.title,
    required this.imagePath,
    required this.routeCategory,
  });

  final String title;
  final String imagePath;
  final String routeCategory;
}

const homeCategoryItems = <HomeCategoryItem>[
  HomeCategoryItem(
    title: 'سوبر ماركت',
    imagePath: 'assets/images/categories/supermarkets.png',
    routeCategory: 'سوبر ماركت',
  ),
  HomeCategoryItem(
    title: 'منتجات مميزة',
    imagePath: 'assets/images/categories/specialty.png',
    routeCategory: 'مخبوزات',
  ),
  HomeCategoryItem(
    title: 'مستلزمات الحيوانات',
    imagePath: 'assets/images/categories/pet_shops.png',
    routeCategory: 'مستلزمات الحيوانات',
  ),
  HomeCategoryItem(
    title: 'صيدليات',
    imagePath: 'assets/images/categories/pharmacies.png',
    routeCategory: 'صيدليات',
  ),
  HomeCategoryItem(
    title: 'لحوم ودواجن',
    imagePath: 'assets/images/categories/butchery.png',
    routeCategory: 'لحوم ودواجن',
  ),
  HomeCategoryItem(
    title: 'خضار وفاكهة',
    imagePath: 'assets/images/categories/fruits.png',
    routeCategory: 'خضار وفاكهة',
  ),
];

class HomeCategoryGrid extends StatelessWidget {
  const HomeCategoryGrid({
    super.key,
    required this.onCategoryTap,
    required this.onSeeAllTap,
  });

  final ValueChanged<String> onCategoryTap;
  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'اطلب الآن',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            TextButton(
              onPressed: onSeeAllTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text(
                'عرض الكل',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 18,
            mainAxisExtent: 145,
          ),
          itemCount: homeCategoryItems.length,
          itemBuilder: (context, index) {
            final item = homeCategoryItems[index];
            return _HomeCategoryTile(
              item: item,
              onTap: () => onCategoryTap(item.routeCategory),
            );
          },
        ),
      ],
    );
  }
}

class _HomeCategoryTile extends StatelessWidget {
  const _HomeCategoryTile({required this.item, required this.onTap});

  final HomeCategoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            SizedBox(
              height: 82,
              width: double.infinity,
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222),
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
