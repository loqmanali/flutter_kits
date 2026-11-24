DOCS.page({
  slug: 'snippets',
  group: 'commands',
  title: 'Using snippets',
  summary: 'Ready-made files copied into your project: what ships, where they land, and what you own after.',
  html: `
<h1>Using snippets</h1>
<p class="lede">
  A snippet is a working source file — a screen, a widget, an app shell — copied
  into your project. Unlike a dependency, it is yours the moment it lands: edit it,
  rename it, delete most of it. fkit never looks at it again.
</p>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">What creating a snippet does</span>
    <p>
      <strong>Writes:</strong> one <code>.dart</code> file, creating parent folders
      as needed.<br>
      <strong>Never overwrites</strong> an existing file unless you pass
      <code>--force</code>.<br>
      <strong>Does not</strong> install anything, edit <code>pubspec.yaml</code>, or
      run <code>pub get</code> — it tells you what is missing and leaves the
      installing to you.
    </p>
  </div>
</div>

<h2>Seeing what ships</h2>

<pre><code>fkit snippet ls</code></pre>

<pre><code>  app-shell       A MaterialApp wired for the kits — theme extensions, ProviderScope, toasts.
                  → lib/app.dart   needs widget_kit
  async-button    A button that shows a spinner for the duration of an async call.
                  → lib/widgets/async_button.dart   needs widget_kit
  confirm-dialog  A yes/no confirmation sheet for destructive actions.
                  → lib/widgets/confirm.dart   needs widget_kit
  otp-screen      A full OTP verification screen with resend cooldown.
                  → lib/features/auth/otp_screen.dart   needs otp_kit

  fkit snippet create &lt;name&gt; to add one</code></pre>

<p>
  Each entry shows where the file will land and which kits it imports. The command
  is also available as <code>fkit sn ls</code>.
</p>

<h2>Creating one</h2>

<pre><code>fkit snippet create app-shell
fkit snippet create async-button confirm-dialog   # several at once
fkit snippet create                               # pick from a list
fkit sn c app-shell                               # short form</code></pre>

<p>
  With no names and an interactive terminal you get a multi-select. In CI, where
  there is nothing to prompt, the command stops and asks you to name them.
</p>

<h3>What the output tells you</h3>

<pre><code>✓ Created lib/features/auth/otp_screen.dart

  ! needs otp_kit
    fkit add otp_kit
  ! needs hooks_riverpod
    flutter pub add hooks_riverpod</code></pre>

<p>
  A snippet that imports something your project does not have compiles into a wall
  of "target of URI doesn't exist" errors that name the file rather than the cause.
  So the command checks first — and separates the two kinds of missing dependency,
  because they install differently:
</p>

<table>
  <thead><tr><th>Missing</th><th>Fix</th><th>Why it differs</th></tr></thead>
  <tbody>
    <tr>
      <td>A kit</td>
      <td><code>fkit add &lt;kit&gt;</code></td>
      <td>Kits are git dependencies from the monorepo, not on pub.dev.</td>
    </tr>
    <tr>
      <td>A pub.dev package</td>
      <td><code>flutter pub add &lt;package&gt;</code></td>
      <td>
        A kit depending on a package is not enough. Importing it in
        <em>your</em> code needs your own direct entry.
      </td>
    </tr>
  </tbody>
</table>

<h3>Flags</h3>

<table>
  <thead><tr><th>Flag</th><th>What it does</th></tr></thead>
  <tbody>
    <tr>
      <td><code>--output</code>, <code>-o</code></td>
      <td>Write somewhere other than the default path. Valid with one snippet only — several cannot share a path, and the command refuses rather than overwriting each with the next.</td>
    </tr>
    <tr>
      <td><code>--force</code>, <code>-f</code></td>
      <td>Overwrite an existing file. Without it, the file is left alone and reported.</td>
    </tr>
  </tbody>
</table>

<h2>What each snippet gives you</h2>

<h3>app-shell</h3>
<p>
  A <code>MaterialApp</code> with the three things that fail quietly when missing:
  the theme extensions, a <code>ProviderScope</code> for the Riverpod-backed kits,
  and the toast host that <code>UIHelper.showToast</code> needs mounted above the
  navigator. Each carries a comment explaining what breaks without it. Start here on
  a new project, then replace the placeholder theme with what
  <a href="#/theme">fkit theme</a> generates.
</p>

<h3>async-button</h3>
<p>
  A button that runs a <code>Future</code> and stays in its loading state until it
  completes, including the <code>mounted</code> check for the case where the user
  navigates away mid-save. Useful mostly as a demonstration that
  <code>AppButton</code> already ignores taps while <code>isLoading</code> is true —
  you do not need to null out the callback or guard against double submission.
</p>

<h3>confirm-dialog</h3>
<p>
  A <code>confirmAction</code> function returning a plain <code>bool</code>:
  dismissing the dialog resolves to <code>false</code> rather than
  <code>null</code>, so call sites do not need to handle three outcomes. Ships with
  an example call site you delete once you have copied the function.
</p>

<h3>otp-screen</h3>
<p>
  A complete verification screen: the code field, the resend button with its
  cooldown, and a verify action that pushes a failure back into the field so it
  shows its error styling. It also demonstrates the part of otp_kit that is easy to
  get wrong — the field and the resend button take
  <strong>two different config objects</strong>, and the cooldown's
  <code>namespace</code> is the key it persists under, so separate flows need
  separate namespaces or one countdown blocks the other.
</p>

<h2>How snippets stay correct</h2>
<p>
  The snippets are not maintained as strings inside the CLI. Each one lives as a
  real Dart file in the monorepo's documentation app, where it is compiled against
  the actual kits on every analysis run, and the CLI's copy is generated from those
  files. A snippet that stopped matching a kit's API fails the build before it can
  be shipped to you.
</p>
<p>
  That guarantee covers the moment the snippet was published. Once it is in your
  project it is a normal file, and a later kit upgrade can break it exactly as it
  would break code you wrote yourself.
</p>

<h2>What snippets are not</h2>
<ul>
  <li>
    <strong>Not tracked or updatable.</strong> There is no command that re-syncs a
    file you have. Re-running <code>create --force</code> overwrites it wholesale,
    discarding your changes.
  </li>
  <li>
    <strong>Not a scaffolding system.</strong> One file each, no templating, no
    project-wide generation, no variable substitution — the package name in an
    import is the one thing you may need to change by hand.
  </li>
  <li>
    <strong>Not complete features.</strong> <code>otp-screen</code> hands you the
    UI and the state wiring; sending the SMS and verifying the code against your
    backend are the callbacks you supply.
  </li>
</ul>

<h2>Things that go wrong</h2>

<h3>"Unknown snippet: otp"</h3>
<p>
  Names are matched exactly, in the kebab-case form <code>fkit snippet ls</code>
  prints — <code>otp-screen</code>, not <code>otp</code> or <code>otp_screen</code>.
</p>

<h3>"Cannot write several snippets to one path."</h3>
<p>
  <code>--output</code> names a single file, so it cannot be combined with more than
  one snippet. Drop the flag to use each snippet's default path, or create them one
  at a time.
</p>

<h3>"lib/app.dart already exists — pass --force to overwrite it."</h3>
<p>
  Nothing was written. When several snippets are named at once, the others are still
  created; only the conflicting one is skipped.
</p>

<h3>The file is created but the import of my own project fails</h3>
<p>
  Snippets that reference sibling files use the package name of the project they
  were written in. Change the import to your own package name — the one at the top
  of your <code>pubspec.yaml</code>.
</p>
`,
});
