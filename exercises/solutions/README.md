# Lab exercise solutions

**Student-facing.** Browse rendered notebooks from the [lab exercises home](../index.qmd) or the [handbook Solutions section](../mlss2026-lab-exercises.qmd#solutions).

Parent handbook: [`../mlss2026-lab-exercises.qmd`](../mlss2026-lab-exercises.qmd)

## Render locally

From the `teaching-hub/` folder:

```bash
quarto render exercises/mlss2026-lab-exercises.qmd
quarto render exercises/solutions/day01-regression-complexity-ladder.Rmd
# … or render all solutions:
for f in exercises/solutions/*.{Rmd,qmd}; do quarto render "$f"; done
```

Day 2 and Day 4 microbiome solutions need **network access** to download CSVs from GitHub. Run from `exercises/solutions/` so `source("_load_microbiome.R")` resolves.

## Shared loader

[`_load_microbiome.R`](_load_microbiome.R) — `load_microbiome(prev = 0.10)`, `mic_otu_cols()`, `mic_group_folds()`.

## Exercise map

| ID | Handbook block | File | `set.seed` | ~Runtime |
|----|----------------|------|------------|----------|
| 1A | Day 1 data card | `day01-data-card-example.qmd` | — | 5 min read |
| 1B | Regression ladder | `day01-regression-complexity-ladder.Rmd` | 123 | 2 min |
| 1C | Classification ladder | `day01-classification-complexity-ladder.Rmd` | 123 | 2 min |
| 1D | Manual k-fold CV | `day01-manual-kfold-cv.Rmd` | 42 | 2 min |
| 2A | Microbiome EDA | `day02-microbiome-eda.Rmd` | 7 | 3 min (+ download) |
| 2B | Baseline workflow | `day02-microbiome-baseline-workflow.Rmd` | 7 | 4 min (+ download) |
| 2C | Group CV + tune | `day02-microbiome-tune-cv.Rmd` | 7 | 5 min (+ download) |
| 2D | Refactor Day 1 | `day02-refactor-day1-with-tidymodels.Rmd` | 123 | 2 min |
| 4A | Imputation | `day04-microbiome-imputation.Rmd` | 4, 14 | 4 min (+ download) |
| 4B | Imbalance | `day04-microbiome-imbalance.Rmd` | 4, 11–13 | 5 min (+ download) |
| 4C | PCA | `day04-microbiome-pca.Rmd` | 7, 8 | 5 min (+ download) |
| 4D | Model shoot-out | `day04-microbiome-model-compare.Rmd` | 7, 9 | 5 min (+ download) |
| 4E | Metrics / select_best | `day04-microbiome-metrics-select-best.Rmd` | 4, 8 | 5 min (+ download) |

## Expected outputs (spot-check)

- **1B:** test RMSE lowest for GeneA+GeneB; rises for all-10-gene model
- **1C:** sensitivity for `Present` drops when too few genes or too many noise genes
- **2C:** `group_vfold_cv` by `Individual`; `roc_auc` > 0.5 (exact value varies)
- **4A:** impute-in-recipe grouped CV ≥ complete-case strategy (similar AUC; fewer rows dropped with imputation)
- **4B:** `step_upsample` often increases sensitivity vs no upsample
- **4C:** PCA vs no-PCA AUC within ~0.05 (either can win)
- **4E:** `select_best` may pick different `tree_depth` for accuracy vs `pr_auc`

**Day 4:** always use **`group_vfold_cv(group = Individual)`** — never row-wise `vfold_cv(strata = Label)` as the final answer on this cohort.
