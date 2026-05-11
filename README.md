# ML Summer School 2026 — teaching hub (Quarto)

Static site + slide decks + student `.Rmd` notebooks. GitHub Actions renders with Quarto and deploys to GitHub Pages.

## Local build

```bash
cd teaching-hub
# R packages used by slides + notebooks (add others if render errors):
Rscript -e "install.packages(c('knitr','rmarkdown','glmnet','caret','dplyr','ggplot2','GGally','rlang','MASS','rpart','rpart.plot','rcartocolor'), repos='https://cloud.r-project.org')"
quarto render
```

Open `_site/index.html` or run `quarto preview`.

## GitHub Actions (“doesn’t build” / “runs forever”)

### It “just keeps running”

1. **Old workflow runs (#5 on commit `1644052`, etc.)** — cancel them in the Actions UI; they used heavier setup. Current `main` **does not embed Shinylive in slides** (only static callouts + App Library links), so **render should finish in a few minutes** once R packages are cached.
2. **First run after a cache miss** — installing R packages from `DESCRIPTION` can still take **~8–20 minutes**; subsequent pushes are much faster.
3. **Stuck on “Deploy” / “Waiting”** — open the run and look for **Review deployments** or **Waiting for approval**. In *Settings → Environments → `github-pages`* turn off **required reviewers** (or approve the deployment). Until that is approved, the job looks like it “never finishes”.
4. **Stuck on “Render site”** — open that step’s log; the first red line is the real error (missing R package, chunk failure).
5. **Pages never updates** — *Settings → Pages → Source* must be **GitHub Actions**, not “Deploy from a branch”.
6. **New pushes** — the workflow uses `cancel-in-progress: true` so an older stuck run should cancel when you push again.

### Re-enabling Shinylive inside slides (optional, local)

Slide decks omit the Shinylive filter so CI stays fast. To embed apps again on your machine, add `filters: [shinylive]` to each `slides/day-*.qmd` YAML and restore `` `{shinylive-r}` `` chunks; install the R package `shinylive` from R-universe.

### Dependency list for CI

R packages used by slides + notebooks are declared in the repo-root **`DESCRIPTION`** (Imports). Add a package there if `setup-r-dependencies` reports a missing library.

## Project layout

- `slides/` — revealjs decks; `slides/_metadata.yml` adds a footer link back to the hub.
- `notebooks/` — student `.Rmd` sources (also listed in `_quarto.yml` `project.render`).
- `_includes/` — shared fragments pulled into slides.
