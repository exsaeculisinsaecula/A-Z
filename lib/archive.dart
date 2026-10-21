/// A-Z 기록 모델 — 화면·디스크 의존 없음 (순수 Dart)
library;

import 'package:flutter/foundation.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

// ───────────────────────────── 예외 계층

sealed class AzException implements Exception {
  const AzException(this.message);
  final String message;
}

class NotFound extends AzException {
  const NotFound(super.message);
}

class InvalidLocation extends AzException {
  const InvalidLocation(super.message);
}

class StorageUnavailable extends AzException {
  const StorageUnavailable(super.message);
}

class VaultConflict extends AzException {
  const VaultConflict(super.message);
}

class CorruptedFile extends AzException {
  const CorruptedFile(super.message);
}

class MediaUnsupported extends AzException {
  const MediaUnsupported(super.message);
}

// ───────────────────────────── 미디어 종류

enum MediaKind { photo, video }

// ───────────────────────────── 값 객체

/// 첨부 — 보관함 기준 상대 경로로 가리킨다
class MediaRef {
  const MediaRef({
    required this.path,
    required this.kind,
    this.width,
    this.height,
    this.duration,
  });

  /// 보관함 기준 상대 경로 (구분자 `/`)
  final String path;
  final MediaKind kind;
  final int? width;
  final int? height;
  final Duration? duration;

  MediaRef copyWith({
    String? path,
    MediaKind? kind,
    int? width,
    int? height,
    Duration? duration,
  }) =>
      MediaRef(
        path: path ?? this.path,
        kind: kind ?? this.kind,
        width: width ?? this.width,
        height: height ?? this.height,
        duration: duration ?? this.duration,
      );

  String get fileName => path.split('/').last;

  @override
  bool operator ==(Object other) =>
      other is MediaRef && other.path == path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => 'MediaRef($path, ${kind.name})';
}

/// 카테고리 = 보관함 바로 아래 폴더
class Category {
  const Category({
    required this.name,
    this.colorIndex = 0,
    this.order = 0,
  });

  final String name;
  final int colorIndex;
  final int order;

  Category copyWith({String? name, int? colorIndex, int? order}) =>
      Category(
        name: name ?? this.name,
        colorIndex: colorIndex ?? this.colorIndex,
        order: order ?? this.order,
      );

  @override
  bool operator ==(Object other) =>
      other is Category && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

/// 포스트 = 기록 한 건 (.md 파일 하나)
class Post {
  Post({
    required this.id,
    required this.text,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.media = const [],
    this.tags = const [],
    this.starred = false,
    this.pinned = false,
    this.relativePath,
    this.extraFields = const {},
  });

  final String id; // p_ + hex 12자리
  final String text;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MediaRef> media;
  final List<String> tags;
  final bool starred;
  final bool pinned;
  final String? relativePath;
  final Map<String, dynamic> extraFields;

  String get title {
    final line = text.split('\n').first.trim();
    return line.isEmpty ? '(제목 없음)' : line;
  }

  bool get isMemo => media.isEmpty;

  Post copyWith({
    String? id,
    String? text,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MediaRef>? media,
    List<String>? tags,
    bool? starred,
    bool? pinned,
    String? relativePath,
    Map<String, dynamic>? extraFields,
  }) =>
      Post(
        id: id ?? this.id,
        text: text ?? this.text,
        category: category ?? this.category,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        media: media ?? this.media,
        tags: tags ?? this.tags,
        starred: starred ?? this.starred,
        pinned: pinned ?? this.pinned,
        relativePath: relativePath ?? this.relativePath,
        extraFields: extraFields ?? this.extraFields,
      );

  @override
  bool operator ==(Object other) => other is Post && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ───────────────────────────── 필터

enum MediaTypeFilter { all, photo, video, memo }

/// 필터 값 객체
class PostQuery {
  const PostQuery({
    this.hiddenCategories = const {},
    this.mediaType = MediaTypeFilter.all,
    this.tags = const {},
    this.searchText = '',
    this.starredOnly = false,
  });

  final Set<String> hiddenCategories;
  final MediaTypeFilter mediaType;
  final Set<String> tags;
  final String searchText;
  final bool starredOnly;

  bool matches(Post post) {
    if (hiddenCategories.contains(post.category)) return false;
    if (starredOnly && !post.starred) return false;
    if (tags.isNotEmpty && !post.tags.any(tags.contains)) return false;

    switch (mediaType) {
      case MediaTypeFilter.photo:
        if (!post.media.any((m) => m.kind == MediaKind.photo)) return false;
      case MediaTypeFilter.video:
        if (!post.media.any((m) => m.kind == MediaKind.video)) return false;
      case MediaTypeFilter.memo:
        if (!post.isMemo) return false;
      case MediaTypeFilter.all:
        break;
    }

    if (searchText.isNotEmpty) {
      final q = KoText.normalize(searchText.toLowerCase());
      final hay = KoText.normalize(
        '${post.text} ${post.tags.join(' ')} '
                '${post.media.map((m) => m.fileName).join(' ')}'
            .toLowerCase(),
      );
      if (!hay.contains(q)) return false;
    }
    return true;
  }

  PostQuery copyWith({
    Set<String>? hiddenCategories,
    MediaTypeFilter? mediaType,
    Set<String>? tags,
    String? searchText,
    bool? starredOnly,
  }) =>
      PostQuery(
        hiddenCategories: hiddenCategories ?? this.hiddenCategories,
        mediaType: mediaType ?? this.mediaType,
        tags: tags ?? this.tags,
        searchText: searchText ?? this.searchText,
        starredOnly: starredOnly ?? this.starredOnly,
      );
}

// ───────────────────────────── 태그 파서

/// 본문에서 `#태그` 추출 (코드 블록·제목 제외)
class TagParser {
  static final _tagRe = RegExp(r'(?:^|[\s(])#([^\s#`.,:;!?]{1,50})');

  static List<String> extract(String text) {
    final result = <String>[];
    var inCodeBlock = false;
    for (final rawLine in text.split('\n')) {
      final line = rawLine;
      if (line.trimLeft().startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) continue;
      // 마크다운 제목 표시(`# `)는 빼고, 그 줄에서 태그는 추출
      final cleaned = line.replaceFirst(RegExp(r'^#{1,6}\s'), '');
      for (final m in _tagRe.allMatches(cleaned)) {
        final tag = m.group(1)!;
        if (!result.contains(tag)) result.add(tag);
      }
    }
    return result;
  }
}

// ───────────────────────────── 한국어 텍스트 도구

/// NFC 정규화 · ko-KR 정렬 비교
abstract final class KoText {
  /// 유니코드 NFC 정규화
  static String normalize(String s) => unorm.nfc(s);

  /// 정렬 비교: 숫자 → 영문 → 한글 (코드 순 = 가나다순)
  static int compare(String a, String b) {
    final na = normalize(a);
    final nb = normalize(b);
    return _sortKey(na).compareTo(_sortKey(nb));
  }

  static String _sortKey(String s) {
    final b = StringBuffer();
    for (final rune in s.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        b.write('0${String.fromCharCode(rune)}');
      } else if ((rune >= 0x41 && rune <= 0x5A) ||
          (rune >= 0x61 && rune <= 0x7A)) {
        b.write('1${String.fromCharCode(rune).toLowerCase()}');
      } else {
        b.write('2${String.fromCharCode(rune)}');
      }
    }
    return b.toString();
  }
}

// ───────────────────────────── 시계 (테스트에서 고정)

class Clock {
  DateTime now() => DateTime.now();
}

// ───────────────────────────── 통계

class ArchiveStats {
  const ArchiveStats({
    required this.total,
    required this.photos,
    required this.videos,
    required this.memos,
    required this.starred,
  });

  final int total;
  final int photos;
  final int videos;
  final int memos;
  final int starred;
}

// ───────────────────────────── 궤도 그래프 자료

class OrbitNode {
  const OrbitNode({required this.post, required this.x, required this.y, required this.z});
  final Post post;
  final double x, y, z;
}

class OrbitLink {
  const OrbitLink({required this.from, required this.to, required this.tag});
  final String from; // post id
  final String to; // post id
  final String tag;
}

class OrbitGraph {
  const OrbitGraph({required this.nodes, required this.links});
  final List<OrbitNode> nodes;
  final List<OrbitLink> links;
}

// ───────────────────────────── Archive

/// 메모리 속 포스트 목록, 검색·통계, 작성·수정·삭제
///
/// 지금은 메모리만 쓰고, T6에서 `Vault`로 저장을 맡긴다.
class Archive extends ChangeNotifier {
  final List<Post> _posts = [];
  final Clock _clock;
  int _idSeq = 0;

  Archive({Clock? clock}) : _clock = clock ?? Clock();

  // ── 조회

  /// 필터 + 정렬(최신순) + 페이징
  List<Post> query(PostQuery q, {int offset = 0, int limit = 30}) {
    final filtered = _posts.where(q.matches).toList()
      ..sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    if (offset >= filtered.length) return const [];
    final end = (offset + limit).clamp(0, filtered.length);
    return filtered.sublist(offset, end);
  }

  /// 하나 찾기 (없으면 `NotFound`)
  Post byId(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      throw NotFound('포스트 없음: $id');
    }
  }

  ArchiveStats stats() {
    final photos = _posts.where((p) => p.media.any((m) => m.kind == MediaKind.photo)).length;
    final videos = _posts.where((p) => p.media.any((m) => m.kind == MediaKind.video)).length;
    return ArchiveStats(
      total: _posts.length,
      photos: photos,
      videos: videos,
      memos: _posts.where((p) => p.isMemo).length,
      starred: _posts.where((p) => p.starred).length,
    );
  }

  /// 궤도 뷰 그래프 (태그 이웃 연결)
  OrbitGraph graph(PostQuery q) {
    final visible = query(q, limit: 9999);
    final byTag = <String, List<Post>>{};
    for (final p in visible) {
      for (final t in p.tags) {
        byTag.putIfAbsent(t, () => []).add(p);
      }
    }
    final links = <OrbitLink>[];
    for (final entry in byTag.entries) {
      final sorted = [...entry.value]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (var i = 0; i < sorted.length - 1; i++) {
        links.add(OrbitLink(from: sorted[i].id, to: sorted[i + 1].id, tag: entry.key));
      }
    }
    // 결정적 배치: id 해시로 좌표
    final nodes = visible.map((p) {
      final h = p.id.hashCode;
      final angle = (h % 360) * 3.14159 / 180.0;
      final r = 200.0 + (h.abs() % 400).toDouble();
      return OrbitNode(
        post: p,
        x: r * _cos(angle),
        y: (h % 200 - 100).toDouble(),
        z: r * _sin(angle),
      );
    }).toList();
    return OrbitGraph(nodes: nodes, links: links);
  }

  double _cos(double rad) {
    // 간단한 코사인 근사 (lib:math 없이)
    return _sin(rad + 1.5707963);
  }

  double _sin(double rad) {
    // 테일러 전개 (소수 몇 자리)
    var result = 0.0, term = rad;
    for (var i = 1; i <= 7; i += 2) {
      result += term;
      term *= -rad * rad / ((i + 1) * (i + 2));
    }
    return result;
  }

  // ── 변경

  /// 새 포스트 (메모리에만, T6에서 Vault 연동)
  Post create({
    required String text,
    required String category,
    List<MediaRef> media = const [],
    bool starred = false,
    bool pinned = false,
  }) {
    _idSeq++;
    final id = 'p_${_idSeq.toRadixString(16).padLeft(12, '0')}';
    final now = _clock.now();
    final post = Post(
      id: id,
      text: text,
      category: category,
      createdAt: now,
      updatedAt: now,
      media: media,
      tags: TagParser.extract(text),
      starred: starred,
      pinned: pinned,
    );
    _posts.add(post);
    notifyListeners();
    return post;
  }

  void update(Post post) {
    final idx = _posts.indexWhere((p) => p.id == post.id);
    if (idx < 0) throw NotFound('포스트 없음: ${post.id}');
    _posts[idx] = post.copyWith(updatedAt: _clock.now());
    notifyListeners();
  }

  void delete(String id) {
    final idx = _posts.indexWhere((p) => p.id == id);
    if (idx < 0) throw NotFound('포스트 없음: $id');
    _posts.removeAt(idx);
    notifyListeners();
  }

  void toggleStar(String id) {
    final p = byId(id);
    update(p.copyWith(starred: !p.starred));
  }

  void moveToCategory(String id, String category) {
    final p = byId(id);
    update(p.copyWith(category: category));
  }
}
