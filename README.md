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

## GitHub Actions (“doesn’t build” / “runs forever”)

### It “just keeps running”

1. **First run is slow (often 15–45 minutes)** — installs many R binaries, then **Shinylive** may download large web assets on first use. Later runs are faster thanks to **caches** (R packages + `~/.cache/shinylive`).
2. **Stuck on “Deploy” / “Waiting”** — open the run and look for **Review deployments** or **Waiting for approval**. In *Settings → Environments → `github-pages`* turn off **required reviewers** (or approve the deployment). Until that is approved, the job looks like it “never finishes”.
3. **Stuck on “Render site”** — open that step’s log; the first red line is the real error (missing R package, chunk failure, Quarto filter).
4. **Pages never updates** — *Settings → Pages → Source* must be **GitHub Actions**, not “Deploy from a branch”.
5. **New pushes** — the workflow uses `cancel-in-progress: true` so an older stuck run should cancel when you push again.

### Dependency list for CI

R packages used by slides + notebooks are declared in the repo-root **`DESCRIPTION`** (Imports). Add a package there if `setup-r-dependencies` reports a missing library. `shinylive` is still installed from **R-universe** in a separate step (see workflow).

## Project layout

- `slides/` — revealjs decks; `slides/_metadata.yml` adds a footer link back to the hub.
- `notebooks/` — student `.Rmd` sources (also listed in `_quarto.yml` `project.render`).
- `_includes/` — shared fragments pulled into slides.
