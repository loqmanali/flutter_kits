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
  style: AppButtonStyleType.filledTonal,
  onPressed: () {},
)

AppButton(
  label: 'Elevated',
  style: AppButtonStyleType.elevated,
  onPressed: () {},
)

AppButton(
  label: 'Outlined',
  style: AppButtonStyleType.outlined,
  onPressed: () {},
)

AppButton(
  label: 'Text',
  style: AppButtonStyleType.text,
  onPressed: () {},
)
''';

const kAppButtonSizes = '''
AppButton(
  label: 'Large',
  size: AdaptiveButtonSize.large,   // 56dp tall, 16sp label
  onPressed: () {},
)

AppButton(
  label: 'Medium',
  size: AdaptiveButtonSize.medium,  // 48dp tall, 14sp label — the default
  onPressed: () {},
)

AppButton(
  label: 'Small',
  size: AdaptiveButtonSize.small,   // 32dp tall, 12sp label
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
  style: AppButtonStyleType.icon,
  icon: const Icon(Icons.favorite_border_rounded),
  tooltip: 'Save to favourites',
  onPressed: () {},
)

AppButton(
  style: AppButtonStyleType.iconFilled,
  icon: const Icon(Icons.add_rounded),
  tooltip: 'Add item',
  onPressed: () {},
)

AppButton(
  style: AppButtonStyleType.iconOutlined,
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
  buttonType: FloatingActionButtonType.extended,
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
MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: const [
      AppButtonThemeExtension(
        filled: AppButtonStyle(
          backgroundColor: Color(0xFF104C65),
          foregroundColor: Colors.white,
          overlayColor: Color(0x14104C65),
        ),
        // The other nine styles are required too; copy the defaults you keep:
        filledTonal: AppButtonStyle.filledTonal,
        elevated: AppButtonStyle.elevated,
        outlined: AppButtonStyle.outlined,
        text: AppButtonStyle.text,
        icon: AppButtonStyle.icon,
        iconFilled: AppButtonStyle.iconFilled,
        iconFilledTonal: AppButtonStyle.iconFilledTonal,
        iconOutlined: AppButtonStyle.iconOutlined,
        fab: AppButtonStyle.fab,
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
