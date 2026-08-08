DOCS.page({
  slug: 'styles',
  group: 'commands',
  title: 'Generating widget styles',
  summary: 'fkit style create — per-widget theming boilerplate with every value spelled out.',
  html: `
<h1>Generating widget styles</h1>
<p class="lede">
  <code>fkit style create</code> writes the styling code for a single widget,
  with every value spelled out rather than inherited, so you can change one
  thing without reconstructing everything around it.
</p>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">style versus theme</span>
    <p>
      <a href="#/theme"><code>fkit theme</code></a> writes <strong>one</strong>
      file wiring the whole kit to a brand colour. Run it once, at the start.<br>
      <code>fkit style create</code> writes <strong>one widget's</strong> styling
      as an editable function. Reach for it when the generated theme is close but
      one widget needs to differ.
    </p>
    <p>
      They are not alternatives you have to choose between — a project usually
      has the theme file, and a style file for the one or two widgets it fusses
      over.
    </p>
  </div>
</div>

<h2>Listing what can be generated</h2>

<pre><code>fkit style ls</code></pre>

<pre><code>  app-button  All ten AppButton styles, written out so any of them can be edited.
              → lib/theme/styles/app_button_style.dart   needs widget_kit
  feedback    Empty and error states, loading colour, shimmer, media placeholders.
              → lib/theme/styles/feedback_style.dart   needs widget_kit
  input       AppTextFormField's borders, colours and text sizes.
              → lib/theme/styles/input_style.dart   needs widget_kit
  surface     Dialog and bottom-sheet corner radii and backgrounds.
              → lib/theme/styles/surface_style.dart   needs widget_kit</code></pre>

<h2>Creating one</h2>

<pre><code>fkit style create app-button
fkit style create input surface       # several at once
fkit style create --all               # every style
fkit style create                     # pick from a list
fkit st c app-button                  # short form</code></pre>

<p>
  Names are matched loosely on case and separators, so
  <code>app-button</code>, <code>app_button</code> and <code>AppButton</code> all
  resolve to the same style.
</p>

<h3>Flags</h3>

<table>
  <thead><tr><th>Flag</th><th>What it does</th></tr></thead>
  <tbody>
    <tr><td><code>--all</code>, <code>-a</code></td><td>Create every style. Cannot be combined with names.</td></tr>
    <tr><td><code>--force</code>, <code>-f</code></td><td>Overwrite an existing file.</td></tr>
    <tr><td><code>--output</code>, <code>-o</code></td><td>Write somewhere else. One style only.</td></tr>
  </tbody>
</table>

<h2>What you get</h2>
<p>
  A function, not a constant. It takes the colours as parameters, so the same
  file can serve a light and a dark theme, and you edit the body rather than
  regenerating:
</p>

<pre><code>AppButtonThemeExtension appButtonTheme({
  required Color primary,
  required Color onPrimary,
  required Color tonal,
  required Color onTonal,
  Color surface = const Color(0xFFFFFFFF),
  Color iconForeground = const Color(0xFF64748B),
  Color iconBorder = const Color(0xFFE2E8F0),
}) {
  final overlay = primary.withValues(alpha: 0.08);
  // …

  return AppButtonThemeExtension(
    filled: AppButtonStyle(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      overlayColor: overlay,
    ),
    // …the other nine, all written out
  );
}</code></pre>

<h2 id="composing">Composing them</h2>
<p>
  This is where widget_kit differs from a library where every widget owns its own
  style object, and it is worth understanding before you generate more than one.
</p>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">Most widgets share one extension</span>
    <p>
      Inputs, dialogs, sheets, feedback states, shimmer and media placeholders
      all read the <em>same</em> <code>WidgetKitTheme</code>, and a
      <code>ThemeData</code> can hold only one of each extension type. So those
      styles are generated as functions that take a base and return it modified,
      and you chain them.
    </p>
    <p>
      <code>AppButton</code> is the exception: it has its own
      <code>AppButtonThemeExtension</code> and sits alongside, not inside.
    </p>
  </div>
</div>

<pre><code>import 'package:flutter/material.dart';
import 'package:widget_kit/widget_kit.dart';

import 'theme/styles/app_button_style.dart';
import 'theme/styles/feedback_style.dart';
import 'theme/styles/input_style.dart';
import 'theme/styles/surface_style.dart';

const brand = Color(0xFF104C65);

ThemeData buildTheme() =&gt; ThemeData.light().copyWith(
      extensions: &lt;ThemeExtension&lt;dynamic&gt;&gt;[
        // The WidgetKitTheme styles chain — there can only be one of them.
        feedbackStyle(
          surfaceStyle(
            inputStyle(WidgetKitTheme.fallback, primary: brand),
          ),
          primary: brand,
        ),
        // AppButton has its own extension, so it sits beside them.
        appButtonTheme(
          primary: brand,
          onPrimary: Colors.white,
          tonal: const Color(0xFFDEE6E9),
          onTonal: const Color(0xFF0D3E53),
        ),
      ],
    );</code></pre>

<p>
  Start the chain from <code>WidgetKitTheme.fallback</code> — the kit's own
  defaults — so anything you do not set keeps a sensible value instead of
  becoming null.
</p>

<h2>How these stay correct</h2>
<p>
  Like the snippets, the style templates are not maintained as strings inside the
  CLI. Each is a real Dart file in the monorepo's documentation app, compiled
  against the actual kits on every analysis run. A style that stopped matching a
  kit's API fails the build before it can reach you.
</p>

<h2>What this command is not</h2>
<ul>
  <li>
    <strong>Not a replacement for <code>fkit theme</code>.</strong> It styles one
    widget; the theme command wires the whole kit at once.
  </li>
  <li>
    <strong>Not tracked.</strong> Once written, the file is yours. Nothing
    re-syncs it, and <code>--force</code> overwrites it wholesale.
  </li>
  <li>
    <strong>Not able to add a style that does not exist yet.</strong> The list
    covers widget_kit's themable surfaces; other kits do their theming
    differently and are not in it.
  </li>
</ul>

<h2>Things that go wrong</h2>

<h3>"Unknown style: button"</h3>
<p>
  Names are matched after folding case and separators, but not guessed. Run
  <code>fkit style ls</code>; the button style is <code>app-button</code>.
</p>

<h3>"Pass --all or a list of names, not both."</h3>
<p><code>--all</code> already means everything, so naming styles alongside it is ambiguous.</p>

<h3>Setting a field had no effect</h3>
<p>
  Check which extension owns it. <code>WidgetKitTheme</code>'s button fields —
  <code>primaryButtonColor</code>, <code>buttonBorderRadius</code> — are read by
  other widgets, never by <code>AppButton</code>. See
  <a href="#/widget-kit-app-button">AppButton</a>.
</p>

<h3>Only the last style in my chain applied</h3>
<p>
  Each function returns a modified copy, so they must be nested, not listed. If
  you pass two separate <code>WidgetKitTheme</code> values in the
  <code>extensions</code> list, Flutter keeps one of them and the other is lost.
</p>
`,
});
