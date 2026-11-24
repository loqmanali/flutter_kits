DOCS.page({
  slug: 'getting-started',
  group: 'start',
  title: 'Getting started',
  summary: 'Add a kit, generate a theme, wire it into MaterialApp, and see a themed button.',
  html: `
<h1>Getting started</h1>
<p class="lede">
  Five minutes, start to finish: put <code>widget_kit</code> into a project, give it
  your brand colour, and get a button on screen that is actually your colour rather
  than the kit's built-in red.
</p>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">Before you start</span>
    <p>
      You need a Flutter project — any project with a <code>pubspec.yaml</code> — and
      <code>fkit</code> on your <code>PATH</code>. If <code>fkit --help</code> does
      not answer, see <a href="#/introduction#installing-it">Installing it</a>.
    </p>
  </div>
</div>

<h2>Where to run the commands</h2>
<p>
  Anywhere inside the project. fkit walks up the directory tree looking for a
  <code>pubspec.yaml</code>, the same way <code>git</code> finds its repository
  root, so running it from <code>lib/features/checkout</code> still edits the
  project's own pubspec.
</p>
<p>
  If it cannot find one, it stops without changing anything:
</p>

<pre><code>No pubspec.yaml found here or in any parent directory.
Run this from inside a Flutter project.</code></pre>

<h2>1. See what is available</h2>
<p>
  Start with the catalogue. A filled circle marks a kit this project already
  depends on; an empty one marks a kit you could add.
</p>

<pre><code>fkit ls</code></pre>

<pre><code>  flutter_kits  pinned at v2.0.0

  ○ animation_kit      0.1.1    A comprehensive Flutter animation package…
  ○ api_kit            1.0.1    A pluggable, project-agnostic API networking layer
  ○ carousel_kit       1.1.4    A flexible, project-agnostic carousel module
  …
  ○ widget_kit         1.2.0    A project-agnostic collection of reusable widgets

  ● installed   ○ available   —   fkit add &lt;kit&gt; to install</code></pre>

<p>
  The version beside each name is the <em>kit's own</em> version, shown so you know
  what you are getting. It is not the value that goes into <code>ref:</code> — see
  <a href="#/introduction#how-the-kits-are-versioned">How the kits are versioned</a>.
</p>

<h2>2. Add the kit</h2>

<pre><code>fkit add widget_kit</code></pre>

<p>This writes the dependency, runs <code>flutter pub get</code>, and then tells you
about anything the kit needs beyond being installed:</p>

<pre><code>Added widget_kit 1.2.0

  ! widget_kit
    AppButton reads AppButtonThemeExtension, not WidgetKitTheme, and its
    defaults are the brand red/orange of the app it was extracted from.
    Run 'fkit theme' to generate both extensions, or every button ships red.

✓ flutter pub get</code></pre>

<p>Your <code>pubspec.yaml</code> now contains:</p>

<pre><code>dependencies:
  flutter:
    sdk: flutter
  # your own comments and packages are untouched
  cupertino_icons: ^1.0.8
  widget_kit:
    git:
      url: https://github.com/loqmanali/flutter_kits.git
      path: widget_kit
      ref: v2.0.0</code></pre>

<h2>3. Generate the theme</h2>
<p>
  Take that warning seriously — it is the single most common surprise with this kit.
  <code>AppButton</code> gets its colours from a theme extension called
  <code>AppButtonThemeExtension</code>, and its built-in defaults are the brand
  colours of the app the kit was originally extracted from. Install the kit, put a
  button on screen, and the button is red.
</p>

<p>Generate a real one from your own brand colour:</p>

<pre><code>fkit theme --primary 104C65</code></pre>

<pre><code>✓ Created lib/theme/kits_theme.dart

  Wire it up:
    import 'package:my_app/theme/kits_theme.dart';

    MaterialApp(
      theme: ThemeData.light().copyWith(
        extensions: kitsThemeExtensions,
      ),
    );</code></pre>

<p>
  The generated file holds two extensions — one for inputs, dialogs and sheets, one
  for all ten button styles — with every colour written out as a literal. It is
  ordinary code from the moment it lands: edit it freely, fkit will not touch it
  again. <a href="#/theme">More about what it generates</a>.
</p>

<h2>4. Wire it into your app</h2>
<p>Do exactly what the command printed. In your <code>MaterialApp</code>:</p>

<pre><code>import 'package:flutter/material.dart';
import 'package:my_app/theme/kits_theme.dart';
import 'package:widget_kit/widget_kit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        extensions: kitsThemeExtensions,
      ),
      home: Scaffold(
        body: Center(
          child: AppButton(
            label: 'It works',
            widthMode: AppButtonWidthMode.hug,
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}</code></pre>

<div class="callout tip">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 18h6M10 21h4M12 3a6 6 0 00-3.5 10.9c.6.4.9 1 .9 1.6v.5h5.2v-.5c0-.6.3-1.2.9-1.6A6 6 0 0012 3z"/></svg>
  <div>
    <span class="callout-title">Or skip steps 4 and 5</span>
    <p>
      <code>fkit snippet create app-shell</code> writes a <code>MaterialApp</code>
      that already has the theme extensions, a <code>ProviderScope</code> and the
      toast host wired in, with the reasons for each in comments. Swap your brand
      colours in and delete what you do not need.
    </p>
  </div>
</div>

<h2>5. Run it, then check the wiring</h2>

<pre><code>flutter run</code></pre>

<p>
  The button should be your colour. If it is red, the extensions did not reach
  <code>ThemeData</code>. Rather than hunting for it by eye:
</p>

<pre><code>fkit doctor</code></pre>

<pre><code>  ✓ 1 kit, nothing to fix.</code></pre>

<p>
  Run it again whenever something behaves oddly, and before you commit a change to
  <code>pubspec.yaml</code>. <a href="#/doctor">What it checks</a>.
</p>

<h2>Where to go next</h2>
<ul>
  <li><a href="#/kits">Adding and removing kits</a> — the other 19 kits, and how to pin them.</li>
  <li><a href="#/snippets">Using snippets</a> — a complete OTP screen, an async button, a confirm dialog.</li>
  <li><a href="#/reference">Command reference</a> — every flag.</li>
</ul>
`,
});
