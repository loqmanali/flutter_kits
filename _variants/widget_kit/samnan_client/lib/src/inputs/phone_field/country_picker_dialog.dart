import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../app_text_form_field.dart';
import 'countries.dart';
import 'helpers.dart';

class PickerDialogStyle {
  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? countryCodeStyle;
  final TextStyle? countryNameStyle;
  final Widget? listTileDivider;
  final EdgeInsets? listTilePadding;
  final EdgeInsets? dialogPadding;
  final EdgeInsets? padding;
  final Color? searchFieldCursorColor;
  final InputDecoration? searchFieldInputDecoration;
  final EdgeInsets? searchFieldPadding;
  final double? width;

  final Color? searchFillColor;
  final Color? dividerColor;
  final Color? iconColor;

  const PickerDialogStyle({
    this.backgroundColor,
    this.titleTextStyle,
    this.countryCodeStyle,
    this.countryNameStyle,
    this.listTileDivider,
    this.listTilePadding,
    this.dialogPadding,
    this.padding,
    this.searchFieldCursorColor,
    this.searchFieldInputDecoration,
    this.searchFieldPadding,
    this.width,
    this.searchFillColor,
    this.dividerColor,
    this.iconColor,
  });
}

class CountryPickerDialog extends StatefulWidget {
  final List<Country> countryList;
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final String searchText;
  final List<Country> filteredCountries;
  final PickerDialogStyle? style;
  final String languageCode;

  final String? titleText;

  final EdgeInsets? dialogPadding;

  const CountryPickerDialog({
    super.key,
    required this.searchText,
    required this.languageCode,
    required this.countryList,
    required this.onCountryChanged,
    required this.selectedCountry,
    required this.filteredCountries,
    this.style,
    this.dialogPadding,
    this.titleText,
  });

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  late List<Country> _filteredCountries;
  late Country _selectedCountry;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    _selectedCountry = widget.selectedCountry;
    _filteredCountries = widget.filteredCountries.toList()
      ..sort(
        (a, b) => a
            .localizedName(widget.languageCode)
            .compareTo(b.localizedName(widget.languageCode)),
      );
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.sizeOf(context).width;
    final width = widget.style?.width ?? mediaWidth;
    const defaultHorizontalPadding = 24.0;
    const defaultVerticalPadding = 24.0;

    final bg = widget.style?.backgroundColor ?? Colors.white;
    final dividerColor =
        widget.style?.dividerColor ?? Colors.grey.withValues(alpha: 0.2);
    final iconColor = widget.style?.iconColor ?? Colors.black54;

    return Dialog(
      backgroundColor: bg,
      insetPadding:
          widget.style?.dialogPadding ??
          widget.dialogPadding ??
          EdgeInsets.symmetric(
            vertical: defaultVerticalPadding,
            horizontal: mediaWidth > (width + defaultHorizontalPadding * 2)
                ? (mediaWidth - width) / 2
                : defaultHorizontalPadding,
          ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding:
              widget.style?.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Header: Title + Close
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.titleText ?? 'Select your country',
                      style:
                          widget.style?.titleTextStyle ??
                          const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: iconColor),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Search field (AppTextFormField بدل TextField) مع احترام PickerDialogStyle
              Padding(
                padding:
                    widget.style?.searchFieldPadding ?? const EdgeInsets.all(0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: widget.style?.searchFieldCursorColor,
                    ),
                  ),
                  child: AppTextFormField(
                    controller: _searchCtrl,
                    hintText:
                        (widget.style?.searchFieldInputDecoration?.hintText ??
                                (widget.searchText.isEmpty
                                    ? 'Search here'
                                    : widget.searchText))
                            .toString(),
                    prefixIcon: Icon(CupertinoIcons.search, color: iconColor),
                    backgroundColor:
                        widget.style?.searchFillColor ?? Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    focusedBorderWidth: 1,
                    focusedBorderColor: Theme.of(context).colorScheme.outline,
                    textColor:
                        Theme.of(context).textTheme.bodySmall?.color ??
                        const Color(0xFF000000),
                    onChanged: (value) {
                      _filteredCountries =
                          widget.countryList.stringSearch(value)..sort(
                            (a, b) => a
                                .localizedName(widget.languageCode)
                                .compareTo(
                                  b.localizedName(widget.languageCode),
                                ),
                          );
                      if (mounted) setState(() {});
                    },
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // List
              Expanded(
                child: Scrollbar(
                  child: ListView.separated(
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, thickness: 1, color: dividerColor),
                    itemBuilder: (ctx, index) {
                      final country = _filteredCountries[index];
                      return ListTile(
                        visualDensity: const VisualDensity(vertical: -1),
                        contentPadding:
                            widget.style?.listTilePadding ??
                            const EdgeInsets.symmetric(),
                        leading: _buildFlag(country),
                        title: Text(
                          country.localizedName(widget.languageCode),
                          style:
                              widget.style?.countryNameStyle ??
                              const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        trailing: Text(
                          '+${country.dialCode}',
                          style:
                              widget.style?.countryCodeStyle ??
                              const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        onTap: () {
                          _selectedCountry = country;
                          widget.onCountryChanged(_selectedCountry);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlag(Country c) {
    if (kIsWeb) {
      return Image.asset(
        'assets/flags/${c.code.toLowerCase()}.png',
        package: 'flutter_intl_phone_field',
        width: 28,
        height: 20,
        fit: BoxFit.cover,
      );
    }
    return Text(c.flag, style: const TextStyle(fontSize: 20));
  }
}
