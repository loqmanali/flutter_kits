import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../buttons/adaptive_button/adaptive_button.dart';
import 'dob_picker_header.dart';
import 'dob_picker_scroll_column.dart';

class DobPickerSheet extends StatefulWidget {
  const DobPickerSheet({
    required this.initialDate,
    required this.firstYear,
    required this.lastDate,
    required this.locale,
    super.key,
  });

  final DateTime initialDate;
  final int firstYear;
  final DateTime lastDate;
  final String locale;

  @override
  State<DobPickerSheet> createState() => _DobPickerSheetState();
}

class _DobPickerSheetState extends State<DobPickerSheet> {
  late int _year;
  late int _month;
  late int _day;

  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  static const List<String> _monthsEn = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const List<String> _monthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  List<String> get _months => widget.locale == 'ar' ? _monthsAr : _monthsEn;

  String get _title =>
      widget.locale == 'ar' ? 'تاريخ الميلاد' : 'Date of birth';

  String get _confirm => widget.locale == 'ar' ? 'تأكيد' : 'Confirm';

  int get _firstYear => widget.firstYear;
  int get _lastYear => widget.lastDate.year;

  int _daysInMonth(int year, int month) {
    final DateTime nextMonth =
        month == 12 ? DateTime(year + 1) : DateTime(year, month + 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  @override
  void initState() {
    super.initState();
    final DateTime init = widget.initialDate;

    _year = init.year.clamp(_firstYear, _lastYear);
    _month = init.month;
    _day = init.day.clamp(1, _daysInMonth(_year, _month));

    _yearController =
        FixedExtentScrollController(initialItem: _year - _firstYear);
    _monthController = FixedExtentScrollController(initialItem: _month - 1);
    _dayController = FixedExtentScrollController(initialItem: _day - 1);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double itemExtent = 36;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DobPickerHeader(
          title: _title,
          onClose: () => Navigator.of(context).pop(),
        ),
        SizedBox(
          height: 180,
          child: Row(
            children: [
              DobPickerScrollColumn(
                controller: _dayController,
                itemExtent: itemExtent,
                childCount: _daysInMonth(_year, _month),
                onSelectedItemChanged: (int index) {
                  HapticFeedback.selectionClick();
                  setState(() => _day = index + 1);
                },
                itemBuilder: (_, int index) {
                  final bool selected = (index + 1) == _day;
                  return Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: selected ? 20 : 16,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
              DobPickerScrollColumn(
                flex: 2,
                controller: _monthController,
                itemExtent: itemExtent,
                childCount: 12,
                onSelectedItemChanged: (int index) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _month = index + 1;
                    _syncDayAfterMonthOrYearChange();
                  });
                },
                itemBuilder: (_, int index) {
                  final bool selected = (index + 1) == _month;
                  return Center(
                    child: Text(
                      _months[index],
                      style: TextStyle(
                        fontSize: selected ? 20 : 16,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
              DobPickerScrollColumn(
                controller: _yearController,
                itemExtent: itemExtent,
                childCount: _lastYear - _firstYear + 1,
                onSelectedItemChanged: (int index) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _year = _firstYear + index;
                    _syncDayAfterMonthOrYearChange();
                  });
                },
                itemBuilder: (_, int index) {
                  final int year = _firstYear + index;
                  final bool selected = year == _year;
                  return Center(
                    child: Text(
                      '$year',
                      style: TextStyle(
                        fontSize: selected ? 20 : 16,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: AppButton(
            onPressed: () {
              Navigator.of(context).pop(DateTime(_year, _month, _day));
            },
            label: _confirm,
            size: AdaptiveButtonSize.large,
          ),
        ),
      ],
    );
  }

  void _syncDayAfterMonthOrYearChange() {
    final int maxDay = _daysInMonth(_year, _month);
    if (_day > maxDay) {
      setState(() {
        _day = maxDay;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _dayController.animateToItem(
          maxDay - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }
}
