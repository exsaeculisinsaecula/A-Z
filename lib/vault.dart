/// A-Z 보관함 파일 변환 — `.md` ↔ `Post`
///
/// 화면·네트워크 의존 없음 (순수 Dart)
library;

import 'package:yaml/yaml.dart';

import 'archive.dart';

/// `.md` 문자열 ↔ `Post` 왕복 변환
///
/// - YAML 1.2 머리말 (`---` 사이) + GFM 본문
/// - 모르는 머리말 필드는 `extraFields`에 보존
/// - 본문: 첫 줄 = 제목, `#태그`, `![[경로]]` 첨부
abstract final class PostCodec {
  // ── 인코딩

  /// Post → `.md` 문자열
  static String encode(Post post) {
    final buf = StringBuffer();

    // YAML 머리말
    buf.writeln('---');
    buf.writeln('id: ${post.id}');
    buf.writeln('created: ${_fmtDate(post.createdAt)}');
    buf.writeln('updated: ${_fmtDate(post.updatedAt)}');
    buf.writeln('starred: ${post.starred}');
    buf.writeln('pinned: ${post.pinned}');
    for (final e in post.extraFields.entries) {
      buf.writeln('${e.key}: ${_yamlValue(e.value)}');
    }
    buf.writeln('---');

    // 본문
    buf.writeln(post.text);

    // 첨부 링크 (본문에 없으면 아래에 붙임)
    for (final m in post.media) {
      final link = '![[${m.path}]]';
      if (!post.text.contains(link)) {
        buf.writeln(link);
      }
    }

    return buf.toString();
  }

  /// `.md` 문자열 → Post
  ///
  /// `relativePath`는 보관함 기준 상대 경로
  static Post decode(String source, {String? relativePath}) {
    var rest = source;

    // YAML 머리말 파싱
    Map<String, dynamic> front = {};
    if (rest.startsWith('---')) {
      final end = rest.indexOf('---', 3);
      if (end > 0) {
        final yamlStr = rest.substring(3, end);
        try {
          final yaml = loadYaml(yamlStr);
          if (yaml is YamlMap) {
            front = Map<String, dynamic>.from(yaml);
          }
        } on YamlException {
          // 깨진 머리말 → 본문만
        }
        rest = rest.substring(end + 3).replaceFirst(RegExp(r'^\n'), '');
      }
    }

    // 본문에서 첨부 링크 추출
    final media = <MediaRef>[];
    final bodyBuf = StringBuffer();
    for (final line in rest.split('\n')) {
      final mediaMatch = RegExp(r'!\[\[([^\]]+)\]\]').firstMatch(line);
      if (mediaMatch != null && line.trim() == mediaMatch.group(0)) {
        // 첨부 전용 줄
        final path = _normPath(mediaMatch.group(1)!);
        media.add(MediaRef(path: path, kind: _guessKind(path)));
      } else {
        // 이미지 마크다운도 인식
        final mdImg = RegExp(r'!\[[^\]]*\]\(([^)]+)\)').firstMatch(line);
        if (mdImg != null && line.trim() == mdImg.group(0)) {
          final path = _normPath(mdImg.group(1)!);
          media.add(MediaRef(path: path, kind: _guessKind(path)));
        } else {
          bodyBuf.writeln(line);
        }
      }
    }

    // 본문 정리
    var body = bodyBuf.toString().trimRight();
    final title = body.split('\n').first.trim();
    if (body.isEmpty) body = title;

    // 머리말 → Post 필드
    final id = front['id'] as String? ?? _tempId(relativePath);
    final createdAt = _parseDate(front['created']) ?? DateTime.now();
    final updatedAt = _parseDate(front['updated']) ?? createdAt;
    final starred = front['starred'] == true;
    final pinned = front['pinned'] == true;

    // 알 수 없는 필드 보존
    final known = {'id', 'created', 'updated', 'starred', 'pinned'};
    final extra = Map<String, dynamic>.from(front)
      ..removeWhere((k, _) => known.contains(k));

    return Post(
      id: id,
      text: body,
      category: _categoryFromPath(relativePath) ?? '미분류',
      createdAt: createdAt,
      updatedAt: updatedAt,
      media: media,
      tags: TagParser.extract(body),
      starred: starred,
      pinned: pinned,
      relativePath: relativePath,
      extraFields: extra,
    );
  }

  // ── 내부 도우미

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}T'
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}:'
      '${d.second.toString().padLeft(2, '0')}'
      '${d.timeZoneOffset.isNegative ? '-' : '+'}'
      '${d.timeZoneOffset.abs().inHours.toString().padLeft(2, '0')}:'
      '${(d.timeZoneOffset.abs().inMinutes % 60).toString().padLeft(2, '0')}';

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String _yamlValue(dynamic v) {
    if (v is bool || v is num) return '$v';
    if (v is String) {
      if (v.contains(': ') || v.startsWith('#') || v.contains('\n')) {
        return '"${v.replaceAll('"', '\\"')}"';
      }
      return v;
    }
    return '$v';
  }

  static String _normPath(String path) {
    var p = path.replaceAll('\\', '/');
    if (p.startsWith('./')) p = p.substring(2);
    return KoText.normalize(p);
  }

  static MediaKind _guessKind(String path) {
    final ext = path.split('.').last.toLowerCase();
    const videoExts = {'mp4', 'mov', 'webm', 'mkv', 'avi', 'm4v'};
    return videoExts.contains(ext) ? MediaKind.video : MediaKind.photo;
  }

  static String _tempId(String? path) {
    final key = path ?? DateTime.now().microsecondsSinceEpoch.toString();
    final hash = key.hashCode & 0xFFFFFFFF;
    return 'p_${hash.toRadixString(16).padLeft(8, '0')}';
  }

  static String? _categoryFromPath(String? path) {
    if (path == null) return null;
    final parts = path.split('/');
    if (parts.length >= 2) return parts[0];
    return null;
  }
}
