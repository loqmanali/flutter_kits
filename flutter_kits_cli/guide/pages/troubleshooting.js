DOCS.page({
  slug: 'troubleshooting',
  group: 'ref',
  title: 'Things that go wrong',
  summary: 'Every message fkit prints when it stops, what caused it, and what to do.',
  html: `
<h1>Things that go wrong</h1>
<p class="lede">
  The messages fkit prints when it refuses to do something, and the failures that
  show up later in <code>flutter pub get</code> or the analyzer but start here.
</p>

<h2>The CLI itself</h2>

<h3>command not found: fkit</h3>
<p>
  Dart installs global executables into <code>~/.pub-cache/bin</code>, which most
  shells do not search by default. Add it to your shell profile and open a new
  terminal:
</p>
<pre><code>export PATH="$PATH:$HOME/.pub-cache/bin"</code></pre>
<p>
  If the directory does not exist, the install did not complete — re-run the
  <code>dart pub global activate</code> command from
  <a href="#/introduction">Introduction</a> and read its output.
</p>

<h3>fkit runs but the kit list looks out of date</h3>
<p>
  The catalogue is compiled into the CLI, so it is as current as your installed
  copy. Re-run <code>dart pub global activate</code> to pick up a newer release. The
  version it will pin to is printed at the top of <code>fkit ls</code>.
</p>

<h2>Finding the project</h2>

<h3>"No pubspec.yaml found here or in any parent directory."</h3>
<p>
  You are outside a Flutter project. fkit searches the current directory and every
  parent, so this means there is genuinely no <code>pubspec.yaml</code> above you —
  usually a shell left in a home directory or a sibling folder.
</p>

<h3>It edited the wrong pubspec.yaml</h3>
<p>
  Because the search walks upward, running fkit inside a nested example app or a
  monorepo package edits the nearest one going up, which may not be the one you had
  in mind. Check the path in the output — the theme and snippet commands print
  absolute paths — and <code>cd</code> to the project you meant.
</p>

<h2>Adding kits</h2>

<h3>"Unknown kit: widgetkit"</h3>
<p>
  The name did not match. fkit suggests the closest one it can find, and nothing is
  installed — including any valid names in the same command, so you do not end up
  with half the request applied. Run <code>fkit ls</code> for exact spellings; they
  are lowercase with underscores.
</p>

<h3>"widget_kit is already in pubspec.yaml — pass --force to replace it."</h3>
<p>
  Deliberate: silently overwriting would discard a considered <code>--ref</code> or
  a path dependency you are in the middle of using. Re-run with <code>--force</code>
  if replacing it is the intent.
</p>

<h3>"No kit named and no terminal to prompt from."</h3>
<p>
  <code>fkit add</code> with no arguments opens an interactive picker, which needs a
  real terminal. In CI, a script, or with output piped, name the kits explicitly.
</p>

<h3>"flutter not found on PATH"</h3>
<p>
  The pubspec edit succeeded and only the fetch was skipped — nothing is corrupted.
  Run <code>flutter pub get</code> yourself.
</p>

<h2>Failures during pub get</h2>

<h3>"could not find package carousel_kit at https://pub.dev"</h3>
<p>
  Something declared a kit as an ordinary version constraint. These packages are not
  published to pub.dev; they are git dependencies. Replace it:
</p>
<pre><code>fkit add carousel_kit --force</code></pre>

<h3>Git cannot resolve the reference</h3>
<p>
  Almost always a <code>ref:</code> pinned to the kit's own version rather than a
  release tag — <code>ref: v3.2.0</code> because otp_kit is at 3.2.0, when the tag
  that contains it is <code>v2.0.0</code>. The error mentions git, so it reads like
  a network or permissions problem.
</p>
<pre><code>fkit doctor        # names it explicitly
fkit add otp_kit --force</code></pre>
<p>See <a href="#/introduction#how-the-kits-are-versioned">How the kits are versioned</a>.</p>

<h3>A path dependency fails for a colleague or in CI</h3>
<p>
  A <code>path:</code> dependency points at a directory on the machine that wrote
  it. Switch back to git before committing:
</p>
<pre><code>fkit add widget_kit --force</code></pre>

<h2>Theme problems</h2>

<h3>The buttons are red</h3>
<p>
  The most common report, and it is not a bug. <code>AppButton</code> reads
  <code>AppButtonThemeExtension</code>, whose built-in defaults are the brand
  colours of the app widget_kit came from. Without that extension on your
  <code>ThemeData</code>, filled buttons are <code>#DC1213</code>.
</p>
<pre><code>fkit theme --primary &lt;hex&gt;</code></pre>
<p>Then pass <code>extensions: kitsThemeExtensions</code> to your <code>ThemeData</code>.</p>

<h3>The buttons are still red after generating the theme</h3>
<p>Work down this list:</p>
<ol class="steps">
  <li>
    <strong>Is the extension reaching ThemeData?</strong>
    <p>
      <code>extensions:</code> must be on the <code>ThemeData</code> your
      <code>MaterialApp</code> uses. Setting it on <code>theme</code> while the
      device is in dark mode means <code>darkTheme</code> applies instead.
    </p>
  </li>
  <li>
    <strong>Did another copyWith replace the list?</strong>
    <p>
      <code>extensions:</code> is a whole-list assignment, not a merge. A later
      <code>copyWith</code> passing its own <code>extensions</code> discards yours.
    </p>
  </li>
  <li>
    <strong>Is a per-button override winning?</strong>
    <p>
      <code>backgroundColor</code> on an individual <code>AppButton</code> beats the
      theme. Search for it before blaming the theme.
    </p>
  </li>
  <li>
    <strong>Were you expecting WidgetKitTheme to do it?</strong>
    <p>
      <code>primaryButtonColor</code> and <code>buttonBorderRadius</code> on
      <code>WidgetKitTheme</code> have no effect on <code>AppButton</code>. See
      <a href="#/theme#why-this-command-exists">Why this command exists</a>.
    </p>
  </li>
</ol>

<h3>Corner radius will not change</h3>
<p>
  <code>AppButton</code>'s radius is a fixed <code>8.0</code>. It is not read from
  either extension. Pass <code>borderRadius:</code> on the button.
</p>

<h2>Snippet problems</h2>

<h3>"target of URI doesn't exist" all over a new snippet</h3>
<p>
  The snippet imports something the project does not have. The
  <code>create</code> output listed it — kits are installed with
  <code>fkit add</code>, pub.dev packages with <code>flutter pub add</code>, and the
  distinction matters because a kit depending on a package does not let
  <em>your</em> code import it.
</p>

<h3>"Cannot write several snippets to one path."</h3>
<p>
  <code>--output</code> names one file. Drop it, or create the snippets one at a
  time.
</p>

<h3>I edited a snippet and want the original back</h3>
<pre><code>fkit snippet create &lt;name&gt; --force</code></pre>
<p>This overwrites the file completely; your changes are gone. Copy anything worth keeping first.</p>

<h2>If none of this helps</h2>
<p>Collect these before asking, because they answer most follow-up questions:</p>
<ul>
  <li><code>fkit doctor</code> output.</li>
  <li>The <code>dependencies:</code> section of your <code>pubspec.yaml</code>.</li>
  <li>The first ten lines of the failure — the top of a resolution error names the cause; the rest is consequence.</li>
</ul>
`,
});
