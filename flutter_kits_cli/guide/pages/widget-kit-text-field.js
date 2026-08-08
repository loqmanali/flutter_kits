DOCS.page({
  slug: 'widget-kit-text-field',
  group: 'widget_kit',
  title: 'AppTextFormField',
  summary: 'The themed text input: three-level styling cascade, validation on interaction, multiline, icons.',
  html: `
<h1>AppTextFormField</h1>

<p class="page-meta">
  <span class="pill">widget_kit</span>
  <span class="pill">Inputs</span>
  <a href="https://github.com/loqmanali/flutter_kits/blob/main/widget_kit/lib/src/inputs/app_text_form_field.dart">Source</a>
</p>

<p class="lede">
  A <code>TextFormField</code> with an outlined decoration already built, every
  visual property resolvable from your theme, and validation that runs once the
  user has actually touched the field.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="t1" data-on>Preview</button>
    <button data-tab="k1">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="t1" data-on>
      <div class="stage">
        <div class="tf">
          <div class="box">
            <span class="label">Email</span>
            <span class="hint grow">you@example.com</span>
          </div>
        </div>
      </div>
    </div>
    <div data-pane="k1">
<pre><code>AppTextFormField(
  labelText: 'Email',
  hintText: 'you@example.com',
  keyboardType: TextInputType.emailAddress,
  onChanged: (value) =&gt; setState(() =&gt; _email = value),
)</code></pre>
    </div>
  </div>
</div>

<div class="callout tip">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 18h6M10 21h4M12 3a6 6 0 00-3.5 10.9c.6.4.9 1 .9 1.6v.5h5.2v-.5c0-.6.3-1.2.9-1.6A6 6 0 0012 3z"/></svg>
  <div>
    <span class="callout-title">This one follows your theme</span>
    <p>
      Unlike <a href="#/widget-kit-app-button">AppButton</a>, which reads only its
      own extension and ships brand red, <code>AppTextFormField</code> resolves
      every colour through <code>WidgetKitTheme</code> and then falls back to
      <code>Theme.of(context).colorScheme</code>. Register nothing at all and it
      already matches your app.
    </p>
  </div>
</div>

<h2>CLI</h2>
<p>Install the kit:</p>

<pre><code>fkit add widget_kit</code></pre>

<p>To generate this widget's style for customization:</p>

<pre><code>fkit style create input</code></pre>

<p>
  That writes <code>lib/theme/styles/input_style.dart</code> — a function
  returning a modified <code>WidgetKitTheme</code>. See
  <a href="#/styles">Generating widget styles</a>.
</p>

<h2>Usage</h2>

<pre><code>import 'package:widget_kit/widget_kit.dart';</code></pre>

<pre><code>AppTextFormField(
  labelText: 'Email',
  hintText: 'you@example.com',
  controller: _controller,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
  validator: (value) =&gt;
      (value == null || value.isEmpty) ? 'Email is required' : null,
  onChanged: (value) {},
)</code></pre>

<h2 id="how-styling-resolves">How styling resolves</h2>
<p>
  Every visual property goes through the same three rungs, and the first
  non-null wins. This is the table to check when a colour is not what you
  expected.
</p>

<table>
  <thead>
    <tr><th>Property</th><th>1. Constructor</th><th>2. WidgetKitTheme</th><th>3. Fallback</th></tr>
  </thead>
  <tbody>
    <tr><td>Corner radius</td><td><code>borderRadius</code></td><td><code>inputBorderRadius</code></td><td class="num">8.0</td></tr>
    <tr><td>Border width</td><td><code>borderWidth</code></td><td><code>inputBorderWidth</code></td><td class="num">1.0</td></tr>
    <tr><td>Focused border width</td><td><code>focusedBorderWidth</code></td><td><code>inputFocusedBorderWidth</code></td><td class="num">2.0</td></tr>
    <tr><td>Border colour</td><td><code>borderColor</code></td><td><code>inputBorderColor</code></td><td><code>colorScheme.outline</code></td></tr>
    <tr><td>Focused border colour</td><td><code>focusedBorderColor</code></td><td><code>inputFocusedBorderColor</code></td><td><code>colorScheme.primary</code></td></tr>
    <tr><td>Background</td><td><code>backgroundColor</code></td><td><code>inputBackgroundColor</code></td><td><code>Colors.transparent</code></td></tr>
    <tr><td>Error colour</td><td><code>errorColor</code></td><td><code>inputErrorColor</code></td><td><code>colorScheme.error</code></td></tr>
    <tr><td>Hint colour</td><td><code>hintColor</code></td><td><code>inputHintColor</code></td><td><code>colorScheme.onSurfaceVariant</code></td></tr>
    <tr><td>Text size</td><td><code>fontSize</code></td><td><code>inputFontSize</code></td><td class="num">14</td></tr>
    <tr><td>Hint size</td><td><code>hintFontSize</code></td><td><code>inputHintFontSize</code></td><td class="num">12</td></tr>
    <tr><td>Text colour</td><td><code>textColor</code></td><td><code>inputTextColor</code></td><td>inherits <code>bodySmall</code></td></tr>
  </tbody>
</table>

<div class="callout">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3l8 4v5c0 4.5-3.2 7.9-8 9-4.8-1.1-8-4.5-8-9V7l8-4z"/></svg>
  <div>
    <span class="callout-title">The field is transparent, not filled</span>
    <p>
      The decoration sets <code>filled: true</code>, but the fill colour defaults
      to <code>Colors.transparent</code> — so whatever is behind the field shows
      through. Set <code>inputBackgroundColor</code> on
      <code>WidgetKitTheme</code> if you want filled inputs everywhere.
    </p>
    <p>
      The default <code>contentPadding</code> is
      <code>EdgeInsets.symmetric(horizontal: 10)</code> — horizontal only. The
      field's height therefore comes from its content, not from a fixed value.
      Pass your own <code>contentPadding</code> to make it taller.
    </p>
  </div>
</div>

<h2>States</h2>
<p>Resting, focused, and showing a validation error.</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="t2" data-on>Preview</button>
    <button data-tab="k2">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="t2" data-on>
      <div class="stage stack">
        <div class="tf">
          <div class="box">
            <span class="label">Full name</span>
            <span class="value grow">Layla Hassan</span>
          </div>
        </div>
        <div class="tf focused">
          <div class="box">
            <span class="label">Email</span>
            <span class="value grow">layla@<span class="caret"></span></span>
          </div>
        </div>
        <div class="tf invalid">
          <div class="box">
            <span class="label">Phone</span>
            <span class="value grow">0100</span>
          </div>
          <p class="msg">Enter a valid phone number</p>
        </div>
        <div class="tf disabled">
          <div class="box">
            <span class="label">Country</span>
            <span class="value grow">Egypt</span>
          </div>
        </div>
      </div>
    </div>
    <div data-pane="k2">
<pre><code>// Resting
AppTextFormField(labelText: 'Full name', controller: _name)

// Errors can come from a validator…
AppTextFormField(
  labelText: 'Phone',
  controller: _phone,
  validator: (value) =&gt;
      (value?.length ?? 0) &lt; 11 ? 'Enter a valid phone number' : null,
)

// …or be driven from outside, e.g. a failed server call.
AppTextFormField(
  labelText: 'Phone',
  controller: _phone,
  errorText: _serverError,
)

// Disabled
AppTextFormField(
  labelText: 'Country',
  initialValue: 'Egypt',
  enabled: false,
)</code></pre>
    </div>
  </div>
</div>

<h2>Validation</h2>

<div class="callout warn">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v5M12 17.5v.5M10.3 3.9L2.6 17.4A2 2 0 004.3 20.4h15.4a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
  <div>
    <span class="callout-title">Validation is on by default — Flutter's is not</span>
    <p>
      <code>autovalidateMode</code> defaults to
      <code>AutovalidateMode.onUserInteraction</code>, where a bare
      <code>TextFormField</code> defaults to <code>disabled</code>. So a field
      with a <code>validator</code> starts showing its error as soon as the user
      has touched it — no <code>Form.validate()</code> call needed, and no error
      shown on a pristine form.
    </p>
    <p>
      If you want errors only on submit, pass
      <code>autovalidateMode: AutovalidateMode.disabled</code> explicitly.
    </p>
  </div>
</div>

<pre><code>final _formKey = GlobalKey&lt;FormState&gt;();

Form(
  key: _formKey,
  child: Column(
    children: [
      AppTextFormField(
        labelText: 'Email',
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Email is required';
          if (!value.contains('@')) return 'That does not look like an email';
          return null;
        },
      ),
      AppButton(
        label: 'Sign in',
        onPressed: () {
          // Still call validate() on submit — onUserInteraction only covers
          // fields the user actually touched.
          if (_formKey.currentState?.validate() ?? false) submit();
        },
      ),
    ],
  ),
)</code></pre>

<h2>Icons and obscured text</h2>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="t3" data-on>Preview</button>
    <button data-tab="k3">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="t3" data-on>
      <div class="stage stack">
        <div class="tf">
          <div class="box">
            <span class="label">Search</span>
            <span class="adorn"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M20 20l-4.3-4.3"/></svg></span>
            <span class="hint grow">Search orders</span>
          </div>
        </div>
        <div class="tf">
          <div class="box">
            <span class="label">Password</span>
            <span class="adorn"><svg viewBox="0 0 24 24"><rect x="4" y="10" width="16" height="10" rx="2"/><path d="M8 10V7a4 4 0 018 0v3"/></svg></span>
            <span class="value grow">••••••••</span>
            <span class="adorn"><svg viewBox="0 0 24 24"><path d="M2 12s3.6-6 10-6 10 6 10 6-3.6 6-10 6-10-6-10-6z"/><circle cx="12" cy="12" r="2.5"/></svg></span>
          </div>
        </div>
      </div>
    </div>
    <div data-pane="k3">
<pre><code>AppTextFormField(
  labelText: 'Search',
  hintText: 'Search orders',
  prefixIcon: const Icon(Icons.search_rounded, size: 20),
)

AppTextFormField(
  labelText: 'Password',
  obscureText: _hidden,
  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
  suffixIcon: IconButton(
    icon: Icon(_hidden
        ? Icons.visibility_outlined
        : Icons.visibility_off_outlined),
    onPressed: () =&gt; setState(() =&gt; _hidden = !_hidden),
    tooltip: _hidden ? 'Show password' : 'Hide password',
  ),
  autofillHints: const [AutofillHints.password],
)</code></pre>
    </div>
  </div>
</div>

<p>
  There is no built-in show/hide toggle — <code>obscureText</code> is a plain
  flag, so the eye button and its state are yours to add, as above.
</p>

<h2>Multiline</h2>
<p>
  Raising <code>maxLines</code> switches two things automatically: the label
  aligns with the hint instead of centring, and the text sits at the top of the
  box rather than the middle.
</p>

<div class="ui demo">
  <div class="ui-tabs">
    <button data-tab="t4" data-on>Preview</button>
    <button data-tab="k4">Code</button>
  </div>
  <div class="ui-panes">
    <div data-pane="t4" data-on>
      <div class="stage">
        <div class="tf multiline">
          <div class="box">
            <span class="label">Delivery notes</span>
            <span class="hint grow">Anything the driver should know</span>
          </div>
        </div>
      </div>
    </div>
    <div data-pane="k4">
<pre><code>AppTextFormField(
  labelText: 'Delivery notes',
  hintText: 'Anything the driver should know',
  maxLines: 4,
  minLines: 3,
  textInputAction: TextInputAction.newline,
)</code></pre>
    </div>
  </div>
</div>

<h2>Theming every input at once</h2>

<pre><code>MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: const [
      WidgetKitTheme(
        inputBorderRadius: 12,
        inputBorderWidth: 1,
        inputFocusedBorderWidth: 2,
        inputBackgroundColor: Color(0xFFF6F8F9),
        inputFocusedBorderColor: Color(0xFF104C65),
        inputFontSize: 15,
        inputHintFontSize: 13,
      ),
    ],
  ),
);</code></pre>

<p>
  Or generate it — <code>fkit style create input</code> writes the same thing as
  an editable function, with the kit's defaults filled in.
</p>

<h2>API reference</h2>

<table>
  <thead><tr><th>Parameter</th><th>Type</th><th>Default</th></tr></thead>
  <tbody>
    <tr><td><code>labelText</code></td><td><code>String?</code></td><td>—</td></tr>
    <tr><td><code>hintText</code></td><td><code>String?</code></td><td>—</td></tr>
    <tr><td><code>errorText</code></td><td><code>String?</code></td><td>— shown regardless of the validator</td></tr>
    <tr><td><code>controller</code></td><td><code>TextEditingController?</code></td><td>—</td></tr>
    <tr><td><code>initialValue</code></td><td><code>String?</code></td><td>— asserts if a controller is also given</td></tr>
    <tr><td><code>keyName</code></td><td><code>String?</code></td><td>— becomes a <code>ValueKey</code></td></tr>
    <tr><td><code>obscureText</code></td><td><code>bool</code></td><td><code>false</code></td></tr>
    <tr><td><code>keyboardType</code></td><td><code>TextInputType?</code></td><td>—</td></tr>
    <tr><td><code>textInputAction</code></td><td><code>TextInputAction?</code></td><td>—</td></tr>
    <tr><td><code>maxLines</code></td><td><code>int?</code></td><td><code>1</code></td></tr>
    <tr><td><code>minLines</code></td><td><code>int?</code></td><td>—</td></tr>
    <tr><td><code>expands</code></td><td><code>bool</code></td><td><code>false</code></td></tr>
    <tr><td><code>maxLength</code></td><td><code>int?</code></td><td>—</td></tr>
    <tr><td><code>readOnly</code></td><td><code>bool</code></td><td><code>false</code></td></tr>
    <tr><td><code>enabled</code></td><td><code>bool?</code></td><td>—</td></tr>
    <tr><td><code>autofocus</code></td><td><code>bool</code></td><td><code>false</code></td></tr>
    <tr><td><code>contentPadding</code></td><td><code>EdgeInsets</code></td><td><code>symmetric(horizontal: 10)</code></td></tr>
    <tr><td><code>prefixIcon</code> / <code>suffixIcon</code></td><td><code>Widget?</code></td><td>—</td></tr>
    <tr><td><code>validator</code></td><td><code>String? Function(String?)?</code></td><td>—</td></tr>
    <tr><td><code>autovalidateMode</code></td><td><code>AutovalidateMode</code></td><td><code>.onUserInteraction</code></td></tr>
    <tr><td><code>inputFormatters</code></td><td><code>List&lt;TextInputFormatter&gt;?</code></td><td>—</td></tr>
    <tr><td><code>autofillHints</code></td><td><code>Iterable&lt;String&gt;?</code></td><td>—</td></tr>
    <tr><td><code>onChanged</code> / <code>onSaved</code> / <code>onFieldSubmitted</code></td><td>callbacks</td><td>—</td></tr>
    <tr><td><code>onTap</code> / <code>onTapOutside</code></td><td>callbacks</td><td><code>onTapOutside</code> unfocuses by default</td></tr>
    <tr><td><code>textAlign</code></td><td><code>TextAlign</code></td><td><code>.start</code></td></tr>
    <tr><td><code>textAlignVertical</code></td><td><code>TextAlignVertical?</code></td><td><code>.center</code>, or <code>.top</code> when multiline</td></tr>
    <tr><td><code>cursorWidth</code></td><td><code>double</code></td><td><code>2.0</code></td></tr>
    <tr><td><code>decorationOverride</code></td><td><code>InputDecoration?</code></td><td>— replaces the whole decoration</td></tr>
    <tr><td><code>textStyle</code></td><td><code>TextStyle?</code></td><td>— replaces the resolved text style</td></tr>
  </tbody>
</table>

<p>
  The eleven styling parameters — <code>borderRadius</code>,
  <code>borderColor</code>, <code>fontSize</code> and the rest — are in the
  <a href="#how-styling-resolves">resolution table</a> above.
</p>

<h2>Things that go wrong</h2>

<h3>The error appears while the user is still typing</h3>
<p>
  That is <code>autovalidateMode: onUserInteraction</code>, the default. It is
  usually what you want for a login form and usually not for a long form. Pass
  <code>AutovalidateMode.disabled</code> and call
  <code>_formKey.currentState!.validate()</code> on submit instead.
</p>

<h3>An assertion fires: "do not use initialValue with controller"</h3>
<p>
  The two are mutually exclusive — a controller already carries its own text.
  Set the starting value on the controller:
  <code>TextEditingController(text: 'Egypt')</code>.
</p>

<h3>My WidgetKitTheme colours are being ignored</h3>
<p>
  Check for a per-instance override first — a <code>borderColor</code> on the
  widget beats the theme by design. If you passed
  <code>decorationOverride</code>, note that it replaces the decoration wholesale
  and every styling parameter along with it.
</p>

<h3>The field has no background</h3>
<p>
  It is transparent by default even though <code>filled</code> is true. Set
  <code>backgroundColor</code>, or <code>inputBackgroundColor</code> on the
  theme.
</p>

<h3>The field is shorter than I expected</h3>
<p>
  The default <code>contentPadding</code> has no vertical component, so the
  height follows the text. Pass e.g.
  <code>contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16)</code>.
</p>

<h3>The keyboard will not dismiss</h3>
<p>
  It should: <code>onTapOutside</code> defaults to unfocusing the field. If you
  passed your own <code>onTapOutside</code>, you replaced that behaviour and need
  to call <code>FocusScope.of(context).unfocus()</code> yourself.
</p>
`,
});
