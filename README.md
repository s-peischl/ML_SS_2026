# ML Summer School 2026 — teaching hub (Quarto)

Static site + slide decks + student `.Rmd` notebooks. **Shiny / Shinylive apps are not part of this project** (removed for simpler CI and local use).

## Local preview (recommended)

From this directory:

```bash
Rscript -e "install.packages(c('knitr','rmarkdown','glmnet','caret','dplyr','ggplot2','GGally','rlang','MASS','rpart','rpart.plot','rcartocolor'), repos='https://cloud.r-project.org')"
quarto preview
```

Then use the browser UI Quarto prints. **Relative links** (slides, notebooks, modules) resolve correctly here.

Opening `_site/index.html` directly with `file://` can still break some browsers; use `quarto preview` or any static server from `_site/`:

```bash
cd _site && python3 -m http.server 8787
```

## Local render

```bash
quarto render
```

Output is `_site/`. We **do not** set `site-url` in `_quarto.yml` so internal links stay **relative** (works for local preview and GitHub Pages under `/ML_SS_2026/`).

## GitHub Actions

- Workflow: `.github/workflows/publish.yml`
- R dependencies: root **`DESCRIPTION`** (used by `r-lib/actions/setup-r-dependencies`)
- If **Deploy** waits forever: *Settings → Environments → `github-pages`* — remove required reviewers or approve the deployment.

## Project layout

- `slides/` — revealjs decks; `slides/_metadata.yml` adds a footer link to the hub
- `notebooks/` — student `.Rmd` sources (`project.render` includes them)
- `_includes/` — shared fragments for slides
