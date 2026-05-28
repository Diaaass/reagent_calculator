import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/models.dart';
import '../state/app_state.dart';
import '../widgets/screen_header.dart';
import '../widgets/soft_container.dart';

/// Справочник реагентов в стиле soft UI. Tap по реагенту подставляет
/// концентрацию в калькулятор (через onSelect). Long-press открывает
/// редактор. «+» в шапке создаёт новый реагент. Свайп влево — удаление.
class ReferenceScreen extends StatefulWidget {
  final AppState appState;
  final ValueChanged<Reagent> onSelect;

  const ReferenceScreen({
    super.key,
    required this.appState,
    required this.onSelect,
  });

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  String _query = '';

  List<Reagent> _filter(List<Reagent> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.category.toLowerCase().contains(q))
        .toList();
  }

  Future<bool> _confirmDelete(Reagent r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить реагент?'),
        content: Text('«${r.name}» будет удалён из справочника.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сбросить к стандартным?'),
        content: const Text(
          'Все ваши изменения справочника будут удалены и возвращён исходный список.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
    if (ok == true) widget.appState.resetReagents();
  }

  Future<void> _openEditor({Reagent? initial}) async {
    final categories = widget.appState.reagents
        .map((r) => r.category)
        .toSet()
        .toList()
      ..sort();
    final result = await showModalBottomSheet<Reagent>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) => _ReagentEditor(
        initial: initial,
        existingCategories: categories,
      ),
    );
    if (result == null) return;
    if (initial == null) {
      widget.appState.addReagent(result);
    } else {
      widget.appState.updateReagent(initial, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final all = widget.appState.reagents;
        final items = _filter(all);

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScreenHeader(
                title: 'Справочник',
                subtitle: 'Реагенты и концентрации',
                actions: [
                  IconButton(
                    tooltip: 'Сбросить к стандартным',
                    onPressed: _confirmReset,
                    icon: Icon(Icons.restart_alt,
                        color: theme.colorScheme.primary),
                  ),
                  IconButton(
                    tooltip: 'Добавить реагент',
                    onPressed: () => _openEditor(),
                    icon: Icon(Icons.add_rounded,
                        color: theme.colorScheme.primary),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Поиск реагента...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            all.isEmpty
                                ? 'Справочник пуст. Нажмите «+», чтобы добавить реагент'
                                : 'Ничего не найдено',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final r = items[i];
                          return Dismissible(
                            key: ObjectKey(r),
                            direction: DismissDirection.endToStart,
                            background: const _SwipeDeleteBackground(),
                            confirmDismiss: (_) => _confirmDelete(r),
                            onDismissed: (_) =>
                                widget.appState.deleteReagent(r),
                            child: _ReagentTile(
                              reagent: r,
                              onTap: () => widget.onSelect(r),
                              onLongPress: () => _openEditor(initial: r),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReagentTile extends StatelessWidget {
  final Reagent reagent;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ReagentTile({
    required this.reagent,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(20),
      child: SoftContainer(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        elevation: 8,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reagent.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reagent.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fmtNum(reagent.concentration),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'доля',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
    );
  }
}

/// Форма создания/редактирования реагента в нижнем шите.
class _ReagentEditor extends StatefulWidget {
  final Reagent? initial;
  final List<String> existingCategories;

  const _ReagentEditor({
    required this.initial,
    required this.existingCategories,
  });

  @override
  State<_ReagentEditor> createState() => _ReagentEditorState();
}

class _ReagentEditorState extends State<_ReagentEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _concentrationCtrl;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _categoryCtrl = TextEditingController(text: i?.category ?? '');
    _concentrationCtrl = TextEditingController(
      text: i == null ? '' : fmtNum(i.concentration),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _concentrationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final value = double.parse(_concentrationCtrl.text.replaceAll(',', '.'));
    Navigator.pop(
      context,
      Reagent(
        name: _nameCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        concentration: value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.initial != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEdit ? 'Изменить реагент' : 'Новый реагент',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Название'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Введите название'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Класс'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Введите класс'
                      : null,
                ),
                if (widget.existingCategories.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.existingCategories
                        .map(
                          (c) => ActionChip(
                            label: Text(c),
                            onPressed: () => _categoryCtrl.text = c,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _concentrationCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Концентрация (0.3 = 30%)',
                    suffixText: 'доля',
                  ),
                  validator: (v) {
                    final raw = (v ?? '').replaceAll(',', '.');
                    final n = double.tryParse(raw);
                    if (n == null) return 'Введите число';
                    if (n <= 0) return 'Должно быть больше нуля';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Сохранить',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
