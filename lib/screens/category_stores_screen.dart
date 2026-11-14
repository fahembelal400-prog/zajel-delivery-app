import 'package:delevery_app/models/store.dart';
import 'package:delevery_app/screens/store_details_screen.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:delevery_app/widgets/home_category_grid.dart';
import 'package:flutter/material.dart';

const allStoresCategoryLabel = 'كل المتاجر';

class CategoryStoresScreen extends StatefulWidget {
  const CategoryStoresScreen({super.key, required this.initialCategory});

  final String initialCategory;

  @override
  State<CategoryStoresScreen> createState() => _CategoryStoresScreenState();
}

class _CategoryStoresScreenState extends State<CategoryStoresScreen> {
  late String _activeCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeCategory = _resolveInitialCategory(widget.initialCategory);
  }

  String _resolveInitialCategory(String initial) {
    if (initial == allStoresCategoryLabel) {
      return homeCategoryItems.first.routeCategory;
    }
    final known = homeCategoryItems.any((item) => item.routeCategory == initial);
    return known ? initial : homeCategoryItems.first.routeCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Store> get _filteredStores {
    final query = _searchController.text.trim();
    Iterable<Store> stores = dummyStores;

    stores = stores.where((store) => store.category == _activeCategory);

    if (query.isNotEmpty) {
      stores = stores.where(
        (store) =>
            store.name.contains(query) || store.category.contains(query),
      );
    }

    return stores.toList();
  }

  @override
  Widget build(BuildContext context) {
    final stores = _filteredStores;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CategoryScreenHeader(
            searchController: _searchController,
            onSearchChanged: (_) => setState(() {}),
          ),
          _HorizontalCategoryBar(
            activeCategory: _activeCategory,
            onCategorySelected: (category) {
              setState(() => _activeCategory = category);
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: stores.isEmpty
                ? const _EmptyStoresMessage()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: stores.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _CategoryStoreCard(store: stores[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryScreenHeader extends StatelessWidget {
  const _CategoryScreenHeader({
    required this.searchController,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
                  ),
                  const Icon(
                    Icons.location_on,
                    color: AppColors.onPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التوصيل إلى',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color:
                                        AppColors.onPrimary.withValues(alpha: 0.9),
                                  ),
                        ),
                        Text(
                          'حدد موقع التوصيل',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'ابحث عن متجر...',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalCategoryBar extends StatelessWidget {
  const _HorizontalCategoryBar({
    required this.activeCategory,
    required this.onCategorySelected,
  });

  final String activeCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.navTopBorder),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        itemCount: homeCategoryItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = homeCategoryItems[index];
          final isActive = item.routeCategory == activeCategory;
          return _HorizontalCategoryChip(
            item: item,
            isActive: isActive,
            onTap: () => onCategorySelected(item.routeCategory),
          );
        },
      ),
    );
  }
}

class _HorizontalCategoryChip extends StatelessWidget {
  const _HorizontalCategoryChip({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final HomeCategoryItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 92,
          child: Column(
            children: [
              SizedBox(
                height: 44,
                width: double.infinity,
                child: Image.asset(
                  item.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Center(
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 3,
                width: isActive ? 40 : 0,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryStoreCard extends StatelessWidget {
  const _CategoryStoreCard({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
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
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _StoreThumbnail(imageUrl: store.imageUrl),
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
                      const SizedBox(height: 6),
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

class _StoreThumbnail extends StatelessWidget {
  const _StoreThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    final radius = BorderRadius.circular(12);

    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
        ),
        child: const Icon(Icons.store_outlined, color: AppColors.primary),
      );
    }

    return ClipRRect(
      borderRadius: radius,
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

class _EmptyStoresMessage extends StatelessWidget {
  const _EmptyStoresMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }
}
