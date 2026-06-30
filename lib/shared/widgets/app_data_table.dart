import 'package:flutter/material.dart';

class AppDataTable<T> extends StatefulWidget {
  final List<DataColumn> columns;
  final List<T> rows;
  final DataRow Function(T item) rowBuilder;
  final Function(T item)? onRowTap;
  final bool showRowCount;
  final String? searchHint;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowBuilder,
    this.onRowTap,
    this.showRowCount = true,
    this.searchHint,
  });

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 16),
              Text('No data available', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showRowCount)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Text(
              '${widget.rows.length} records found',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.01),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: theme.copyWith(
                dividerColor: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columns: widget.columns,
                    rows: widget.rows.map((item) => widget.rowBuilder(item)).toList(),
                    showCheckboxColumn: false,
                    headingRowHeight: 48,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 56,
                    columnSpacing: 24,
                    horizontalMargin: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
