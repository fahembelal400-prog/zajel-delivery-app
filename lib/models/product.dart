class Product {
  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.unitLabel,
    required this.subCategory,
    required this.description,
    this.originalPrice,
  });

  final String id;
  final String storeId;
  final String name;
  final double price;
  final String imageUrl;
  final String unitLabel;
  final String subCategory;
  final String description;
  final double? originalPrice;

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price;
}

String productAisleKey(Product product) {
  switch (product.subCategory) {
    case 'milk':
    case 'cheese':
      return 'dairy';
    case 'offers':
      return 'offers';
    case 'new':
      final name = product.name;
      if (name.contains('خبز') || name.contains('كرواسون')) {
        return 'bakery';
      }
      if (name.contains('طماطم') || name.contains('موز')) {
        return 'fruits';
      }
      if (name.contains('بنادول') || name.contains('فيتامين')) {
        return 'snacks';
      }
      return 'drinks';
    default:
      return 'offers';
  }
}

const dummyProducts = <Product>[
  Product(
    id: 'p1',
    storeId: '1',
    name: 'لبن جهينة كامل الدسم',
    price: 42.5,
    originalPrice: 48,
    imageUrl: '',
    unitLabel: '1 L',
    subCategory: 'milk',
    description:
        'لبن طازج كامل الدسم، مناسب للشرب والتحضير، معبأ بعناية للحفاظ على الجودة.',
  ),
  Product(
    id: 'p2',
    storeId: '1',
    name: 'أرز المصري الأمريكي',
    price: 189,
    originalPrice: 215,
    imageUrl: '',
    unitLabel: '5 kg',
    subCategory: 'offers',
    description: 'أرز طويل الحبة بجودة ممتازة، مثالي للأطباق اليومية والمناسبات.',
  ),
  Product(
    id: 'p3',
    storeId: '1',
    name: 'زيت عباد الشمس',
    price: 115,
    originalPrice: 130,
    imageUrl: '',
    unitLabel: '1.5 L',
    subCategory: 'offers',
    description: 'زيت نقي مناسب للقلي والطبخ بدرجة حرارة عالية دون رائحة زائدة.',
  ),
  Product(
    id: 'p4',
    storeId: '2',
    name: 'بنادول أكسترا',
    price: 58,
    imageUrl: '',
    unitLabel: '24 tablets',
    subCategory: 'new',
    description: 'مسكن للآلام وخافض للحرارة، للاستخدام حسب تعليمات الطبيب أو الصيدلي.',
  ),
  Product(
    id: 'p5',
    storeId: '2',
    name: 'فيتامين سي',
    price: 95,
    imageUrl: '',
    unitLabel: '1000 mg',
    subCategory: 'new',
    description: 'مكمل غذائي لدعم المناعة، يُستخدم وفق الإرشادات المكتوبة على العبوة.',
  ),
  Product(
    id: 'p6',
    storeId: '3',
    name: 'طماطم طازجة',
    price: 18,
    imageUrl: '',
    unitLabel: '1 kg',
    subCategory: 'new',
    description: 'طماطم محلية طازجة مناسبة للسلطات والطبخ اليومي.',
  ),
  Product(
    id: 'p7',
    storeId: '3',
    name: 'موز مستورد',
    price: 32,
    imageUrl: '',
    unitLabel: '1 kg',
    subCategory: 'offers',
    description: 'موز ناضج بطعم حلو، مثالي كوجبة خفيفة أو للعصائر.',
  ),
  Product(
    id: 'p8',
    storeId: '4',
    name: 'عيش بلدي',
    price: 7.5,
    imageUrl: '',
    unitLabel: '5 pieces',
    subCategory: 'new',
    description: 'خبز بلدي طازج من الفرن، طري ومناسب للفطار والعشاء.',
  ),
  Product(
    id: 'p9',
    storeId: '4',
    name: 'كرواسون بالزبدة',
    price: 45,
    imageUrl: '',
    unitLabel: '4 pieces',
    subCategory: 'cheese',
    description: 'كرواسون هش بالزبدة، مثالي مع القهوة أو كتحلية خفيفة.',
  ),
];

List<Product> productsForStore(String storeId) {
  return dummyProducts.where((product) => product.storeId == storeId).toList();
}
