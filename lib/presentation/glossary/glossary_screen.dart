import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/theme_extensions.dart';
import '../../application/cache/cache_providers.dart';
import '../../application/db_provider.dart';
import '../../application/project/project_session.dart';
import '../../domain/glossary/glossary_term.dart';
import '../common/lf_button.dart';
import '../common/lf_text_field.dart';

/// S12 — glossary management. DESIGN.md 11.4 · EXPERIENCE.md S12.
class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _search = TextEditingController();
  List<GlossaryTerm> _terms = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) unawaited(_reload());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_reload()));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final store = ref.read(glossaryStoreProvider);
    if (store == null) {
      setState(() {
        _terms = const [];
        _loading = false;
      });
      return;
    }
    store.attachProject(ref.read(appDatabaseProvider));
    setState(() => _loading = true);
    final search = _search.text;
    final terms = _tabs.index == 0
        ? await store.listGlobal(search: search)
        : await store.listProject(search: search);
    if (!mounted) return;
    setState(() {
      _terms = terms;
      _loading = false;
    });
  }

  Future<void> _addOrEdit([GlossaryTerm? existing]) async {
    final store = ref.read(glossaryStoreProvider);
    if (store == null) return;
    final isGlobal = _tabs.index == 0;
    if (!isGlobal && !ref.read(projectSessionProvider).isOpen) return;

    final result = await showDialog<GlossaryTerm>(
      context: context,
      builder: (ctx) => _GlossaryEditDialog(initial: existing),
    );
    if (result == null) return;

    if (isGlobal) {
      await store.upsertGlobal(result);
    } else {
      await store.upsertProject(result);
    }
    await _reload();
  }

  Future<void> _delete(GlossaryTerm term) async {
    final store = ref.read(glossaryStoreProvider);
    if (store == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('용어 삭제'),
        content: Text('"${term.sourceTerm}" 항목을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (_tabs.index == 0) {
      await store.deleteGlobal(term.id);
    } else {
      await store.deleteProject(term.id);
    }
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;
    final projectOpen = ref.watch(projectSessionProvider).isOpen;
    final canEditProjectTab = _tabs.index == 0 || projectOpen;

    return Scaffold(
      backgroundColor: colors.bgBase,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(context.d.topBar),
        child: Material(
          color: colors.bgBar,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.space7),
              child: Row(
                children: [
                  Text('용어집', style: context.t.title),
                  const Spacer(),
                  LfButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    label: '닫기',
                    style: LfButtonStyle.tertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            labelColor: colors.accent,
            unselectedLabelColor: colors.textMuted,
            indicatorColor: colors.accent,
            tabs: [
              const Tab(text: '전역'),
              Tab(
                child: Opacity(
                  opacity: projectOpen ? 1 : 0.4,
                  child: const Text('프로젝트'),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(spacing.space7),
            child: LfTextField(
              controller: _search,
              placeholder: '검색…',
              onChanged: (_) => unawaited(_reload()),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _terms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '등록된 용어가 없습니다',
                          style: context.t.body.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                        SizedBox(height: spacing.space5),
                        LfButton(
                          onPressed: canEditProjectTab
                              ? () => unawaited(_addOrEdit())
                              : null,
                          label: '추가',
                          style: LfButtonStyle.primary,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _terms.length,
                    itemExtent: context.d.treeRowFile * 2,
                    itemBuilder: (context, index) {
                      final term = _terms[index];
                      return ListTile(
                        title: Text(
                          term.sourceTerm,
                          style: context.t.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${term.targetTerm} · ${term.namespace ?? '(전체)'} · '
                          '${term.caseSensitive ? '대소문자 구분' : '구분 안 함'}',
                          style: context.t.caption.copyWith(
                            color: colors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => unawaited(_addOrEdit(term)),
                        trailing: IconButton(
                          tooltip: '삭제',
                          icon: Icon(
                            LucideIcons.trash2,
                            size: context.d.iconMd,
                          ),
                          onPressed: () => unawaited(_delete(term)),
                        ),
                      );
                    },
                  ),
          ),
          if (_terms.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(spacing.space7),
              child: Align(
                alignment: Alignment.centerLeft,
                child: LfButton(
                  onPressed: canEditProjectTab
                      ? () => unawaited(_addOrEdit())
                      : null,
                  label: '추가',
                  style: LfButtonStyle.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlossaryEditDialog extends StatefulWidget {
  const _GlossaryEditDialog({this.initial});

  final GlossaryTerm? initial;

  @override
  State<_GlossaryEditDialog> createState() => _GlossaryEditDialogState();
}

class _GlossaryEditDialogState extends State<_GlossaryEditDialog> {
  late final TextEditingController _source;
  late final TextEditingController _target;
  late final TextEditingController _namespace;
  late final TextEditingController _note;
  bool _caseSensitive = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _source = TextEditingController(text: initial?.sourceTerm ?? '');
    _target = TextEditingController(text: initial?.targetTerm ?? '');
    _namespace = TextEditingController(text: initial?.namespace ?? '');
    _note = TextEditingController(text: initial?.note ?? '');
    _caseSensitive = initial?.caseSensitive ?? false;
  }

  @override
  void dispose() {
    _source.dispose();
    _target.dispose();
    _namespace.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.s;
    return AlertDialog(
      title: Text(widget.initial == null ? '용어 추가' : '용어 수정'),
      content: SizedBox(
        width: context.d.modalMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LfTextField(controller: _source, placeholder: '원문 용어'),
            SizedBox(height: spacing.space5),
            LfTextField(controller: _target, placeholder: '번역 용어'),
            SizedBox(height: spacing.space5),
            LfTextField(controller: _namespace, placeholder: '스코프 (비우면 전체)'),
            SizedBox(height: spacing.space5),
            LfTextField(controller: _note, placeholder: '메모 (선택)'),
            SizedBox(height: spacing.space5),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('대소문자 구분', style: context.t.body),
              value: _caseSensitive,
              onChanged: (v) => setState(() => _caseSensitive = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            final source = _source.text.trim();
            final target = _target.text.trim();
            if (source.isEmpty || target.isEmpty) return;
            final ns = _namespace.text.trim();
            Navigator.pop(
              context,
              GlossaryTerm(
                id: widget.initial?.id ?? '',
                sourceTerm: source,
                targetTerm: target,
                sourceLang: widget.initial?.sourceLang ?? 'en_us',
                targetLang: widget.initial?.targetLang ?? 'ko_kr',
                namespace: ns.isEmpty ? null : ns,
                caseSensitive: _caseSensitive,
                note: _note.text.trim().isEmpty ? null : _note.text.trim(),
              ),
            );
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
