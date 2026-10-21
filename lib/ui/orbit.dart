/// 궤도 뷰 — 카테고리별 구체와 링이 떠 있는 2.5D 공간
library;

import 'dart:math';

import 'package:flutter/material.dart';

import '../archive.dart';
import '../main.dart';
import '../theme.dart';

class OrbitView extends StatefulWidget {
  final AppState state;
  const OrbitView({super.key, required this.state});

  @override
  State<OrbitView> createState() => _OrbitViewState();
}

class _OrbitViewState extends State<OrbitView> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  double _yaw = 0.3;
  double _pitch = 0.25;
  double _distance = 800.0;
  Offset? _dragStart;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 30))
      ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final graph = widget.state.archive.graph(widget.state.query);
    return GestureDetector(
      onScaleStart: (d) => _dragStart = d.localFocalPoint,
      onScaleUpdate: (d) {
        setState(() {
          if (_dragStart != null) {
            final delta = d.localFocalPoint - _dragStart!;
            _yaw += delta.dx * 0.005;
            _pitch = (_pitch + delta.dy * 0.005).clamp(-0.8, 0.8);
            _dragStart = d.localFocalPoint;
          }
          if (d.scale != 1.0) {
            _distance = (_distance / d.scale).clamp(300, 2000);
          }
        });
      },
      onScaleEnd: (_) => _dragStart = null,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          return CustomPaint(
            painter: OrbitPainter(
              graph: graph,
              yaw: _yaw,
              pitch: _pitch,
              distance: _distance,
              time: _anim.value,
              selectedId: widget.state.selectedId,
              hiddenCategories: widget.state.query.hiddenCategories,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

/// 2.5D 궤도 투영 페인터
class OrbitPainter extends CustomPainter {
  final OrbitGraph graph;
  final double yaw;
  final double pitch;
  final double distance;
  final double time;
  final String? selectedId;
  final Set<String> hiddenCategories;

  OrbitPainter({
    required this.graph,
    required this.yaw,
    required this.pitch,
    required this.distance,
    required this.time,
    this.selectedId,
    required this.hiddenCategories,
  });

  /// 3D → 2D 투영
  Offset _project(double x, double y, double z, Size size) {
    final cosY = cos(yaw), sinY = sin(yaw);
    final cosP = cos(pitch), sinP = sin(pitch);
    // Y축 회전
    final x1 = x * cosY - z * sinY;
    final z1 = x * sinY + z * cosY;
    // X축 회전
    final y1 = y * cosP - z1 * sinP;
    final z2 = y * sinP + z1 * cosP;
    // 원근 투영
    final f = 800.0 / (800.0 + z2);
    return Offset(
      size.width / 2 + x1 * f,
      size.height / 2 + y1 * f,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 배경
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [AzColors.space, AzColors.space2, AzColors.edge],
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width * 0.7));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 궤도 링 (기울어진 타원)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 0; i < 4; i++) {
      final r = 250.0 + i * 80.0;
      final opacity = (0.15 - i * 0.03).clamp(0.03, 0.15);
      ringPaint.color = Colors.white.withValues(alpha: opacity);
      // 3D 궤도를 투영해 그리기
      final path = Path();
      for (int a = 0; a <= 64; a++) {
        final angle = a / 64 * 2 * pi;
        final x = cos(angle) * r;
        final z = sin(angle) * r;
        final p = _project(x, 0, z, size);
        if (a == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, ringPaint);
    }

    // 카테고리 구체
    final spheres = <String, List<OrbitNode>>{};
    for (final n in graph.nodes) {
      spheres.putIfAbsent(n.post.category, () => []).add(n);
    }

    final catIdx = <String, int>{};
    var ci = 0;
    for (final cat in spheres.keys) {
      catIdx[cat] = ci++ % AzColors.categories.length;
    }

    // 구체 글로우 + 표면
    for (final entry in spheres.entries) {
      final idx = catIdx[entry.key] ?? 0;
      final color = AzColors.categoryColor(idx);
      final hidden = hiddenCategories.contains(entry.key);

      // 중심 좌표 (노드 평균)
      double cx = 0, cy = 0, cz = 0;
      for (final n in entry.value) {
        cx += n.x;
        cy += n.y;
        cz += n.z;
      }
      final count = entry.value.length.toDouble();
      cx /= count; cy /= count; cz /= count;

      final center = _project(cx, cy, cz, size);
      final radius = 40.0 + entry.value.length * 3.0;

      if (hidden) {
        final dimPaint = Paint()..color = color.withValues(alpha: 0.05);
        canvas.drawCircle(center, radius, dimPaint);
        continue;
      }

      // 글로우
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 2.5));
      canvas.drawCircle(center, radius * 2.5, glowPaint);

      // 구체
      final spherePaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            color.withValues(alpha: 0.4),
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, spherePaint);

      // 테두리
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: 0.5);
      canvas.drawCircle(center, radius, borderPaint);

      // 카테고리 이름
      final tp = TextPainter(
        text: TextSpan(
          text: entry.key.toUpperCase(),
          style: TextStyle(
            color: AzColors.categoryTextColor(idx),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center + Offset(-tp.width / 2, radius + 8));
    }

    // 링크 선
    final linkPaint = Paint()
      ..strokeWidth = 1
      ..color = AzColors.muted.withValues(alpha: 0.3);
    for (final link in graph.links) {
      final fromNode = graph.nodes.where((n) => n.post.id == link.from).firstOrNull;
      final toNode = graph.nodes.where((n) => n.post.id == link.to).firstOrNull;
      if (fromNode == null || toNode == null) continue;
      final p1 = _project(fromNode.x, fromNode.y, fromNode.z, size);
      final p2 = _project(toNode.x, toNode.y, toNode.z, size);
      canvas.drawLine(p1, p2, linkPaint);
    }

    // 노드 점
    for (final n in graph.nodes) {
      final idx = catIdx[n.post.category] ?? 0;
      final color = AzColors.categoryColor(idx);
      final hidden = hiddenCategories.contains(n.post.category);
      final p = _project(n.x, n.y, n.z, size);
      final isSelected = n.post.id == selectedId;
      final radius = isSelected ? 8.0 : 5.0;

      if (hidden) {
        canvas.drawCircle(p, radius, Paint()..color = color.withValues(alpha: 0.1));
        continue;
      }

      // 선택 글로우
      if (isSelected) {
        final glow = Paint()
          ..shader = RadialGradient(
            colors: [color.withValues(alpha: 0.3), Colors.transparent],
          ).createShader(Rect.fromCircle(center: p, radius: 24));
        canvas.drawCircle(p, 24, glow);
      }

      canvas.drawCircle(p, radius, Paint()..color = color);
      if (isSelected) {
        canvas.drawCircle(p, radius, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white);
      }
    }

    // 선택된 노드 라벨 알약
    for (final n in graph.nodes) {
      if (n.post.id != selectedId) continue;
      final p = _project(n.x, n.y, n.z, size);
      final text = n.post.title;
      final tp = TextPainter(
        text: TextSpan(
          text: text.length > 20 ? '${text.substring(0, 20)}...' : text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final pillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(p.dx - tp.width / 2 - 12, p.dy - 40, tp.width + 24, 28),
        const Radius.circular(14),
      );
      final idx = catIdx[n.post.category] ?? 0;
      canvas.drawRRect(pillRect, Paint()..color = AzColors.categoryTextColor(idx));
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - 36));
    }
  }

  @override
  bool shouldRepaint(covariant OrbitPainter old) =>
      old.yaw != yaw ||
      old.pitch != pitch ||
      old.distance != distance ||
      old.selectedId != selectedId ||
      old.time != time;
}
