class Store {
  const Store({
    required this.id,
    required this.name,
    required this.category,
    required this.deliveryTime,
    required this.rating,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final String deliveryTime;
  final double rating;
  final String imageUrl;
}

const dummyStores = <Store>[
  Store(
    id: '1',
    name: 'كارفور أكتوبر',
    category: 'سوبر ماركت',
    deliveryTime: '35-45 دقيقة',
    rating: 4.6,
    imageUrl: '',
  ),
  Store(
    id: '2',
    name: 'صيدلية العزبي',
    category: 'صيدليات',
    deliveryTime: '25-35 دقيقة',
    rating: 4.8,
    imageUrl: '',
  ),
  Store(
    id: '3',
    name: 'خضار بلدي',
    category: 'خضار وفاكهة',
    deliveryTime: '30-40 دقيقة',
    rating: 4.4,
    imageUrl: '',
  ),
  Store(
    id: '4',
    name: 'مخبز الحرم',
    category: 'مخبوزات',
    deliveryTime: '20-30 دقيقة',
    rating: 4.7,
    imageUrl: '',
  ),
];
