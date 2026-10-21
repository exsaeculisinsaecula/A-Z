/// A-Z 보관함 파일 변환 · 저장 — `.md` ↔ `Post`, 보관함 읽기·쓰기
///
/// 화면·네트워크 의존 없음 (순수 Dart + `package:file`)
library;

import 'dart:convert';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'archive.dart';

/// MemoryFileSystem·크로스 플랫폼을 위한 POSIX 경로 컨텍스트
final _posix = p.posix;

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
    var normalized = path.replaceAll('\\', '/');
    if (normalized.startsWith('./')) normalized = normalized.substring(2);
    return KoText.normalize(normalized);
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

// ───────────────────────────── AtomicWriter

/// 임시 파일에 쓰고 rename으로 교체 — 파일이 깨지지 않는다
class AtomicWriter {
  final FileSystem _fs;
  AtomicWriter(this._fs);

  Future<void> writeString(String path, String content) async {
    await _fs.directory(_posix.dirname(path)).create(recursive: true);
    final tmp = '$path.tmp';
    await _fs.file(tmp).writeAsString(content, flush: true);
    await _fs.file(tmp).rename(path);
  }

  Future<void> writeBytes(String path, List<int> bytes) async {
    await _fs.directory(_posix.dirname(path)).create(recursive: true);
    final tmp = '$path.tmp';
    await _fs.file(tmp).writeAsBytes(bytes, flush: true);
    await _fs.file(tmp).rename(path);
  }

  Future<void> copy(String src, String dest) async {
    await _fs.file(src).copy(dest);
  }

  /// 남은 `.tmp` 파일 정리 (강제 종료 복구)
  Future<void> cleanTmp(String dir) async {
    await for (final e in _fs.directory(dir).list()) {
      if (e is File && e.path.endsWith('.tmp')) {
        try {
          await e.delete();
        } catch (_) {}
      }
    }
  }
}

// ───────────────────────────── Vault

/// 보관함 폴더 하나 — 만들기·열기·포스트 읽기·쓰기·첨부·휴지통
///
/// 모든 경로는 보관함 기준 상대 경로(구분자 `/`)
class Vault {
  final Directory _root;
  final FileSystem _fs;
  final AtomicWriter _writer;

  Vault._(this._root, this._fs, this._writer);

  Directory get root => _root;

  /// 새 보관함 만들기
  static Future<Vault> create(Directory parent, String name,
      {required FileSystem fs, required AtomicWriter writer}) async {
    final dir = fs.directory(_posix.join(parent.path, name));
    await dir.create(recursive: true);
    final az = fs.directory(_posix.join(dir.path, '.az'));
    await az.create(recursive: true);
    await writer.writeString(
      _posix.join(az.path, 'vault.json'),
      jsonEncode({
        'format': 'a-z-vault',
        'version': 1,
        'created': DateTime.now().toIso8601String(),
      }),
    );
    await writer.writeString(_posix.join(az.path, 'settings.json'), '{}');
    // 미분류 폴더
    await fs.directory(_posix.join(dir.path, '미분류')).create(recursive: true);
    return Vault._(dir, fs, writer);
  }

  /// 기존 보관함 열기
  static Future<Vault> open(Directory root,
      {required FileSystem fs, required AtomicWriter writer}) async {
    final marker = fs.file(_posix.join(root.path, '.az', 'vault.json'));
    if (!await marker.exists()) {
      throw InvalidLocation('보관함이 아닙니다: ${root.path}');
    }
    await writer.cleanTmp(root.path);
    return Vault._(root, fs, writer);
  }

  /// 상대 경로(`a/b.md`) → 절대 경로
  String absPath(String relativePath) {
    final norm = relativePath.replaceAll('\\', '/');
    final parts = norm.split('/');
    return _posix.joinAll([_root.path, ...parts]);
  }

  /// 절대 경로 → 상대 경로(`/` 구분자)
  String relPath(String absolutePath) {
    final r = _posix.relative(absolutePath, from: _root.path);
    return r.replaceAll('\\', '/');
  }

  // ── 포스트

  /// `.md` 파일 목록 (하위 폴더 포함, `.az/` 제외)
  Stream<String> listPostPaths() async* {
    await for (final entity in _root.list(recursive: true)) {
      if (entity is! File) continue;
      final rel = relPath(entity.path);
      if (rel.startsWith('.az/')) continue;
      if (!rel.endsWith('.md')) continue;
      yield rel;
    }
  }

  /// 포스트 읽기
  Future<Post> readPost(String relativePath) async {
    final file = _fs.file(absPath(relativePath));
    if (!await file.exists()) {
      throw NotFound('포스트 없음: $relativePath');
    }
    try {
      final source = await file.readAsString();
      return PostCodec.decode(source, relativePath: relativePath);
    } on AzException {
      rethrow;
    } catch (e) {
      throw CorruptedFile('읽을 수 없음: $relativePath ($e)');
    }
  }

  /// 포스트 쓰기 (원자적)
  Future<void> writePost(Post post) async {
    final rel = post.relativePath ??
        '${post.category}/${_fileName(post)}.md';
    final abs = absPath(rel);
    await _fs.directory(_posix.dirname(abs)).create(recursive: true);
    final md = PostCodec.encode(post.copyWith(relativePath: rel));
    await _writer.writeString(abs, md);
  }

  /// 포스트 삭제 (휴지통으로)
  Future<void> trashPost(String relativePath) async {
    final abs = absPath(relativePath);
    final file = _fs.file(abs);
    if (!await file.exists()) {
      throw NotFound('포스트 없음: $relativePath');
    }
    final trashDir = _posix.join(_root.path, '.az', 'trash',
        DateTime.now().millisecondsSinceEpoch.toString());
    await _fs.directory(trashDir).create(recursive: true);
    final dest = _posix.join(trashDir, relativePath.replaceAll('/', '_'));
    await file.copy(dest);
    await file.delete();
  }

  // ── 첨부

  /// 바깥 파일을 보관함 `<카테고리>/첨부/`로 복사 → 상대 경로
  Future<String> copyAttachment(String sourcePath, String category) async {
    final name = _posix.basename(sourcePath);
    final dir = _fs.directory(absPath('$category/첨부'));
    await dir.create(recursive: true);
    var dest = absPath('$category/첨부/$name');
    var finalName = name;

    // 이름 충돌 → (2), (3) ...
    var i = 1;
    while (await _fs.file(dest).exists()) {
      final stem = _posix.basenameWithoutExtension(name);
      final ext = _posix.extension(name);
      finalName = '$stem ($i)$ext';
      dest = absPath('$category/첨부/$finalName');
      i++;
    }

    await _writer.copy(sourcePath, dest);
    return '$category/첨부/$finalName';
  }

  /// 첨부 파일 존재 여부
  Future<bool> attachmentExists(String relativePath) async {
    return _fs.file(absPath(relativePath)).exists();
  }

  // ── 카테고리 이동

  /// 포스트 + 그 포스트만 쓰는 첨부를 새 카테고리로 옮김
  Future<void> moveToCategory(Post post, String newCategory) async {
    final oldRel = post.relativePath!;
    final oldCat = post.category;

    // 새 경로
    final name = _posix.basename(oldRel);
    final newRel = '$newCategory/$name';
    final newAbs = absPath(newRel);

    await _fs.directory(_posix.dirname(newAbs)).create(recursive: true);

    // 포스트 파일 이동
    await _fs.file(absPath(oldRel)).rename(newAbs);

    // 첨부 이동 (그 포스트만 쓰는 것)
    final oldAttachDir = _fs.directory(absPath('$oldCat/첨부'));
    if (await oldAttachDir.exists()) {
      final newAttachDir = absPath('$newCategory/첨부');
      await _fs.directory(newAttachDir).create(recursive: true);
      await for (final e in oldAttachDir.list()) {
        if (e is File) {
          final fname = _posix.basename(e.path);
          final dest = _posix.join(newAttachDir, fname);
          await e.copy(dest);
          await e.delete();
        }
      }
    }
  }

  String _fileName(Post post) {
    final title = post.title;
    final safe = title
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .substring(0, title.length.clamp(0, 40));
    final date = post.createdAt
        .toIso8601String()
        .substring(0, 16)
        .replaceAll('T', ' ')
        .replaceAll(':', '');
    return '$date $safe';
  }
}

// ───────────────────────────── Trash

/// 휴지통 — 지운 파일 보관·복원·비우기
class Trash {
  final FileSystem _fs;
  final Directory _trashDir;

  Trash(this._fs, this._trashDir);

  /// 지운 항목 목록 (상대 경로)
  Future<List<String>> list() async {
    final result = <String>[];
    await for (final e in _trashDir.list(recursive: true)) {
      if (e is File) {
        result.add(_posix.relative(e.path, from: _trashDir.path));
      }
    }
    return result;
  }

  /// 복원
  Future<void> restore(String trashId, String targetPath) async {
    final src = _posix.join(_trashDir.path, trashId);
    final file = _fs.file(src);
    if (!await file.exists()) {
      throw NotFound('휴지통에 없음: $trashId');
    }
    await _fs.directory(_posix.dirname(targetPath)).create(recursive: true);
    await file.copy(targetPath);
    await file.delete();
  }

  /// 비우기
  Future<void> empty() async {
    await _trashDir.delete(recursive: true);
    await _trashDir.create(recursive: true);
  }
}
