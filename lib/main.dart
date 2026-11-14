import 'package:delevery_app/data/orders_manager.dart';
import 'package:delevery_app/screens/home_screen.dart';
import 'package:delevery_app/screens/orders_screen.dart';
import 'package:delevery_app/screens/profile_screen.dart';
import 'package:delevery_app/services/storage_service.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:delevery_app/widgets/app_shell_scope.dart';
import 'package:delevery_app/widgets/sticky_cart_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await OrdersManager.instance.loadFromStorage();
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'زاجل',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            onSurface: AppColors.onSurface,
            error: AppColors.error,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            centerTitle: true,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.background,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.navUnselected,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
          dividerColor: AppColors.divider,
        ),
        home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  Widget _tabBody(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const OrdersScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayStyle = _currentIndex == 0
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: AppColors.primary,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: AppColors.background,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: AppShellScope(
        selectTab: (index) => setState(() => _currentIndex = index),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              Expanded(child: _tabBody(_currentIndex)),
              if (_currentIndex == 0)
                const SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StickyCartBar(),
                    ],
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.navTopBorder),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              elevation: 0,
              backgroundColor: AppColors.background,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.navUnselected,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: 'طلباتي',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'حسابي',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
