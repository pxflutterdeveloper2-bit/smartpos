import 'package:flutter/material.dart';
import 'package:smartpos/database/db_helper.dart';
import 'package:smartpos/screens/cart_screen.dart';
import 'package:smartpos/screens/product_screen.dart';
import 'package:smartpos/widget/custom_button.dart';
import 'package:smartpos/widget/screen_animation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final _titles = const ['Dashboard', 'Products', 'Orders', 'Reports'];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardHome(onNavigate: _setTab),
      const ProductsScreen(),
      const Placeholder(),
      const Placeholder(),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _setTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  void _setTab(int index) {
    if (index >= 0 && index < _titles.length) {
      setState(() => _selectedIndex = index);
    }
  }
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  late Future<Map<String, num>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = DatabaseHelper.instance.getDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenAnimation(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(
            () => _statsFuture = DatabaseHelper.instance.getDashboardStats(),
          );
          await _statsFuture;
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _Header(title: 'Dashboard', subtitle: 'Welcome back!'),
            Padding(
              padding: EdgeInsets.all(15),
              child: FutureBuilder<Map<String, num>>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  final stats =
                      snapshot.data ??
                      const {'sales': 0, 'orders': 0, 'products': 0};
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatTile(
                        icon: Icons.trending_up,
                        color: Color(0xff08C95E),
                        title: 'Total Sale',
                        value: '\$${stats['orders']}',
                      ),
                      _StatTile(
                        icon: Icons.shopping_cart_outlined,
                        color: const Color(0xFF2F80ED),
                        title: 'Total Orders',
                        value: '${stats['orders']}',
                      ),
                      _StatTile(
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFFB144F6),
                        title: 'Total Products',
                        value: '${stats['products']}',
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 14),
                      CustomButton(
                        color: const Color(0xFF2563EB),
                        label: 'Add Product',
                        icon: Icons.add,
                        onPressed: () => widget.onNavigate(1),

                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'New Order',
                        icon: Icons.shopping_cart_outlined,
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'View Reports',
                        icon: Icons.bar_chart_outlined,
                        color: const Color(0xFFFF6B00),
                        onPressed: () => widget.onNavigate(3),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(23, 30, 23, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF52627A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) =>
      _Header(title: title, subtitle: subtitle);
}
