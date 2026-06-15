# Lab exercise solutions

**Student-facing.** Browse rendered notebooks from the [lab exercises home](../index.qmd).

## Render locally

From the `teaching-hub/` folder:

```bash
quarto render exercises/index.qmd
quarto render exercises/solutions/day01-microbiome-classical.Rmd
quarto render exercises/solutions/day02-microbiome-pipeline.Rmd
quarto render exercises/solutions/day04-microbiome-advanced.Rmd
```

Microbiome solutions need **network access** to download CSVs from GitHub. **Day 1** embeds its own loader in the `.Rmd`; **Days 2 and 4** use `source("_load_microbiome.R")` from `exercises/solutions/`.

## Shared loader (Days 2 and 4)

[`_load_microbiome.R`](_load_microbiome.R) — `load_microbiome(prev = 0.10)`, `mic_otu_cols()`, `mic_recipe_base()`, `mic_group_folds()`.

## Current solutions

| Day | File | `set.seed` | ~Runtime |
|-----|------|------------|----------|
| 1 | `day01-microbiome-classical.Rmd` | 7 | ~8 min (+ download) |
| 2 | `day02-microbiome-pipeline.Rmd` | 7 | ~5 min (+ download) |
| 4 | `day04-microbiome-advanced.Rmd` | 7, 9, 11 | ~5 min first knit (+ download); SHAP uses top 10 OTUs only |

## Archive

Older A–F block solutions: [`_archive/`](_archive/).

## Spot-check

- **Day 1:** PCA often separates Early/Late; lasso selects a sparse OTU set
- **Day 2:** test accuracy for tree and logistic both above majority baseline
- **Day 4:** grouped CV `roc_auc` > 0.5; VIP/SHAP show top OTUs (not causal claims)

**Day 4** uses **`group_vfold_cv(group = Individual)`**. **Day 2** uses a random train/test split for teaching — discuss leakage in class.
