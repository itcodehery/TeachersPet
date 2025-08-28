import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'package:flutter/material.dart';
import 'core/dependency_injection/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const ProviderScope(child: MyApp()));
}
