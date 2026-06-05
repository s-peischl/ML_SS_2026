# Reading companion maintainer notes

This folder keeps the eight chapter pages linked from `modules/index.qmd` (displayed as **Reading companion** in the navbar).

## Writing template (all chapters)

1. Start with 2-4 paragraphs of plain-language motivation.
2. Teach with narrative `##` sections in order: intuition -> small example -> caveats.
3. Use one running dataset thread (simulated genes or Palmer Penguins) and link to data cards.
4. Keep code light in concept chapters (01-03, 05-06); keep runnable code in code chapters (04, 07, 08).
5. Add one `callout-tip` takeaway near the end.
6. Keep footer links compact (previous/next chapter, one slide link, one notebook link).

## Consistency rules

- Use chapter wording in text: "Chapter 1", "Chapter 2", etc.
- Keep file paths unchanged (`module-*.qmd`) to avoid breaking links.
- Avoid internal taxonomy labels in student-facing prose (`Canonical_code`, `Lab_exploration`).

## Shared include warning

`module-04-pipeline.qmd` must keep:

`{{< include ../_includes/day02-tidymodels-walkthrough.qmd >}}`

That include is shared with Day 2 slides and should remain a single source of truth.
