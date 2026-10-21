/// A-Z 디자인 토큰 (design.md 2.2)
library;

import 'package:flutter/material.dart';

abstract final class AzColors {
  // 공간
  static const space = Color(0xFFF3F3FA);
  static const space2 = Color(0xFFEEEEF7);
  static const edge = Color(0xFFE8EAF6);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFD9E1ED);
  static const muted = Color(0xFFB6B6BF);

  // 글씨
  static const inkStrong = Color(0xFF090911);
  static const ink = Color(0xFF302F35);
  static const inkSub = Color(0xFF726E76);

  // 주 버튼
  static const primary = Color(0xFF4B5CDE);
  static const primary2 = Color(0xFF6A3BD9);

  // 카테고리 팔레트
  static const categories = <Color>[
    Color(0xFF2970FC), Color(0xFF00C080), Color(0xFFE9980B),
    Color(0xFFDE57A3), Color(0xFF5C4AEC), Color(0xFF18B791),
    Color(0xFFF62066), Color(0xFFD19E04), Color(0xFF6A3BD9),
  ];

  // 글씨용 카테고리 색 (대비 4.5:1+)
  static const categoriesText = <Color>[
    Color(0xFF1563FC), Color(0xFF008055), Color(0xFF996407),
    Color(0xFFCB2884), Color(0xFF5C4AEC), Color(0xFF107C63),
    Color(0xFFDD094E), Color(0xFF8B6903), Color(0xFF6A3BD9),
  ];

  static const uncategorized = Color(0xFF868DA7);

  static Color categoryColor(int index) =>
      categories[index % categories.length];
  static Color categoryTextColor(int index) =>
      categoriesText[index % categoriesText.length];
}

abstract final class AzShapes {
  static const unit = 8.0;
  static const minTouch = 48.0;
  static const radiusPill = 100.0;
  static const radiusCard = 16.0;
  static const radiusPanel = 20.0;
  static const radiusThumb = 12.0;
}

abstract final class AzMotion {
  static const fast = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 560);
  static const fly = Duration(milliseconds: 1200);
  static const easeOut = Cubic(0.2, 0.8, 0.2, 1);
  static const easeInOut = Cubic(0.4, 0.0, 0.2, 1);
}

/// 배경 링 — OZ 감성 (옅은 동심원, 회전)
class OrbitBackgroundPainter extends CustomPainter {
  final double rotation;
  final double scrollOffset;

  OrbitBackgroundPainter({this.rotation = 0, this.scrollOffset = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 방사형 그라데이션 배경
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          AzColors.space,
          AzColors.space2,
          AzColors.edge,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 동심원 링 (패럴랙스 + 느린 회전)
    for (int i = 0; i < 6; i++) {
      final radius = 200.0 + i * 120.0 + scrollOffset * 0.15;
      final opacity = (0.12 - i * 0.015).clamp(0.02, 0.12);
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.white.withValues(alpha: opacity);

      // 기울어진 타원 (원근감)
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation * 0.3 + i * 0.15);
      canvas.scale(1.0, 0.45);
      canvas.drawCircle(Offset.zero, radius, ringPaint);
      canvas.restore();
    }

    // 반투명 구체 글로우 (배경 장식)
    final spheres = [
      (size.width * 0.15, size.height * 0.3, 80.0, AzColors.categories[0]),
      (size.width * 0.85, size.height * 0.25, 60.0, AzColors.categories[1]),
      (size.width * 0.7, size.height * 0.7, 70.0, AzColors.categories[4]),
    ];
    for (final (sx, sy, sr, color) in spheres) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.02),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(sx, sy), radius: sr * 2.5));
      canvas.drawCircle(Offset(sx, sy), sr * 2.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OrbitBackgroundPainter old) =>
      old.rotation != rotation || old.scrollOffset != scrollOffset;
}

ThemeData azTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AzColors.space,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AzColors.primary,
      primary: AzColors.primary,
      surface: AzColors.surface,
    ),
    fontFamily: 'Pretendard',
    cardTheme: CardThemeData(
      color: AzColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AzShapes.radiusCard),
        side: const BorderSide(color: AzColors.line),
      ),
    ),
  );
}
