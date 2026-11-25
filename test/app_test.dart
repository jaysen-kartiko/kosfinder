import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/app/app.dart';
import 'package:kosfinder/core/app_config.dart';

void main() {
  test('US01-AC3: konfigurasi Supabase URL kosong dikenali', () {
    const config = AppConfig(supabaseUrl: '', supabaseAnonKey: '');

    expect(config.isValid, isFalse);
    expect(config.validationMessage, contains('URL'));
  });

  test('US01-AC3: konfigurasi Supabase lengkap dinyatakan valid', () {
    const config = AppConfig(
      supabaseUrl: 'https://project.supabase.co',
      supabaseAnonKey: 'anon-key-example',
    );

    expect(config.isValid, isTrue);
    expect(config.validationMessage, isEmpty);
  });

  testWidgets('halaman About menampilkan identitas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KosFinderApp());

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.text('241501028 - Jaysen Natanael Kartiko'), findsOneWidget);
  });

  testWidgets('US02-AC3: halaman konfigurasi menampilkan pesan galat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const KosFinderConfigErrorApp(
        message: 'Konfigurasi Supabase URL belum disediakan.',
      ),
    );

    expect(
      find.text('Konfigurasi Supabase URL belum disediakan.'),
      findsOneWidget,
    );
  });
}
