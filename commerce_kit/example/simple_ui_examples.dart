/// # Simple UI Examples for Commerce Kit
///
/// This file contains standalone UI examples that demonstrate the visual components
/// you would see in a Commerce Kit application using the actual Commerce Kit package.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../commerce_kit.dart';

/// Main UI Examples App
class SimpleCommerceUIExamples extends StatelessWidget {
  const SimpleCommerceUIExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Commerce UI Examples',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        home: const ExamplesHomePage(),
        routes: {
          '/cart': (context) => const CartExamplePage(),
          '/product-detail': (context) => const ProductDetailExamplePage(),
          '/category-grid': (context) => const CategoryGridExamplePage(),
          '/checkout': (context) => const CheckoutExamplePage(),
        },
      ),
    );
  }
}

/// Home page with all example navigation
class ExamplesHomePage extends StatelessWidget {
  const ExamplesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commerce UI Examples'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Choose an example to explore:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _ExampleCard(
            title: '🛒 Shopping Cart',
            description: 'Complete cart with items, quantities, and checkout',
            onTap: () => Navigator.pushNamed(context, '/cart'),
          ),
          _ExampleCard(
            title: '🍔 Product Detail',
            description: 'Product page with variants, options, and add to cart',
            onTap: () => Navigator.pushNamed(context, '/product-detail'),
          ),
          _ExampleCard(
            title: '📂 Categories',
            description: 'Category grid with images and navigation',
            onTap: () => Navigator.pushNamed(context, '/category-grid'),
          ),
          _ExampleCard(
            title: '💳 Checkout',
            description: 'Complete checkout flow with payment options',
            onTap: () => Navigator.pushNamed(context, '/checkout'),
          ),
        ],
      ),
    );
  }
}

/// Reusable example card widget
class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shopping Cart Example Page
class CartExamplePage extends ConsumerWidget {
  const CartExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final itemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart ($itemCount items)'),
        backgroundColor: Colors.orange,
        actions: [
          CartIconButton(
            itemCount: itemCount,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add some delicious items!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemWidget(
                        item: item,
                        onQuantityChanged: (quantity) {
                          ref
                              .read(commerceCartProvider.notifier)
                              .updateQuantity(item.id, quantity);
                        },
                        onRemove: () {
                          ref
                              .read(commerceCartProvider.notifier)
                              .removeItem(item.id);
                        },
                      );
                    },
                  ),
          ),
          if (cartItems.isNotEmpty)
            CartSummaryWidget(
              breakdown: PriceBreakdown(
                subtotal: cartTotal,
                total: Money(cartTotal.amount + 5.99),
              ),
            ),
        ],
      ),
    );
  }
}

/// Product Detail Example Page
class ProductDetailExamplePage extends ConsumerStatefulWidget {
  const ProductDetailExamplePage({super.key});

  @override
  ConsumerState<ProductDetailExamplePage> createState() =>
      _ProductDetailExamplePageState();
}

class _ProductDetailExamplePageState
    extends ConsumerState<ProductDetailExamplePage> {
  String? selectedSize;
  String? selectedCheese;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    // Sample product
    const product = Product(
      id: 'burger-001',
      name: 'Classic Cheeseburger',
      description:
          'Juicy beef patty with cheese, lettuce, tomato, and our special sauce',
      price: Money(12.99),
      type: ProductType.configurable,
      images: [
        ProductImage(
          url: 'https://via.placeholder.com/300x200/FF6B35/FFFFFF?text=Burger',
          isPrimary: true,
          id: 'burger-001',
        ),
      ],
      options: [
        ProductOption(
          id: 'size',
          name: 'Size',
          type: VariantType.size,
          isRequired: true,
          values: [
            ProductOptionValue(id: 'small', value: 'Small'),
            ProductOptionValue(id: 'medium', value: 'Medium'),
            ProductOptionValue(
              id: 'large',
              value: 'Large',
              priceModifier: Money(2.00),
            ),
          ],
        ),
        ProductOption(
          id: 'cheese',
          name: 'Cheese Option',
          type: VariantType.customization,
          values: [
            ProductOptionValue(
              id: 'regular',
              value: 'Regular Cheese',
            ),
            ProductOptionValue(
              id: 'extra',
              value: 'Extra Cheese',
              priceModifier: Money(1.50),
            ),
            ProductOptionValue(
              id: 'double',
              value: 'Double Cheese',
              priceModifier: Money(3.00),
            ),
          ],
        ),
      ],
    );

    final quantityInCart = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        backgroundColor: Colors.orange,
        actions: [
          CartIconButton(
            itemCount: quantityInCart,
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://via.placeholder.com/400x250/FF6B35/FFFFFF?text=Classic+Burger',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PriceDisplayWidget(
                        price: product.price,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Size Options
                  const Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OptionSelectorWidget(
                    option:
                        product.options.firstWhere((opt) => opt.id == 'size'),
                    selectedValueIds:
                        selectedSize != null ? {selectedSize!} : {},
                    onSelectionChanged: (values) {
                      setState(() {
                        selectedSize = values.isNotEmpty ? values.first : null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cheese Options
                  const Text(
                    'Cheese Option',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OptionSelectorWidget(
                    option:
                        product.options.firstWhere((opt) => opt.id == 'cheese'),
                    selectedValueIds:
                        selectedCheese != null ? {selectedCheese!} : {},
                    onSelectionChanged: (values) {
                      setState(() {
                        selectedCheese =
                            values.isNotEmpty ? values.first : null;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  Row(
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      QuantitySelectorWidget(
                        quantity: quantity,
                        onChanged: (newQuantity) {
                          setState(() {
                            quantity = newQuantity;
                          });
                        },
                        maxQuantity: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: AddToCartButton(
                      onPressed: selectedSize != null
                          ? () {
                              ref
                                  .read(commerceCartProvider.notifier)
                                  .addProduct(
                                product,
                                quantity: quantity,
                                selectedOptions: {
                                  if (selectedSize != null)
                                    'size': SelectedOption(
                                      optionId: 'size',
                                      optionName: 'Size',
                                      valueId: selectedSize!,
                                      valueName: selectedSize!,
                                    ),
                                  if (selectedCheese != null)
                                    'cheese': SelectedOption(
                                      optionId: 'cheese',
                                      optionName: 'Cheese Option',
                                      valueId: selectedCheese!,
                                      valueName: selectedCheese!,
                                    ),
                                },
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added $quantity ${product.name} to cart!',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                      price: product.price,
                      label: 'Add to Cart',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category Grid Example Page
class CategoryGridExamplePage extends StatelessWidget {
  const CategoryGridExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample categories
    final categories = [
      Category(
        id: 'burgers',
        name: 'Burgers',
        image: CategoryImage.network(
          url: 'https://via.placeholder.com/150x150/FF6B35/FFFFFF?text=Burgers',
        ),
        productCount: 15,
      ),
      Category(
        id: 'pizzas',
        name: 'Pizzas',
        image: CategoryImage.network(
          url: 'https://via.placeholder.com/150x150/4CAF50/FFFFFF?text=Pizzas',
        ),
        productCount: 12,
      ),
      Category(
        id: 'drinks',
        name: 'Drinks',
        image: CategoryImage.network(
          url: 'https://via.placeholder.com/150x150/2196F3/FFFFFF?text=Drinks',
        ),
        productCount: 20,
      ),
      Category(
        id: 'desserts',
        name: 'Desserts',
        image: CategoryImage.network(
          url:
              'https://via.placeholder.com/150x150/E91E63/FFFFFF?text=Desserts',
        ),
        productCount: 8,
      ),
      Category(
        id: 'salads',
        name: 'Salads',
        image: CategoryImage.network(
          url: 'https://via.placeholder.com/150x150/8BC34A/FFFFFF?text=Salads',
        ),
        productCount: 6,
      ),
      Category(
        id: 'sides',
        name: 'Sides',
        image: CategoryImage.network(
          url: 'https://via.placeholder.com/150x150/FFC107/000000?text=Sides',
        ),
        productCount: 10,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CategoryGrid(
          categories: categories,
          onCategoryTap: (category) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected category: ${category.name}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Checkout Example Page
class CheckoutExamplePage extends ConsumerWidget {
  const CheckoutExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartTotal = ref.watch(cartTotalProvider);
    final cartItems = ref.watch(cartItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        PriceDisplayWidget(price: cartTotal),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Shipping'),
                        Text('\$5.99'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tax'),
                        Text('\$2.40'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        PriceDisplayWidget(
                          price:
                              cartTotal + const Money(5.99) + const Money(2.40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Information
            const Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Cash on Delivery'),
                    value: 'cash',
                    groupValue: 'cash',
                    onChanged: (value) {},
                  ),
                  RadioListTile<String>(
                    title: const Text('Credit Card'),
                    value: 'card',
                    groupValue: 'cash',
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cartItems.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        // Clear cart after successful order
                        ref.read(commerceCartProvider.notifier).clearCart();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
