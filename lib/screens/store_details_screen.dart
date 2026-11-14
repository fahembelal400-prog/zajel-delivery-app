import 'package:delevery_app/data/cart_manager.dart';
import 'package:delevery_app/models/product.dart';
import 'package:delevery_app/models/store.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:delevery_app/widgets/product_card.dart';
import 'package:delevery_app/widgets/sticky_cart_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _StoreAisle {
  const _StoreAisle({
    required this.key,
    required this.label,
    required this.icon,
    required this.tint,
  });

  final String key;
  final String label;
  final IconData icon;
  final Color tint;
}

const _storeAisles = <_StoreAisle>[
  _StoreAisle(
    key: 'offers',
    label: 'العروض',
    icon: Icons.local_offer_outlined,
    tint: Color(0xFFFDF2F8),
  ),
  _StoreAisle(
    key: 'dairy',
    label: 'ألبان وبيض',
    icon: Icons.breakfast_dining_outlined,
    tint: Color(0xFFF0F9FF),
  ),
  _StoreAisle(
    key: 'fruits',
    label: 'خضار وفاكهة',
    icon: Icons.eco_outlined,
    tint: Color(0xFFF0FDF4),
  ),
  _StoreAisle(
    key: 'bakery',
    label: 'مخبوزات',
    icon: Icons.bakery_dining,
    tint: Color(0xFFFFF7ED),
  ),
  _StoreAisle(
    key: 'snacks',
    label: 'سناكس ومقرمشات',
    icon: Icons.fastfood_outlined,
    tint: Color(0xFFFEFCE8),
  ),
  _StoreAisle(
    key: 'drinks',
    label: 'مشروبات وعصائر',
    icon: Icons.local_drink_outlined,
    tint: Color(0xFFF5F3FF),
  ),
];

class StoreDetailsScreen extends StatefulWidget {
  const StoreDetailsScreen({super.key, required this.store});

  final Store store;

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    for (final aisle in _storeAisles) aisle.key: GlobalKey(),
  };
  String? _highlightedAisleKey;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Product> _storeProducts() {
    final query = _searchController.text.trim();
    final all = productsForStore(widget.store.id);
    if (query.isEmpty) {
      return all;
    }
    return all.where((product) => product.name.contains(query)).toList();
  }

  Map<String, List<Product>> _productsByAisle(List<Product> products) {
    final map = <String, List<Product>>{
      for (final aisle in _storeAisles) aisle.key: <Product>[],
    };
    for (final product in products) {
      final key = productAisleKey(product);
      map.putIfAbsent(key, () => <Product>[]).add(product);
    }
    return map;
  }

  void _onAisleTap(String aisleKey) {
    setState(() => _highlightedAisleKey = aisleKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _sectionKeys[aisleKey]?.currentContext;
      if (target == null) {
        return;
      }
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartManager.instance;
    final products = _storeProducts();
    final grouped = _productsByAisle(products);
    final showFreeDeliveryBadge = widget.store.rating >= 4.5;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: AppColors.primary),
      child: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                _StoreDetailsHeader(
                  storeName: widget.store.name,
                  searchController: _searchController,
                  onSearchChanged: (_) => setState(() {}),
                ),
                _StoreMetaStrip(
                  deliveryTime: widget.store.deliveryTime,
                  rating: widget.store.rating,
                  showFreeDelivery: showFreeDeliveryBadge,
                ),
                Expanded(
                  child: products.isEmpty
                      ? const Center(
                          child: Text(
                            'لم يتم العثور على منتجات',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              sliver: SliverToBoxAdapter(
                                child: _StoreAisleGrid(
                                  aisles: _storeAisles,
                                  highlightedKey: _highlightedAisleKey,
                                  onAisleTap: _onAisleTap,
                                ),
                              ),
                            ),
                            for (final aisle in _storeAisles)
                              if ((grouped[aisle.key]?.isNotEmpty ?? false)) ...[
                                SliverPadding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  sliver: SliverToBoxAdapter(
                                    child: Text(
                                      aisle.label,
                                      key: _sectionKeys[aisle.key],
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 20),
                                  sliver: SliverGrid(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.76,
                                    ),
                                    delegate: SliverChildListDelegate(
                                      [
                                        for (final product in grouped[aisle.key]!)
                                          ProductCard(product: product),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            const SliverToBoxAdapter(child: SizedBox(height: 8)),
                          ],
                        ),
                ),
              ],
            ),
            bottomNavigationBar: const SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StickyCartBar(
                    variant: StickyCartBarVariant.storeBasket,
                    showFreeDeliveryHint: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StoreDetailsHeader extends StatelessWidget {
  const _StoreDetailsHeader({
    required this.storeName,
    required this.searchController,
    required this.onSearchChanged,
  });

  final String storeName;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
                  ),
                  Expanded(
                    child: Text(
                      storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 0),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: searchController,
                  builder: (context, value, _) {
                    return TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'ابحث داخل المتجر...',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: value.text.isEmpty
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreMetaStrip extends StatelessWidget {
  const _StoreMetaStrip({
    required this.deliveryTime,
    required this.rating,
    required this.showFreeDelivery,
  });

  final String deliveryTime;
  final double rating;
  final bool showFreeDelivery;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              deliveryTime,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          if (showFreeDelivery)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: const Text(
                'توصيل مجاني',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StoreAisleGrid extends StatelessWidget {
  const _StoreAisleGrid({
    required this.aisles,
    required this.highlightedKey,
    required this.onAisleTap,
  });

  final List<_StoreAisle> aisles;
  final String? highlightedKey;
  final ValueChanged<String> onAisleTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: aisles.length,
      itemBuilder: (context, index) {
        final aisle = aisles[index];
        final isHighlighted = aisle.key == highlightedKey;
        return _StoreAisleTile(
          aisle: aisle,
          isHighlighted: isHighlighted,
          onTap: () => onAisleTap(aisle.key),
        );
      },
    );
  }
}

class _StoreAisleTile extends StatelessWidget {
  const _StoreAisleTile({
    required this.aisle,
    required this.isHighlighted,
    required this.onTap,
  });

  final _StoreAisle aisle;
  final bool isHighlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: aisle.tint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isHighlighted
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : AppColors.border.withValues(alpha: 0.6),
                    width: isHighlighted ? 1.5 : 1,
                  ),
                ),
                child: Icon(
                  aisle.icon,
                  color: AppColors.primary.withValues(alpha: 0.85),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              aisle.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
