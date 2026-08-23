part of '../intl_phone_field.dart';

// Behaviour: controller wiring, country selection, and the field itself.
class _IntlPhoneFieldState extends State<IntlPhoneField> {
  late List<Country> _countryList;
  late Country _selectedCountry;
  late List<Country> filteredCountries;
  late String number;

  String? validatorMessage;

  @override
  void initState() {
    super.initState();

    _countryList = widget.countries ?? countries;
    filteredCountries = _countryList;
    number = widget.initialValue ?? widget.controller?.text ?? '';
    if (widget.initialCountryCode == null && number.startsWith('+')) {
      number = number.substring(1);
      // parse initial value
      _selectedCountry = countries.firstWhere(
        (country) => number.startsWith(country.fullCountryCode),
        orElse: () => _countryList.first,
      );

      // remove country code from the initial number value
      number = number.replaceFirst(
        RegExp('^${_selectedCountry.fullCountryCode}'),
        '',
      );
    } else {
      _selectedCountry = _countryList.firstWhere(
        (item) => item.code == (widget.initialCountryCode ?? 'US'),
        orElse: () => _countryList.first,
      );

      // remove country code from the initial number value
      if (number.startsWith('+')) {
        number = number.replaceFirst(
          RegExp('^\\+${_selectedCountry.fullCountryCode}'),
          '',
        );
      } else {
        number = number.replaceFirst(
          RegExp('^${_selectedCountry.fullCountryCode}'),
          '',
        );
      }
    }
    Future.microtask(
      () {
        if (widget.controller?.text.isNotEmpty ?? false) {
          widget.controller?.text = number;
        }

        if (widget.autovalidateMode == AutovalidateMode.always) {
          final initialPhoneNumber = PhoneNumber(
            countryISOCode: _selectedCountry.code,
            countryCode: '+${_selectedCountry.dialCode}',
            number: widget.initialValue ?? '',
          );

          final value = widget.validator?.call(initialPhoneNumber);

          if (value is String) {
            validatorMessage = value;
          } else {
            (value as Future).then((msg) {
              validatorMessage = msg;
            });
          }
        }
      },
    );
  }

  Future<void> _changeCountryDialog() async {
    filteredCountries = _countryList;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => CountryPickerDialog(
          languageCode: widget.languageCode,
          style: widget.pickerDialogStyle,
          filteredCountries: filteredCountries,
          searchText: widget.searchText,
          countryList: _countryList,
          selectedCountry: _selectedCountry,
          onCountryChanged: (Country country) {
            _selectedCountry = country;
            widget.onCountryChanged?.call(country);
            setState(() {});
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _changeCountryModalBottomSheet() async {
    filteredCountries = _countryList;
    final height = context.windowHeight;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => SizedBox(
          height: height * 0.9,
          child: CountryPickerDialog(
            dialogPadding: EdgeInsets.zero,
            languageCode: widget.languageCode,
            style: widget.pickerDialogStyle,
            filteredCountries: filteredCountries,
            searchText: widget.searchText,
            countryList: _countryList,
            selectedCountry: _selectedCountry,
            onCountryChanged: (Country country) {
              _selectedCountry = country;
              widget.onCountryChanged?.call(country);
              setState(() {});
            },
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CountryFlagButton(
              selectedCountry: _selectedCountry,
              enabled: widget.enabled,
              showCountryDialog: widget.showCountryDialog,
              showCountryFlag: widget.showCountryFlag,
              showDropdownIcon: widget.showDropdownIcon,
              dropdownIconPosition: widget.dropdownIconPosition,
              dropdownIcon: widget.dropdownIcon,
              dropdownTextStyle: widget.dropdownTextStyle,
              dialogType: widget.dialogType,
              onTap: widget.enabled && widget.showCountryDialog
                  ? widget.dialogType == DialogType.showDialog
                      ? _changeCountryDialog
                      : _changeCountryModalBottomSheet
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: AppTextFormField(
              key: widget.formFieldKey,
              initialValue: (widget.controller == null) ? number : null,
              controller: widget.controller,
              focusNode: widget.focusNode,
              autofillHints: widget.autofillHints ??
                  const [
                    AutofillHints.telephoneNumberNational,
                    AutofillHints.telephoneNumber,
                  ],
              readOnly: widget.readOnly,
              obscureText: widget.obscureText,
              textAlign: widget.textAlign,
              textAlignVertical: widget.textAlignVertical,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              keyboardAppearance: widget.keyboardAppearance,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              cursorColor: widget.cursorColor,
              cursorHeight: widget.cursorHeight,
              cursorRadius: widget.cursorRadius,
              cursorWidth: widget.cursorWidth,
              showCursor: widget.showCursor,
              magnifierConfiguration: widget.magnifierConfiguration,
              decorationOverride: widget.decoration.copyWith(
                counterText: !widget.enabled ? '' : null,
              ),
              textStyle: widget.style,
              onSaved: (value) {
                widget.onSaved?.call(
                  PhoneNumber(
                    countryISOCode: _selectedCountry.code,
                    countryCode:
                        '+${_selectedCountry.dialCode}${_selectedCountry.regionCode}',
                    number: value ?? '',
                  ),
                );
                return null;
              },
              onChanged: (value) async {
                final phoneNumber = PhoneNumber(
                  countryISOCode: _selectedCountry.code,
                  countryCode: '+${_selectedCountry.fullCountryCode}',
                  number: value,
                );
                if (widget.autovalidateMode != AutovalidateMode.disabled) {
                  validatorMessage = await widget.validator?.call(phoneNumber);
                }
                widget.onChanged?.call(phoneNumber);
              },
              validator: widget.validator != null
                  ? (value) {
                      final initialPhoneNumber = PhoneNumber(
                        countryISOCode: _selectedCountry.code,
                        countryCode: '+${_selectedCountry.dialCode}',
                        number: value ?? '',
                      );
                      final result = widget.validator?.call(initialPhoneNumber);
                      if (result is String) {
                        validatorMessage = result;
                        return result;
                      } else if (result is Future) {
                        // For async validators, we'll handle this differently
                        // For now, return null and handle async validation in onChanged
                        return null;
                      }
                      return null;
                    }
                  : (value) {
                      return phoneNumberValidator(
                        value,
                        _selectedCountry,
                        validatorMessage: validatorMessage,
                        disableLengthCheck: widget.disableLengthCheck,
                        maxLength: widget.maxLength,
                        invalidMessage: widget.invalidMessage,
                        phoneNumberRequired: widget.phoneNumberRequiredText,
                      );
                    },
              maxLength: widget.disableLengthCheck
                  ? null
                  : (widget.maxLength ?? _selectedCountry.maxLength),
              onEditingComplete: widget.onEditingComplete,
              expands: widget.expands,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLengthEnforcement: widget.maxLengthEnforcement,
              buildCounter: widget.buildCounter,
              inputFormatters: widget.inputFormatters ??
                  [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(
                      widget.maxLength ?? _selectedCountry.maxLength,
                    ),
                  ],
              autovalidateMode:
                  widget.autovalidateMode ?? AutovalidateMode.disabled,
            ),
          ),
        ],
      ),
    );
  }
}
