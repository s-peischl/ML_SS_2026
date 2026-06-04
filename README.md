# ML Summer School 2026 — teaching hub (Quarto)

Static site + slide decks + student `.Rmd` notebooks. **Shiny / Shinylive apps are not part of this project** (removed for simpler CI and local use).

## Local preview (recommended)

From this directory:

```bash
Rscript -e "install.packages(c('knitr','rmarkdown','glmnet','tidymodels','dplyr','ggplot2','GGally','rlang','MASS','rpart','rpart.plot','rcartocolor','ranger','xgboost','themis'), repos='https://cloud.r-project.org')"
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

## Printable slides (PDF)

Reveal.js decks support **print layout** (one slide per page). No separate LaTeX build is required.

### In the browser (recommended)

1. Render or preview: `quarto preview` (or open `_site/slides/day-01-monday.html` via a local server).
2. Open a deck in **print mode**, e.g.  
   `slides/day-01-monday.html?print-pdf`  
   (or click **Print PDF** in the slide footer).
3. **Ctrl/Cmd+P** → **Save as PDF**  
   - Layout: **Landscape**  
   - Margins: **None**  
   - **Background graphics**: enabled  

Works best in **Chrome** or **Chromium**.

### Command line (optional)

```bash
chmod +x scripts/export-slides-pdf.sh
./scripts/export-slides-pdf.sh          # all day decks
./scripts/export-slides-pdf.sh day-02-tuesday
```

Without [decktape](https://github.com/astefanutti/decktape) (`npm install -g decktape`), the script prints the browser URLs above. With decktape, PDFs are written to `slides/pdf/`.

Print options for all decks live in `slides/_metadata.yml` (`pdf-max-pages-per-slide`, slide numbers in print view).

## GitHub Actions

- Workflow: `.github/workflows/publish.yml`
- R dependencies: root **`DESCRIPTION`** (used by `r-lib/actions/setup-r-dependencies`)
- If **Deploy** waits forever: *Settings → Environments → `github-pages`* — remove required reviewers or approve the deployment.

## Project layout

- `slides/` — revealjs decks; `slides/_metadata.yml` adds a footer link to the hub
- `notebooks/` — student `.Rmd` sources (`project.render` includes them)
- `_includes/` — shared fragments for slides
