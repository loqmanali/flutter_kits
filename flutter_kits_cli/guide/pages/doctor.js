DOCS.page({
  slug: 'doctor',
  group: 'commands',
  title: 'Checking your setup',
  summary: 'The five problems fkit doctor finds, what each one breaks, and how to fix it.',
  html: `
<h1>Checking your setup</h1>
<p class="lede">
  <code>fkit doctor</code> reads your <code>pubspec.yaml</code> and your
  <code>lib/</code> folder and reports the mistakes that produce confusing failures
  — the ones whose error message points somewhere other than the cause.
</p>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">It only reads</span>
    <p>
      doctor changes nothing. It prints findings and exits successfully even when it
      finds them, because several are legitimate mid-development states — a path
      dependency while you are editing a kit, for instance. It is safe to run at any
      time and safe to put in a pre-commit hook for its output, but it will not fail
      a build for you.
    </p>
  </div>
</div>

<h2>Running it</h2>

<pre><code>fkit doctor</code></pre>

<p>A healthy project:</p>

<pre><code>  ✓ 2 kits, nothing to fix.</code></pre>

<p>A project with problems:</p>

<pre><code>  ! otp_kit is pinned to "v3.2.0", which looks like the package version.
    Tags are monorepo releases — there is no v3.2.0 tag. Use v2.0.0:
    fkit add otp_kit --force
  ! widget_kit has no ref — it will float on the default branch.
    Pin it: fkit add widget_kit --force
  ! carousel_kit is declared as "^1.1.4". Kits are not on pub.dev —
    use a git dependency, or run "fkit add carousel_kit --force".
  ! widget_kit is installed but no AppButtonThemeExtension was found in
    lib/. AppButton ignores WidgetKitTheme and falls back to its built-in
    brand red. Generate one: fkit theme --primary &lt;hex&gt;</code></pre>

<p>Every finding names the command that fixes it.</p>

<h2>What it checks</h2>

<h3>A ref that looks like a package version</h3>
<p>
  The most expensive mistake, because the failure names git rather than the pin.
  <code>otp_kit</code> is at version <code>3.2.0</code>, so <code>ref: v3.2.0</code>
  looks obviously right — but tags in this repository are monorepo releases, and no
  such tag exists. <code>flutter pub get</code> reports that it cannot resolve the
  reference, which reads like a network or access problem.
</p>
<p>
  doctor recognises the case specifically: it compares the ref against the kit's own
  version and says so in those words rather than just "outdated".
</p>
<p><strong>Fix:</strong> <code>fkit add &lt;kit&gt; --force</code>, which writes the correct tag.</p>

<h3>A missing ref</h3>
<p>
  A git dependency with no <code>ref</code> follows the default branch. The build is
  reproducible until someone pushes, and then it is not — and the change arrives on
  whichever machine next resolves dependencies, which is rarely the one that made it.
</p>
<p><strong>Fix:</strong> <code>fkit add &lt;kit&gt; --force</code>.</p>

<h3>A kit declared as a pub.dev version</h3>
<p>
  <code>carousel_kit: ^1.1.4</code> looks like every other dependency, but these
  packages are not published to pub.dev. Resolution fails with "could not find
  package … at https://pub.dev", which reads like an outage.
</p>
<p><strong>Fix:</strong> <code>fkit add &lt;kit&gt; --force</code> to replace it with a git dependency.</p>

<h3>A local path dependency</h3>
<p>
  Legitimate while you are working on a kit; broken for everyone else the moment it
  is committed, because the path points at your disk. Reported as a warning rather
  than an error for exactly that reason.
</p>
<p>
  <strong>Fix, when you are done:</strong> <code>fkit add &lt;kit&gt; --force</code>
  with no <code>--path</code>. See
  <a href="#/kits#working-on-the-kits-themselves">Working on the kits themselves</a>.
</p>

<h3>widget_kit without a button theme</h3>
<p>
  The quiet one. doctor scans every <code>.dart</code> file under <code>lib/</code>
  for the text <code>AppButtonThemeExtension</code>. If widget_kit is installed and
  the extension appears nowhere, every <code>AppButton</code> in the app is using
  the kit's built-in defaults — filled buttons in <code>#DC1213</code> red, tonal
  buttons and the FAB in <code>#F49B25</code> orange. Nothing errors. The buttons
  are simply the wrong colour, and the reason is not visible from any of your code.
</p>
<p><strong>Fix:</strong> <code>fkit theme --primary &lt;hex&gt;</code>, then wire the result into your <code>MaterialApp</code>. See <a href="#/theme">Generating a theme</a>.</p>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">This check is a text search</span>
    <p>
      It looks for the name anywhere in <code>lib/</code>, so a mention in a comment
      counts as registered and a real registration in a file outside
      <code>lib/</code> does not. It is a smoke alarm, not a compiler: a clean result
      means the extension exists somewhere, not that it reaches the
      <code>ThemeData</code> your app is using.
    </p>
  </div>
</div>

<h2>What doctor is not</h2>
<ul>
  <li>
    <strong>Not <code>flutter doctor</code>.</strong> It says nothing about your SDK,
    toolchain, devices or licences.
  </li>
  <li>
    <strong>Not a linter.</strong> It does not read your code for correctness. The
    only thing it looks for inside <code>lib/</code> is that one extension name.
  </li>
  <li>
    <strong>Not a build gate.</strong> It exits successfully whatever it finds, so a
    CI step running it will not fail on findings. Grep its output if you want that.
  </li>
  <li>
    <strong>Not aware of kit-specific setup.</strong> It will not tell you that
    notify_kit needs its platform files or that firebase_kit needs a configured
    project — those notes are printed by <code>fkit add</code> at install time.
  </li>
</ul>

<h2>Things that go wrong</h2>

<h3>It reports nothing at all</h3>
<pre><code>  No kits in pubspec.yaml.</code></pre>
<p>
  It found a project but no kits in it. If you expected some, check you are in the
  right project — with a monorepo or a nested example app, the nearest
  <code>pubspec.yaml</code> going up may not be the one you were thinking of.
</p>

<h3>It flags a path dependency I want to keep</h3>
<p>
  That is the intended behaviour and there is no way to silence it. The finding is
  informational; keep working. Just do not commit it.
</p>

<h3>It says the button theme is missing, but I registered it</h3>
<p>
  The check searches <code>lib/</code> only. If your theme lives outside it — in a
  separate package, or a <code>packages/</code> folder — the check cannot see it and
  will keep reporting. Compare against what your app actually renders; if the
  buttons are your colours, the wiring is fine.
</p>
`,
});
