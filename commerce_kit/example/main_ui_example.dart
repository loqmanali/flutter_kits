/// # Main UI Example Runner
///
/// Run this file to see the Commerce Kit UI examples in action.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'simple_ui_examples.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SimpleCommerceUIExamples(),
    ),
  );
}
