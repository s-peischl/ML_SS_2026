# Static figures for the teaching hub

Put **PNG**, **SVG**, or **PDF** files here when you do **not** generate the plot from an R chunk (screenshots, exported diagrams, photos).

**Prefer R + `ggplot2` in slide includes** when the figure should stay reproducible — see `_includes/day01-rstudio-intro.qmd`.

## Subfolders

| Folder | Use for |
|--------|---------|
| [`slides/`](slides/) | Images for one deck (e.g. RStudio screenshot for Monday) |
| [`shared/`](shared/) | Logos, diagrams reused on hub pages, modules, or several decks |
| [`shared/penguins/`](shared/penguins/) | Palmer penguins artwork (`lter_penguins.png`, Allison Horst) — **Day 2 & 4 slides only** |
| [`shared/old_faithful.jpg`](shared/old_faithful.jpg) | Old Faithful geyser photo — **Day 1** ggplot demo |

## Path cheat sheet (Quarto)

Paths are **relative to the `.qmd` file** that references the image.

| Source file | Example |
|-------------|---------|
| `slides/day-01-monday.qmd` | `../assets/figures/slides/rstudio-panes.png` |
| `_includes/day01-*.qmd` | `../assets/figures/slides/rstudio-panes.png` |
| `modules/module-01-*.qmd` | `../assets/figures/shared/course-logo.png` |
| `index.qmd` (hub home) | `assets/figures/shared/course-logo.png` |

## Markdown

```markdown
![](../assets/figures/slides/my-figure.png){width=85% fig-align="center"}
```

## R chunk

```r
#| echo: false
#| fig-align: center
#| out-width: "85%"
knitr::include_graphics("../assets/figures/slides/my-figure.png")
```
