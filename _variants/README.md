# _variants — raw imports of every vendored kit copy

Layout: `_variants/<kit>/<source_project>/` — an exact copy of each project's
vendored package as of 2026-07-07 (before consolidation).

Purpose: guarantee no edit from any project is ever lost. When a kit is
consolidated into a top-level canonical folder, its `_variants/<kit>/` folder
is deleted from the working tree — git history keeps it forever.

To recover any variant later:
    git log --oneline -- _variants/<kit>/<project>
    git checkout <sha> -- _variants/<kit>/<project>
