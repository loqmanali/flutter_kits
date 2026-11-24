DOCS.page({
  slug: 'introduction',
  group: 'start',
  title: 'Introduction',
  summary: 'What fkit is, what it writes to your project, and how the kits are versioned.',
  html: `
<h1>Introduction</h1>
<p class="lede">
  <strong>fkit</strong> is the command-line tool for the flutter_kits monorepo. It
  puts kits into your project's dependencies, generates the theme code those kits
  expect, drops in ready-made screens, and tells you when the wiring is wrong.
</p>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">What it touches in your project</span>
    <p>
      <strong>Edits:</strong> <span class="pill perm">pubspec.yaml</span> — only the
      <code>dependencies</code> section. Your comments, ordering and other packages
      are left exactly as they were.<br>
      <strong>Creates:</strong> <span class="pill perm">lib/theme/kits_theme.dart</span>
      and any snippet files you ask for.<br>
      <strong>Runs:</strong> <span class="pill perm">flutter pub get</span> after
      adding or removing a kit, unless you pass <code>--no-pub-get</code>.
    </p>
    <p>
      It never edits your existing Dart code, never deletes files it did not
      create, and never overwrites anything without <code>--force</code>.
    </p>
  </div>
</div>

<h2>Installing it</h2>
<p>
  fkit is a Dart command-line program. Install it once, globally, and it works in
  every Flutter project on your machine:
</p>

<pre><code>dart pub global activate --source git \\
  https://github.com/loqmanali/flutter_kits.git --git-path flutter_kits_cli</code></pre>

<p>
  Then check that it answers:
</p>

<pre><code>fkit --help</code></pre>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">If the shell says "command not found"</span>
    <p>
      Dart installs global executables into <code>~/.pub-cache/bin</code>, which is
      not on most shells' <code>PATH</code> by default. Add it to your shell profile
      — <code>~/.zshrc</code> on macOS, <code>~/.bashrc</code> on most Linux —
      and open a new terminal:
    </p>
    <pre><code>export PATH="$PATH:$HOME/.pub-cache/bin"</code></pre>
  </div>
</div>

<h2>Two kinds of thing it installs</h2>
<p>
  fkit deals in two things, and the difference decides what happens when the
  monorepo changes later.
</p>

<table>
  <thead>
    <tr><th>&nbsp;</th><th>Kits</th><th>Snippets</th></tr>
  </thead>
  <tbody>
    <tr>
      <th>What it is</th>
      <td>A package your project depends on.</td>
      <td>A source file copied into your project.</td>
    </tr>
    <tr>
      <th>Where it lands</th>
      <td><code>pubspec.yaml</code>, as a git dependency.</td>
      <td><code>lib/</code>, as an ordinary Dart file.</td>
    </tr>
    <tr>
      <th>Who owns it after</th>
      <td>The monorepo. You get updates by changing the pinned ref.</td>
      <td>You. Edit it, rename it, delete half of it.</td>
    </tr>
    <tr>
      <th>Effect of an upgrade</th>
      <td>New code arrives when you re-pin.</td>
      <td>Nothing. fkit never revisits a file it wrote.</td>
    </tr>
  </tbody>
</table>

<h2>How the kits are versioned</h2>
<p>
  This is the one piece of background worth reading before you install anything,
  because getting it wrong produces a confusing failure.
</p>
<p>
  The kits live in one repository, and that repository is tagged as a whole. Tags
  look like <code>v2.0.0</code>. Each kit <em>also</em> carries its own version in
  its <code>pubspec.yaml</code> — <code>widget_kit</code> is at <code>1.2.0</code>,
  <code>otp_kit</code> at <code>3.2.0</code> — and those two numbering schemes are
  unrelated.
</p>

<div class="callout danger">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">A kit's version is not a tag you can pin to</span>
    <p>
      Writing <code>ref: v3.2.0</code> because otp_kit is at 3.2.0 fails: no such
      tag exists. <code>flutter pub get</code> reports that it cannot resolve the
      git reference, which reads like a network or permissions problem rather than
      a typo.
    </p>
    <p>
      <strong>widget_kit 1.2.0 ships inside the tag <code>v2.0.0</code>.</strong>
      That tag is what you pin to. <code>fkit add</code> writes it for you, and
      <a href="#/doctor">fkit doctor</a> catches it when something else wrote the
      wrong one.
    </p>
  </div>
</div>

<h2>What is in this guide</h2>

<ul class="cards">
  <li><a href="#/getting-started"><strong>Getting started</strong><span>Install a kit, generate a theme, and run the app — the first five minutes.</span></a></li>
  <li><a href="#/kits"><strong>Adding and removing kits</strong><span>ls, add and remove: the commands that change pubspec.yaml.</span></a></li>
  <li><a href="#/theme"><strong>Generating a theme</strong><span>Why widget_kit needs generated theme code, and what the command produces.</span></a></li>
  <li><a href="#/snippets"><strong>Using snippets</strong><span>Ready-made screens and widgets, copied into your project.</span></a></li>
  <li><a href="#/doctor"><strong>Checking your setup</strong><span>The five problems doctor finds, and how to fix each one.</span></a></li>
  <li><a href="#/styles"><strong>Generating widget styles</strong><span>Per-widget theming boilerplate, every value spelled out.</span></a></li>
  <li><a href="#/widget-kit-app-button"><strong>widget_kit reference</strong><span>Each widget with a live preview, copyable code and its API.</span></a></li>
  <li><a href="#/reference"><strong>Command reference</strong><span>Every command, alias and flag, in one table.</span></a></li>
  <li><a href="#/troubleshooting"><strong>Things that go wrong</strong><span>Error messages, what causes them, and what to do.</span></a></li>
</ul>
`,
});
