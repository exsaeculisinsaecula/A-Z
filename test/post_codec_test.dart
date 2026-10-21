import 'package:flutter_test/flutter_test.dart';
import 'package:a_z/archive.dart';
import 'package:a_z/vault.dart';

void main() {
  group('PostCodec.encode', () {
    test('기본 포스트를 .md로 만든다', () {
      final p = Post(
        id: 'p_abc',
        text: '제목\n본문 #태그',
        category: '디자인',
        createdAt: DateTime(2026, 10, 1, 9, 30),
        updatedAt: DateTime(2026, 10, 21, 13, 20),
        tags: ['태그'],
      );
      final md = PostCodec.encode(p);
      expect(md, contains('id: p_abc'));
      expect(md, contains('created: 2026-10-01T09:30:00'));
      expect(md, contains('starred: false'));
      expect(md, contains('제목\n본문 #태그'));
    });

    test('첨부가 본문에 없으면 아래에 붙인다', () {
      final p = Post(
        id: 'p_x',
        text: '내용',
        category: 'a',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        media: [const MediaRef(path: 'a/첨부/ring.jpg', kind: MediaKind.photo)],
      );
      final md = PostCodec.encode(p);
      expect(md, contains('![[a/첨부/ring.jpg]]'));
    });

    test('첨부가 본문에 있으면 중복 안 함', () {
      final p = Post(
        id: 'p_x',
        text: '내용\n![[a/ring.jpg]]',
        category: 'a',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        media: [const MediaRef(path: 'a/ring.jpg', kind: MediaKind.photo)],
      );
      final md = PostCodec.encode(p);
      expect('![[a/ring.jpg]]'.allMatches(md).length, 1);
    });

    test('starred·pinned 반영', () {
      final p = Post(
        id: 'p_s',
        text: 'x',
        category: 'a',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        starred: true,
        pinned: true,
      );
      final md = PostCodec.encode(p);
      expect(md, contains('starred: true'));
      expect(md, contains('pinned: true'));
    });
  });

  group('PostCodec.decode', () {
    test('머리말 + 본문 파싱', () {
      const md = '''
---
id: p_3f9a
created: 2026-10-01T09:30:00+09:00
updated: 2026-10-21T13:20:00+09:00
starred: true
pinned: false
---
궤도 링 색감 연구
레퍼런스에서 뽑은 색으로 #색감 #레퍼런스

![[디자인/첨부/ring-01.jpg]]
![[디자인/첨부/ring-02.jpg]]
''';
      final p = PostCodec.decode(md, relativePath: '디자인/2026-10-01 0930 궤도 링 색감 연구.md');
      expect(p.id, 'p_3f9a');
      expect(p.starred, true);
      expect(p.pinned, false);
      expect(p.text, contains('궤도 링 색감 연구'));
      expect(p.tags, ['색감', '레퍼런스']);
      expect(p.media.length, 2);
      expect(p.media[0].path, '디자인/첨부/ring-01.jpg');
      expect(p.category, '디자인');
    });

    test('머리말이 없으면 임시 id', () {
      final p = PostCodec.decode('제목만 있는 메모');
      expect(p.id, startsWith('p_'));
      expect(p.title, '제목만 있는 메모');
    });

    test('모르는 머리말 필드 보존', () {
      const md = '''
---
id: p_x
created: 2026-01-01T00:00:00+09:00
updated: 2026-01-01T00:00:00+09:00
starred: false
pinned: false
obsidian_custom: hello
priority: 3
---
본문
''';
      final p = PostCodec.decode(md);
      expect(p.extraFields['obsidian_custom'], 'hello');
      expect(p.extraFields['priority'], 3);
    });

    test('마크다운 이미지 링크도 인식', () {
      const md = '''
---
id: p_md
---
내용

![](디자인/첨부/photo.png)
''';
      final p = PostCodec.decode(md);
      expect(p.media.length, 1);
      expect(p.media[0].kind, MediaKind.photo);
    });

    test('영상 확장자 → MediaKind.video', () {
      const md = '''
---
id: p_v
---
영상

![[실험/첨부/clip.mp4]]
''';
      final p = PostCodec.decode(md);
      expect(p.media[0].kind, MediaKind.video);
    });

    test('카테고리는 경로에서 추출', () {
      const md = '---\nid: p_c\n---\n제목';
      final p = PostCodec.decode(md, relativePath: '과학 노트/메모.md');
      expect(p.category, '과학 노트');
    });

    test('깨진 YAML → 본문만', () {
      const md = '---\n{{{broken\n---\n본문만';
      final p = PostCodec.decode(md);
      expect(p.text, contains('본문만'));
      expect(p.id, startsWith('p_'));
    });

    test('ISO 8601 날짜 파싱', () {
      const md = '---\nid: p_t\ncreated: 2026-08-17T04:57:12+09:00\nupdated: 2026-08-17T04:57:12+09:00\n---\n내용';
      final p = PostCodec.decode(md);
      // UTC 변환 확인 (+09:00 → UTC 19:57)
      final utc = p.createdAt.toUtc();
      expect(utc.year, 2026);
      expect(utc.month, 8);
      expect(utc.day, 16);
      expect(utc.hour, 19);
    });
  });

  group('PostCodec 왕복', () {
    test('encode → decode → 같은 값', () {
      final original = Post(
        id: 'p_round',
        text: '제목\n설명 #테스트 #한글',
        category: '디자인',
        createdAt: DateTime(2026, 10, 1, 9, 30),
        updatedAt: DateTime(2026, 10, 21, 13, 20),
        media: [
          const MediaRef(path: '디자인/첨부/ring.jpg', kind: MediaKind.photo),
        ],
        tags: ['테스트', '한글'],
        starred: true,
        pinned: true,
      );
      final md = PostCodec.encode(original);
      final decoded = PostCodec.decode(md, relativePath: '디자인/메모.md');
      expect(decoded.id, original.id);
      expect(decoded.text, original.text);
      expect(decoded.starred, original.starred);
      expect(decoded.pinned, original.pinned);
      expect(decoded.media.length, original.media.length);
      expect(decoded.tags, original.tags);
      expect(decoded.createdAt.isAtSameMomentAs(original.createdAt), true);
    });

    test('모르는 필드가 왕복에서 살아남는다', () {
      final original = Post(
        id: 'p_extra',
        text: 'x',
        category: 'a',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        extraFields: {'obsidian_custom': 'hello', 'priority': 3},
      );
      final md = PostCodec.encode(original);
      final decoded = PostCodec.decode(md);
      expect(decoded.extraFields['obsidian_custom'], 'hello');
      expect(decoded.extraFields['priority'], 3);
    });

    test('한글 경로·이름 왕복', () {
      final original = Post(
        id: 'p_ko',
        text: '한글 제목',
        category: '과학 지식 자료',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        media: [
          const MediaRef(path: '과학 지식 자료/첨부/영상.mp4', kind: MediaKind.video),
        ],
      );
      final md = PostCodec.encode(original);
      final decoded = PostCodec.decode(md, relativePath: '과학 지식 자료/한글 메모.md');
      expect(decoded.category, '과학 지식 자료');
      expect(decoded.media[0].path, '과학 지식 자료/첨부/영상.mp4');
      expect(decoded.media[0].kind, MediaKind.video);
    });
  });
}
