# ML Summer School 2026 — teaching hub (Quarto)

Static site + slide decks + student `.Rmd` notebooks. GitHub Actions renders with Quarto and deploys to GitHub Pages.

## Local build

```bash
cd teaching-hub
# R packages used by slides + notebooks (add others if render errors):
Rscript -e "install.packages(c('knitr','rmarkdown','glmnet','caret','dplyr','ggplot2','GGally','rlang','MASS','rpart','rpart.plot','rcartocolor'), repos='https://cloud.r-project.org')"
Rscript -e "install.packages('shinylive', repos=c('https://posit-dev.r-universe.dev','https://cloud.r-project.org'))"
quarto render
```

Open `_site/index.html` or run `quarto preview`.

## GitHub Actions (“doesn’t build” checklist)

1. **Actions tab** — open the latest *Publish Quarto site* run; expand **Render site** to see the first R/Quarto error (missing package, chunk failure, etc.).
2. **Pages** — *Settings → Pages → Build and deployment → Source* must be **GitHub Actions** (not “Deploy from a branch”). First-time deploy may wait on the `github-pages` environment if you use protection rules.
3. **Workflow permissions** — this repo uses `permissions: pages: write` + `id-token: write`; default `GITHUB_TOKEN` is enough for Pages publish from Actions.
4. **R package errors** — add the missing CRAN package to the `Install R packages` step in `.github/workflows/publish.yml` and push again.

## Project layout

- `slides/` — revealjs decks; `slides/_metadata.yml` adds a footer link back to the hub.
- `notebooks/` — student `.Rmd` sources (also listed in `_quarto.yml` `project.render`).
- `_includes/` — shared fragments pulled into slides.
