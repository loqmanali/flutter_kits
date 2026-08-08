DOCS.page({
  slug: 'reference',
  group: 'ref',
  title: 'Command reference',
  summary: 'Every command, alias and flag, plus the kits and snippets that ship today.',
  html: `
<h1>Command reference</h1>
<p class="lede">
  Everything <code>fkit</code> accepts, in one place. <code>fkit --help</code> and
  <code>fkit help &lt;command&gt;</code> print the same information at the terminal.
</p>

<h2>Commands</h2>

<table>
  <thead><tr><th>Command</th><th>Aliases</th><th>Does</th></tr></thead>
  <tbody>
    <tr><td><code>fkit ls</code></td><td><code>list</code></td><td>List the kits.</td></tr>
    <tr><td><code>fkit add &lt;kit...&gt;</code></td><td><code>a</code></td><td>Add kits to <code>pubspec.yaml</code>.</td></tr>
    <tr><td><code>fkit remove &lt;kit...&gt;</code></td><td><code>rm</code></td><td>Remove kits from <code>pubspec.yaml</code>.</td></tr>
    <tr><td><code>fkit theme</code></td><td>—</td><td>Generate the theme extensions.</td></tr>
    <tr><td><code>fkit snippet ls</code></td><td><code>sn list</code></td><td>List the snippets.</td></tr>
    <tr><td><code>fkit snippet create &lt;name...&gt;</code></td><td><code>sn c</code></td><td>Copy snippet files in.</td></tr>
    <tr><td><code>fkit style ls</code></td><td><code>st list</code></td><td>List the widget styles.</td></tr>
    <tr><td><code>fkit style create &lt;name...&gt;</code></td><td><code>st c</code></td><td>Generate a widget's style boilerplate.</td></tr>
    <tr><td><code>fkit doctor</code></td><td>—</td><td>Check the setup.</td></tr>
  </tbody>
</table>

<h2>Flags</h2>

<h3>fkit ls</h3>
<table>
  <thead><tr><th>Flag</th><th>Default</th><th>Does</th></tr></thead>
  <tbody>
    <tr><td><code>--installed</code>, <code>-i</code></td><td>off</td><td>Show only kits this project depends on.</td></tr>
  </tbody>
</table>

<h3>fkit add</h3>
<table>
  <thead><tr><th>Flag</th><th>Default</th><th>Does</th></tr></thead>
  <tbody>
    <tr><td><code>--force</code>, <code>-f</code></td><td>off</td><td>Replace an entry that already exists.</td></tr>
    <tr><td><code>--dry-run</code></td><td>off</td><td>Print the resulting pubspec; write nothing.</td></tr>
    <tr><td><code>--pub-get</code></td><td><strong>on</strong></td><td>Run <code>flutter pub get</code> after editing. Disable with <code>--no-pub-get</code>.</td></tr>
    <tr><td><code>--ref &lt;ref&gt;</code></td><td>current release tag</td><td>Pin to a tag, branch or commit.</td></tr>
    <tr><td><code>--path &lt;dir&gt;</code></td><td>—</td><td>Use path dependencies rooted at <code>&lt;dir&gt;</code> instead of git.</td></tr>
  </tbody>
</table>

<h3>fkit remove</h3>
<table>
  <thead><tr><th>Flag</th><th>Default</th><th>Does</th></tr></thead>
  <tbody>
    <tr><td><code>--pub-get</code></td><td><strong>on</strong></td><td>Run <code>flutter pub get</code> after editing.</td></tr>
  </tbody>
</table>

<h3>fkit theme</h3>
<table>
  <thead><tr><th>Flag</th><th>Default</th><th>Does</th></tr></thead>
  <tbody>
    <tr><td><code>--primary &lt;hex&gt;</code>, <code>-p</code></td><td>prompts</td><td>The brand colour.</td></tr>
    <tr><td><code>--output &lt;path&gt;</code>, <code>-o</code></td><td><code>lib/theme/kits_theme.dart</code></td><td>Where to write it.</td></tr>
    <tr><td><code>--force</code>, <code>-f</code></td><td>off</td><td>Overwrite without asking.</td></tr>
  </tbody>
</table>

<h3>fkit style create</h3>
<table>
  <thead><tr><th>Flag</th><th>Default</th><th>Does</th></tr></thead>
  <tbody>
    <tr><td><code>--all</code>, <code>-a</code></td><td>off</td><td>Create every style.</td></tr>
    <tr><td><code>--output &lt;path&gt;</code>, <code>-o</code></td><td>the style's own path</td><td>Where to write it. One style only.</td></tr>
    <tr><td><code>--force</code>, <code>-f</code></td><td>off</td><td>Overwrite an existing file.</td></tr>
  </tbody>
</table>

<h3>fkit snippet create</h3>
<table>
  <thead><tr><th>Flag</th><th>Default</th><th>Does</th></tr></thead>
  <tbody>
    <tr><td><code>--output &lt;path&gt;</code>, <code>-o</code></td><td>the snippet's own path</td><td>Where to write it. One snippet only.</td></tr>
    <tr><td><code>--force</code>, <code>-f</code></td><td>off</td><td>Overwrite an existing file.</td></tr>
  </tbody>
</table>

<h2>Behaviour worth knowing</h2>

<table>
  <thead><tr><th>Situation</th><th>What happens</th></tr></thead>
  <tbody>
    <tr>
      <td>Run from a subdirectory</td>
      <td>fkit walks up to the nearest <code>pubspec.yaml</code>, like git.</td>
    </tr>
    <tr>
      <td>Run with no project anywhere above</td>
      <td>Every command stops with a message. <code>ls</code> is the exception — it still lists, marking nothing as installed.</td>
    </tr>
    <tr>
      <td>Run with no terminal (CI, piped output)</td>
      <td>Commands that would prompt stop and tell you what to name instead of hanging.</td>
    </tr>
    <tr>
      <td>An unknown kit name</td>
      <td>Nothing is installed — not even the valid names in the same command — and the closest match is suggested.</td>
    </tr>
    <tr>
      <td>An existing file or entry</td>
      <td>Skipped and reported. Only <code>--force</code> overwrites.</td>
    </tr>
    <tr>
      <td>Flutter missing from <code>PATH</code></td>
      <td>The file edit still succeeds; only the <code>pub get</code> is skipped.</td>
    </tr>
  </tbody>
</table>

<h2>The kits</h2>
<p>
  Twenty packages. <code>fkit ls</code> prints the current list with versions; this
  is what shipped with release <code>v2.0.0</code>.
</p>

<table>
  <thead><tr><th>Kit</th><th>What it covers</th></tr></thead>
  <tbody>
    <tr><td><code>animation_kit</code></td><td>Reusable animation widgets and utilities.</td></tr>
    <tr><td><code>api_kit</code></td><td>Dio-based networking: token refresh, typed failures, error mapping.</td></tr>
    <tr><td><code>carousel_kit</code></td><td>Image and widget carousels, auto-scroll, indicators, RTL.</td></tr>
    <tr><td><code>commerce_kit</code></td><td>A standalone e-commerce module.</td></tr>
    <tr><td><code>context_menu_kit</code></td><td>Tap or long-press menus with screen-aware positioning and submenus.</td></tr>
    <tr><td><code>deep_link_kit</code></td><td>Parses custom-scheme and universal links into structured data.</td></tr>
    <tr><td><code>dropdown_menu_kit</code></td><td>Overlay dropdowns with checkboxes, radios, labels and separators.</td></tr>
    <tr><td><code>firebase_kit</code></td><td>Auth, Firestore CRUD, Firebase AI, Riverpod providers.</td></tr>
    <tr><td><code>force_update_gate</code></td><td>Gates the app behind an update screen when a newer store version exists.</td></tr>
    <tr><td><code>local_db_kit</code></td><td>Drift/sqlite3 plumbing: migrations, background open, foreign keys.</td></tr>
    <tr><td><code>localization_kit</code></td><td>Locale state, persistence, RTL handling, API-driven language lists.</td></tr>
    <tr><td><code>logging_kit</code></td><td>A small shared logger with level filtering and coloured output.</td></tr>
    <tr><td><code>map_kit</code></td><td>Location picker and delivery tracking with routing.</td></tr>
    <tr><td><code>navigation_kit</code></td><td>A customizable bottom navigation bar with animated indicators.</td></tr>
    <tr><td><code>notify_kit</code></td><td>FCM plus local notifications behind one init, with unified tap routing.</td></tr>
    <tr><td><code>otp_kit</code></td><td>OTP input: validation, theming, RTL, paste handling, resend cooldown.</td></tr>
    <tr><td><code>selection_kit</code></td><td>Themable radio and checkbox groups with validation.</td></tr>
    <tr><td><code>storage_kit</code></td><td>Key-value storage over SharedPreferences or Hive behind one API.</td></tr>
    <tr><td><code>system_ui_kit</code></td><td>Syncs status and navigation bar colours with your top surfaces.</td></tr>
    <tr><td><code>widget_kit</code></td><td>Buttons, inputs, dialogs, feedback, media, menus, pickers, effects.</td></tr>
  </tbody>
</table>

<h2>The snippets</h2>

<table>
  <thead><tr><th>Name</th><th>Lands at</th><th>Needs</th></tr></thead>
  <tbody>
    <tr><td><code>app-shell</code></td><td><code>lib/app.dart</code></td><td>widget_kit, hooks_riverpod</td></tr>
    <tr><td><code>async-button</code></td><td><code>lib/widgets/async_button.dart</code></td><td>widget_kit</td></tr>
    <tr><td><code>confirm-dialog</code></td><td><code>lib/widgets/confirm.dart</code></td><td>widget_kit</td></tr>
    <tr><td><code>otp-screen</code></td><td><code>lib/features/auth/otp_screen.dart</code></td><td>otp_kit, hooks_riverpod</td></tr>
  </tbody>
</table>

<h2>The styles</h2>

<table>
  <thead><tr><th>Name</th><th>Lands at</th><th>Covers</th></tr></thead>
  <tbody>
    <tr><td><code>app-button</code></td><td><code>lib/theme/styles/app_button_style.dart</code></td><td>All ten AppButton styles</td></tr>
    <tr><td><code>input</code></td><td><code>lib/theme/styles/input_style.dart</code></td><td>AppTextFormField</td></tr>
    <tr><td><code>surface</code></td><td><code>lib/theme/styles/surface_style.dart</code></td><td>Dialogs and bottom sheets</td></tr>
    <tr><td><code>feedback</code></td><td><code>lib/theme/styles/feedback_style.dart</code></td><td>Empty/error states, shimmer, media</td></tr>
  </tbody>
</table>

<h2>Keeping the CLI current</h2>
<p>
  The kit list, the release tag and the snippets are compiled into the CLI, because
  it runs inside your project and cannot read the monorepo at the time you use it.
  Two generators keep that baked-in copy honest. Run them from
  <code>packages/flutter_kits_cli</code> after adding a kit or cutting a release:
</p>

<pre><code>dart run tool/sync_catalog.dart    # kits + the newest release tag
dart run tool/sync_templates.dart  # snippets + styles, from the docs app</code></pre>

<p>
  Then reinstall so your shell picks up the change:
</p>

<pre><code>dart pub global activate --source git \\
  https://github.com/loqmanali/flutter_kits.git --git-path flutter_kits_cli</code></pre>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">Where the facts come from</span>
    <p>
      <code>sync_catalog</code> reads each kit's own <code>pubspec.yaml</code> for
      its name, version and description, and the newest plain <code>v*</code> git
      tag for the ref. <code>sync_snippets</code> reads the snippet sources, which
      live in the documentation app where they are compiled against the real kits.
      Neither list is written by hand, so neither can drift from what is actually
      in the repository.
    </p>
  </div>
</div>
`,
});
