/// Copy-able snippets for the AppButton page.
///
/// These are written by hand so they stay short enough to paste straight into a
/// widget tree. Each one matches the demo rendered beside it — if the kit's API
/// changes, both the demo and the snippet have to change together.
library;

const kAppButtonBasic = '''
AppButton(
  label: 'Continue',
  onPressed: () => submit(),
)
''';

const kAppButtonWidthMode = '''
// Default: a button fills the width its parent gives it.
AppButton(
  label: 'Fills the row',
  onPressed: () {},
)

// hug shrinks the button to its label.
AppButton(
  label: 'Hugs its label',
  widthMode: AppButtonWidthMode.hug,
  onPressed: () {},
)
''';

const kAppButtonStyles = '''
AppButton(label: 'Filled', onPressed: () {})

AppButton(
  label: 'Filled tonal',
  style: AppButtonVariant.filledTonal,
  onPressed: () {},
)

AppButton(
  label: 'Elevated',
  style: AppButtonVariant.elevated,
  onPressed: () {},
)

AppButton(
  label: 'Outlined',
  style: AppButtonVariant.outlined,
  onPressed: () {},
)

AppButton(
  label: 'Text',
  style: AppButtonVariant.text,
  onPressed: () {},
)
''';

const kAppButtonSizes = '''
AppButton(
  label: 'Large',
  size: AppButtonSize.large,   // 56dp tall, 16sp label
  onPressed: () {},
)

AppButton(
  label: 'Medium',
  size: AppButtonSize.medium,  // 48dp tall, 14sp label — the default
  onPressed: () {},
)

AppButton(
  label: 'Small',
  size: AppButtonSize.small,   // 32dp tall, 12sp label
  onPressed: () {},
)
''';

const kAppButtonIcon = '''
AppButton(
  label: 'Download',
  icon: const Icon(Icons.download_rounded, size: 20),
  widthMode: AppButtonWidthMode.hug,
  onPressed: () {},
)

// Put the icon after the label.
AppButton(
  label: 'Next',
  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
  iconAlignment: AppIconAlignment.end,
  widthMode: AppButtonWidthMode.hug,
  onPressed: () {},
)
''';

const kAppButtonIconOnly = '''
// The four icon styles require `icon` and ignore `label`.
AppButton(
  style: AppButtonVariant.icon,
  icon: const Icon(Icons.favorite_border_rounded),
  tooltip: 'Save to favourites',
  onPressed: () {},
)

AppButton(
  style: AppButtonVariant.iconFilled,
  icon: const Icon(Icons.add_rounded),
  tooltip: 'Add item',
  onPressed: () {},
)

AppButton(
  style: AppButtonVariant.iconOutlined,
  icon: const Icon(Icons.share_rounded),
  tooltip: 'Share',
  onPressed: () {},
)
''';

const kAppButtonStates = '''
// While loading, the label is replaced by a spinner and taps are ignored —
// you do not need to null out onPressed yourself.
AppButton(
  label: 'Saving…',
  isLoading: true,
  onPressed: () {},
)

AppButton(
  label: 'Unavailable',
  isDisabled: true,
  onPressed: () {},
)
''';

const kAppButtonLoadingFlow = '''
class SaveButton extends StatefulWidget {
  const SaveButton({super.key});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await api.save();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppButton(
        label: 'Save changes',
        isLoading: _saving,
        onPressed: _save,
      );
}
''';

const kAppButtonFab = '''
AppButton.fab(
  icon: const Icon(Icons.add),
  heroTag: 'compose',   // distinct per FAB — see the note below
  onPressed: () {},
)

AppButton.fab(
  icon: const Icon(Icons.edit),
  label: 'Compose',
  buttonType: AppFabVariant.extended,
  heroTag: 'compose-extended',
  onPressed: () {},
)
''';

const kAppButtonPerInstanceColors = '''
AppButton(
  label: 'Delete account',
  backgroundColor: const Color(0xFFB3261E),
  foregroundColor: Colors.white,
  onPressed: () {},
)
''';

const kAppButtonThemeExtension = '''
// AppButton reads its colours from AppButtonThemeExtension — register one on
// your ThemeData and every AppButton in the app follows it.
final defaults = AppButtonThemeExtension.fromScheme(
  ColorScheme.fromSeed(seedColor: const Color(0xFF104C65)),
);

MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: [
      AppButtonThemeExtension(
        filled: AppButtonStyle(
          backgroundColor: Color(0xFF104C65),
          foregroundColor: Colors.white,
          overlayColor: Color(0x14104C65),
        ),
        // The other nine styles are required too; start from the scheme-derived
        // defaults and keep the ones you don't override:
        filledTonal: defaults.filledTonal,
        elevated: defaults.elevated,
        outlined: defaults.outlined,
        text: defaults.text,
        icon: defaults.icon,
        iconFilled: defaults.iconFilled,
        iconFilledTonal: defaults.iconFilledTonal,
        iconOutlined: defaults.iconOutlined,
        fab: defaults.fab,
      ),
    ],
  ),
);
''';

const kAppButtonCupertino = '''
AppButton(
  label: 'Continue',
  useCupertinoStyle: true,
  cupertinoColor: CupertinoColors.activeBlue,
  onPressed: () {},
)
''';
