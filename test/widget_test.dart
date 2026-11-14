import 'package:delevery_app/data/cart_manager.dart';
import 'package:delevery_app/data/orders_manager.dart';
import 'package:delevery_app/main.dart';
import 'package:delevery_app/models/store.dart';
import 'package:delevery_app/screens/store_details_screen.dart';
import 'package:delevery_app/services/storage_service.dart';
import 'package:delevery_app/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    CartManager.instance.clear();
    OrdersManager.instance.clear();
    await OrdersManager.instance.loadFromStorage();
  });
  tearDown(() {
    CartManager.instance.clear();
    OrdersManager.instance.clear();
  });
  testWidgets('main shell shows home content', (WidgetTester tester) async {
    await tester.pumpWidget(const DeliveryApp());
    expect(find.text('التوصيل إلى:'), findsOneWidget);
    expect(find.text('الشروق، القاهرة'), findsOneWidget);
    expect(find.text('المتاجر المتاحة'), findsOneWidget);
    expect(find.text('كارفور أكتوبر'), findsOneWidget);
  });

  testWidgets('store details renders full catalog', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: MaterialApp(
          home: StoreDetailsScreen(store: dummyStores[0]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No products found'), findsNothing);
    expect(find.text('العروض'), findsWidgets);
    expect(find.byType(ProductCard), findsNWidgets(3));
    expect(find.text('لبن جهينة كامل الدسم'), findsOneWidget);
  });

  testWidgets('opens store details from store card', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const DeliveryApp());
    await tester.scrollUntilVisible(
      find.text('كارفور أكتوبر'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('كارفور أكتوبر'));
    await tester.pumpAndSettle();
    expect(find.text('ابحث داخل المتجر...'), findsOneWidget);
    expect(find.text('لبن جهينة كامل الدسم'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('adds product and opens cart screen', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const DeliveryApp());
    await tester.scrollUntilVisible(
      find.text('كارفور أكتوبر'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('كارفور أكتوبر'));
    await tester.pumpAndSettle();
    final addButton = find.descendant(
      of: find.byType(ProductCard).first,
      matching: find.byIcon(Icons.add),
    );
    await tester.ensureVisible(addButton);
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.textContaining('عرض السلة'), findsOneWidget);
    await tester.tap(find.textContaining('عرض السلة'));
    await tester.pumpAndSettle();
    expect(find.text('متابعة لإتمام الطلب'), findsOneWidget);
    expect(find.text('مصاريف التوصيل'), findsOneWidget);
    await tester.tap(find.text('متابعة لإتمام الطلب'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'شارع النيل، المعادي');
    await tester.enterText(find.byType(TextFormField).at(1), 'عمارة 5، الدور 2، شقة 4');
    await tester.enterText(find.byType(TextFormField).at(3), '01012345678');
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_place_order')));
    await tester.pumpAndSettle();
    expect(find.text('تم استلام طلبك بنجاح!'), findsOneWidget);
    await tester.tap(find.text('العودة للرئيسية'));
    await tester.pumpAndSettle();
    expect(find.text('التوصيل إلى:'), findsOneWidget);
    expect(find.text('الشروق، القاهرة'), findsOneWidget);
    expect(CartManager.instance.isEmpty, isTrue);
    expect(OrdersManager.instance.orders, isNotEmpty);

    await tester.tap(find.text('طلباتي'));
    await tester.pumpAndSettle();
    expect(find.text('كارفور أكتوبر'), findsOneWidget);
    expect(find.text('تم استلام الطلب'), findsOneWidget);
  });
}
