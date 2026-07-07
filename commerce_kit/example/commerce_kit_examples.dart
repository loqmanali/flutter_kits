/// # Commerce Kit - Complete Examples
///
/// This file contains comprehensive examples for all features in the Commerce Kit package.
/// Each section demonstrates how to use specific components of the library.
///
/// ## Table of Contents
///
/// 1. [Money Examples](#money-examples)
/// 2. [Product Examples](#product-examples)
/// 3. [Product Variant Examples](#product-variant-examples)
/// 4. [Product Option Examples](#product-option-examples)
/// 5. [Category Examples](#category-examples)
/// 6. [Cart Examples](#cart-examples)
/// 7. [Discount Examples](#discount-examples)
/// 8. [API Adapter Examples](#api-adapter-examples)
/// 9. [State Management Examples](#state-management-examples)
/// 10. [Widget Examples](#widget-examples)
/// 11. [Configuration Examples](#configuration-examples)
/// 12. [Integration Examples](#integration-examples)
///
/// ## Usage
///
/// Run individual examples by calling the respective functions:
/// ```dart
/// // Money examples
/// MoneyExamples.runAll();
///
/// // Product examples
/// ProductExamples.runAll();
///
/// // etc.
/// ```

// ignore_for_file: avoid_print

library;

// Export all example modules
export 'money_examples.dart';
export 'review_examples.dart';
export 'search_examples.dart';
export 'wishlist_examples.dart';

/// Main entry point to run all examples
void runAllExamples() {
  print('════════════════════════════════════════════════════════════════');
  print('COMMERCE KIT - COMPLETE EXAMPLES');
  print('════════════════════════════════════════════════════════════════\n');

  // Run individual examples (uncomment as they're implemented)
  // MoneyExamples.runAll();
  // ProductExamples.runAll();
  // ProductVariantExamples.runAll();
  // ProductOptionExamples.runAll();
  // CategoryExamples.runAll();
  // CartExamples.runAll();
  // DiscountExamples.runAll();
  // AdapterExamples.runAll();
  // ProviderExamples.runAll();
  // WidgetExamples.runAll();
  // ConfigurationExamples.runAll();
  // IntegrationExamples.runAll();

  // New feature examples
  // ReviewExamples.runAll();
  // WishlistExamples.runAll();
  // SearchExamples.runAll();

  print('════════════════════════════════════════════════════════════════');
  print('ALL EXAMPLES COMPLETED');
  print('════════════════════════════════════════════════════════════════');
}

/// Helper class for printing section headers
class ExamplePrinter {
  static void header(String title) {
    print('\n${'═' * 60}');
    print('  $title');
    print('═' * 60);
  }

  static void subHeader(String title) {
    print('\n▶ $title');
    print('─' * 60);
  }

  static void example(String description) {
    print('\n  Example: $description');
  }

  static void result(String result) {
    print('  Result: $result');
  }

  static void code(String code) {
    print('  Code: $code');
  }

  static void separator() {
    print('─' * 60);
  }
}
