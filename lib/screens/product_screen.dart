import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/product.dart';
import '../widget/custom_button.dart';
import '../widget/product_card.dart';
import '../widget/screen_animation.dart';
import 'dashboard_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = await DatabaseHelper.instance.getProducts(query: _searchController.text);
    if (!mounted) return;
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenAnimation(child: Column(
      children: [
        ScreenHeader(title: 'Products', subtitle: '${_products.length} items available'),
        Expanded(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _loadProducts,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(15, 16, 15, 0),
                      sliver: SliverToBoxAdapter(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => _loadProducts(),
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E5EE)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E5EE)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_loading)
                      const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                    else if (_products.isEmpty)
                      const SliverFillRemaining(child: Center(child: Text('No products found')))
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(15, 16, 15, 92),
                        sliver: SliverGrid.builder(
                          itemCount: _products.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.88,
                          ),
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ProductCard(
                              product: product,
                              onEdit: () => _showProductSheet(product: product),
                              onDelete: () => _deleteProduct(product),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: 15,
                right: 15,
                bottom: 16,
                child: CustomButton(
                  label: 'Add Product',
                  icon: Icons.add,
                  onPressed: () => _showProductSheet(),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Future<void> _deleteProduct(Product product) async {
    await DatabaseHelper.instance.deleteProduct(product.id!);
    await _loadProducts();
  }

  Future<void> _showProductSheet({Product? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product == null ? '' : product.price.toStringAsFixed(2));
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product == null ? 'Add Product' : 'Edit Product',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text('Add, update, or remove products'),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Product name', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                    validator: (value) => double.tryParse(value ?? '') == null ? 'Valid price required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()),
                    validator: (value) => int.tryParse(value ?? '') == null ? 'Valid stock required' : null,
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    label: product == null ? 'Save Product' : 'Update Product',
                    icon: Icons.check,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final newProduct = Product(
                        id: product?.id,
                        name: nameController.text.trim(),
                        price: double.parse(priceController.text),
                        stock: int.parse(stockController.text),
                        createdAt: product?.createdAt,
                      );
                      if (product == null) {
                        await DatabaseHelper.instance.insertProduct(newProduct);
                      } else {
                        await DatabaseHelper.instance.updateProduct(newProduct);
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      await _loadProducts();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
