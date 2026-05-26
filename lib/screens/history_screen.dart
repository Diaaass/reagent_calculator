import 'package:flutter/material.dart';
import '../domain/models.dart';
import '../state/app_state.dart';

/// История расчётов, сгруппированная по дате (Сегодня / Вчера / дата).
class HistoryScreen extends StatelessWidget {
  final AppState appState;

  const HistoryScreen({super.key, required this.appState});

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить историю?'),
        content: const Text('Все сохранённые расчёты будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              appState.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final history = appState.history;
        return Scaffold(
          appBar: AppBar(
            title: const Text('История'),
            actions: [
              IconButton(
                tooltip: 'Очистить историю',
                onPressed: history.isEmpty ? null : () => _confirmClear(context),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: history.isEmpty
              ? const _EmptyHistory()
              : _HistoryList(history: history, appState: appState),
        );
      },
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<HistoryEntry> history;
  final AppState appState;

  const _HistoryList({required this.history, required this.appState});

  Future<bool> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить запись?'),
        content: const Text('Эта запись истории будет удалена.'),
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

  @override
  Widget build(BuildContext context) {
    // Собираем плоский список: заголовок группы, затем dismissible-карточки.
    final widgets = <Widget>[];
    String? currentLabel;

    for (final e in history) {
      final label = dateLabel(e.time);
      if (label != currentLabel) {
        currentLabel = label;
        widgets.add(_GroupHeader(label: label));
      }
      widgets.add(
        Dismissible(
          key: ObjectKey(e),
          direction: DismissDirection.endToStart,
          background: const _SwipeDeleteBackground(),
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) => appState.removeHistoryEntry(e),
          child: _HistoryCard(entry: e),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: widgets,
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      // У карточки margin bottom 8 — повторяем, чтобы фон не наезжал на соседа.
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.outline,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reagentName = entry.reagentName;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reagentName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.science_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reagentName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LabelValue(label: 'ВРЕМЯ', value: fmtTime(entry.time)),
                _FlowChip(flow: entry.flowMlPerMin),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _LabelValue(
                    label: 'ГРАММОВКА',
                    value: '${fmtNum(entry.dosage)} г/т',
                  ),
                ),
                Expanded(
                  child: _LabelValue(
                    label: 'КОНЦЕНТР.',
                    value: '${fmtNum(entry.concentration)} дол.',
                  ),
                ),
                Expanded(
                  child: _LabelValue(
                    label: 'ПЕРЕРАБ.',
                    value: '${fmtNum(entry.throughput)} т/ч',
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

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _FlowChip extends StatelessWidget {
  final double flow;
  const _FlowChip({required this.flow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'ВЫЛИВ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            '${fmtNum(flow)} мл/мин',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'Пока нет расчётов',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Сохраните расчёт на вкладке «Калькулятор»',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
