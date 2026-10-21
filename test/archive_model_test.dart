import 'package:flutter_test/flutter_test.dart';
import 'package:a_z/archive.dart';

void main() {
  // ── Post
  group('Post', () {
    test('title은 본문 첫 줄', () {
      final p = _post(text: '첫줄\n둘째줄');
      expect(p.title, '첫줄');
    });

    test('title이 비면 대체 문자열', () {
      final p = _post(text: '\n\n');
      expect(p.title, '(제목 없음)');
    });

    test('isMemo는 첨부 없을 때만', () {
      expect(_post().isMemo, true);
      final withMedia = _post(media: [
        const MediaRef(path: 'a/b.jpg', kind: MediaKind.photo),
      ]);
      expect(withMedia.isMemo, false);
    });

    test('copyWith가 값 객체처럼 동작', () {
      final p = _post(text: '원본');
      final q = p.copyWith(text: '수정');
      expect(q.text, '수정');
      expect(p.text, '원본');
    });

    test('id로 동등성 판단', () {
      final a = _post(id: 'p_123');
      final b = _post(id: 'p_123');
      expect(a, equals(b));
    });
  });

  // ── MediaRef
  group('MediaRef', () {
    test('fileName은 마지막 경로 조각', () {
      const m = MediaRef(path: '디자인/첨부/ring-01.jpg', kind: MediaKind.photo);
      expect(m.fileName, 'ring-01.jpg');
    });

    test('경로로 동등성', () {
      const a = MediaRef(path: 'x/y.jpg', kind: MediaKind.photo);
      const b = MediaRef(path: 'x/y.jpg', kind: MediaKind.video);
      expect(a, equals(b));
    });
  });

  // ── TagParser
  group('TagParser', () {
    test('해시태그 추출', () {
      expect(TagParser.extract('안녕 #인사 #첫글'), ['인사', '첫글']);
    });

    test('중복 제거', () {
      expect(TagParser.extract('#중복 #중복'), ['중복']);
    });

    test('코드 블록 속 # 제외', () {
      expect(TagParser.extract('```\n#코드\n```\n#실제'), ['실제']);
    });

    test('마크다운 제목 표시 제외', () {
      expect(TagParser.extract('# 제목 #본문'), ['본문']);
    });

    test('문장 부호 옆 태그 인식', () {
      expect(TagParser.extract('끝! #끝 #마무리.'), ['끝', '마무리']);
    });

    test('한글 태그', () {
      expect(TagParser.extract('#한글태그 #한글'), ['한글태그', '한글']);
    });

    test('태그 없으면 빈 목록', () {
      expect(TagParser.extract('태그 없는 글'), isEmpty);
    });
  });

  // ── PostQuery
  group('PostQuery', () {
    final post = Post(
      id: 'p_1',
      text: '디자인 참고 #디자인',
      category: '디자인',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      tags: ['디자인'],
      media: [
        const MediaRef(path: 'a/b.jpg', kind: MediaKind.photo),
      ],
    );

    test('기본 필터는 전부 통과', () {
      expect(const PostQuery().matches(post), true);
    });

    test('숨긴 카테고리 제외', () {
      const q = PostQuery(hiddenCategories: {'디자인'});
      expect(q.matches(post), false);
    });

    test('유형 필터: 사진', () {
      const q = PostQuery(mediaType: MediaTypeFilter.photo);
      expect(q.matches(post), true);
    });

    test('유형 필터: 메모는 첨부 없을 때만', () {
      const q = PostQuery(mediaType: MediaTypeFilter.memo);
      expect(q.matches(post), false);
    });

    test('태그 필터', () {
      const q = PostQuery(tags: {'디자인'});
      expect(q.matches(post), true);
      const other = PostQuery(tags: {'사진'});
      expect(other.matches(post), false);
    });

    test('검색어 필터', () {
      const q = PostQuery(searchText: '디자인');
      expect(q.matches(post), true);
      const none = PostQuery(searchText: '여행');
      expect(none.matches(post), false);
    });

    test('즐겨찾기만', () {
      final starred = post.copyWith(starred: true);
      expect(const PostQuery(starredOnly: true).matches(starred), true);
      expect(const PostQuery(starredOnly: true).matches(post), false);
    });
  });

  // ── KoText
  group('KoText', () {
    test('NFC 정규화', () {
      final nfd = String.fromCharCodes([0x1100, 0x1161]); // ᄀ + ᅡ
      final nfc = String.fromCharCode(0xAC00); // 가
      expect(KoText.normalize(nfd), nfc);
    });

    test('같은 한글이 다르게 저장돼도 비교 시 같음', () {
      final a = KoText.normalize(String.fromCharCodes([0x1100, 0x1161]));
      final b = KoText.normalize('가');
      expect(a, b);
    });

    test('정렬: 숫자 → 영문 → 한글', () {
      final list = ['한글', 'abc', '123', 'Apple', '가나'];
      list.sort(KoText.compare);
      expect(list, ['123', 'abc', 'Apple', '가나', '한글']);
    });

    test('가나다순', () {
      final list = ['한글', '가나', '다라'];
      list.sort(KoText.compare);
      expect(list, ['가나', '다라', '한글']);
    });
  });

  // ── Category
  group('Category', () {
    test('이름으로 동등성', () {
      const a = Category(name: '디자인');
      const b = Category(name: '디자인', colorIndex: 3);
      expect(a, equals(b));
    });
  });

  // ── AzException
  group('AzException', () {
    test('sealed 계층', () {
      const e = NotFound('없음');
      expect(e, isA<AzException>());
      expect(e.message, '없음');
    });
  });
}

Post _post({
  String id = 'p_test',
  String text = '내용',
  String category = '미분류',
  List<MediaRef> media = const [],
  List<String> tags = const [],
}) =>
    Post(
      id: id,
      text: text,
      category: category,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      media: media,
      tags: tags,
    );
