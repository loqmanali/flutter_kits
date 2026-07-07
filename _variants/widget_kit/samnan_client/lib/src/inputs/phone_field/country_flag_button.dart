import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../app_text_form_field.dart';
import 'countries.dart';

export 'countries.dart';

enum IconPosition {
  leading,
  trailing,
}

enum DialogType {
  showDialog,
  showModalBottomSheet,
}

class CountryFlagButton extends StatelessWidget {
  const CountryFlagButton({
    super.key,
    required this.selectedCountry,
    required this.enabled,
    required this.showCountryDialog,
    required this.showCountryFlag,
    required this.showDropdownIcon,
    required this.dropdownIconPosition,
    required this.dropdownIcon,
    required this.dropdownTextStyle,
    required this.dialogType,
    required this.onTap,
  });

  final Country selectedCountry;
  final bool enabled;
  final bool showCountryDialog;
  final bool showCountryFlag;
  final bool showDropdownIcon;
  final IconPosition dropdownIconPosition;
  final Widget dropdownIcon;
  final TextStyle? dropdownTextStyle;
  final DialogType dialogType;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppTextFormField(
      readOnly: true,
      backgroundColor: scheme.surfaceContainerHighest,
      focusedBorderColor: scheme.outline,
      onTap: enabled && showCountryDialog ? onTap : null,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: showDropdownIcon
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: <Widget>[
            if (enabled &&
                showDropdownIcon &&
                dropdownIconPosition == IconPosition.leading) ...[
              dropdownIcon,
              const SizedBox(width: 2),
            ],
            if (showCountryFlag) ...[
              kIsWeb
                  ? Image.asset(
                      'assets/flags/${selectedCountry.code.toLowerCase()}.png',
                      package: 'flutter_intl_phone_field',
                      width: 24,
                    )
                  : Text(
                      selectedCountry.flag,
                      style: const TextStyle(fontSize: 16),
                    ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '+${selectedCountry.dialCode}',
                  style: dropdownTextStyle ?? const TextStyle(),
                ),
              ),
            ),
            if (enabled &&
                showDropdownIcon &&
                dropdownIconPosition == IconPosition.trailing) ...[
              const SizedBox(width: 2),
              dropdownIcon,
            ],
          ],
        ),
      ),
    );
  }
}
