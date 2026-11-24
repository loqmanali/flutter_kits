/// Hand-written snippets for the Validation demos.
library;

const String kValidationBuiltInSnippet = r'''// Validate before submitting. Returns an error message string, or null if OK.
final config = OTPTheme.custom(context: context, length: 4);
final controller = ref.read(otpControllerProvider(config).notifier);
final error = controller.validate(); // checks length + inputType by default

if (error != null) {
  controller.setError(error);
} else {
  // proceed with controller state's value
}''';

const String kValidationRulesSnippet = r'''// Custom rules are simple classes implementing OTPValidationRule.
final rules = <OTPValidationRule>[
  MinimumUniqueDigitsRule(minimumUnique: 3),
  NoSequentialPatternRule(),
  NoRepeatedDigitsRule(),
  PatternMatchRule(pattern: RegExp(r'^\d{6}$')),
  LengthRangeRule(minLength: 4, maxLength: 8),
];

OTPTextField(
  config: OTPTheme.custom(context: context, length: 6),
  customValidationRules: rules,
)''';

const String kValidationMessagesSnippet = r'''// Localize every validator message once at startup. The {length} placeholder
// is supported in `wrongLength`.
void main() {
  OTPValidatorMessages.instance = const OTPValidatorMessages(
    required: 'الكود مطلوب',
    wrongLength: 'يجب أن يكون الكود من {length} أرقام',
    notNumeric: 'يرجى إدخال أرقام فقط',
    invalidCharacter: 'حرف غير صالح',
    sequential: 'لا يمكن أن يكون الكود أرقاماً متسلسلة',
    repeated: 'لا يمكن أن تكون كل الأرقام متشابهة',
  );
  runApp(const MyApp());
}''';
