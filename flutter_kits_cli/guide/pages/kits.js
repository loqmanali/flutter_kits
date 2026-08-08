DOCS.page({
  slug: 'kits',
  group: 'commands',
  title: 'Adding and removing kits',
  summary: 'ls, add and remove — the commands that change pubspec.yaml, and how pinning works.',
  html: `
<h1>Adding and removing kits</h1>
<p class="lede">
  Three commands cover the whole lifecycle: <code>ls</code> to see what exists,
  <code>add</code> to depend on one, <code>remove</code> to stop. All three touch
  only the <code>dependencies</code> section of <code>pubspec.yaml</code>.
</p>

<h2>Listing the kits</h2>

<pre><code>fkit ls              # everything
fkit ls --installed  # only what this project uses
fkit ls -i           # same, short</code></pre>

<p>
  The header line names the release the CLI will pin to. If it says
  <code>pinned at v2.0.0</code>, that is the tag <code>add</code> writes.
</p>

<p>
  <code>ls</code> works outside a project too. With no <code>pubspec.yaml</code> to
  read it simply shows nothing as installed, rather than refusing to run — useful
  for browsing before you have decided where the code is going.
</p>

<h2>Adding kits</h2>

<pre><code>fkit add widget_kit
fkit add widget_kit otp_kit storage_kit   # several at once
fkit add                                  # no names: pick from a list</code></pre>

<p>
  With no arguments and an interactive terminal, <code>add</code> shows a
  multi-select of the kits you do not already have. Space toggles, Enter confirms.
  In a script or CI, where there is no terminal to prompt from, it stops and tells
  you to name them instead of hanging.
</p>

<h3>What it writes</h3>
<p>For each kit, a git dependency pinned to the current release tag:</p>

<pre><code>  widget_kit:
    git:
      url: https://github.com/loqmanali/flutter_kits.git
      path: widget_kit
      ref: v2.0.0</code></pre>

<div class="callout tip">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 18h6M10 21h4M12 3a6 6 0 00-3.5 10.9c.6.4.9 1 .9 1.6v.5h5.2v-.5c0-.6.3-1.2.9-1.6A6 6 0 0012 3z"/></svg>
  <div>
    <span class="callout-title">Your pubspec keeps its shape</span>
    <p>
      The edit is made through a YAML editor that preserves the rest of the
      document, so comments, blank lines, key order and quoting style all survive.
      Only the new entry appears in the diff.
    </p>
  </div>
</div>

<h3>Setup notes</h3>
<p>
  Some kits need more than a dependency line — a platform permission, a wrapper
  widget, a configured Firebase project. <code>add</code> prints those immediately
  after installing, because they are the things that make a kit appear broken when
  it is merely unconfigured. For example:
</p>

<pre><code>  ! otp_kit
    Built on hooks_riverpod — wrap your app in a ProviderScope before using it.</code></pre>

<h3>Useful flags</h3>

<table>
  <thead><tr><th>Flag</th><th>What it does</th></tr></thead>
  <tbody>
    <tr>
      <td><code>--dry-run</code></td>
      <td>Print the resulting <code>pubspec.yaml</code> and write nothing. Good for seeing the change before you accept it.</td>
    </tr>
    <tr>
      <td><code>--force</code>, <code>-f</code></td>
      <td>Replace a kit that is already listed. Without it, an existing entry is left alone and reported.</td>
    </tr>
    <tr>
      <td><code>--no-pub-get</code></td>
      <td>Edit the file only. Use when adding several things and fetching once at the end.</td>
    </tr>
    <tr>
      <td><code>--ref &lt;tag&gt;</code></td>
      <td>Pin to a specific tag, branch or commit instead of the current release.</td>
    </tr>
    <tr>
      <td><code>--path &lt;dir&gt;</code></td>
      <td>Use local path dependencies rooted at <code>&lt;dir&gt;</code> instead of git. For working on the kits themselves.</td>
    </tr>
  </tbody>
</table>

<h2>Choosing what to pin to</h2>
<p>
  By default every kit is pinned to the newest release tag the CLI knows about. That
  is the right choice almost always: it is reproducible, and everyone who clones
  your project gets the same code.
</p>

<h3>Upgrading</h3>
<p>
  There is no upgrade command — an upgrade is a re-pin. Install a newer fkit so it
  knows the new tag, then:
</p>

<pre><code>fkit add widget_kit --force</code></pre>

<p>
  To move several kits at once, name them all in one command. To move to a specific
  release rather than the newest, add <code>--ref</code>.
</p>

<h3>Working on the kits themselves</h3>
<p>
  If you are changing a kit and want your app to pick the change up without
  committing and re-tagging, switch to path dependencies:
</p>

<pre><code>fkit add widget_kit --force --path ../flutter_kits</code></pre>

<pre><code>  widget_kit:
    path: ../flutter_kits/widget_kit</code></pre>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">Switch back before committing</span>
    <p>
      A path dependency points at <em>your</em> disk. Committed, it breaks the build
      for everyone else and for CI, with an error about a missing directory rather
      than anything that names the real cause.
    </p>
    <p>
      <code>fkit doctor</code> flags path dependencies for exactly this reason. To
      go back: <code>fkit add widget_kit --force</code> with no <code>--path</code>.
    </p>
  </div>
</div>

<h2>Removing kits</h2>

<pre><code>fkit remove widget_kit
fkit rm widget_kit otp_kit
fkit remove                 # no names: pick from what is installed</code></pre>

<p>
  This deletes the dependency entry and re-runs <code>flutter pub get</code>, which
  matters: leaving a stale <code>pubspec.lock</code> behind is what produces
  "package not found" on the next build. Naming a kit that is not a dependency is
  reported and otherwise ignored.
</p>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">What removing does not do</span>
    <p>
      It does not touch your Dart code. Imports of the removed package stay where
      they are and stop compiling, which is the honest outcome — fkit cannot know
      what you meant to replace them with. Delete the imports yourself, or add the
      kit back.
    </p>
    <p>
      It also leaves generated and copied files alone:
      <code>lib/theme/kits_theme.dart</code> and any snippets remain, because they
      are yours once written.
    </p>
  </div>
</div>

<h2>What these commands are not</h2>
<ul>
  <li>
    <strong>Not a package manager.</strong> They edit one section of
    <code>pubspec.yaml</code> and shell out to <code>flutter pub get</code>. Version
    conflicts, overrides and the lockfile stay pub's business.
  </li>
  <li>
    <strong>Not able to add ordinary pub.dev packages.</strong> <code>fkit add</code>
    only knows the kits in its catalogue. For anything else, use
    <code>flutter pub add</code>.
  </li>
  <li>
    <strong>Not aware of what your code imports.</strong> Removing a kit you still
    use is allowed; the compiler is what tells you.
  </li>
</ul>

<h2>Things that go wrong</h2>

<h3>"Unknown kit: widgetkit"</h3>
<p>
  The name did not match the catalogue. fkit suggests the closest match, so a
  missing underscore or a plural is usually obvious from the message. Run
  <code>fkit ls</code> for the exact spellings — they are the package names, always
  lowercase with underscores.
</p>

<h3>"widget_kit is already in pubspec.yaml — pass --force to replace it"</h3>
<p>
  Nothing was changed, deliberately: overwriting an existing pin silently would lose
  a deliberate <code>--ref</code> or a path dependency you are mid-way through
  using. Re-run with <code>--force</code> if replacing it is what you meant.
</p>

<h3>"flutter not found on PATH"</h3>
<p>
  The pubspec edit succeeded; only the fetch was skipped. Run
  <code>flutter pub get</code> yourself. This normally means fkit was run from an
  environment where Flutter is not installed, such as a bare CI image.
</p>

<h3>pub get fails with a git error after adding</h3>
<p>
  Usually the ref. Run <a href="#/doctor">fkit doctor</a> — a <code>ref:</code> that
  looks like a kit version rather than a release tag is the first thing it checks.
</p>
`,
});
