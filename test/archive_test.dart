import 'package:flutter_test/flutter_test.dart';
import 'package:a_z/archive.dart';

void main() {
  late Archive archive;

  setUp(() {
    archive = Archive(clock: _FixedClock(DateTime(2026, 10, 21, 9, 30)));
  });

  group('Archive.create', () {
    test('포스트를 만들면 목록에 들어간다', () {
      archive.create(text: '첫 기록', category: '미분류');
      expect(archive.stats().total, 1);
    });

    test('태그가 자동 추출된다', () {
      final p = archive.create(text: '안녕 #인사', category: '미분류');
      expect(p.tags, ['인사']);
    });

    test('고유 id가 생성된다', () {
      final a = archive.create(text: 'A', category: '미분류');
      final b = archive.create(text: 'B', category: '미분류');
      expect(a.id, isNot(b.id));
    });

    test('notifyListeners가 호출된다', () {
      var notified = false;
      archive.addListener(() => notified = true);
      archive.create(text: 'x', category: '미분류');
      expect(notified, true);
    });
  });

  group('Archive.query', () {
    setUp(() {
      archive.create(
        text: '사진 기록',
        category: '디자인',
        media: [const MediaRef(path: 'a.jpg', kind: MediaKind.photo)],
      );
      archive.create(text: '메모 기록 #과학', category: '과학');
      archive.create(text: '오래된 기록', category: '디자인');
    });

    test('필터 없으면 전체', () {
      expect(archive.query(const PostQuery()).length, 3);
    });

    test('카테고리 필터', () {
      const q = PostQuery(hiddenCategories: {'디자인'});
      expect(archive.query(q).length, 1);
    });

    test('유형 필터: 사진', () {
      const q = PostQuery(mediaType: MediaTypeFilter.photo);
      expect(archive.query(q).length, 1);
    });

    test('유형 필터: 메모', () {
      const q = PostQuery(mediaType: MediaTypeFilter.memo);
      expect(archive.query(q).length, 2);
    });

    test('검색어 필터', () {
      const q = PostQuery(searchText: '메모');
      expect(archive.query(q).length, 1);
    });

    test('페이징', () {
      expect(archive.query(const PostQuery(), limit: 2).length, 2);
      expect(archive.query(const PostQuery(), offset: 2).length, 1);
    });

    test('정렬: pinned 우선, 같은 시각은 입력 순', () {
      final list = archive.query(const PostQuery());
      expect(list.first.text, '사진 기록'); // 같은 시각이므로 입력 순 유지
    });
  });

  group('Archive 수정·삭제', () {
    late Post post;

    setUp(() {
      post = archive.create(text: '원본', category: '미분류');
    });

    test('update로 메모를 고칠 수 있다', () {
      archive.update(post.copyWith(text: '수정됨'));
      expect(archive.byId(post.id).text, '수정됨');
    });

    test('update 시 updatedAt이 바뀐다', () {
      final archive2 = Archive(clock: _FixedClock(DateTime(2026, 10, 22)));
      final p = archive2.create(text: 'x', category: '미분류');
      archive2.update(p.copyWith(text: 'y'));
      expect(archive2.byId(p.id).updatedAt, DateTime(2026, 10, 22));
    });

    test('delete하면 목록에서 사라진다', () {
      archive.delete(post.id);
      expect(archive.stats().total, 0);
    });

    test('없는 id 수정→NotFound', () {
      expect(() => archive.update(post.copyWith(id: 'p_none')), throwsA(isA<NotFound>()));
    });

    test('없는 id 삭제→NotFound', () {
      expect(() => archive.delete('p_none'), throwsA(isA<NotFound>()));
    });

    test('toggleStar', () {
      archive.toggleStar(post.id);
      expect(archive.byId(post.id).starred, true);
      archive.toggleStar(post.id);
      expect(archive.byId(post.id).starred, false);
    });

    test('moveToCategory', () {
      archive.moveToCategory(post.id, '디자인');
      expect(archive.byId(post.id).category, '디자인');
    });
  });

  group('Archive.stats', () {
    test('유형별 개수', () {
      archive.create(text: '사진', category: 'a', media: [
        const MediaRef(path: 'x.jpg', kind: MediaKind.photo),
      ]);
      archive.create(text: '영상', category: 'a', media: [
        const MediaRef(path: 'y.mp4', kind: MediaKind.video),
      ]);
      archive.create(text: '메모', category: 'b');
      final s = archive.stats();
      expect(s.total, 3);
      expect(s.photos, 1);
      expect(s.videos, 1);
      expect(s.memos, 1);
    });
  });

  group('Archive.graph', () {
    test('노드 수 = 포스트 수', () {
      for (var i = 0; i < 5; i++) {
        archive.create(text: 'p$i #공통', category: 'a');
      }
      final g = archive.graph(const PostQuery());
      expect(g.nodes.length, 5);
    });

    test('같은 태그 이웃 연결', () {
      archive.create(text: 'A #태그', category: 'a');
      archive.create(text: 'B #태그', category: 'a');
      archive.create(text: 'C #태그', category: 'a');
      final g = archive.graph(const PostQuery());
      // 태그 3개 → 시간순 이웃 2개 링크
      expect(g.links.length, 2);
    });

    test('같은 자료 → 같은 배치', () {
      for (var i = 0; i < 3; i++) {
        archive.create(text: 'p$i', category: 'a');
      }
      final g1 = archive.graph(const PostQuery());
      final g2 = archive.graph(const PostQuery());
      for (var i = 0; i < 3; i++) {
        expect(g1.nodes[i].x, g2.nodes[i].x);
        expect(g1.nodes[i].z, g2.nodes[i].z);
      }
    });
  });

  group('성능', () {
    test('2,000개에서 query 50 ms 이내', () {
      for (var i = 0; i < 2000; i++) {
        archive.create(text: '기록 $i #자료', category: 'c${i % 10}');
      }
      final sw = Stopwatch()..start();
      final result = archive.query(const PostQuery(), limit: 30);
      sw.stop();
      expect(result.length, 30);
      expect(sw.elapsedMilliseconds, lessThan(50), reason: '${sw.elapsedMilliseconds} ms');
    });
  });
}

class _FixedClock extends Clock {
  final DateTime _t;
  _FixedClock(this._t);
  @override
  DateTime now() => _t;
}
