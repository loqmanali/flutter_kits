import 'package:flutter/material.dart';

import '../../dialogs/ui_helper.dart';
import 'dob_picker_sheet.dart';

export 'dob_picker_sheet.dart';

/// Open a localized Date of Birth picker (supports 'ar' or 'en')
Future<DateTime?> showDobPicker(
  BuildContext context, {
  DateTime? initialDate,
  int firstYear = 1900,
  DateTime? lastDate,
  String locale = 'en',
}) {
  final now = DateTime.now();
  final DateTime safeInitial = initialDate ??
      DateTime(
        now.year - 18,
        6,
        15,
      );
  final DateTime maxDate = lastDate ?? now;

  return UIHelper.showBottomSheet<DateTime?>(
    context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Directionality(
      textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: DobPickerSheet(
        initialDate: safeInitial,
        firstYear: firstYear,
        lastDate: maxDate,
        locale: locale,
      ),
    ),
  );
}
