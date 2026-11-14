import 'package:delevery_app/data/cart_actions.dart';
import 'package:delevery_app/data/search_service.dart';
import 'package:delevery_app/models/product.dart';
import 'package:delevery_app/models/store.dart';
import 'package:delevery_app/screens/store_details_screen.dart';
import 'package:delevery_app/services/storage_service.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _committedQuery;
  bool _inStockOnly = true;
  List<String> _recentSearches = const [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _queryController.text = widget.initialQuery!.trim();
      _committedQuery = widget.initialQuery!.trim();
    }
    _loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final items = await StorageService.instance.loadRecentSearches();
    if (!mounted) {
      return;
    }
    setState(() => _recentSearches = items);
  }

  Future<void> _commitQuery(String query) async {
    final trimmed = SearchService.normalizeQuery(query);
    if (trimmed.isEmpty) {
      setState(() => _committedQuery = null);
      return;
    }
    setState(() {
      _queryController.text = trimmed;
      _committedQuery = trimmed;
    });
    await StorageService.instance.addRecentSearch(trimmed);
    await _loadRecentSearches();
    _focusNode.unfocus();
  }

  void _onDraftChanged(String value) {
    if (_committedQuery != null) {
      setState(() => _committedQuery = null);
    }
  }

  void _clearQuery() {
    _queryController.clear();
    setState(() => _committedQuery = null);
    _focusNode.requestFocus();
  }

  Future<void> _clearRecent() async {
    await StorageService.instance.clearRecentSearches();
    await _loadRecentSearches();
  }

  void _openStoreForProduct(Product product) {
    final store = SearchService.storeForProduct(product);
    if (store == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoreDetailsScreen(store: store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = _queryController.text.trim();
    final showingResults =
        _committedQuery != null && _committedQuery!.trim().isNotEmpty;
    final suggestions = !showingResults && draft.isNotEmpty
        ? SearchService.buildSuggestions(draft)
        : const <String>[];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: AppColors.primary),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchHeader(
              controller: _queryController,
              focusNode: _focusNode,
              onChanged: _onDraftChanged,
              onSubmitted: _commitQuery,
              onClear: _clearQuery,
            ),
            Expanded(
              child: showingResults
                  ? _SearchResultsBody(
                      query: _committedQuery!,
                      inStockOnly: _inStockOnly,
                      onInStockChanged: (value) =>
                          setState(() => _inStockOnly = value),
                      onOpenStore: _openStoreForProduct,
                    )
                  : draft.isNotEmpty
                      ? _SuggestionsList(
                          suggestions: suggestions,
                          onSuggestionTap: _commitQuery,
                        )
                      : _SearchEmptyBody(
                          recentSearches: _recentSearches,
                          onPopularTap: _commitQuery,
                          onRecentTap: _commitQuery,
                          onClearRecent: _clearRecent,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 12, 14),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
              ),
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن أي منتج أو متجر...',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: value.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: onClear,
                                icon: const Icon(
                                  Icons.close,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
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

class _SearchEmptyBody extends StatelessWidget {
  const _SearchEmptyBody({
    required this.recentSearches,
    required this.onPopularTap,
    required this.onRecentTap,
    required this.onClearRecent,
  });

  final List<String> recentSearches;
  final ValueChanged<String> onPopularTap;
  final ValueChanged<String> onRecentTap;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        const Text(
          'الأكثر بحثاً',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: SearchService.popularSearches.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final term = SearchService.popularSearches[index];
              return _PopularChip(
                label: term,
                onTap: () => onPopularTap(term),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        if (recentSearches.isEmpty)
          const _RecentPlaceholder()
        else
          _RecentSearchesSection(
            items: recentSearches,
            onItemTap: onRecentTap,
            onClear: onClearRecent,
          ),
      ],
    );
  }
}

class _PopularChip extends StatelessWidget {
  const _PopularChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentPlaceholder extends StatelessWidget {
  const _RecentPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.search,
            size: 48,
            color: AppColors.textHint.withValues(alpha: 0.65),
          ),
          const SizedBox(height: 12),
          Text(
            'عمليات البحث الأخيرة ستظهر هنا',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentSearchesSection extends StatelessWidget {
  const _RecentSearchesSection({
    required this.items,
    required this.onItemTap,
    required this.onClear,
  });

  final List<String> items;
  final ValueChanged<String> onItemTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'عمليات البحث الأخيرة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: const Text(
                'مسح',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              _PopularChip(
                label: item,
                onTap: () => onItemTap(item),
              ),
          ],
        ),
      ],
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const Center(
        child: Text(
          'تابع الكتابة لعرض الاقتراحات',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: suggestions.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          onTap: () => onSuggestionTap(suggestion),
          title: Text(
            suggestion,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(
            Icons.north_west,
            color: AppColors.textSecondary,
            size: 18,
          ),
        );
      },
    );
  }
}

class _SearchResultsBody extends StatelessWidget {
  const _SearchResultsBody({
    required this.query,
    required this.inStockOnly,
    required this.onInStockChanged,
    required this.onOpenStore,
  });

  final String query;
  final bool inStockOnly;
  final ValueChanged<bool> onInStockChanged;
  final ValueChanged<Product> onOpenStore;

  @override
  Widget build(BuildContext context) {
    final products = SearchService.searchProducts(
      query,
      inStockOnly: inStockOnly,
    );
    final stores = SearchService.searchStores(query);
    final groups = SearchService.groupProducts(products);

    if (products.isEmpty && stores.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد نتائج',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'المتوفر فقط',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Switch(
              value: inStockOnly,
              onChanged: onInStockChanged,
              activeThumbColor: AppColors.onPrimary,
              activeTrackColor: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (stores.isNotEmpty) ...[
          _StoresSection(stores: stores),
          const SizedBox(height: 16),
        ],
        for (final group in groups) ...[
          _CategoryResultsHeader(
            title: group.categoryTitle,
            imagePath: group.imagePath,
            count: group.products.length,
          ),
          const SizedBox(height: 8),
          ...group.products.map(
            (product) => _SearchProductRow(
              product: product,
              onOpenStore: () => onOpenStore(product),
              onAdd: () => addProductToCart(context, product),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _StoresSection extends StatelessWidget {
  const _StoresSection({required this.stores});

  final List<Store> stores;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المتاجر',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        for (final store in stores)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              store.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(store.category),
            trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StoreDetailsScreen(store: store),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _CategoryResultsHeader extends StatelessWidget {
  const _CategoryResultsHeader({
    required this.title,
    required this.imagePath,
    required this.count,
  });

  final String title;
  final String imagePath;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          imagePath,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.storefront_outlined,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          count == 1 ? 'نتيجة واحدة' : '$count نتيجة',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _SearchProductRow extends StatelessWidget {
  const _SearchProductRow({
    required this.product,
    required this.onOpenStore,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onOpenStore;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final availability = SearchService.availabilityForProduct(product);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onOpenStore,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProductThumb(imageUrl: product.imageUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.unitLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'متوفر في ${availability.shopCount} متاجر قريبة من ${_formatPriceLabel(availability.minPrice)} ج.م',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 12,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    children: [
                      IconButton(
                        onPressed: onOpenStore,
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: onAdd,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'أضف للقائمة',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
      ),
      child: imageUrl.isEmpty
          ? const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primary,
              size: 26,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
    );
  }
}

String _formatPriceLabel(double price) {
  if (price == price.roundToDouble()) {
    return price.toStringAsFixed(0);
  }
  return price.toStringAsFixed(2);
}
