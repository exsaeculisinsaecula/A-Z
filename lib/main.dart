import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// A-Z 앱 진입점 — 객체 조립(합성 루트)은 여기서만 한다.
void main() {
  runApp(const AzApp());
}

/// 대상 지역 상수 (ISO 3166-1 `KR`, 로캘 `ko-KR`)
abstract final class AzRegion {
  static const countryCode = 'KR';
  static const locale = Locale('ko', 'KR');
}

class AzApp extends StatelessWidget {
  const AzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A-Z',
      locale: AzRegion.locale,
      supportedLocales: const [AzRegion.locale],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4B5CDE)),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('A-Z')),
      body: const Center(child: Text('A-Z 보관함')),
    );
  }
}
