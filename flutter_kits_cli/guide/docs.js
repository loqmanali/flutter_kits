/* fkit — CLI Guide runtime.

   Loaded before the page files. Each pages/<slug>.js calls DOCS.page({...})
   to register itself; index.html then calls DOCS.start().

   This guide is English-only (LANGS below). The runtime's translation support
   is left intact so a second language can be added without rewriting it.

   No fetch, no ES modules — the guide works when opened straight from disk. */
(() => {
'use strict';

// ── menu groups, in the order they should appear ───────────────────────
// Page files reference these by id, so a label change never touches a page.
const GROUPS = [
  { id: 'start',      en: 'Start here' },
  { id: 'commands',   en: 'Commands' },
  { id: 'widget_kit', en: 'widget_kit' },
  { id: 'ref',        en: 'Reference' },
];

// ── interface strings ─────────────────────────────────────────────────
const STRINGS = {
  en: {
    guide:        'Guide',
    subtitle:     'User Guide',
    searchOpen:   'Search the guide…',
    searchInput:  'Search pages and sections…',
    searchLabel:  'Search the guide',
    closeSearch:  'Close search',
    onThisPage:   'On this page',
    prev:         'Previous',
    next:         'Next',
    menuLabel:    'Open the guide menu',
    themeLabel:   'Switch between light and dark',
    langLabel:    'Read this guide in Arabic',
    langSwitch:   'العربية',
    noMatch:      q => `Nothing in the guide matches “${q}”.`,
    paletteFoot:  '<kbd>↑</kbd><kbd>↓</kbd> to move · <kbd>Enter</kbd> to open · <kbd>Esc</kbd> to close',
    missingTitle: 'Not written yet',
    missingLede:  s => `There is no page in this guide for “${s}” — it is one of the modules still being documented. Here is everything that is ready:`,
    noPages:      'None of the guide\'s page files were registered. If you copied the guide somewhere, make sure the <strong>pages</strong> folder came with it and sits next to this file.',
    untranslated: 'Not translated yet',
    untranslatedBody: 'This page has not been translated into Arabic yet, so the English version is shown below.',
    anchorLabel:  t => `Link to “${t}”`,
    noRows:       'Nothing matches these filters. Clear them to see the full list.',
    demoNote:     'Illustration — the real screen\'s own design, filled with example data.',
    demoMore:     'What this means',
    demoAnchor:   'about-the-illustrations',
  },
  ar: {
    guide:        'الدليل',
    subtitle:     'دليل المستخدم',
    searchOpen:   'ابحث في الدليل…',
    searchInput:  'ابحث في الصفحات والأقسام…',
    searchLabel:  'البحث في الدليل',
    closeSearch:  'إغلاق البحث',
    onThisPage:   'في هذه الصفحة',
    prev:         'السابق',
    next:         'التالي',
    menuLabel:    'فتح قائمة الدليل',
    themeLabel:   'التبديل بين المظهر الفاتح والغامق',
    langLabel:    'Read this guide in English',
    langSwitch:   'English',
    noMatch:      q => `لا يوجد في الدليل ما يطابق «${q}».`,
    paletteFoot:  '<kbd>↑</kbd><kbd>↓</kbd> للتنقل · <kbd>Enter</kbd> للفتح · <kbd>Esc</kbd> للإغلاق',
    missingTitle: 'لم تُكتب بعد',
    missingLede:  s => `لا توجد صفحة في هذا الدليل لـ «${s}» — هي أحد الأقسام التي ما زال توثيقها جاريًا. وهذا كل ما هو جاهز الآن:`,
    noPages:      'لم يتم تحميل أي من ملفات صفحات الدليل. إذا نسخت الدليل إلى مكان آخر، تأكد من نسخ مجلد <strong>pages</strong> معه وأن يكون بجانب هذا الملف.',
    untranslated: 'لم تُترجم بعد',
    untranslatedBody: 'لم تُترجم هذه الصفحة إلى العربية بعد، لذلك تُعرض النسخة الإنجليزية أدناه.',
    anchorLabel:  t => `رابط إلى «${t}»`,
    noRows:       'لا يوجد ما يطابق هذه الفلاتر. أزلها لعرض القائمة كاملة.',
    demoNote:     'رسم توضيحي — تصميم الشاشة الحقيقية نفسه، مملوءًا ببيانات تجريبية.',
    demoMore:     'ما معنى ذلك',
    demoAnchor:   'عن-الامثله-التوضيحيه',
  },
};

// This guide ships in English only. Keeping the array single-entry disables the
// language toggle and the untranslated-page fallback without touching the rest
// of the runtime.
const LANGS = ['en'];
const registry = new Map();   // "lang:slug" → page
const canonical = [];         // English pages, in registration order

// ── public registry ───────────────────────────────────────────────────
window.DOCS = {
  page(def) {
    for (const key of ['slug', 'group', 'title', 'html']) {
      if (!def?.[key]) { console.error('DOCS.page: missing', key, def); return; }
    }
    const lang = def.lang || 'en';
    if (!LANGS.includes(lang)) { console.error('DOCS.page: unknown lang', lang, def.slug); return; }
    const key = `${lang}:${def.slug}`;
    if (registry.has(key)) { console.error('DOCS.page: duplicate', key); return; }

    const page = { summary: '', ...def, lang };
    registry.set(key, page);
    if (lang === 'en') canonical.push(page);
  },
  start() {
    if (document.readyState === 'loading') addEventListener('DOMContentLoaded', boot, { once: true });
    else boot();
  },
};

// ── platform ──────────────────────────────────────────────────────────
// navigator.platform is deprecated but still the only signal some browsers
// give us, so try the modern hint first and fall back.
const IS_APPLE = /Mac|iPhone|iPad|iPod/i.test(
  navigator.userAgentData?.platform || navigator.platform || navigator.userAgent || ''
);
const MOD_LABEL = IS_APPLE ? '⌘' : 'Ctrl';

const $  = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => [...root.querySelectorAll(sel)];

const store = {
  get(k) { try { return localStorage.getItem(k); } catch { return null; } },
  set(k, v) { try { localStorage.setItem(k, v); } catch {} },
};

let el, LANG, T, HOME, rendered;

// ── boot ──────────────────────────────────────────────────────────────
function boot() {
  el = {
    sidebar:  $('#sidebar'),
    sideIn:   $('#sidebarInner'),
    article:  $('#article'),
    crumb:    $('#breadcrumb'),
    pager:    $('#pager'),
    toc:      $('#toc'),
    scrim:    $('#scrim'),
    navBtn:   $('#navToggle'),
    langBtn:  $('#langToggle'),
    palette:  $('#palette'),
    pInput:   $('#paletteInput'),
    pResults: $('#paletteResults'),
  };

  LANG = readLang();
  T = STRINGS[LANG];

  if (!canonical.length) {
    el.article.innerHTML = `<h1>No pages loaded</h1><p class="lede">${T.noPages}</p>`;
    return;
  }
  HOME = canonical[0].slug;

  initTheme();
  el.navBtn.addEventListener('click', () => drawer(el.sidebar.dataset.open !== 'true'));
  el.scrim.addEventListener('click', () => drawer(false));
  // Absent in a single-language guide — index.html drops the button.
  if (el.langBtn) {
    el.langBtn.addEventListener('click', () => {
      const to = LANG === 'ar' ? 'en' : 'ar';
      store.set(LANG_KEY, to);
      location.hash = `#/${to}/${currentSlug()}`;
    });
  }
  initSearch();
  wireKeys();

  addEventListener('hashchange', route);
  route();
}

// ── language ──────────────────────────────────────────────────────────
const LANG_KEY = 'userguide-lang';

function readLang() {
  // An explicit language in the address wins, so a link can carry it.
  const first = location.hash.replace(/^#\/?/, '').split('/')[0];
  if (LANGS.includes(first)) return first;
  const saved = store.get(LANG_KEY);
  if (LANGS.includes(saved)) return saved;
  // Fall back to the browser's language only if this guide actually ships it —
  // otherwise an Arabic-locale browser would get an RTL shell with Arabic
  // chrome wrapped around English-only pages.
  const preferred = (navigator.language || '').startsWith('ar') ? 'ar' : 'en';
  return LANGS.includes(preferred) ? preferred : LANGS[0];
}

function applyLang() {
  const html = document.documentElement;
  html.lang = LANG;
  html.dir = LANG === 'ar' ? 'rtl' : 'ltr';

  $('.brand-text em').textContent   = T.subtitle;
  $('#searchTrigger span').textContent = T.searchOpen;
  $('#searchTrigger').setAttribute('aria-label', T.searchLabel);
  el.pInput.placeholder             = T.searchInput;
  $('#paletteClose').setAttribute('aria-label', T.closeSearch);
  $('.palette-foot').innerHTML      = T.paletteFoot;
  $('#palette').setAttribute('aria-label', T.searchLabel);
  el.navBtn.setAttribute('aria-label', T.menuLabel);
  $('#themeToggle').setAttribute('aria-label', T.themeLabel);
  if (el.langBtn) {
    el.langBtn.setAttribute('aria-label', T.langLabel);
    el.langBtn.textContent          = T.langSwitch;
  }
  $('#searchHint').textContent      = `${MOD_LABEL} K`;
}

const groupLabel = id => {
  const g = GROUPS.find(g => g.id === id) || GROUPS.at(-1);
  return g[LANG] || g.en;
};

// The page in the active language, or the English original as a fallback.
function resolve(slug) {
  const wanted = registry.get(`${LANG}:${slug}`);
  if (wanted) return { page: wanted, translated: true };
  const fallback = registry.get(`en:${slug}`);
  return fallback ? { page: fallback, translated: LANG === 'en' } : null;
}

// Titles come from the translation when there is one, so a half-translated
// guide still reads as a coherent menu.
const menuTitle = slug => (registry.get(`${LANG}:${slug}`) || registry.get(`en:${slug}`)).title;

// ── appearance ────────────────────────────────────────────────────────
const THEME_KEY = 'userguide-theme';
function initTheme() {
  const set = t => { document.documentElement.dataset.theme = t; store.set(THEME_KEY, t); };
  set(store.get(THEME_KEY) || (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'));
  $('#themeToggle').addEventListener('click', () =>
    set(document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark'));
}

// ── side menu ─────────────────────────────────────────────────────────
function buildSidebar() {
  const known = new Set(GROUPS.map(g => g.id));
  const groups = [];
  for (const p of canonical) {
    const id = known.has(p.group) ? p.group : 'other';
    const last = groups.at(-1);
    if (last?.id === id) last.pages.push(p);
    else groups.push({ id, pages: [p] });
  }

  const shut = collapsedGroups();
  const current = currentSlug();

  el.sideIn.innerHTML = groups.map(g => {
    // Never collapse the group the reader is currently inside — a menu that
    // hides the page you are on is worse than one that is slightly long.
    const holdsCurrent = g.pages.some(p => p.slug === current);
    const off = shut.has(g.id) && !holdsCurrent;
    return `
    <section class="sidebar-group" data-group="${g.id}"${off ? ' data-collapsed="true"' : ''}>
      <h2>
        <button type="button" class="group-toggle" aria-expanded="${!off}">
          <span>${esc(groupLabel(g.id))}</span>
          <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9l6 6 6-6"/></svg>
        </button>
      </h2>
      <ul>${g.pages.map(p => {
        const pending = !registry.has(`${LANG}:${p.slug}`);
        return `<li><a href="#/${LANG}/${p.slug}" data-slug="${p.slug}"${pending ? ' data-pending="true"' : ''}>${esc(menuTitle(p.slug))}</a></li>`;
      }).join('')}</ul>
    </section>`;
  }).join('');

  // One delegated listener, so rebuilding the menu never leaks handlers.
  el.sideIn.onclick = e => {
    const btn = e.target.closest('.group-toggle');
    if (!btn) return;
    const section = btn.closest('.sidebar-group');
    const off = section.toggleAttribute('data-collapsed');
    btn.setAttribute('aria-expanded', String(!off));
    const set = collapsedGroups();
    off ? set.add(section.dataset.group) : set.delete(section.dataset.group);
    store.set(COLLAPSE_KEY, JSON.stringify([...set]));
  };
}

// Which menu groups the reader has collapsed, remembered across visits.
const COLLAPSE_KEY = 'userguide-collapsed';
function collapsedGroups() {
  try {
    const raw = JSON.parse(store.get(COLLAPSE_KEY) || '[]');
    return new Set(Array.isArray(raw) ? raw : []);
  } catch { return new Set(); }
}

function drawer(open) {
  el.sidebar.dataset.open = String(open);
  el.scrim.hidden = !open;
  el.navBtn.setAttribute('aria-expanded', String(open));
}

// ── routing ───────────────────────────────────────────────────────────
// Hash is #/<lang>/<slug>[#heading]; the language segment is optional.
function currentSlug() {
  const parts = location.hash.replace(/^#\/?/, '').split('#')[0].split('/');
  if (LANGS.includes(parts[0])) return parts[1] || HOME;
  return parts[0] || HOME;
}

function route() {
  const before = LANG;
  LANG = readLang();
  T = STRINGS[LANG];
  const slug = currentSlug();

  // Arabic heading ids arrive percent-encoded in the address bar, so they must
  // be decoded before getElementById will ever match them.
  const frag = decodeURIComponent(location.hash.split('#')[2] || '');

  drawer(false);
  closePalette();
  if (LANG !== before) index = null;   // the search index is per-language

  // Same page, different heading — just move. Re-rendering would reset the
  // interactive mock-ups and throw away the reader's place.
  if (rendered === `${LANG}:${slug}`) { jumpTo(frag); return; }

  applyLang();
  buildSidebar();

  const found = resolve(slug);
  if (!found) { notWritten(slug); return; }
  const { page, translated } = found;

  // An untranslated page is shown in English inside an explicitly LTR block,
  // so Arabic chrome keeps its direction while the English body keeps its own.
  el.article.innerHTML = translated
    ? page.html
    : untranslatedNotice() + `<div dir="ltr" lang="en">${page.html}</div>`;
  document.title = `${menuTitle(slug)} — fkit ${T.subtitle}`;

  $$('a[data-slug]', el.sidebar).forEach(a => {
    if (a.dataset.slug === slug) a.setAttribute('aria-current', 'page');
    else a.removeAttribute('aria-current');
  });

  el.crumb.innerHTML =
    `<a href="#/${LANG}/${HOME}">${esc(T.guide)}</a><span aria-hidden="true">/</span>` +
    `<span>${esc(groupLabel(page.group))}</span><span aria-hidden="true">/</span>` +
    `<span>${esc(menuTitle(slug))}</span>`;

  decorate(slug);
  wireMockups();
  wireCopyButtons();
  buildToc(slug);
  buildPager(slug);

  rendered = `${LANG}:${slug}`;
  jumpTo(frag);
}

function jumpTo(frag) {
  let target = frag && document.getElementById(frag);
  // Heading ids are stored folded (ة→ه, أ→ا, ى→ي). A hand-written link may use
  // any of those spellings, so fall back to comparing folded forms rather than
  // sending the reader to the top of the page.
  if (frag && !target) {
    const want = slugify(frag);
    target = $$('[id]', el.article).find(n => n.id === want);
  }
  if (target) target.scrollIntoView();
  else scrollTo({ top: 0 });
}

function untranslatedNotice() {
  return `<div class="callout warn">
    <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 9v4M12 17h.01M10.3 3.9L2.4 18a2 2 0 001.7 3h15.8a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z"/></svg>
    <div><span class="callout-title">${esc(T.untranslated)}</span><p>${esc(T.untranslatedBody)}</p></div>
  </div>`;
}

function notWritten(slug) {
  rendered = null;   // never let a missing page leave a stale render key
  el.crumb.innerHTML = `<a href="#/${LANG}/${HOME}">${esc(T.guide)}</a>`;
  el.article.innerHTML =
    `<h1>${esc(T.missingTitle)}</h1><p class="lede">${esc(T.missingLede(slug))}</p>
     <ul class="cards">${canonical.map(p => {
       const t = registry.get(`${LANG}:${p.slug}`) || p;
       return `<li><a href="#/${LANG}/${p.slug}"><strong>${esc(t.title)}</strong><span>${esc(t.summary)}</span></a></li>`;
     }).join('')}</ul>`;
  el.toc.replaceChildren();
  el.pager.replaceChildren();
  scrollTo({ top: 0 });
}

// ── content polish ────────────────────────────────────────────────────
function decorate(slug) {
  $$('h2, h3', el.article).forEach(h => {
    if (!h.id) h.id = slugify(h.textContent);
    const a = document.createElement('a');
    a.className = 'anchor';
    a.href = `#/${LANG}/${slug}#${h.id}`;
    a.textContent = '#';
    a.setAttribute('aria-label', T.anchorLabel(h.textContent.trim()));
    h.append(a);
  });

  // Wide tables scroll inside their own box, never the whole page. Tables
  // inside a mock-up are exempt — they carry the dashboard's own styling.
  $$('table', el.article).forEach(t => {
    if (t.closest('.ui')) return;
    if (t.parentElement.classList.contains('table-wrap')) return;
    const wrap = document.createElement('div');
    wrap.className = 'table-wrap';
    wrap.tabIndex = 0;
    t.replaceWith(wrap);
    wrap.append(t);
  });
}

// ── interactive mock-ups ──────────────────────────────────────────────
// The dashboard replicas respond for real: tabs switch panes, filter buttons
// toggle, the search box filters rows, column headers sort, and hovering a
// Every code block gets a copy button. Added here rather than written into the
// pages so the markup stays plain <pre><code> and forty copies cannot drift.
function wireCopyButtons() {
  for (const pre of $$('pre', el.article)) {
    if (pre.parentElement?.classList.contains('code-wrap')) continue;

    const wrap = document.createElement('div');
    wrap.className = 'code-wrap';
    pre.parentNode.insertBefore(wrap, pre);
    wrap.appendChild(pre);

    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'copy-btn';
    btn.textContent = 'Copy';
    btn.setAttribute('aria-label', 'Copy this code');
    wrap.appendChild(btn);

    btn.addEventListener('click', async () => {
      const text = pre.innerText;
      try {
        // Needs a secure context; file:// counts, plain http:// on a LAN does
        // not, so fall back rather than failing silently.
        if (navigator.clipboard?.writeText) await navigator.clipboard.writeText(text);
        else legacyCopy(text);
        flash(btn, 'Copied');
      } catch {
        flash(btn, 'Press Ctrl+C');
      }
    });
  }
}

function legacyCopy(text) {
  const ta = document.createElement('textarea');
  ta.value = text;
  ta.setAttribute('readonly', '');
  ta.style.cssText = 'position:fixed;opacity:0';
  document.body.appendChild(ta);
  ta.select();
  document.execCommand('copy');
  ta.remove();
}

function flash(btn, label) {
  btn.textContent = label;
  btn.setAttribute('data-copied', '');
  clearTimeout(btn._t);
  btn._t = setTimeout(() => {
    btn.textContent = 'Copy';
    btn.removeAttribute('data-copied');
  }, 1600);
}

// numbered marker lights up its entry in the legend. One listener per mock-up.
function wireMockups() {
  for (const ui of $$('.ui', el.article)) {
    // Semantics the page markup should not have to repeat every time.
    const tablist = $('.ui-tabs', ui);
    if (tablist) {
      tablist.setAttribute('role', 'tablist');
      $$('button', tablist).forEach(b => {
        b.setAttribute('role', 'tab');
        b.setAttribute('aria-selected', String(b.hasAttribute('data-on')));
      });
    }
    $$('.ui-btn[data-toggle]', ui).forEach(b =>
      b.setAttribute('aria-pressed', String(b.hasAttribute('data-on'))));
    // <th> is not focusable, so sorting would otherwise be mouse-only.
    $$('th[data-sort]', ui).forEach(th => {
      th.tabIndex = 0;
      th.setAttribute('aria-sort', 'none');
      th.addEventListener('keydown', e => {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); sortBy(ui, th); }
      });
    });

    ui.addEventListener('click', e => {
      const tab = e.target.closest('.ui-tabs button');
      if (tab) return switchTab(ui, tab);

      const toggle = e.target.closest('.ui-btn[data-toggle]');
      if (toggle) {
        toggle.toggleAttribute('data-on');
        toggle.setAttribute('aria-pressed', String(toggle.hasAttribute('data-on')));
        return applyFilters(ui);
      }

      const th = e.target.closest('th[data-sort]');
      if (th) return sortBy(ui, th);
    });

    $('.ui-field input', ui)?.addEventListener('input', () => applyFilters(ui));

    // Every mock-up says what it is, right above itself. Generated here rather
    // than written into each page: forty page files would drift, and a reader
    // who meets a replica without this label may reasonably wonder whether the
    // guide is showing them the real product or something invented.
    const fig = ui.closest('figure');
    if (fig && !$('.demo-note', fig)) {
      const note = document.createElement('p');
      note.className = 'demo-note';
      note.innerHTML =
        `<i class="ti ti-info-circle" aria-hidden="true"></i>` +
        `<span>${esc(T.demoNote)}</span> ` +
        `<a href="#/${LANG}/introduction#${T.demoAnchor}">${esc(T.demoMore)}</a>`;
      fig.prepend(note);
    }

    // Marker ⇄ legend cross-highlight. The legend is the <ol class="ui-key">
    // that follows the mock-up's <figure>.
    const key = fig?.nextElementSibling?.matches?.('.ui-key') ? fig.nextElementSibling : null;
    if (!key) continue;
    const items = $$('li', key);
    $$('.ui-mark', ui).forEach((mark, i) => {
      const item = items[(Number(mark.textContent.trim()) || i + 1) - 1];
      if (!item) return;
      const lit = on => { mark.toggleAttribute('data-lit', on); item.toggleAttribute('data-lit', on); };
      mark.addEventListener('mouseenter', () => lit(true));
      mark.addEventListener('mouseleave', () => lit(false));
      item.addEventListener('mouseenter', () => lit(true));
      item.addEventListener('mouseleave', () => lit(false));
    });
  }
}

function switchTab(ui, tab) {
  $$('.ui-tabs button', ui).forEach(b => {
    b.toggleAttribute('data-on', b === tab);
    b.setAttribute('aria-selected', String(b === tab));
  });
  $$('[data-pane]', ui).forEach(p => p.toggleAttribute('data-on', p.dataset.pane === tab.dataset.tab));
}

function applyFilters(ui) {
  const q = ($('.ui-field input', ui)?.value || '').trim().toLowerCase();
  const active = $$('.ui-btn[data-toggle][data-on]', ui).map(b => b.dataset.toggle);
  let shown = 0;

  for (const tr of $$('tbody tr[data-tags]', ui)) {
    const tags = tr.dataset.tags.split(/\s+/);
    const hit = (!q || tr.textContent.toLowerCase().includes(q))
             && active.every(t => tags.includes(t));
    tr.hidden = !hit;
    if (hit) shown++;
  }

  const body = $('tbody', ui);
  if (!body) return;
  let none = $('tr[data-none]', body);
  if (!none) {
    none = document.createElement('tr');
    none.dataset.none = '';
    none.innerHTML = `<td class="empty" colspan="99">${esc(T.noRows)}</td>`;
    body.append(none);
  }
  none.hidden = shown > 0;
}

function sortBy(ui, th) {
  const cells = $$('th', th.parentElement);
  const col = cells.indexOf(th);
  const dir = th.dataset.dir === 'asc' ? 'desc' : 'asc';
  cells.forEach(c => {
    if (c === th) return;
    delete c.dataset.dir;
    if (c.dataset.sort !== undefined) c.setAttribute('aria-sort', 'none');
  });
  th.dataset.dir = dir;
  th.setAttribute('aria-sort', dir === 'asc' ? 'ascending' : 'descending');

  const body = $('tbody', ui);
  const numeric = th.dataset.sort === 'num';
  const value = tr => {
    const raw = (tr.children[col]?.textContent || '').trim();
    return numeric ? (parseFloat(raw.replace(/[^\d.-]/g, '')) || 0) : raw.toLowerCase();
  };
  $$('tr', body)
    .filter(tr => !tr.dataset.none)
    .sort((a, b) => (value(a) > value(b) ? 1 : value(a) < value(b) ? -1 : 0) * (dir === 'asc' ? 1 : -1))
    .forEach(tr => body.append(tr));
  const none = $('tr[data-none]', body);
  if (none) body.append(none);
}

// ── on this page ──────────────────────────────────────────────────────
let spy;
function buildToc(slug) {
  spy?.disconnect();
  const heads = $$('h2, h3', el.article);
  if (heads.length < 2) { el.toc.replaceChildren(); return; }

  el.toc.innerHTML = `<h2>${esc(T.onThisPage)}</h2><ul>${heads.map(h =>
    `<li class="lvl-${h.tagName[1]}"><a href="#/${LANG}/${slug}#${h.id}">${esc(headingText(h))}</a></li>`
  ).join('')}</ul>`;

  const links = new Map($$('a', el.toc).map(a => [decodeURIComponent(a.href.split('#').pop()), a]));
  spy = new IntersectionObserver(entries => {
    const seen = entries.find(e => e.isIntersecting);
    if (!seen) return;
    links.forEach(a => a.classList.remove('active'));
    links.get(seen.target.id)?.classList.add('active');
  }, { rootMargin: '-25% 0px -70% 0px' });
  heads.forEach(h => spy.observe(h));
}

// ── previous / next ───────────────────────────────────────────────────
function buildPager(slug) {
  const i = canonical.findIndex(p => p.slug === slug);
  const prev = canonical[i - 1], next = canonical[i + 1];
  const link = (p, cls, label) =>
    `<a class="${cls}" href="#/${LANG}/${p.slug}"><small>${esc(label)}</small><strong>${esc(menuTitle(p.slug))}</strong></a>`;
  el.pager.innerHTML =
    (prev ? link(prev, 'prev', T.prev) : '<span></span>') +
    (next ? link(next, 'next', T.next) : '');
}

// ── search ────────────────────────────────────────────────────────────
let index = null;

function buildIndex() {
  if (index) return index;
  index = [];
  const scratch = document.createElement('div');
  for (const c of canonical) {
    const page = registry.get(`${LANG}:${c.slug}`) || c;
    scratch.innerHTML = page.html;
    index.push({ slug: c.slug, title: page.title, heading: null, id: '', text: page.summary });
    for (const h of $$('h2, h3', scratch)) {
      let text = '', n = h.nextElementSibling;
      while (n && !/^H[123]$/.test(n.tagName)) { text += ' ' + n.textContent; n = n.nextElementSibling; }
      index.push({
        slug: c.slug,
        title: page.title,
        heading: headingText(h),
        id: slugify(h.textContent),
        text: text.replace(/\s+/g, ' ').trim(),
      });
    }
  }
  return index;
}

function search(q) {
  const terms = norm(q).split(/\s+/).filter(Boolean);
  if (!terms.length) return [];
  const hits = [];
  for (const row of buildIndex()) {
    const title = norm(`${row.title} ${row.heading || ''}`);
    const body = norm(row.text);
    let score = 0, all = true;
    for (const t of terms) {
      if (title.includes(t)) score += 10;
      else if (body.includes(t)) score += 3;
      else { all = false; break; }
    }
    if (all) hits.push({ row, score });
  }
  return hits.sort((a, b) => b.score - a.score).slice(0, 12).map(h => h.row);
}

function renderResults(q) {
  if (!q.trim()) {
    el.pResults.innerHTML = canonical.map(c => {
      const p = registry.get(`${LANG}:${c.slug}`) || c;
      return `<li role="option"><a href="#/${LANG}/${c.slug}"><strong>${esc(p.title)}</strong><small>${esc(p.summary)}</small></a></li>`;
    }).join('');
  } else {
    const rows = search(q);
    el.pResults.innerHTML = rows.length
      ? rows.map(r => {
          const href = `#/${LANG}/${r.slug}${r.id ? '#' + r.id : ''}`;
          const label = r.heading ? `${r.title} › ${r.heading}` : r.title;
          return `<li role="option"><a href="${href}"><strong>${hl(label, q)}</strong><small>${hl(snippet(r.text, q), q)}</small></a></li>`;
        }).join('')
      : `<li class="palette-empty">${esc(T.noMatch(q))}</li>`;
  }
  select(0);
}

let cursor = 0;
function select(i) {
  const items = $$('li[role="option"]', el.pResults);
  if (!items.length) return;
  cursor = (i + items.length) % items.length;
  items.forEach((li, n) => li.setAttribute('aria-selected', String(n === cursor)));
  items[cursor].scrollIntoView({ block: 'nearest' });
}

function openPalette() {
  el.palette.hidden = false;
  el.pInput.value = '';
  renderResults('');
  el.pInput.focus();
}
function closePalette() { el.palette.hidden = true; }

function initSearch() {
  $('#searchTrigger').addEventListener('click', openPalette);
  $('#paletteClose').addEventListener('click', closePalette);
  el.pInput.addEventListener('input', e => renderResults(e.target.value));
  el.palette.addEventListener('mousedown', e => { if (e.target === el.palette) closePalette(); });
  el.pResults.addEventListener('click', closePalette);
}

function wireKeys() {
  document.addEventListener('keydown', e => {
    // Accept both modifiers whatever the platform — only the label adapts, so
    // a Mac keyboard plugged into Windows still works.
    if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 'k') {
      e.preventDefault();
      el.palette.hidden ? openPalette() : closePalette();
      return;
    }
    if (e.key === 'Escape') { closePalette(); drawer(false); return; }
    if (el.palette.hidden) {
      if (e.key === '/' && !/^(INPUT|TEXTAREA|SELECT)$/.test(e.target.tagName)) { e.preventDefault(); openPalette(); }
      return;
    }
    if (e.key === 'ArrowDown') { e.preventDefault(); select(cursor + 1); }
    if (e.key === 'ArrowUp')   { e.preventDefault(); select(cursor - 1); }
    if (e.key === 'Enter') {
      const a = $('li[aria-selected="true"] a', el.pResults);
      if (a) { e.preventDefault(); closePalette(); location.hash = a.getAttribute('href'); }
    }
  });
}

// ── helpers ───────────────────────────────────────────────────────────
function esc(s) { return String(s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c])); }
function headingText(h) { return h.textContent.replace(/#$/, '').trim(); }

// Arabic slugs keep their letters; harakat and tatweel are dropped so an id
// stays stable whether or not the heading was typed with vowel marks.
function slugify(s) {
  return norm(s)
    .replace(/[#’'"«»]/g, '')
    .replace(/[^a-z0-9ء-ي]+/g, '-')
    .replace(/^-|-$/g, '');
}

// Fold the differences Arabic typists disagree on, so searching "احمد"
// finds "أحمد" and "علي" finds "على".
function norm(s) {
  return String(s).toLowerCase()
    .replace(/[ً-ْـ]/g, '')
    .replace(/[أإآٱ]/g, 'ا')
    .replace(/ى/g, 'ي')
    .replace(/ؤ/g, 'و')
    .replace(/ئ/g, 'ي')
    .replace(/ة/g, 'ه');
}

function hl(text, q) {
  // Match on the folded form but highlight the original characters, so the
  // result still reads the way the author wrote it.
  const terms = norm(q).split(/\s+/).filter(Boolean);
  const chars = [...String(text)];
  const marked = new Array(chars.length).fill(false);
  const folded = chars.map(c => norm(c));
  const flat = folded.join('');
  // Map each position in the folded string back to its source character.
  const back = [];
  folded.forEach((f, i) => { for (let k = 0; k < f.length; k++) back.push(i); });

  for (const t of terms) {
    let from = 0, at;
    while (t && (at = flat.indexOf(t, from)) !== -1) {
      for (let k = at; k < at + t.length; k++) marked[back[k]] = true;
      from = at + t.length;
    }
  }

  let out = '', open = false;
  chars.forEach((c, i) => {
    if (marked[i] && !open) { out += '<mark>'; open = true; }
    if (!marked[i] && open) { out += '</mark>'; open = false; }
    out += esc(c);
  });
  return out + (open ? '</mark>' : '');
}

function snippet(text, q) {
  const term = norm(q).split(/\s+/).filter(Boolean)[0] || '';
  const at = norm(text).indexOf(term);
  if (at < 0) return text.slice(0, 110);
  const from = Math.max(0, at - 40);
  return (from ? '…' : '') + text.slice(from, from + 130).trim() + (text.length > from + 130 ? '…' : '');
}
})();
