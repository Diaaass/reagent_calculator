import 'package:flutter/material.dart';
import '../domain/models.dart';
import '../state/app_state.dart';
import '../widgets/screen_header.dart';
import '../widgets/soft_container.dart';

/// История расчётов в стиле soft UI, сгруппированная по дате.
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
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final history = appState.history;
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScreenHeader(
                title: 'История',
                subtitle: 'Сохранённые расчёты',
                actions: [
                  IconButton(
                    tooltip: 'Очистить историю',
                    onPressed:
                        history.isEmpty ? null : () => _confirmClear(context),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: history.isEmpty
                          ? theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4)
                          : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: history.isEmpty
                    ? const _EmptyHistory()
                    : _HistoryList(history: history, appState: appState),
              ),
            ],
          ),
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
    final widgets = <Widget>[];
    String? currentLabel;

    for (final e in history) {
      final label = dateLabel(e.time);
      if (label != currentLabel) {
        currentLabel = label;
        widgets.add(_GroupHeader(label: label));
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: ObjectKey(e),
            direction: DismissDirection.endToStart,
            background: const _SwipeDeleteBackground(),
            confirmDismiss: (_) => _confirmDelete(context),
            onDismissed: (_) => appState.removeHistoryEntry(e),
            child: _HistoryCard(entry: e),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
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

class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w600,
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
    return SoftContainer(
      padding: const EdgeInsets.all(18),
      elevation: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reagentName != null) ...[
                      Text(
                        reagentName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      fmtTime(entry.time),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _FlowBadge(flow: entry.flowMlPerMin),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LabelValue(
                  label: 'Граммовка',
                  value: '${fmtNum(entry.dosage)} г/т',
                ),
              ),
              Expanded(
                child: _LabelValue(
                  label: 'Концентр.',
                  value: '${fmtNum(entry.concentration)} дол.',
                ),
              ),
              Expanded(
                child: _LabelValue(
                  label: 'Перераб.',
                  value: '${fmtNum(entry.throughput)} т/ч',
                ),
              ),
            ],
          ),
        ],
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
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _FlowBadge extends StatelessWidget {
  final double flow;
  const _FlowBadge({required this.flow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F6BF6), Color(0xFF2E48D8)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            fmtNum(flow),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'мл/мин',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
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
          Icon(
            Icons.history_rounded,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Пока нет расчётов',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Сохраните расчёт на вкладке «Калькулятор»',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
