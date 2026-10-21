/// A-Z 앱 — 사진·영상·메모를 A부터 Z까지
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'archive.dart';
import 'theme.dart';
import 'ui/feed.dart';

/// 대상 지역 (ISO 3166-1 `KR`)
abstract final class AzRegion {
  static const countryCode = 'KR';
  static const locale = Locale('ko', 'KR');
}

void main() {
  runApp(const AzApp());
}

class AzApp extends StatelessWidget {
  const AzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A-Z',
      locale: AzRegion.locale,
      supportedLocales: const [AzRegion.locale],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: azTheme(),
      home: const HomeShell(),
    );
  }
}

/// 앱 상태 — 열린 보관함, 필터, 선택
class AppState extends ChangeNotifier {
  final Archive archive;
  PostQuery query;
  String? selectedId;

  AppState({required this.archive}) : query = const PostQuery();

  void setQuery(PostQuery q) {
    query = q;
    notifyListeners();
  }

  void toggleCategory(String category) {
    final hidden = Set<String>.from(query.hiddenCategories);
    if (hidden.contains(category)) {
      hidden.remove(category);
    } else {
      hidden.add(category);
    }
    setQuery(query.copyWith(hiddenCategories: hidden));
  }

  void setMediaType(MediaTypeFilter type) {
    setQuery(query.copyWith(mediaType: type));
  }

  void setSearch(String text) {
    setQuery(query.copyWith(searchText: text));
  }

  void toggleStarredOnly() {
    setQuery(query.copyWith(starredOnly: !query.starredOnly));
  }

  void select(String? id) {
    selectedId = id;
    notifyListeners();
  }
}

/// 홈 셸 — 반응형 배치
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final Archive _archive;
  late final AppState _state;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _archive = Archive();
    _state = AppState(archive: _archive);
    _seedSampleData();
  }

  void _seedSampleData() {
    _archive.create(
      text: '3D 지식 그래프 레퍼런스\n카테고리별 구체와 궤도 링을 가진 화면을 분석했다 #레퍼런스 #3D',
      category: 'science',
    );
    _archive.create(
      text: '궤도 링 색감 연구\n레퍼런스에서 뽑은 색으로 링 네 개를 그려 봤다 #색감 #디자인',
      category: 'design',
    );
    _archive.create(
      text: '제주도 사진 정리\n바다와 산 사진을 모았다 #여행 #제주',
      category: 'travel',
    );
    _archive.create(
      text: 'A-Z 시작하기\n이 앱은 사진·영상·메모를 한 곳에 모읍니다 #안내',
      category: '미분류',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) {
        final width = MediaQuery.of(context).size.width;
        final isDesktop = width >= 1200;
        final isTablet = width >= 800 && width < 1200;

        return Scaffold(
          body: Column(
            children: [
              _TopBar(state: _state),
              Expanded(
                child: Row(
                  children: [
                    if (isDesktop || isTablet) _LegendPanel(state: _state),
                    Expanded(child: FeedView(state: _state)),
                    if (isDesktop) _NavigatorPanel(state: _state),
                  ],
                ),
              ),
              _ControlBar(
                state: _state,
                navIndex: _navIndex,
                onNav: (i) => setState(() => _navIndex = i),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── 상단 바

class _TopBar extends StatelessWidget {
  final AppState state;
  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final stats = state.archive.stats();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 검색
          SizedBox(
            width: 220,
            height: 40,
            child: TextField(
              onChanged: state.setSearch,
              decoration: InputDecoration(
                hintText: '검색...',
                hintStyle: const TextStyle(color: AzColors.muted),
                prefixIcon: const Icon(Icons.search, color: AzColors.muted, size: 20),
                filled: true,
                fillColor: AzColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AzColors.line),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const Spacer(),
          // A - Z
          const Text('A', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AzColors.inkStrong)),
          const Text(' - ', style: TextStyle(fontSize: 32, color: AzColors.muted)),
          const Text('Z', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AzColors.primary)),
          const Spacer(),
          // 상태 알약
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AzColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AzColors.line),
            ),
            child: Text(
              '${stats.total} | ${stats.photos} | ${stats.videos}',
              style: const TextStyle(color: AzColors.inkSub, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 범례 패널

class _LegendPanel extends StatelessWidget {
  final AppState state;
  const _LegendPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final categories = <String, int>{};
    for (final p in state.archive.query(const PostQuery(), limit: 9999)) {
      categories[p.category] = (categories[p.category] ?? 0) + 1;
    }

    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CATEGORIES', style: TextStyle(color: AzColors.inkSub, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...categories.entries.map((e) {
            final idx = e.key.hashCode.abs() % AzColors.categories.length;
            final hidden = state.query.hiddenCategories.contains(e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: InkWell(
                onTap: () => state.toggleCategory(e.key),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AzColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hidden ? AzColors.line : AzColors.categoryColor(idx).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: hidden ? AzColors.muted : AzColors.categoryColor(idx),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.key,
                          style: TextStyle(
                            color: hidden ? AzColors.muted : AzColors.ink,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '${e.value}',
                        style: const TextStyle(color: AzColors.inkSub, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text('TYPE', style: TextStyle(color: AzColors.inkSub, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: MediaTypeFilter.values.map((t) {
              final selected = state.query.mediaType == t;
              return FilterChip(
                label: Text(
                  switch (t) {
                    MediaTypeFilter.all => '전체',
                    MediaTypeFilter.photo => '사진',
                    MediaTypeFilter.video => '영상',
                    MediaTypeFilter.memo => '메모',
                  },
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : AzColors.ink,
                  ),
                ),
                selected: selected,
                onSelected: (_) => state.setMediaType(t),
                selectedColor: AzColors.primary,
                backgroundColor: AzColors.surface,
                side: const BorderSide(color: AzColors.line),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          FilterChip(
            label: const Text('★ 즐겨찾기만', style: TextStyle(fontSize: 12)),
            selected: state.query.starredOnly,
            onSelected: (_) => state.toggleStarredOnly(),
            selectedColor: AzColors.primary,
            backgroundColor: AzColors.surface,
            side: const BorderSide(color: AzColors.line),
            showCheckmark: false,
          ),
        ],
      ),
    );
  }
}

// ── 내비게이터 패널

class _NavigatorPanel extends StatelessWidget {
  final AppState state;
  const _NavigatorPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.selectedId == null) return const SizedBox(width: 300);
    Post? post;
    try {
      post = state.archive.byId(state.selectedId!);
    } catch (_) {
      return const SizedBox(width: 300);
    }

    final idx = post.category.hashCode.abs() % AzColors.categories.length;
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('NAVIGATOR', style: TextStyle(color: AzColors.inkSub, fontSize: 11, fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AzColors.inkSub),
                onPressed: () => state.select(null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AzColors.categoryColor(idx),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(post.category, style: const TextStyle(color: AzColors.ink, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.title, style: const TextStyle(color: AzColors.inkStrong, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (post.media.isNotEmpty) ...[
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: AzColors.edge,
                borderRadius: BorderRadius.circular(AzShapes.radiusThumb),
              ),
              child: const Center(child: Icon(Icons.play_circle_outline, size: 40, color: AzColors.muted)),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            post.text.length > 150 ? '${post.text.substring(0, 150)}...' : post.text,
            style: const TextStyle(color: AzColors.inkSub, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('파일 열기', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AzColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => state.select(null),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AzColors.line),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('닫기', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 컨트롤 막대

class _ControlBar extends StatelessWidget {
  final AppState state;
  final int navIndex;
  final ValueChanged<int> onNav;

  const _ControlBar({required this.state, required this.navIndex, required this.onNav});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 마스코트
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AzColors.primary, width: 2),
            ),
          ),
          const SizedBox(width: 24),
          // 뷰 전환
          _NavButton(label: 'FEED', active: navIndex == 0, onTap: () => onNav(0)),
          const SizedBox(width: 8),
          _NavButton(label: 'orbit', active: navIndex == 1, onTap: () => onNav(1)),
          const SizedBox(width: 24),
          // 이전·다음
          TextButton(onPressed: () {}, child: const Text('< prev', style: TextStyle(color: AzColors.inkSub))),
          TextButton(onPressed: () {}, child: const Text('next >', style: TextStyle(color: AzColors.inkSub))),
          const SizedBox(width: 24),
          // 가져오기
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file, size: 16, color: AzColors.ink),
            label: const Text('IMPORT', style: TextStyle(color: AzColors.ink, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AzColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AzColors.inkSub,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
