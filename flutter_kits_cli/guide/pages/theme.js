DOCS.page({
  slug: 'theme',
  group: 'commands',
  title: 'Generating a theme',
  summary: 'Why widget_kit needs generated theme code, what fkit theme writes, and how to change it after.',
  html: `
<h1>Generating a theme</h1>
<p class="lede">
  <code>fkit theme</code> writes one file containing the two theme extensions
  widget_kit expects, with every colour derived from a brand colour you supply.
  Without that file, the kit's buttons are not your colours.
</p>

<h2>Why this command exists</h2>
<p>
  widget_kit is styled through <code>ThemeExtension</code>s rather than
  <code>ColorScheme</code>, and it uses <strong>two separate</strong> ones:
</p>

<table>
  <thead><tr><th>Extension</th><th>Styles</th></tr></thead>
  <tbody>
    <tr>
      <td><code>WidgetKitTheme</code></td>
      <td>Text fields, dialogs, bottom sheets, feedback and shimmer states, media placeholders.</td>
    </tr>
    <tr>
      <td><code>AppButtonThemeExtension</code></td>
      <td><code>AppButton</code>, and nothing else.</td>
    </tr>
  </tbody>
</table>

<div class="callout danger">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">Two facts that cost people an afternoon</span>
    <p>
      <strong>AppButton ignores WidgetKitTheme entirely.</strong> Setting
      <code>buttonBorderRadius</code>, <code>primaryButtonColor</code> or
      <code>primaryButtonTextColor</code> there changes nothing about a button —
      those fields are read by other widgets. AppButton reads only
      <code>AppButtonThemeExtension</code>, and its corner radius is a fixed
      <code>8.0</code> unless you pass <code>borderRadius</code> per button.
    </p>
    <p>
      <strong>Its defaults are hardcoded brand colours, not your ColorScheme.</strong>
      Filled buttons are <code>#DC1213</code> red, tonal buttons and the FAB are
      <code>#F49B25</code> orange, and elevated buttons sit on an opaque white that
      stays white in dark mode. They come from the app widget_kit was extracted
      from. Nothing warns you; the buttons simply come out red.
    </p>
  </div>
</div>

<p>
  Registering the extension by hand means writing all ten button styles —
  <code>filled</code>, <code>filledTonal</code>, <code>elevated</code>,
  <code>outlined</code>, <code>text</code>, four icon variants and
  <code>fab</code> — because the extension has no partial form. That is the reason
  nobody does it, and the reason this command exists.
</p>

<h2>Running it</h2>

<pre><code>fkit theme --primary 104C65
fkit theme -p "#104C65"
fkit theme                     # prompts for the colour</code></pre>

<p>
  The colour is any hex form: <code>104C65</code>, <code>#104C65</code>,
  <code>0xFF104C65</code>, or the three-digit shorthand <code>1AB</code>. A leading
  alpha channel is ignored. Anything unparseable stops the command before it writes:
</p>

<pre><code>Could not read "octarine" as a colour. Use a hex value like 104C65.</code></pre>

<h3>Flags</h3>

<table>
  <thead><tr><th>Flag</th><th>What it does</th></tr></thead>
  <tbody>
    <tr><td><code>--primary</code>, <code>-p</code></td><td>The brand colour. Prompted for if omitted.</td></tr>
    <tr><td><code>--output</code>, <code>-o</code></td><td>Write somewhere other than <code>lib/theme/kits_theme.dart</code>.</td></tr>
    <tr><td><code>--force</code>, <code>-f</code></td><td>Overwrite without asking. Without it you get a confirmation prompt, or a refusal when there is no terminal.</td></tr>
  </tbody>
</table>

<h2>What it writes</h2>
<p>
  One self-contained file. Every colour is a literal — the derived tint, the
  readable foreground, each overlay alpha — so your app does no colour arithmetic at
  runtime and every value is greppable:
</p>

<pre><code>const brandPrimary = Color(0xFF104C65);
const brandOnPrimary = Color(0xFFFFFFFF);
const brandTonal = Color(0xFFDEE6E9);
const brandOnTonal = Color(0xFF0D3E53);

/// Pass to ThemeData.extensions.
const kitsThemeExtensions = &lt;ThemeExtension&lt;dynamic&gt;&gt;[
  kitsWidgetTheme,
  kitsButtonTheme,
];</code></pre>

<p>Three values are derived from the one you gave:</p>

<ul>
  <li>
    <strong>The foreground on your colour</strong> — white or near-black, chosen by
    perceived brightness, so the label stays readable whichever colour you pick.
  </li>
  <li>
    <strong>The tonal background</strong> — your colour mixed toward white, used for
    the medium-emphasis buttons.
  </li>
  <li>
    <strong>The overlay colours</strong> — your colour at the ripple and hover
    alphas Material expects.
  </li>
</ul>

<h2>Wiring it in</h2>

<pre><code>import 'package:my_app/theme/kits_theme.dart';

MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: kitsThemeExtensions,
  ),
);</code></pre>

<p>
  The command prints this with your project's real package name filled in, so you
  can copy it straight out of the terminal.
</p>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">copyWith replaces the whole extensions list</span>
    <p>
      If you already pass other <code>ThemeExtension</code>s, adding
      <code>extensions: kitsThemeExtensions</code> discards them. Combine the lists
      instead:
    </p>
    <pre><code>extensions: [...kitsThemeExtensions, myOtherExtension]</code></pre>
  </div>
</div>

<h2>Changing it afterwards</h2>
<p>
  Edit the file. It is ordinary Dart the moment it is written, it is not registered
  anywhere, and no command regenerates it behind your back — the only way to replace
  it is to re-run with <code>--force</code>, which asks first.
</p>
<p>
  Common changes: adjust <code>inputBorderRadius</code> and the radii in
  <code>kitsWidgetTheme</code>; give a single style its own colour by editing that
  entry in <code>kitsButtonTheme</code>; delete the fields you do not care about
  and let the kit's own defaults apply.
</p>

<h3>Two themes</h3>
<p>
  The command generates one set of colours. For a separate dark palette, run it a
  second time into another file and pass each to the matching <code>ThemeData</code>:
</p>

<pre><code>fkit theme --primary 104C65 -o lib/theme/kits_theme.dart
fkit theme --primary 5FB2D1 -o lib/theme/kits_theme_dark.dart</code></pre>

<p>Then rename the constants in the second file so they do not collide.</p>

<h2>What this command is not</h2>
<ul>
  <li>
    <strong>Not a full app theme.</strong> It generates the kits' extensions only.
    Your <code>ColorScheme</code>, typography and Material component themes are
    still yours to write.
  </li>
  <li>
    <strong>Not connected to your ColorScheme.</strong> The colour you pass is used
    directly; it is not read from or written back to <code>ThemeData</code>. If you
    change your seed colour later, re-run this command too.
  </li>
  <li>
    <strong>Not tracked.</strong> fkit has no record of having written the file and
    will not update it when a kit changes.
  </li>
</ul>

<h2>Things that go wrong</h2>

<h3>Buttons are still red after generating the file</h3>
<p>
  The file exists but is not reaching <code>ThemeData</code>. Check that
  <code>extensions: kitsThemeExtensions</code> is on the <code>ThemeData</code> your
  <code>MaterialApp</code> actually uses — a common miss is setting it on
  <code>theme</code> while running in dark mode, where <code>darkTheme</code> applies.
  <code>fkit doctor</code> reports whether the extension appears anywhere in
  <code>lib/</code> at all.
</p>

<h3>"lib/theme/kits_theme.dart already exists; pass --force to overwrite."</h3>
<p>
  Shown when there is no terminal to confirm at — in CI, or with output piped.
  Interactively you get a yes/no prompt instead. Pass <code>--force</code> if
  replacing it is intended; your edits to that file will be lost.
</p>

<h3>The generated file does not compile</h3>
<p>
  It imports <code>package:widget_kit/widget_kit.dart</code>, so it needs the kit
  installed. Run <code>fkit add widget_kit</code>.
</p>
`,
});
