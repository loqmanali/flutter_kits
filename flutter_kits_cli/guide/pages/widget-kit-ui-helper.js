DOCS.page({
  slug: 'widget-kit-ui-helper',
  group: 'widget_kit',
  title: 'UIHelper',
  summary: 'Bottom sheets, dialogs and toasts behind one class — plus the wrapper without which toasts do nothing.',
  html: `
<h1>UIHelper</h1>

<p class="page-meta">
  <span class="pill">widget_kit</span>
  <span class="pill">Dialogs</span>
  <a href="https://github.com/loqmanali/flutter_kits/blob/main/widget_kit/lib/src/dialogs/ui_helper.dart">Source</a>
</p>

<p class="lede">
  Static methods for the three things every screen eventually needs: a bottom
  sheet, a dialog, and a transient message. Each one resolves its behaviour from
  the call site, then your app-wide config, then a built-in default.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="u1" data-on>Preview</button>
    <button data-tab="v1">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="u1" data-on>
      <div class="stage">
        <div class="phone">
          <div class="scrim"></div>
          <div class="sheet">
            <div class="handle"></div>
            <div class="sheet-head literal-black">
              <span class="lead"></span>
              <span class="title">Choose a city</span>
              <span class="x"><svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg></span>
            </div>
            <p class="d-msg">Your sheet content goes here.</p>
          </div>
        </div>
      </div>
    </div>
    <div data-pane="v1">
<pre><code>UIHelper.showBottomSheet&lt;String&gt;(
  context,
  showDragHandle: true,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SheetHeader(title: 'Choose a city'),
      // …your content
    ],
  ),
);</code></pre>
    </div>
  </div>
</div>

<div class="callout danger">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">Toasts do nothing without a ToastificationWrapper</span>
    <p>
      <code>showToast</code> — and therefore <code>showSnackBar</code>, which
      forwards to it — is wrapped in a <code>try</code>/<code>catch</code> that
      <strong>swallows the failure</strong>. With no toast host mounted above
      your app, nothing appears, nothing is logged, and nothing throws. The bug
      presents as "toasts don't work".
    </p>
    <p>Mount it once, above <code>MaterialApp</code>:</p>
    <pre><code>ToastificationWrapper(
  child: MaterialApp(/* … */),
)</code></pre>
    <p>
      <code>fkit snippet create app-shell</code> writes an app root that already
      has it.
    </p>
  </div>
</div>

<h2>CLI</h2>
<p>Install the kit:</p>

<pre><code>fkit add widget_kit</code></pre>

<p>To generate the dialog and sheet styling for customization:</p>

<pre><code>fkit style create surface</code></pre>

<h2>Usage</h2>

<pre><code>import 'package:widget_kit/widget_kit.dart';</code></pre>

<p>
  Everything is static — there is nothing to construct and nothing to dispose.
  <code>toastification</code> is re-exported by the kit, so the
  <code>ToastificationType</code> and <code>ToastificationStyle</code> enums
  come with the same import.
</p>

<h2 id="how-behaviour-resolves">How behaviour resolves</h2>
<p>
  Sheets and dialogs use the same three rungs as the inputs do, except the
  middle rung is <code>WidgetKitBehavior</code> — carried by a
  <code>WidgetKitScope</code> rather than a theme extension, because these are
  behaviour choices, not styling.
</p>

<table>
  <thead>
    <tr><th>Setting</th><th>1. Call site</th><th>2. WidgetKitBehavior</th><th>3. Built-in</th></tr>
  </thead>
  <tbody>
    <tr><td>Sheet is dismissible</td><td><code>isDismissible</code></td><td><code>bottomSheetIsDismissible</code></td><td><code>true</code></td></tr>
    <tr><td>Sheet respects safe area</td><td><code>useSafeArea</code></td><td><code>bottomSheetUseSafeArea</code></td><td><code>false</code></td></tr>
    <tr><td>Uses the root navigator</td><td><code>useRootNavigator</code></td><td><code>useRootNavigator</code></td><td><code>true</code></td></tr>
    <tr><td>Dialog barrier dismissible</td><td><code>barrierDismissible</code></td><td><code>dialogBarrierDismissible</code></td><td><code>true</code></td></tr>
  </tbody>
</table>

<pre><code>WidgetKitScope(
  config: const WidgetKitConfig(
    behavior: WidgetKitBehavior(
      bottomSheetUseSafeArea: true,
      dialogBarrierDismissible: false,
    ),
  ),
  child: const App(),
);</code></pre>

<h2>Bottom sheets</h2>

<pre><code>final city = await UIHelper.showBottomSheet&lt;String&gt;(
  context,
  showDragHandle: true,
  child: CityPicker(),
);
if (city != null) applyCity(city);</code></pre>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">Sheets are scroll-controlled by default</span>
    <p>
      <code>type</code> defaults to <code>BottomSheetType.scrollable</code>,
      which sets <code>isScrollControlled: true</code> — the sheet may grow past
      half the screen and a tall child will size to its content. Pass
      <code>BottomSheetType.normal</code> for the capped Material behaviour.
    </p>
    <p>
      <code>showDragHandle</code> defaults to <code>false</code>, so unless you
      pass it or add your own header there is no visible affordance for
      dismissing the sheet.
    </p>
  </div>
</div>

<h3>SheetHeader</h3>
<p>A title row with a close button that pops the sheet.</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="u2" data-on>Preview</button>
    <button data-tab="v2">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="u2" data-on>
      <div class="stage">
        <div class="sheet" style="width:300px">
          <div class="sheet-head literal-black">
            <span class="lead"></span>
            <span class="title">Delivery address</span>
            <span class="x"><svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg></span>
          </div>
        </div>
      </div>
    </div>
    <div data-pane="v2">
<pre><code>SheetHeader(
  title: 'Delivery address',
  // onClose defaults to Navigator.pop(context)
  onClose: () =&gt; Navigator.of(context).pop(),
  // leading defaults to a 24-wide spacer, which balances the close icon
  // so the title stays centred.
  leading: const Icon(Icons.arrow_back_rounded),
)</code></pre>
    </div>
  </div>
</div>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">SheetHeader is hardcoded black</span>
    <p>
      Both the title and the close icon are <code>Colors.black</code> in the
      widget's source, not a theme colour. On a dark sheet the header is
      effectively invisible. Until that is fixed in the kit, either wrap it in a
      light-coloured sheet or build the row yourself — it is a
      <code>Row</code> with a spacer, a <code>Text</code> and an icon.
    </p>
  </div>
</div>

<h2>Dialogs</h2>

<pre><code>final choice = await UIHelper.showDialogPicker&lt;String&gt;(
  context,
  child: const LanguageList(),
);</code></pre>

<p>
  Without a <code>dialogWidget</code>, the child is wrapped in a
  <code>DialogPicker</code>: corner radius from
  <code>WidgetKitTheme.dialogBorderRadius</code> (falling back to
  <code>16</code>), background from <code>dialogBackgroundColor</code>, clipped,
  and placed inside a <code>SingleChildScrollView</code> so long content
  scrolls rather than overflowing.
</p>

<p>
  Passing <code>dialogWidget</code> replaces that wrapper entirely — the
  <code>backgroundColor</code> and <code>insetPadding</code> arguments are then
  ignored, because nothing reads them.
</p>

<h3>AppWarningDialog</h3>
<p>A ready-made confirmation for destructive actions.</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="u3" data-on>Preview</button>
    <button data-tab="v3">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="u3" data-on>
      <div class="stage">
        <div class="dialog">
          <div class="row">
            <span class="badge"><svg viewBox="0 0 24 24"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg></span>
            <div>
              <p class="d-title">Delete account?</p>
              <p class="d-msg">This permanently removes your data. It cannot be undone.</p>
            </div>
          </div>
          <div class="actions">
            <span class="ab md outlined">Cancel</span>
            <span class="ab md filled" style="background:#B3261E">Delete</span>
          </div>
        </div>
      </div>
    </div>
    <div data-pane="v3">
<pre><code>// AppWarningDialog is a widget, not a method — show it yourself.
final confirmed = await showDialog&lt;bool&gt;(
  context: context,
  builder: (dialogContext) =&gt; AppWarningDialog(
    title: 'Delete account?',
    message: 'This permanently removes your data. It cannot be undone.',
    buttonText: 'Delete',
    cancelText: 'Cancel',
    // The confirm button does NOT pop for you — do it here.
    onPressed: () =&gt; Navigator.of(dialogContext).pop(true),
  ),
);

if (confirmed ?? false) await deleteAccount();</code></pre>
    </div>
  </div>
</div>

<p>
  The Cancel button pops on its own; the confirm button runs your
  <code>onPressed</code> and nothing else, so popping and returning a result are
  yours to do. <code>dangerColor</code> tints the icon, the icon's circular
  background (at <code>iconBackgroundOpacity</code>, default <code>0.08</code>)
  and the confirm button, and falls back to <code>colorScheme.error</code>.
</p>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">Its Cancel button inherits AppButton's defaults</span>
    <p>
      Cancel is an <code>AppButton</code> with the outlined style, so in a
      project that has not registered an
      <code>AppButtonThemeExtension</code> it renders in widget_kit's brand red
      — next to a red confirm button. Generate the button theme
      (<code>fkit style create app-button</code>) and the dialog looks right for
      free. See <a href="#/widget-kit-app-button">AppButton</a>.
    </p>
  </div>
</div>

<h2>Toasts</h2>
<p>
  Four semantic types. The chrome is toastification's <code>flatColored</code>
  style, which the kit passes by default: a tinted background with a 1.5px
  border in the type's colour.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="u4" data-on>Preview</button>
    <button data-tab="v4">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="u4" data-on>
      <div class="stage stack">
        <div class="toast success">
          <span class="dot"><svg viewBox="0 0 24 24"><path d="M4 12.5l5 5L20 6.5"/></svg></span>
          <span class="grow"><span class="t-title">Saved</span></span>
        </div>
        <div class="toast error">
          <span class="dot"><svg viewBox="0 0 24 24"><path d="M6 6l12 12M18 6L6 18"/></svg></span>
          <span class="grow"><span class="t-title">Could not save</span></span>
        </div>
        <div class="toast warning">
          <span class="dot"><svg viewBox="0 0 24 24"><path d="M12 8v5M12 16.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg></span>
          <span class="grow"><span class="t-title">Your session expires soon</span></span>
        </div>
        <div class="toast">
          <span class="dot"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8v.5"/></svg></span>
          <span class="grow">
            <span class="t-title">Order received</span>
            <div class="bar"></div>
          </span>
        </div>
      </div>
    </div>
    <div data-pane="v4">
<pre><code>UIHelper.showToast(
  title: 'Saved',
  type: ToastificationType.success,
);

UIHelper.showToast(
  title: 'Could not save',
  description: 'Check your connection and try again.',
  type: ToastificationType.error,
  duration: const Duration(seconds: 4),
);

// The snackbar entry point maps SnackBarType onto the same toasts.
UIHelper.showSnackBar(
  context,
  message: 'Order received',
  type: SnackBarType.success,
);</code></pre>
    </div>
  </div>
</div>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">showSnackBar is a toast, and most of its arguments are ignored</span>
    <p>
      It forwards to <code>showToast</code>. The parameters that only ever made
      sense for a real <code>SnackBar</code> — <code>action</code>,
      <code>elevation</code>, <code>margin</code>, <code>padding</code>,
      <code>behavior</code>, and <code>context</code> itself — are still accepted
      so existing call sites compile, but <strong>nothing reads them</strong>.
      An <code>action:</code> button you pass will never appear.
    </p>
    <p>
      The same is true of <code>showSnackBarMoveToCart</code>, whose
      <code>icon</code> and colour arguments are also inert.
    </p>
  </div>
</div>

<h3>Toast defaults</h3>
<table>
  <thead><tr><th>Parameter</th><th>Default</th></tr></thead>
  <tbody>
    <tr><td><code>type</code></td><td><code>ToastificationType.success</code></td></tr>
    <tr><td><code>style</code></td><td><code>ToastificationStyle.flatColored</code></td></tr>
    <tr><td><code>duration</code></td><td>2 seconds</td></tr>
    <tr><td><code>showProgressBar</code></td><td><code>true</code></td></tr>
    <tr><td><code>showIcon</code></td><td><code>false</code></td></tr>
    <tr><td><code>pauseOnHover</code></td><td><code>true</code></td></tr>
    <tr><td><code>closeOnClick</code> / <code>dragToClose</code></td><td><code>false</code></td></tr>
    <tr><td>close button</td><td><code>CloseButtonShowType.none</code></td></tr>
    <tr><td>animation</td><td>fade in and out</td></tr>
  </tbody>
</table>

<p>
  Note the pairing: no close button, no close-on-click and no drag-to-close, so
  by default a toast can only be waited out. For anything the user may want to
  dismiss early, pass <code>closeOnClick: true</code> or a
  <code>closeButtonShowType</code>.
</p>

<h2>API reference</h2>

<h3>UIHelper.showBottomSheet&lt;T&gt;</h3>
<table>
  <thead><tr><th>Parameter</th><th>Type</th><th>Default</th></tr></thead>
  <tbody>
    <tr><td><code>child</code></td><td><code>Widget</code></td><td>required</td></tr>
    <tr><td><code>type</code></td><td><code>BottomSheetType</code></td><td><code>.scrollable</code></td></tr>
    <tr><td><code>isDismissible</code></td><td><code>bool?</code></td><td>behavior, then <code>true</code></td></tr>
    <tr><td><code>useSafeArea</code></td><td><code>bool?</code></td><td>behavior, then <code>false</code></td></tr>
    <tr><td><code>useRootNavigator</code></td><td><code>bool?</code></td><td>behavior, then <code>true</code></td></tr>
    <tr><td><code>showDragHandle</code></td><td><code>bool</code></td><td><code>false</code></td></tr>
    <tr><td><code>backgroundColor</code> / <code>elevation</code> / <code>shape</code></td><td>—</td><td>passed straight through</td></tr>
  </tbody>
</table>

<h3>UIHelper.showDialogPicker&lt;T&gt;</h3>
<table>
  <thead><tr><th>Parameter</th><th>Type</th><th>Default</th></tr></thead>
  <tbody>
    <tr><td><code>child</code></td><td><code>Widget</code></td><td>required</td></tr>
    <tr><td><code>barrierDismissible</code></td><td><code>bool?</code></td><td>behavior, then <code>true</code></td></tr>
    <tr><td><code>barrierColor</code></td><td><code>Color?</code></td><td>—</td></tr>
    <tr><td><code>backgroundColor</code></td><td><code>Color?</code></td><td><code>dialogBackgroundColor</code></td></tr>
    <tr><td><code>insetPadding</code></td><td><code>EdgeInsets?</code></td><td>—</td></tr>
    <tr><td><code>dialogWidget</code></td><td><code>Widget?</code></td><td>— replaces DialogPicker entirely</td></tr>
  </tbody>
</table>

<h3>AppWarningDialog</h3>
<table>
  <thead><tr><th>Parameter</th><th>Type</th><th>Default</th></tr></thead>
  <tbody>
    <tr><td><code>title</code> / <code>message</code> / <code>buttonText</code></td><td><code>String</code></td><td>required</td></tr>
    <tr><td><code>onPressed</code></td><td><code>VoidCallback</code></td><td>required — must pop itself</td></tr>
    <tr><td><code>cancelText</code></td><td><code>String</code></td><td><code>'Cancel'</code></td></tr>
    <tr><td><code>dangerColor</code></td><td><code>Color?</code></td><td><code>colorScheme.error</code></td></tr>
    <tr><td><code>iconBackgroundOpacity</code></td><td><code>double</code></td><td><code>0.08</code></td></tr>
  </tbody>
</table>

<h3>Enums</h3>
<table>
  <thead><tr><th>Enum</th><th>Values</th></tr></thead>
  <tbody>
    <tr><td><code>BottomSheetType</code></td><td><code>normal</code>, <code>scrollable</code></td></tr>
    <tr><td><code>SnackBarType</code></td><td><code>normal</code> → info, <code>success</code>, <code>error</code>, <code>warning</code></td></tr>
  </tbody>
</table>

<h2>Things that go wrong</h2>

<h3>Nothing happens when I call showToast or showSnackBar</h3>
<p>
  No <code>ToastificationWrapper</code> above your app. The call is wrapped in a
  <code>try</code>/<code>catch</code> that swallows the error, so there is no
  exception and no log to find. Mount the wrapper around
  <code>MaterialApp</code>.
</p>

<h3>My snackbar action button never shows</h3>
<p>
  <code>showSnackBar</code> is a toast. <code>action</code> is accepted for
  source compatibility and ignored. If you need an action, build a toast with a
  <code>description</code> and a close button, or use Flutter's
  <code>ScaffoldMessenger</code> directly.
</p>

<h3>The sheet header is invisible in dark mode</h3>
<p>
  <code>SheetHeader</code> hardcodes <code>Colors.black</code>. Build the row
  yourself, or give the sheet a light background.
</p>

<h3>The dialog's Cancel button is red</h3>
<p>
  <code>AppWarningDialog</code> builds it from <code>AppButton</code>, which
  defaults to widget_kit's brand red until you register an
  <code>AppButtonThemeExtension</code>. Run
  <code>fkit style create app-button</code>.
</p>

<h3>The dialog closed but my await never returned a value</h3>
<p>
  <code>AppWarningDialog</code>'s confirm button calls your
  <code>onPressed</code> and does not pop. Pop with the result yourself:
  <code>Navigator.of(dialogContext).pop(true)</code>.
</p>

<h3>The sheet covers the status bar</h3>
<p>
  <code>useSafeArea</code> defaults to <code>false</code>. Pass
  <code>useSafeArea: true</code>, or set
  <code>bottomSheetUseSafeArea</code> once on <code>WidgetKitBehavior</code>.
  Note the widget applies <code>SafeArea(top: false)</code>, so it guards the
  bottom inset rather than the notch.
</p>

<h3>backgroundColor on showDialogPicker did nothing</h3>
<p>
  You also passed <code>dialogWidget</code>, which replaces the
  <code>DialogPicker</code> that would have read it.
</p>
`,
});
