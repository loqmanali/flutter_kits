import 'package:flutter/material.dart';

/// One row of the API reference table.
class ApiParam {
  const ApiParam({
    required this.name,
    required this.type,
    this.defaultValue,
    this.required = false,
    this.note,
  });

  final String name;
  final String type;
  final String? defaultValue;
  final bool required;
  final String? note;
}

/// A compact table of constructor parameters, forui/shadcn-leaning.
///
/// Columns: name | type | default. Required rows carry a small badge.
class ApiTable extends StatelessWidget {
  const ApiTable({super.key, required this.params});

  final List<ApiParam> params;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
          2: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header.
          TableRow(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            ),
            children: [
              _cell('Name', header: true, padded: true),
              _cell('Type', header: true, padded: true),
              _cell('Default', header: true, padded: true),
            ],
          ),
          for (final p in params)
            TableRow(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          p.name,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (p.required) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'required',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    p.type,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Text(
                    p.defaultValue ?? '—',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      color: p.defaultValue == null
                          ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(String text, {bool header = false, bool padded = false}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: padded
              ? const EdgeInsets.fromLTRB(14, 10, 14, 10)
              : EdgeInsets.zero,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
