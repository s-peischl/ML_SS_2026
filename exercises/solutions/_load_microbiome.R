# Shared Schloss mouse 16S loader for Day 2 / Day 4 solutions.
# source("_load_microbiome.R") from exercises/solutions/

load_microbiome <- function(prev = 0.10) {
  microbiome_base <- "https://raw.githubusercontent.com/quadram-institute-bioscience/datasciencegroup/main/4_machine_learning/mouse-16s"
  if (!requireNamespace("readr", quietly = TRUE)) stop("Install readr")
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("Install dplyr")

  meta <- readr::read_csv(file.path(microbiome_base, "metadata.csv"), show_col_types = FALSE) |>
    dplyr::rename(sample_id = `#NAME`)
  otu_raw <- readr::read_csv(file.path(microbiome_base, "otutab_raw.csv"), show_col_types = FALSE)
  otu_mat <- t(as.matrix(otu_raw[, -1]))
  colnames(otu_mat) <- otu_raw$`#NAME`
  meta <- dplyr::filter(meta, sample_id %in% rownames(otu_mat))
  otu_mat <- otu_mat[meta$sample_id, , drop = FALSE]
  prev_keep <- colMeans(otu_mat > 0) >= prev
  otu_mat <- otu_mat[, prev_keep, drop = FALSE]

  dplyr::bind_cols(
    sample_id = meta$sample_id,
    Individual = meta$Individual,
    Label = factor(meta$Label, levels = c("Early", "Late")),
    Sex = meta$Sex,
    Day = meta$Day,
    as.data.frame(otu_mat)
  )
}

mic_otu_cols <- function(mic) {
  setdiff(names(mic), c("sample_id", "Individual", "Label", "Sex", "Day"))
}

mic_recipe_base <- function(data, otu_cols = mic_otu_cols(data), log1p = TRUE) {
  rec <- recipes::recipe(Label ~ ., data = data) |>
    recipes::update_role(sample_id, Individual, new_role = "id")
  if (log1p) {
    rec <- rec |>
      recipes::step_mutate(dplyr::across(dplyr::all_of(otu_cols), ~ log1p(.x)))
  }
  rec |>
    recipes::step_zv(recipes::all_predictors()) |>
    recipes::step_normalize(recipes::all_numeric_predictors())
}

mic_group_folds <- function(data, v = 5) {
  rsample::group_vfold_cv(data, group = Individual, v = v)
}
