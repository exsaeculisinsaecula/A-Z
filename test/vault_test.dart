import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a_z/archive.dart';
import 'package:a_z/vault.dart';

void main() {
  late MemoryFileSystem fs;
  late AtomicWriter writer;

  setUp(() {
    fs = MemoryFileSystem();
    writer = AtomicWriter(fs);
  });

  // ── AtomicWriter
  group('AtomicWriter', () {
    test('writeString으로 파일을 만든다', () async {
      await writer.writeString('/a/b.txt', 'hello');
      expect(await fs.file('/a/b.txt').readAsString(), 'hello');
    });

    test('.tmp을 남기지 않는다', () async {
      await writer.writeString('/a/b.txt', 'x');
      final entries = await fs.directory('/a').list().toList();
      expect(entries.where((e) => e.path.endsWith('.tmp')), isEmpty);
    });

    test('copy', () async {
      await writer.writeString('/src.txt', 'data');
      await writer.copy('/src.txt', '/dest.txt');
      expect(await fs.file('/dest.txt').readAsString(), 'data');
    });

    test('cleanTmp은 .tmp만 지운다', () async {
      await fs.directory('/a').create(recursive: true);
      await fs.file('/a/keep.txt').writeAsString('keep');
      await fs.file('/a/old.tmp').writeAsString('tmp');
      await writer.cleanTmp('/a');
      expect(await fs.file('/a/keep.txt').exists(), true);
      expect(await fs.file('/a/old.tmp').exists(), false);
    });
  });

  // ── Vault.create / open
  group('Vault', () {
    test('create하면 폴더·표시 파일이 생긴다', () async {
      final vault = await Vault.create(fs.directory('/home'), '보관함',
          fs: fs, writer: writer);
      expect(await fs.file('/home/보관함/.az/vault.json').exists(), true);
      expect(await fs.directory('/home/보관함/미분류').exists(), true);
      expect(vault.root.path, contains('보관함'));
    });

    test('open: 보관함이 아니면 InvalidLocation', () async {
      await fs.directory('/notvault').create();
      expect(
        () => Vault.open(fs.directory('/notvault'), fs: fs, writer: writer),
        throwsA(isA<InvalidLocation>()),
      );
    });

    test('open: create한 보관함을 열 수 있다', () async {
      await Vault.create(fs.directory('/home'), 'v', fs: fs, writer: writer);
      final vault = await Vault.open(fs.directory('/home/v'),
          fs: fs, writer: writer);
      expect(vault.root.path, contains('v'));
    });

    test('상대 경로 ↔ 절대 경로', () async {
      final vault = await Vault.create(fs.directory('/'), 'v',
          fs: fs, writer: writer);
      final abs = vault.absPath('디자인/메모.md');
      expect(abs, contains('디자인'));
      expect(vault.relPath(abs), '디자인/메모.md');
    });
  });

  // ── 포스트 읽기·쓰기
  group('Vault 포스트', () {
    late Vault vault;

    setUp(() async {
      vault = await Vault.create(fs.directory('/'), 'v', fs: fs, writer: writer);
    });

    test('writePost → readPost 왕복', () async {
      final post = Post(
        id: 'p_test',
        text: '제목\n본문 #테스트',
        category: '디자인',
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 21),
        media: [const MediaRef(path: '디자인/첨부/a.jpg', kind: MediaKind.photo)],
      );
      await vault.writePost(post);

      final paths = await vault.listPostPaths().toList();
      expect(paths, isNotEmpty);

      final read = await vault.readPost(paths.first);
      expect(read.text, contains('제목'));
      expect(read.tags, ['테스트']);
    });

    test('listPostPaths는 .az를 제외한다', () async {
      await vault.writePost(Post(
        id: 'p_1',
        text: 'x',
        category: '미분류',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ));
      // .az 안에 가짜 .md
      await writer.writeString('/v/.az/fake.md', 'fake');
      final paths = await vault.listPostPaths().toList();
      expect(paths.any((p) => p.contains('.az/')), false);
    });

    test('없는 포스트 → NotFound', () async {
      expect(() => vault.readPost('없는파일.md'), throwsA(isA<NotFound>()));
    });
  });

  // ── 첨부
  group('Vault 첨부', () {
    late Vault vault;

    setUp(() async {
      vault = await Vault.create(fs.directory('/'), 'v', fs: fs, writer: writer);
    });

    test('copyAttachment로 사본을 만든다', () async {
      await fs.directory('/source').create(recursive: true);
      await fs.file('/source/photo.jpg').writeAsBytes([1, 2, 3]);
      final rel = await vault.copyAttachment('/source/photo.jpg', '디자인');
      expect(rel, '디자인/첨부/photo.jpg');
      expect(await vault.attachmentExists(rel), true);
    });

    test('이름 충돌 시 (2)를 붙인다', () async {
      await fs.directory('/b').create(recursive: true);
      await fs.file('/a.jpg').writeAsBytes([1]);
      await fs.file('/b/a.jpg').writeAsBytes([2]);
      await vault.copyAttachment('/a.jpg', '디자인');
      final second = await vault.copyAttachment('/b/a.jpg', '디자인');
      expect(second, '디자인/첨부/a (1).jpg');
    });

    test('원본은 남아 있다', () async {
      await fs.directory('/source').create(recursive: true);
      await fs.file('/source/x.png').writeAsBytes([9]);
      await vault.copyAttachment('/source/x.png', 'c');
      expect(await fs.file('/source/x.png').exists(), true);
    });
  });

  // ── 휴지통
  group('Vault 휴지통', () {
    late Vault vault;

    setUp(() async {
      vault = await Vault.create(fs.directory('/'), 'v', fs: fs, writer: writer);
    });

    test('trashPost로 옮기고 사라진다', () async {
      final post = Post(
        id: 'p_del',
        text: '지울 것',
        category: '미분류',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      await vault.writePost(post);
      final paths = await vault.listPostPaths().toList();
      await vault.trashPost(paths.first);

      expect(await vault.listPostPaths().toList(), isEmpty);
      // 휴지통에 있는지
      final trashDir = fs.directory('/v/.az/trash');
      final files = await trashDir.list(recursive: true).toList();
      expect(files.whereType<File>().length, 1);
    });
  });

  // ── 카테고리 이동
  group('Vault 카테고리 이동', () {
    late Vault vault;

    setUp(() async {
      vault = await Vault.create(fs.directory('/'), 'v', fs: fs, writer: writer);
    });

    test('포스트를 새 카테고리로 옮긴다', () async {
      final post = Post(
        id: 'p_move',
        text: '옮길 것',
        category: '디자인',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        relativePath: '디자인/메모.md',
      );
      await vault.writePost(post);
      await vault.moveToCategory(post, '과학');

      final paths = await vault.listPostPaths().toList();
      expect(paths.any((p) => p.startsWith('과학/')), true);
      expect(paths.any((p) => p.startsWith('디자인/')), false);
    });
  });

  // ── 이식성
  group('Vault 이식성', () {
    test('폴더를 복사해도 같은 내용', () async {
      final vault = await Vault.create(fs.directory('/a'), '원본',
          fs: fs, writer: writer);
      await vault.writePost(Post(
        id: 'p_move',
        text: '이식 테스트 #이식',
        category: '미분류',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ));

      // 폴더째 복사
      await fs.directory('/b/원본').create(recursive: true);
      await for (final e in fs.directory('/a/원본').list(recursive: true)) {
        if (e is File) {
          final rel = e.path.substring('/a/원본/'.length);
          final dest = '/b/원본/$rel';
          await fs.directory(dest.substring(0, dest.lastIndexOf('/'))).create(recursive: true);
          await e.copy(dest);
        }
      }

      final vault2 = await Vault.open(fs.directory('/b/원본'),
          fs: fs, writer: writer);
      final posts = await vault2.listPostPaths().toList();
      expect(posts, isNotEmpty);
      final p = await vault2.readPost(posts.first);
      expect(p.text, contains('이식 테스트'));
    });
  });

  // ── Trash 클래스
  group('Trash', () {
    test('list·restore·empty', () async {
      final trashDir = fs.directory('/trash');
      await trashDir.create(recursive: true);
      final trash = Trash(fs, trashDir);

      await fs.file('/trash/deleted.md').writeAsString('deleted');
      expect(await trash.list(), ['deleted.md']);

      await trash.restore('deleted.md', '/restored/file.md');
      expect(await fs.file('/restored/file.md').readAsString(), 'deleted');
      expect(await trash.list(), isEmpty);

      await fs.file('/trash/x.md').writeAsString('x');
      await trash.empty();
      expect(await trash.list(), isEmpty);
    });
  });
}
