import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce_kespro/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Kespro Event Hub'), findsWidgets);
    expect(find.text('HERO SECTION'), findsOneWidget);
  });
}
