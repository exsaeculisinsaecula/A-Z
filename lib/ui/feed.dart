/// 피드 뷰 — 카드 목록 + 작성칸
library;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../archive.dart';
import '../main.dart';
import '../theme.dart';

class FeedView extends StatelessWidget {
  final AppState state;
  const FeedView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final posts = state.archive.query(state.query, limit: 50);
    return Column(
      children: [
        // 작성칸
        _Composer(state: state),
        // 카드 목록
        Expanded(
          child: posts.isEmpty
              ? const _EmptyHint()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: posts.length,
                  itemBuilder: (context, i) => PostCard(
                    post: posts[i],
                    state: state,
                  ),
                ),
        ),
      ],
    );
  }
}

// ── 작성칸

class _Composer extends StatefulWidget {
  final AppState state;
  const _Composer({required this.state});

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _ctrl = TextEditingController();
  String _category = '미분류';
  final List<String> _attachedFiles = [];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    setState(() {
      _attachedFiles.addAll(files.map((f) => f.path));
    });
  }

  void _removeAttachment(int index) {
    setState(() => _attachedFiles.removeAt(index));
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty && _attachedFiles.isEmpty) return;
    // 첨부 파일을 MediaRef로 변환
    final media = _attachedFiles.map((path) {
      final name = path.split('\\').last.split('/').last;
      final ext = name.split('.').last.toLowerCase();
      final isVideo = ['mp4', 'mov', 'webm', 'mkv', 'avi'].contains(ext);
      return MediaRef(path: name, kind: isVideo ? MediaKind.video : MediaKind.photo);
    }).toList();
    widget.state.archive.create(
      text: text.isEmpty ? '(첨부 파일)' : text,
      category: _category,
      media: media,
    );
    _ctrl.clear();
    setState(() => _attachedFiles.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AzColors.surface,
        borderRadius: BorderRadius.circular(AzShapes.radiusCard),
        border: Border.all(color: AzColors.line),
      ),
      child: Column(
        children: [
          // 첨부 파일 미리보기
          if (_attachedFiles.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(_attachedFiles.length, (i) {
                final name = _attachedFiles[i].split('\\').last.split('/').last;
                return Chip(
                  label: Text(name, style: const TextStyle(fontSize: 11)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => _removeAttachment(i),
                  backgroundColor: AzColors.space2,
                );
              }),
            ),
          ],
          Row(
            children: [
              // 파일 첨부 버튼
              IconButton(
                onPressed: _pickFiles,
                icon: const Icon(Icons.attach_file, color: AzColors.inkSub, size: 20),
                tooltip: '사진·영상 첨부',
              ),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  maxLines: 3,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: '무슨 생각을 하고 계신가요?  #태그도 쓸 수 있어요',
                    hintStyle: TextStyle(color: AzColors.muted),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 8),
              // 카테고리 선택
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AzColors.space2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _category,
                  isDense: true,
                  underline: const SizedBox(),
                  items: ['미분류', 'science', 'design', 'travel']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? '미분류'),
                ),
              ),
              const SizedBox(width: 8),
              // 게시 버튼
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AzColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('게시', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 포스트 카드

class PostCard extends StatelessWidget {
  final Post post;
  final AppState state;

  const PostCard({super.key, required this.post, required this.state});

  @override
  Widget build(BuildContext context) {
    final idx = post.category.hashCode.abs() % AzColors.categories.length;
    final selected = state.selectedId == post.id;

    return GestureDetector(
      onTap: () => state.select(post.id),
      child: AnimatedContainer(
        duration: AzMotion.fast,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AzColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AzColors.categoryColor(idx) : AzColors.line,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AzColors.categoryColor(idx).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: selected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 머리줄
            Row(
              children: [
                // 카테고리 링 아바타
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AzColors.categoryColor(idx), width: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.category,
                        style: const TextStyle(
                          color: AzColors.inkStrong,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _relativeTime(post.createdAt),
                        style: const TextStyle(color: AzColors.inkSub, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // 별표
                IconButton(
                  icon: Icon(
                    post.starred ? Icons.star : Icons.star_border,
                    color: post.starred ? AzColors.categories[2] : AzColors.muted,
                    size: 20,
                  ),
                  onPressed: () => state.archive.toggleStar(post.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 본문
            Text(
              post.text,
              style: const TextStyle(color: AzColors.ink, fontSize: 14, height: 1.5),
            ),
            // 미디어 그리드
            if (post.media.isNotEmpty) ...[
              const SizedBox(height: 12),
              _MediaGrid(media: post.media),
            ],
            // 태그
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: post.tags.map((t) {
                  return GestureDetector(
                    onTap: () => state.setSearch('#$t'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AzColors.space2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$t',
                        style: TextStyle(
                          color: AzColors.categoryTextColor(idx),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.year}.${dt.month}.${dt.day}';
  }
}

// ── 미디어 그리드

class _MediaGrid extends StatelessWidget {
  final List<MediaRef> media;
  const _MediaGrid({required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();
    if (media.length == 1) {
      return _MediaBox(media: media[0], height: 200);
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 2,
      children: media.take(4).map((m) => _MediaBox(media: m, height: 100)).toList(),
    );
  }
}

class _MediaBox extends StatelessWidget {
  final MediaRef media;
  final double height;
  const _MediaBox({required this.media, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AzColors.edge,
        borderRadius: BorderRadius.circular(AzShapes.radiusThumb),
      ),
      child: Center(
        child: Icon(
          media.kind == MediaKind.video ? Icons.play_circle_outline : Icons.image_outlined,
          color: AzColors.muted,
          size: 32,
        ),
      ),
    );
  }
}

// ── 빈 화면

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AzColors.muted, width: 2),
            ),
            child: const Icon(Icons.edit_note, color: AzColors.muted, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 기록이 없어요',
            style: TextStyle(color: AzColors.inkSub, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            '위 작성칸에 글을 쓰거나 [+]를 눌러 보세요',
            style: TextStyle(color: AzColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
