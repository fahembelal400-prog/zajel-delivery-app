import 'package:delevery_app/models/product.dart';
import 'package:delevery_app/models/store.dart';
import 'package:delevery_app/widgets/home_category_grid.dart';

class SearchProductGroup {
  const SearchProductGroup({
    required this.categoryKey,
    required this.categoryTitle,
    required this.imagePath,
    required this.products,
  });

  final String categoryKey;
  final String categoryTitle;
  final String imagePath;
  final List<Product> products;
}

abstract final class SearchService {
  static String normalizeQuery(String input) {
    final trimmed = input.trim();
    if (trimmed.contains(' / ')) {
      final arabic = trimmed.split(' / ').first.trim();
      if (arabic.isNotEmpty) {
        return arabic;
      }
      return trimmed.split(' / ').last.trim();
    }
    return trimmed;
  }

  static const popularSearches = <String>[
    'لبن',
    'مياه',
    'جبنة',
    'بيبسي',
    'خبز',
  ];

  static HomeCategoryItem? categoryMetaForStore(String storeCategory) {
    for (final item in homeCategoryItems) {
      if (item.routeCategory == storeCategory) {
        return item;
      }
    }
    return null;
  }

  static String categoryTitleForStore(String storeCategory) {
    return categoryMetaForStore(storeCategory)?.title ?? storeCategory;
  }

  static Store? storeForProduct(Product product) {
    for (final store in dummyStores) {
      if (store.id == product.storeId) {
        return store;
      }
    }
    return null;
  }

  static bool productMatchesQuery(Product product, String query) {
    final q = query.trim();
    if (q.isEmpty) {
      return false;
    }
    final needle = q.toLowerCase();
    final haystacks = <String>[
      product.name,
      product.unitLabel,
      product.description,
      product.subCategory,
    ];
    for (final text in haystacks) {
      if (text.toLowerCase().contains(needle)) {
        return true;
      }
      if (text.contains(q)) {
        return true;
      }
    }
    final store = storeForProduct(product);
    if (store != null &&
        (store.name.contains(q) || store.category.contains(q))) {
      return true;
    }
    return false;
  }

  static bool storeMatchesQuery(Store store, String query) {
    final q = query.trim();
    if (q.isEmpty) {
      return false;
    }
    return store.name.contains(q) || store.category.contains(q);
  }

  static List<Product> searchProducts(
    String query, {
    required bool inStockOnly,
  }) {
    final q = normalizeQuery(query);
    if (q.isEmpty) {
      return const [];
    }
    final results = dummyProducts.where((p) => productMatchesQuery(p, q));
    if (!inStockOnly) {
      return results.toList();
    }
    return results.toList();
  }

  static List<Store> searchStores(String query) {
    final q = normalizeQuery(query);
    if (q.isEmpty) {
      return const [];
    }
    return dummyStores.where((s) => storeMatchesQuery(s, q)).toList();
  }

  static List<String> buildSuggestions(String query) {
    final q = normalizeQuery(query);
    if (q.isEmpty) {
      return const [];
    }
    final matches = <String>{};
    for (final term in popularSearches) {
      if (term.toLowerCase().contains(q.toLowerCase()) || term.contains(q)) {
        matches.add(term);
      }
    }
    for (final product in dummyProducts) {
      if (product.name.contains(q)) {
        matches.add(product.name);
      }
    }
    for (final store in dummyStores) {
      if (store.name.contains(q)) {
        matches.add(store.name);
      }
    }
    for (final token in q.split(RegExp(r'\s+'))) {
      if (token.length >= 2) {
        matches.add(token);
      }
    }
    return matches.take(10).toList();
  }

  static List<SearchProductGroup> groupProducts(List<Product> products) {
    final buckets = <String, List<Product>>{};
    for (final product in products) {
      final store = storeForProduct(product);
      final key = store?.category ?? 'other';
      buckets.putIfAbsent(key, () => <Product>[]).add(product);
    }

    final groups = <SearchProductGroup>[];
    for (final entry in buckets.entries) {
      final meta = categoryMetaForStore(entry.key);
      groups.add(
        SearchProductGroup(
          categoryKey: entry.key,
          categoryTitle: meta?.title ?? entry.key,
          imagePath: meta?.imagePath ?? homeCategoryItems.first.imagePath,
          products: entry.value,
        ),
      );
    }
    groups.sort((a, b) => a.categoryTitle.compareTo(b.categoryTitle));
    return groups;
  }

  static ({int shopCount, double minPrice}) availabilityForProduct(Product product) {
    final siblings = dummyProducts
        .where((candidate) => candidate.name == product.name)
        .toList();
    final shopCount = siblings.map((p) => p.storeId).toSet().length;
    final minPrice = siblings
        .map((p) => p.price)
        .fold<double>(product.price, (min, price) => price < min ? price : min);
    final nearbyFloor = shopCount <= 1 ? shopCount : (shopCount * 2).clamp(2, 6);
    return (shopCount: nearbyFloor, minPrice: minPrice);
  }
}
