DOCS.page({
  slug: 'widget-kit-app-button',
  group: 'widget_kit',
  title: 'AppButton',
  summary: 'Ten Material 3 variants, three sizes, loading and disabled states, FAB and Cupertino modes.',
  html: `
<h1>AppButton</h1>

<p class="page-meta">
  <span class="pill">widget_kit</span>
  <span class="pill">Buttons</span>
  <a href="https://github.com/loqmanali/flutter_kits/blob/main/widget_kit/lib/src/buttons/adaptive_button/src/app_button.dart">Source</a>
</p>

<p class="lede">
  One widget covering every button widget_kit ships: five text styles, four
  icon-only styles, the floating action button, and a Cupertino mode. Sizes,
  loading and disabled states, and haptics are built in.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="p1" data-on>Preview</button>
    <button data-tab="c1">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="p1" data-on>
      <div class="stage">
        <span class="ab md filled">Continue</span>
      </div>
    </div>
    <div data-pane="c1">
<pre><code>AppButton(
  label: 'Continue',
  onPressed: () =&gt; submit(),
)</code></pre>
    </div>
  </div>
</div>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">What the previews on this page show</span>
    <p>
      They are drawn at the widget's own measurements — the heights, paddings,
      font sizes and corner radius are the values in widget_kit's source, not
      approximations. The colours are the kit's <strong>built-in defaults</strong>,
      so what you see is what you get <em>before</em> registering
      <code>AppButtonThemeExtension</code>: brand red and orange.
      <a href="#/theme">fkit theme</a> replaces them with yours.
    </p>
  </div>
</div>

<h2>CLI</h2>
<p>Install the kit:</p>

<pre><code>fkit add widget_kit</code></pre>

<p>To generate this widget's style for customization:</p>

<pre><code>fkit style create app-button</code></pre>

<p>
  That writes <code>lib/theme/styles/app_button_style.dart</code> — a function
  returning an <code>AppButtonThemeExtension</code> with all ten styles spelled
  out, so you can change one without reconstructing the other nine. See
  <a href="#/styles">Generating widget styles</a>.
</p>

<h2>Usage</h2>
<p>One import covers the whole kit.</p>

<pre><code>import 'package:widget_kit/widget_kit.dart';</code></pre>

<p>The constructor, with every parameter you are likely to reach for:</p>

<pre><code>AppButton(
  label: 'Continue',
  style: AppButtonStyleType.filled,
  size: AdaptiveButtonSize.medium,
  widthMode: AppButtonWidthMode.fill,
  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
  iconAlignment: AppIconAlignment.end,
  isLoading: false,
  isDisabled: false,
  onPressed: () {},
)</code></pre>

<p>
  There is a second constructor, <code>AppButton.fab</code>, for the floating
  action button — see <a href="#floating-action-button">below</a>.
</p>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">A button fills its parent unless you say otherwise</span>
    <p>
      <code>widthMode</code> defaults to <code>fill</code> for every style except
      the four icon-only ones, which default to <code>hug</code>. Drop an
      <code>AppButton</code> straight into a <code>Column</code> and it spans the
      full width. That is the right default for form and sheet actions, and the
      usual surprise when you wanted a small inline button.
    </p>
  </div>
</div>

<h2>Width mode</h2>
<p>The same button both ways, in a parent 320 logical pixels wide.</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="p2" data-on>Preview</button>
    <button data-tab="c2">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="p2" data-on>
      <div class="stage stack" style="max-width:320px;margin-inline:auto">
        <span class="ab md filled fill">Fills the row</span>
        <span class="ab md filled" style="align-self:flex-start">Hugs its label</span>
      </div>
    </div>
    <div data-pane="c2">
<pre><code>// Default: fills the width its parent gives it.
AppButton(
  label: 'Fills the row',
  onPressed: () {},
)

// hug shrinks the button to its label.
AppButton(
  label: 'Hugs its label',
  widthMode: AppButtonWidthMode.hug,
  onPressed: () {},
)</code></pre>
    </div>
  </div>
</div>

<h2>Styles</h2>
<p>
  Five text styles, in descending emphasis. Use one filled button per screen and
  make everything else quieter.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="p3" data-on>Preview</button>
    <button data-tab="c3">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="p3" data-on>
      <div class="stage">
        <span class="ab md filled">Filled</span>
        <span class="ab md tonal">Filled tonal</span>
        <span class="ab md elevated">Elevated</span>
        <span class="ab md outlined">Outlined</span>
        <span class="ab md text">Text</span>
      </div>
    </div>
    <div data-pane="c3">
<pre><code>AppButton(label: 'Filled', onPressed: () {})

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
)</code></pre>
    </div>
  </div>
</div>

<p>Switch this page to dark mode and look at the elevated button again:</p>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">The defaults are not theme-aware</span>
    <p>
      <code>elevated</code> has an opaque white background written into the kit's
      defaults, so it stays white on a dark surface. None of the ten styles read
      <code>Theme.of(context).colorScheme</code>. Register an
      <code>AppButtonThemeExtension</code> per brightness if your app has a dark
      theme.
    </p>
  </div>
</div>

<h2>Sizes</h2>
<p>Three sizes. Every measurement below is fixed in the widget, not derived from the theme.</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="p4" data-on>Preview</button>
    <button data-tab="c4">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="p4" data-on>
      <div class="stage">
        <span class="ab lg filled">Large</span>
        <span class="ab md filled">Medium</span>
        <span class="ab sm filled">Small</span>
      </div>
    </div>
    <div data-pane="c4">
<pre><code>AppButton(
  label: 'Large',
  size: AdaptiveButtonSize.large,
  onPressed: () {},
)

AppButton(
  label: 'Medium',                  // the default
  size: AdaptiveButtonSize.medium,
  onPressed: () {},
)

AppButton(
  label: 'Small',
  size: AdaptiveButtonSize.small,
  onPressed: () {},
)</code></pre>
    </div>
  </div>
</div>

<table>
  <thead>
    <tr><th>Size</th><th>Height</th><th>Label</th><th>Padding</th><th>Icon</th></tr>
  </thead>
  <tbody>
    <tr><td><code>large</code></td><td class="num">56</td><td class="num">16 / w600</td><td class="num">24 × 16</td><td class="num">24</td></tr>
    <tr><td><code>medium</code></td><td class="num">48</td><td class="num">14 / w600</td><td class="num">20 × 12</td><td class="num">20</td></tr>
    <tr><td><code>small</code></td><td class="num">32</td><td class="num">12 / w600</td><td class="num">16 × 8</td><td class="num">18</td></tr>
  </tbody>
</table>

<p>
  The corner radius is <strong>8</strong> for every size and style. It is not read
  from <code>WidgetKitTheme</code> — pass <code>borderRadius</code> on the button to
  change it.
</p>

<h2>With an icon</h2>
<p>
  Pass <code>icon</code> alongside <code>label</code>. Sizing the icon is yours to
  do: the button does not resize the widget you hand it.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="p5" data-on>Preview</button>
    <button data-tab="c5">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="p5" data-on>
      <div class="stage">
        <span class="ab md filled">
          <span class="i"><svg viewBox="0 0 24 24"><path d="M12 3v12M7 11l5 5 5-5M4 20h16"/></svg></span>
          Download
        </span>
        <span class="ab md outlined">
          Next
          <span class="i"><svg viewBox="0 0 24 24"><path d="M4 12h15M13 6l6 6-6 6"/></svg></span>
        </span>
      </div>
    </div>
    <div data-pane="c5">
<pre><code>AppButton(
  label: 'Download',
  icon: const Icon(Icons.download_rounded, size: 20),
  widthMode: AppButtonWidthMode.hug,
  onPressed: () {},
)

// Put the icon after the label.
AppButton(
  label: 'Next',
  style: AppButtonStyleType.outlined,
  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
  iconAlignment: AppIconAlignment.end,
  widthMode: AppButtonWidthMode.hug,
  onPressed: () {},
)</code></pre>
    </div>
  </div>
</div>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">The icon stays on the left in RTL too</span>
    <p>
      <code>iconAlignment</code> defaults to <code>start</code> in LTR and
      <code>end</code> in RTL. Because a <code>Row</code> already mirrors under
      RTL, both resolve to the same visual side — the icon does not swap sides
      with the text. Set <code>iconAlignment</code> explicitly if you want it to
      follow the reading direction.
    </p>
  </div>
</div>

<h2>Icon-only</h2>
<p>
  The four icon styles render <code>icon</code> and ignore <code>label</code>. They
  default to <code>hug</code> and come out square. Give each one a
  <code>tooltip</code>: an icon alone is not a name, and screen readers have
  nothing else to announce.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="p6" data-on>Preview</button>
    <button data-tab="c6">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="p6" data-on>
      <div class="stage">
        <span class="ab md icon only" title="Save to favourites">
          <span class="i"><svg viewBox="0 0 24 24"><path d="M12 20s-7-4.4-7-9a4 4 0 017-2.6A4 4 0 0119 11c0 4.6-7 9-7 9z"/></svg></span>
        </span>
        <span class="ab md icon-filled only" title="Add item">
          <span class="i"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></span>
        </span>
        <span class="ab md icon-tonal only" title="Bookmark">
          <span class="i"><svg viewBox="0 0 24 24"><path d="M6 4h12v16l-6-4-6 4z"/></svg></span>
        </span>
        <span class="ab md icon-outlined only" title="Share">
          <span class="i"><svg viewBox="0 0 24 24"><circle cx="18" cy="5" r="2.5"/><circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="19" r="2.5"/><path d="M8.2 10.8l7.6-4.1M8.2 13.2l7.6 4.1"/></svg></span>
        </span>
      </div>
    </div>
    <div data-pane="c6">
<pre><code>AppButton(
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
  style: AppButtonStyleType.iconFilledTonal,
  icon: const Icon(Icons.bookmark_border_rounded),
  tooltip: 'Bookmark',
  onPressed: () {},
)

AppButton(
  style: AppButtonStyleType.iconOutlined,
  icon: const Icon(Icons.share_rounded),
  tooltip: 'Share',
  onPressed: () {},
)</code></pre>
    </div>
  </div>
</div>

<h2>Loading and disabled</h2>
<p>
  Both states swallow taps — you do not need to null out <code>onPressed</code> or
  guard against double submission. <code>isLoading</code> also replaces the label
  with a spinner sized to the icon, so a hugging button shrinks while it loads.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="p7" data-on>Preview</button>
    <button data-tab="c7">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="p7" data-on>
      <div class="stage">
        <span class="ab md filled" style="width:150px"><span class="spin"></span></span>
        <span class="ab md filled disabled" style="width:150px">Unavailable</span>
      </div>
    </div>
    <div data-pane="c7">
<pre><code>// While loading, the label becomes a spinner and taps are ignored.
AppButton(
  label: 'Saving…',
  isLoading: true,
  onPressed: () {},
)

AppButton(
  label: 'Unavailable',
  isDisabled: true,
  onPressed: () {},
)</code></pre>
    </div>
  </div>
</div>

<p>The pattern this is built for — flip the flag around the await and leave <code>onPressed</code> alone:</p>

<pre><code>class _SaveButtonState extends State&lt;SaveButton&gt; {
  bool _saving = false;

  Future&lt;void&gt; _save() async {
    setState(() =&gt; _saving = true);
    try {
      await api.save();
    } finally {
      // The widget can be disposed mid-flight if the user navigates away.
      if (mounted) setState(() =&gt; _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) =&gt; AppButton(
        label: 'Save changes',
        isLoading: _saving,
        onPressed: _save,
      );
}</code></pre>

<p>
  <code>fkit snippet create async-button</code> writes this as a reusable widget.
</p>

<h2>Floating action button</h2>
<p>
  A separate constructor, <code>AppButton.fab</code>, with four types: regular
  (56), small (40), large (96), and extended with a label.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="p8" data-on>Preview</button>
    <button data-tab="c8">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="p8" data-on>
      <div class="stage">
        <span class="ab fab fab-sm" title="Add">
          <span class="i"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></span>
        </span>
        <span class="ab fab" title="Add">
          <span class="i"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></span>
        </span>
        <span class="ab fab fab-ext">
          <span class="i"><svg viewBox="0 0 24 24"><path d="M4 20h4l10-10-4-4L4 16v4zM14 6l4 4"/></svg></span>
          Compose
        </span>
      </div>
    </div>
    <div data-pane="c8">
<pre><code>AppButton.fab(
  icon: const Icon(Icons.add),
  buttonType: FloatingActionButtonType.small,
  heroTag: 'add-small',
  onPressed: () {},
)

AppButton.fab(
  icon: const Icon(Icons.add),
  heroTag: 'add',
  onPressed: () {},
)

AppButton.fab(
  icon: const Icon(Icons.edit),
  label: 'Compose',
  buttonType: FloatingActionButtonType.extended,
  heroTag: 'compose',
  onPressed: () {},
)</code></pre>
    </div>
  </div>
</div>

<div class="callout danger">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">Two FABs on one route crash without distinct heroTags</span>
    <p>
      <code>FloatingActionButton</code> animates through a <code>Hero</code> with a
      default tag, so a second one on the same route throws
      <em>"There are multiple heroes that share the same tag"</em> — at runtime,
      when the route builds. Give each FAB its own <code>heroTag</code>, or pass
      <code>null</code> to opt out of the Hero entirely.
    </p>
  </div>
</div>

<h2>Theming</h2>
<p>
  For one button, override the colours directly. This is right for a destructive
  action and wrong as a way to restyle an app.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="p9" data-on>Preview</button>
    <button data-tab="c9">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="p9" data-on>
      <div class="stage">
        <span class="ab md filled" style="background:#B3261E">Delete account</span>
      </div>
    </div>
    <div data-pane="c9">
<pre><code>AppButton(
  label: 'Delete account',
  backgroundColor: const Color(0xFFB3261E),
  foregroundColor: Colors.white,
  widthMode: AppButtonWidthMode.hug,
  onPressed: () {},
)</code></pre>
    </div>
  </div>
</div>

<p>
  For the whole app, register an <code>AppButtonThemeExtension</code>. All ten
  styles are required — the extension has no partial form — which is why
  generating it is easier than writing it:
</p>

<pre><code>fkit theme --primary 104C65</code></pre>

<p>
  That writes <code>lib/theme/kits_theme.dart</code> with both extensions filled
  in. See <a href="#/theme">Generating a theme</a>.
</p>

<h2>API reference</h2>

<table>
  <thead><tr><th>Parameter</th><th>Type</th><th>Default</th></tr></thead>
  <tbody>
    <tr><td><code>label</code></td><td><code>String?</code></td><td>required unless <code>child</code> or an icon style</td></tr>
    <tr><td><code>child</code></td><td><code>Widget?</code></td><td>—</td></tr>
    <tr><td><code>style</code></td><td><code>AppButtonStyleType</code></td><td><code>.filled</code></td></tr>
    <tr><td><code>size</code></td><td><code>AdaptiveButtonSize</code></td><td><code>.medium</code></td></tr>
    <tr><td><code>widthMode</code></td><td><code>AppButtonWidthMode?</code></td><td><code>.fill</code> — <code>.hug</code> for icon styles</td></tr>
    <tr><td><code>icon</code></td><td><code>Widget?</code></td><td>—</td></tr>
    <tr><td><code>iconAlignment</code></td><td><code>AppIconAlignment?</code></td><td><code>.start</code> in LTR, <code>.end</code> in RTL</td></tr>
    <tr><td><code>isLoading</code></td><td><code>bool</code></td><td><code>false</code></td></tr>
    <tr><td><code>isDisabled</code></td><td><code>bool</code></td><td><code>false</code></td></tr>
    <tr><td><code>onPressed</code></td><td><code>VoidCallback?</code></td><td>—</td></tr>
    <tr><td><code>onLongPress</code></td><td><code>VoidCallback?</code></td><td>—</td></tr>
    <tr><td><code>backgroundColor</code></td><td><code>Color?</code></td><td>from the style</td></tr>
    <tr><td><code>foregroundColor</code></td><td><code>Color?</code></td><td>from the style</td></tr>
    <tr><td><code>borderRadius</code></td><td><code>double?</code></td><td><code>8.0</code></td></tr>
    <tr><td><code>fitLabel</code></td><td><code>bool</code></td><td><code>true</code> — scales the label down rather than wrapping</td></tr>
    <tr><td><code>enableHapticFeedback</code></td><td><code>bool</code></td><td><code>true</code> — Android, iOS and Fuchsia only</td></tr>
    <tr><td><code>tooltip</code></td><td><code>String?</code></td><td>—</td></tr>
    <tr><td><code>semanticLabel</code></td><td><code>String?</code></td><td>—</td></tr>
    <tr><td><code>useCupertinoStyle</code></td><td><code>bool</code></td><td><code>false</code></td></tr>
  </tbody>
</table>

<h3>Enums</h3>
<table>
  <thead><tr><th>Enum</th><th>Values</th></tr></thead>
  <tbody>
    <tr>
      <td><code>AppButtonStyleType</code></td>
      <td><code>filled</code>, <code>filledTonal</code>, <code>elevated</code>, <code>outlined</code>, <code>text</code>, <code>icon</code>, <code>iconFilled</code>, <code>iconFilledTonal</code>, <code>iconOutlined</code>, <code>fab</code></td>
    </tr>
    <tr><td><code>AdaptiveButtonSize</code></td><td><code>large</code>, <code>medium</code>, <code>small</code></td></tr>
    <tr><td><code>AppButtonWidthMode</code></td><td><code>fill</code>, <code>hug</code></td></tr>
    <tr><td><code>AppIconAlignment</code></td><td><code>start</code>, <code>end</code></td></tr>
    <tr><td><code>FloatingActionButtonType</code></td><td><code>regular</code>, <code>small</code>, <code>large</code>, <code>extended</code></td></tr>
  </tbody>
</table>

<h2>Things that go wrong</h2>

<h3>The button is red and I never asked for red</h3>
<p>
  No <code>AppButtonThemeExtension</code> is registered, so the kit's built-in
  defaults apply. Run <code>fkit theme --primary &lt;hex&gt;</code> and pass the
  result to <code>ThemeData.extensions</code>.
  <code>fkit doctor</code> reports this too.
</p>

<h3>Setting primaryButtonColor on WidgetKitTheme changed nothing</h3>
<p>
  <code>AppButton</code> never reads <code>WidgetKitTheme</code>. Its colours come
  only from <code>AppButtonThemeExtension</code>, and its radius is a fixed
  <code>8.0</code>. Those <code>WidgetKitTheme</code> fields are used by other
  widgets in the kit.
</p>

<h3>The button stretched across the whole screen</h3>
<p>
  That is <code>widthMode: fill</code>, the default. Pass
  <code>widthMode: AppButtonWidthMode.hug</code>.
</p>

<h3>"There are multiple heroes that share the same tag"</h3>
<p>
  Two FABs on one route. Give each a distinct <code>heroTag</code>, or
  <code>null</code> to skip the Hero.
</p>

<h3>An assertion fires when the button is built</h3>
<p>
  The constructor asserts that icon styles get an <code>icon</code>, and that every
  other style gets a <code>label</code> or a <code>child</code>. Check which style
  you passed.
</p>

<h3>My long label is shrinking instead of wrapping</h3>
<p>
  <code>fitLabel</code> defaults to <code>true</code>, which wraps the label in a
  scale-down <code>FittedBox</code>. Set it to <code>false</code>, or give the
  button more width.
</p>
`,
});
