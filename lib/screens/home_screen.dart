import 'package:delevery_app/data/cart_manager.dart';
import 'package:delevery_app/models/store.dart';
import 'package:delevery_app/screens/category_stores_screen.dart';
import 'package:delevery_app/screens/search_screen.dart';
import 'package:delevery_app/screens/store_details_screen.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:delevery_app/widgets/home_category_grid.dart';
import 'package:delevery_app/widgets/instashop_header.dart';
import 'package:delevery_app/widgets/promo_banner_carousel.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _openSearchScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  void _openCategoryScreen(String category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryStoresScreen(initialCategory: category),
      ),
    );
  }

  void _openSeeAllCategories() {
    _openCategoryScreen(allStoresCategoryLabel);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InstaShopHeader(
            onSearchTap: _openSearchScreen,
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: CartManager.instance,
              builder: (context, _) {
                final extraBottom = CartManager.instance.isEmpty ? 24.0 : 12.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: extraBottom),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: PromoBannerCarousel(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: HomeCategoryGrid(
                      onCategoryTap: _openCategoryScreen,
                      onSeeAllTap: _openSeeAllCategories,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const AvailableStoresSection(stores: dummyStores),
                  ),
                ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AvailableStoresSection extends StatelessWidget {
  const AvailableStoresSection({super.key, required this.stores});

  final List<Store> stores;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'المتاجر المتاحة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 14),
        if (stores.isEmpty)
          const _NoStoresCard()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stores.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return StoreCard(store: stores[index]);
            },
          ),
      ],
    );
  }
}

class _NoStoresCard extends StatelessWidget {
  const _NoStoresCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 48,
            color: AppColors.textHint.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد متاجر مطابقة للبحث',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StoreDetailsScreen(store: store),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _StoreImage(imageUrl: store.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              store.deliveryTime,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Color(0xFFFFB800),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            store.rating.toStringAsFixed(1),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ],
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

class _StoreImage extends StatelessWidget {
  const _StoreImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    final borderRadius = BorderRadius.circular(12);

    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius,
        ),
        child: const Icon(
          Icons.store_outlined,
          color: AppColors.primary,
          size: 32,
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          color: AppColors.surface,
          child: const Icon(Icons.store_outlined, color: AppColors.primary),
        ),
      ),
    );
  }
}
