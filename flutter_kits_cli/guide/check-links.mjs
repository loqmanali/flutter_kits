// Checks every internal link in the user guide (<DOCS_DIR>/pages/**) against
// the heading ids each page actually generates.
//
// Worth running after adding or translating a page: Arabic heading ids are
// folded (ة→ه, أ→ا, ى→ي), so a hand-written anchor that looks right can still
// miss. The guide's router tolerates the variants at runtime; this reports the
// canonical form so the source stays tidy.
//
//   node check-links.mjs        (from the project root)

import fs from 'node:fs';
import path from 'node:path';
const norm = s => String(s).toLowerCase().replace(/[ً-ْـ]/g,'').replace(/[أإآٱ]/g,'ا').replace(/ى/g,'ي').replace(/ؤ/g,'و').replace(/ئ/g,'ي').replace(/ة/g,'ه');
const slugify = s => norm(s).replace(/[#’'"«»]/g,'').replace(/[^a-z0-9ء-ي]+/g,'-').replace(/^-|-$/g,'');
const strip = h => h.replace(/<[^>]*>/g,'').replace(/&amp;/g,'&').trim();

const pages = new Map();   // "lang:slug" -> Set of heading slugs
const links = [];
const files = [];
// Resolved from this file's own location, so the check works from any cwd.
// English-only guide, so there is no second-language directory to scan.
const here = path.dirname(new URL(import.meta.url).pathname);
for (const d of [path.join(here, 'pages')])
  for (const f of fs.readdirSync(d)) if (f.endsWith('.js')) files.push(path.join(d, f));

for (const f of files) {
  const src = fs.readFileSync(f, 'utf8');
  const slug = src.match(/slug: '([^']+)'/)[1];
  const lang = (src.match(/lang: '([^']+)'/) || [,'en'])[1];
  const key = `${lang}:${slug}`;
  const heads = [...src.matchAll(/<h[23]>([\s\S]*?)<\/h[23]>/g)].map(m => slugify(strip(m[1])));
  pages.set(key, new Set(heads));
  for (const m of src.matchAll(/href="#\/([^"#]+)(?:#([^"]+))?"/g))
    links.push({ from: `${f} (${key})`, target: m[1], frag: m[2] || null });
}

console.log('pages:', [...pages.keys()].join(', '), '\n');
let bad = 0; const fallback = [];
for (const l of links) {
  const parts = l.target.split('/');
  const key = parts.length > 1 ? `${parts[0]}:${parts[1]}` : `en:${parts[0]}`;
  // A missing Arabic page is not a broken link: the router falls back to the
  // English original and flags it. Only "neither language exists" is a fault.
  let resolved = key;
  if (!pages.has(resolved)) {
    const en = `en:${key.split(':')[1]}`;
    if (pages.has(en)) { fallback.push(`${key} → ${en}`); resolved = en; }
    else { console.log('✗ unknown page  ', key, '   in', l.from); bad++; continue; }
  }
  if (l.frag && !pages.get(resolved).has(l.frag)) {
    console.log('✗ missing anchor', `${resolved}#${l.frag}`, '  in', l.from);
    console.log('   available:', [...pages.get(key)].join(' | '));
    bad++;
  }
}
if (fallback.length) console.log('· falls back to English (not translated yet):', [...new Set(fallback)].join(', '), '\n');
console.log(bad ? `\n${bad} broken link(s)` : `✓ all ${links.length} internal links resolve`);
