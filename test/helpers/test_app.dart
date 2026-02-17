import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/design_system/theme.dart';

Widget buildTestApp(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      theme: AppTheme.light,
      home: child,
    ),
  );
}

Widget buildTestAppDark(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: child,
    ),
  );
}
