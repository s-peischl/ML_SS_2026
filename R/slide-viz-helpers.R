# Reusable teaching plots for MLSS slide decks (Days 1-4).
# Source from slides/*.qmd: source("../R/slide-viz-helpers.R")

plot_workflow_prob_boundary <- function(
    fitted_wf,
    data,
    f1,
    f2,
    y_col = "y",
    title = NULL,
    positive_class = "Gentoo"
) {
  r1 <- range(data[[f1]], na.rm = TRUE)
  r2 <- range(data[[f2]], na.rm = TRUE)
  grid <- expand.grid(
    seq(r1[1] - 0.5, r1[2] + 0.5, length.out = 130),
    seq(r2[1] - 0.5, r2[2] + 0.5, length.out = 130)
  )
  names(grid) <- c(f1, f2)
  for (nm in setdiff(names(data), c(f1, f2, y_col))) {
    v <- data[[nm]]
    grid[[nm]] <- if (is.numeric(v)) {
      stats::median(v, na.rm = TRUE)
    } else {
      tab <- table(v)
      names(tab)[which.max(tab)]
    }
  }
  prob_col <- paste0(".pred_", positive_class)
  grid$prob <- predict(fitted_wf, new_data = grid, type = "prob")[[prob_col]]
  ggplot2::ggplot(data, ggplot2::aes(!!rlang::sym(f1), !!rlang::sym(f2))) +
    ggplot2::geom_raster(
      data = grid,
      ggplot2::aes(!!rlang::sym(f1), !!rlang::sym(f2), fill = prob),
      interpolate = TRUE,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_point(ggplot2::aes(color = !!rlang::sym(y_col)), size = 2.4) +
    ggplot2::scale_fill_gradient(
      low = "turquoise",
      high = "magenta",
      name = paste0("P(", positive_class, ")")
    ) +
    ggplot2::scale_color_manual(
      values = c(Adelie = "black", Gentoo = "white"),
      name = "Species"
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(title = title, x = f1, y = f2)
}

plot_glm_logistic_boundary <- function(
    model,
    data,
    f1,
    f2,
    outcome,
    title = NULL,
    levels = c("Absent", "Present"),
    fill_colors = c(Absent = "turquoise", Present = "magenta")
) {
  r1 <- range(data[[f1]], na.rm = TRUE)
  r2 <- range(data[[f2]], na.rm = TRUE)
  grid <- expand.grid(
    seq(r1[1] - 1, r1[2] + 1, length.out = 150),
    seq(r2[1] - 1, r2[2] + 1, length.out = 150)
  )
  names(grid) <- c(f1, f2)
  for (feat in setdiff(names(data), c(f1, f2, outcome))) {
    grid[[feat]] <- mean(data[[feat]], na.rm = TRUE)
  }
  grid$prob <- predict(model, newdata = grid, type = "response")
  grid$cls <- factor(
    ifelse(grid$prob > 0.5, levels[2], levels[1]),
    levels = levels
  )
  ggplot2::ggplot(data, ggplot2::aes(!!rlang::sym(f1), !!rlang::sym(f2))) +
    ggplot2::geom_raster(
      data = grid,
      ggplot2::aes(!!rlang::sym(f1), !!rlang::sym(f2), fill = cls),
      alpha = 0.32,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_contour(
      data = grid,
      ggplot2::aes(!!rlang::sym(f1), !!rlang::sym(f2), z = prob),
      breaks = 0.5,
      color = "white",
      linewidth = 1.1,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_point(
      ggplot2::aes(fill = !!rlang::sym(outcome)),
      shape = 21,
      color = "black",
      size = 2.6
    ) +
    ggplot2::scale_fill_manual(values = fill_colors, name = "Class") +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(title = title, x = f1, y = f2)
}

plot_pca_biplot <- function(data, num_cols, y_col = "y", arrow_scale = 2.8) {
  mat <- scale(as.matrix(data[, num_cols, drop = FALSE]))
  pc <- stats::prcomp(mat, center = FALSE, scale. = FALSE)
  scores <- as.data.frame(pc$x[, 1:2, drop = FALSE])
  colnames(scores) <- c("PC1", "PC2")
  scores[[y_col]] <- data[[y_col]]

  load <- as.data.frame(pc$rotation[, 1:2, drop = FALSE])
  load$variable <- rownames(load)
  mx <- max(sqrt(load$PC1^2 + load$PC2^2))
  load <- load |>
    dplyr::mutate(
      PC1 = PC1 / mx * arrow_scale,
      PC2 = PC2 / mx * arrow_scale
    )

  ggplot2::ggplot(scores, ggplot2::aes(PC1, PC2, color = !!rlang::sym(y_col))) +
    ggplot2::geom_point(size = 3, alpha = 0.9) +
    ggplot2::stat_ellipse(linewidth = 0.9, alpha = 0.35) +
    ggplot2::geom_segment(
      data = load,
      ggplot2::aes(x = 0, y = 0, xend = PC1, yend = PC2),
      arrow = grid::arrow(length = grid::unit(0.12, "inches")),
      color = "#37474F",
      linewidth = 0.7,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_text(
      data = load,
      ggplot2::aes(x = PC1 * 1.12, y = PC2 * 1.12, label = variable),
      size = 3.8,
      color = "#263238",
      inherit.aes = FALSE
    ) +
    ggplot2::scale_color_manual(
      values = c(Adelie = "turquoise", Gentoo = "magenta"),
      name = "Species"
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = "PCA biplot  -  scores (points) and loadings (arrows)",
      x = "PC1",
      y = "PC2",
      caption = "Arrows show how original measurements contribute to each component"
    )
}

plot_pca_loadings_bars <- function(data, num_cols) {
  mat <- scale(as.matrix(data[, num_cols, drop = FALSE]))
  pc <- stats::prcomp(mat, center = FALSE, scale. = FALSE)
  load <- as.data.frame(pc$rotation[, 1:2, drop = FALSE])
  load$variable <- rownames(load)
  load_long <- tidyr::pivot_longer(
    load,
    c("PC1", "PC2"),
    names_to = "component",
    values_to = "loading"
  )
  load_long$variable <- factor(load_long$variable, levels = rev(num_cols))

  ggplot2::ggplot(load_long, ggplot2::aes(loading, variable, fill = loading > 0)) +
    ggplot2::geom_col(width = 0.72) +
    ggplot2::geom_vline(xintercept = 0, color = "gray40", linewidth = 0.6) +
    ggplot2::facet_wrap(~component, ncol = 2, scales = "free_x") +
    ggplot2::scale_fill_manual(
      values = c("TRUE" = "#1565C0", "FALSE" = "#C62828"),
      labels = c("TRUE" = "positive", "FALSE" = "negative"),
      name = "Direction"
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = "PCA loadings  -  weight of each measurement on each component",
      x = "Loading (after scaling predictors)",
      y = NULL,
      caption = paste(
        "Positive loading: higher values of that column push scores up on the component.",
        "Larger |loading|: stronger contribution."
      )
    )
}

plot_mlp_schematic <- function() {
  nodes <- data.frame(
    layer = rep(c("Inputs", "Hidden", "Output"), c(4, 5, 1)),
    id = c(paste0("x", 1:4), paste0("h", 1:5), "y"),
    x = c(1, 1, 1, 1, 2, 2, 2, 2, 2, 3),
    y = c(4:1, 5:1, 3)
  )
  edges <- data.frame(
    x = rep(1, 20),
    xend = rep(2, 20),
    y = rep(1:4, each = 5),
    yend = rep(1:5, 4)
  )
  out_edges <- data.frame(x = 2, xend = 3, y = 1:5, yend = 3)

  ggplot2::ggplot() +
    ggplot2::geom_segment(
      data = edges,
      ggplot2::aes(x = x + 0.08, xend = xend - 0.08, y = y, yend = yend),
      color = "gray70",
      linewidth = 0.35
    ) +
    ggplot2::geom_segment(
      data = out_edges,
      ggplot2::aes(x = x + 0.08, xend = xend - 0.12, y = y, yend = yend),
      color = "gray70",
      linewidth = 0.35
    ) +
    ggplot2::geom_point(
      data = nodes,
      ggplot2::aes(x, y, fill = layer),
      size = 8.2,
      shape = 21,
      color = "gray25",
      stroke = 0.8
    ) +
    ggplot2::geom_text(
      data = nodes,
      ggplot2::aes(x, y, label = id),
      size = 3,
      fontface = "bold"
    ) +
    ggplot2::annotate(
      "text",
      x = c(1, 2, 3),
      y = 5.4,
      label = c("Bill / island / sex", "Hidden layer", "P(Gentoo)"),
      size = 4,
      fontface = "italic"
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        Inputs = "#B3E5FC",
        Hidden = "#FFE082",
        Output = "#F48FB1"
      )
    ) +
    ggplot2::coord_fixed(
      xlim = c(0.72, 3.28),
      ylim = c(0.6, 5.85),
      clip = "off"
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      legend.position = "none",
      plot.margin = ggplot2::margin(t = 14, r = 8, b = 6, l = 8)
    ) +
    ggplot2::labs(title = "Small MLP (one hidden layer)  -  schematic")
}

# --- rpart control parameters (Day 2 slides) ---

plot_rpart_params_comparison <- function(seed = 42L) {
  set.seed(seed)
  n <- 80L
  demo <- tibble::tibble(
    x1 = c(
      stats::rnorm(n / 2, 0.35, 0.12),
      stats::rnorm(n / 2, 0.65, 0.12)
    ),
    x2 = c(
      stats::rnorm(n / 2, 0.65, 0.12),
      stats::rnorm(n / 2, 0.35, 0.12)
    ),
    y = factor(rep(c("A", "B"), each = n / 2))
  )

  rpart_n_splits <- function(model) {
    sum(model$frame$var != "<leaf>")
  }

  fit_demo <- function(control) {
    rpart::rpart(
      y ~ x1 + x2,
      data = demo,
      method = "class",
      control = control
    )
  }

  wrap_tree <- function(model, subtitle) {
    nsp <- rpart_n_splits(model)
    main_title <- paste0(
      subtitle, "\n(", nsp, " split", ifelse(nsp == 1L, "", "s"), ")"
    )
    tree_model <- model
    patchwork::wrap_elements(
      full = ~{
        graphics::par(mar = c(0.5, 0.5, 2.4, 0.5))
        rpart.plot::rpart.plot(
          tree_model,
          type = 2,
          extra = 102,
          fallen.leaves = TRUE,
          main = main_title,
          cex = 0.72
        )
      }
    )
  }

  rows <- list(
    list(
      tag = "cp",
      left = "Higher cp",
      right = "Lower cp",
      left_ctl = rpart::rpart.control(cp = 0.06, minsplit = 8, maxdepth = 30),
      right_ctl = rpart::rpart.control(cp = 0.0005, minsplit = 8, maxdepth = 30)
    ),
    list(
      tag = "minsplit",
      left = "Larger minsplit",
      right = "Smaller minsplit",
      left_ctl = rpart::rpart.control(cp = 0.01, minsplit = 35, maxdepth = 30),
      right_ctl = rpart::rpart.control(cp = 0.01, minsplit = 4, maxdepth = 30)
    ),
    list(
      tag = "maxdepth",
      left = "maxdepth = 2",
      right = "maxdepth = 6",
      left_ctl = rpart::rpart.control(cp = 0.001, minsplit = 5, maxdepth = 2),
      right_ctl = rpart::rpart.control(cp = 0.001, minsplit = 5, maxdepth = 6)
    )
  )

  row_plots <- lapply(rows, function(row) {
    m_left <- fit_demo(row$left_ctl)
    m_right <- fit_demo(row$right_ctl)
    wrap_tree(m_left, row$left) + wrap_tree(m_right, row$right)
  })

  patchwork::wrap_plots(row_plots, ncol = 1) +
    patchwork::plot_annotation(
      title = "rpart.control(): same demo data, one knob changed per row",
      subtitle = paste(
        "cp = complexity penalty (pruning); minsplit = minimum cases to attempt a split;",
        "maxdepth = maximum tree depth"
      ),
      theme = ggplot2::theme(
        plot.title = ggplot2::element_text(face = "bold", size = 13),
        plot.subtitle = ggplot2::element_text(size = 9.5, color = "gray30")
      )
    )
}

# --- ROC / PR (Gentoo as positive class; y levels Adelie then Gentoo) ---

plot_roc_gentoo <- function(
    predictions,
    truth_col = "y",
    prob_col = ".pred_Gentoo",
    title = "ROC curve  -  Gentoo as positive class",
    subtitle = NULL
) {
  curve <- yardstick::roc_curve(
    predictions,
    truth = !!rlang::sym(truth_col),
    !!rlang::sym(prob_col),
    event_level = "second"
  ) |>
    dplyr::mutate(fpr = 1 - specificity)

  ggplot2::ggplot(curve, ggplot2::aes(fpr, sensitivity)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::geom_point(alpha = 0.35, size = 1.2) +
    ggplot2::geom_abline(
      slope = 1,
      intercept = 0,
      linetype = "dashed",
      alpha = 0.45
    ) +
    ggplot2::coord_equal() +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = "False positive rate (1 - specificity)",
      y = "True positive rate (sensitivity)",
      caption = "event_level = \"second\" so Gentoo is the positive class"
    )
}

plot_pr_gentoo <- function(
    predictions,
    truth_col = "y",
    prob_col = ".pred_Gentoo",
    title = "Precision-recall curve  -  Gentoo as positive class",
    subtitle = NULL
) {
  curve <- yardstick::pr_curve(
    predictions,
    truth = !!rlang::sym(truth_col),
    !!rlang::sym(prob_col),
    event_level = "second"
  )

  ggplot2::ggplot(curve, ggplot2::aes(recall, precision)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::geom_point(alpha = 0.35, size = 1.2) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = "Recall (sensitivity for Gentoo)",
      y = "Precision",
      caption = "event_level = \"second\" so Gentoo is the positive class"
    )
}

# --- Palmer Penguins: predict sex (no species) + SHAP (Day 4 / Module 06) ---

prep_penguins_sex <- function() {
  palmerpenguins::penguins |>
    tidyr::drop_na(
      sex,
      bill_length_mm,
      bill_depth_mm,
      flipper_length_mm,
      body_mass_g,
      island,
      year
    ) |>
    dplyr::mutate(
      sex = droplevels(sex),
      year = as.numeric(year)
    ) |>
    dplyr::select(-species)
}

build_sex_rf_workflow <- function(trees = 300, mtry = 3, min_n = 2) {
  rec <- recipes::recipe(
    sex ~ bill_length_mm + bill_depth_mm + flipper_length_mm +
      body_mass_g + island + year,
    data = prep_penguins_sex()
  ) |>
    recipes::step_zv(recipes::all_predictors()) |>
    recipes::step_dummy(recipes::all_nominal_predictors()) |>
    recipes::step_normalize(recipes::all_numeric_predictors())

  spec <- parsnip::rand_forest(
    trees = trees,
    mtry = mtry,
    min_n = min_n
  ) |>
    parsnip::set_engine("ranger", importance = "impurity", probability = TRUE) |>
    parsnip::set_mode("classification")

  wf <- workflows::workflow() |>
    workflows::add_recipe(rec) |>
    workflows::add_model(spec)

  list(workflow = wf, recipe = rec)
}

fit_sex_rf_workflow <- function(data = prep_penguins_sex(), trees = 300) {
  wf <- build_sex_rf_workflow(trees = trees)$workflow
  workflows::fit(wf, data)
}

bake_workflow_predictors <- function(fitted_wf, data) {
  rec_est <- workflows::extract_recipe(fitted_wf, estimated = TRUE)
  recipes::bake(rec_est, new_data = data, recipes::all_predictors())
}

compute_shap_sex <- function(
    fitted_wf,
    data,
    n_sample = 80,
    n_bg = 35,
    seed = 11,
    positive_class = "male"
) {
  if (!requireNamespace("shapviz", quietly = TRUE)) {
    stop("Install shapviz: install.packages(\"shapviz\")", call. = FALSE)
  }
  if (!requireNamespace("kernelshap", quietly = TRUE)) {
    stop("Install kernelshap: install.packages(\"kernelshap\")", call. = FALSE)
  }

  X_full <- bake_workflow_predictors(fitted_wf, data)
  set.seed(seed)
  n_sample <- min(n_sample, nrow(X_full))
  idx <- sample.int(nrow(X_full), n_sample)
  X <- X_full[idx, , drop = FALSE]
  sex_sample <- data$sex[idx]
  bg <- dplyr::slice_sample(X_full, n = min(n_bg, nrow(X_full)))

  rf <- workflows::extract_fit_parsnip(fitted_wf)$fit
  pred_fun <- function(object, X_new) {
    as.numeric(predict(object, data = X_new)$predictions[, positive_class])
  }

  ks <- kernelshap::kernelshap(
    rf,
    X = X,
    pred_fun = pred_fun,
    bg_X = bg
  )
  shp <- shapviz::shapviz(ks, X_pred = X)

  male_row <- which(sex_sample == "male")[1]
  female_row <- which(sex_sample == "female")[1]

  list(
    shp = shp,
    X = X,
    sex_sample = sex_sample,
    male_row = male_row,
    female_row = female_row,
    positive_class = positive_class
  )
}

fit_sex_shap_bundle <- function(
    data = prep_penguins_sex(),
    trees = 300,
    n_sample = 80,
    n_bg = 35,
    seed = 11
) {
  fit <- fit_sex_rf_workflow(data = data, trees = trees)
  shap_info <- compute_shap_sex(
    fit,
    data = data,
    n_sample = n_sample,
    n_bg = n_bg,
    seed = seed
  )
  c(list(fit = fit, data = data), shap_info)
}

plot_shap_beeswarm <- function(
    shp,
    title = "SHAP beeswarm: predict sex (no species in model)",
    subtitle = "Each dot = one penguin; color = feature value; x = push toward P(male)"
) {
  shapviz::sv_importance(shp, max_display = 12) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(title = title, subtitle = subtitle)
}

plot_shap_waterfall <- function(
    shp,
    row_id,
    title = NULL,
    subtitle = NULL
) {
  p <- shapviz::sv_waterfall(shp, row_id = row_id)
  if (!is.null(title) || !is.null(subtitle)) {
    p <- p + ggplot2::labs(title = title, subtitle = subtitle)
  }
  p
}

plot_sex_rf_vip <- function(fitted_wf, num_features = 12) {
  fitted_wf |>
    workflows::extract_fit_parsnip() |>
    vip::vip(geom = "point", num_features = num_features) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      title = "VIP (random forest on sex task)",
      subtitle = "Global split frequency  -  compare to SHAP for one bird"
    )
}

# --- Multiclass imbalance helpers (Day 4 Part E) ---

prep_penguins_multiclass_imbalance <- function(
    minority_class = "Chinstrap",
    hard_to_class = "Adelie",
    n_minority = 15L
) {
  pg <- palmerpenguins::penguins |>
    tidyr::drop_na(
      species,
      bill_length_mm,
      bill_depth_mm,
      flipper_length_mm,
      body_mass_g,
      island,
      sex,
      year
    ) |>
    dplyr::mutate(
      species = factor(species, levels = c("Adelie", "Gentoo", "Chinstrap")),
      year = as.numeric(year)
    )

  anchor <- pg |>
    dplyr::filter(species == hard_to_class) |>
    dplyr::summarise(
      bill_length_mm = mean(bill_length_mm),
      bill_depth_mm = mean(bill_depth_mm),
      flipper_length_mm = mean(flipper_length_mm),
      body_mass_g = mean(body_mass_g)
    )

  minority <- pg |>
    dplyr::filter(species == minority_class) |>
    dplyr::mutate(
      overlap_dist = sqrt(
        (bill_length_mm - anchor$bill_length_mm)^2 +
          (bill_depth_mm - anchor$bill_depth_mm)^2 +
          ((flipper_length_mm - anchor$flipper_length_mm) / 8)^2 +
          ((body_mass_g - anchor$body_mass_g) / 350)^2
      )
    ) |>
    dplyr::arrange(overlap_dist, island, year, bill_length_mm) |>
    dplyr::slice_head(n = n_minority) |>
    dplyr::select(-overlap_dist)

  dplyr::bind_rows(
    pg |> dplyr::filter(species != minority_class),
    minority
  ) |>
    dplyr::mutate(y3 = factor(species, levels = levels(species))) |>
    dplyr::select(
      y3,
      bill_length_mm,
      bill_depth_mm,
      flipper_length_mm,
      body_mass_g,
      island,
      sex,
      year
    )
}

multiclass_recall_table <- function(
    predictions,
    truth_col = "y3",
    estimate_col = ".pred_class"
) {
  cm <- predictions |>
    yardstick::conf_mat(
      truth = !!rlang::sym(truth_col),
      estimate = !!rlang::sym(estimate_col)
    )

  tab <- as.data.frame(cm$table, stringsAsFactors = FALSE)
  colnames(tab) <- c("truth", "prediction", "n")

  tab |>
    dplyr::group_by(truth) |>
    dplyr::summarise(
      recall = n[prediction == truth] / sum(n),
      .groups = "drop"
    ) |>
    dplyr::arrange(recall)
}

metrics_summary_table_multiclass <- function(fit_res, label) {
  collect_metrics(fit_res) |>
    dplyr::filter(.metric %in% c("accuracy", "recall_macro", "f_meas_macro")) |>
    dplyr::mutate(
      .metric = dplyr::recode(
        .metric,
        recall_macro = "recall_macro",
        f_meas_macro = "f1_macro"
      )
    ) |>
    dplyr::select(.metric, mean, std_err) |>
    dplyr::mutate(model = label) |>
    dplyr::relocate(model)
}

plot_multiclass_recall_compare <- function(
    pred_no,
    pred_up,
    truth_col = "y3",
    highlight_class = "Chinstrap"
) {
  bind_rows(
    multiclass_recall_table(pred_no, truth_col = truth_col) |> mutate(model = "No upsample"),
    multiclass_recall_table(pred_up, truth_col = truth_col) |> mutate(model = "Upsample")
  ) |>
    mutate(recall = round(recall, 3)) |>
    ggplot(aes(truth, recall, fill = model)) +
    geom_col(position = position_dodge(width = 0.75), width = 0.7) +
    geom_hline(yintercept = 1, linetype = "dashed", color = "gray45") +
    scale_fill_manual(values = c("No upsample" = "#4C78A8", "Upsample" = "#E45756")) +
    theme_minimal(base_size = 13) +
    labs(
      title = "Holdout per-class recall",
      subtitle = paste("Highlight:", highlight_class),
      x = "Species",
      y = "Recall",
      fill = NULL
    )
}

compare_metrics_tbl_multiclass <- function(...) {
  tab <- purrr::imap_dfr(
    rlang::list2(...),
    ~ metrics_summary_table_multiclass(.x, .y)
  ) |>
    dplyr::select(model, .metric, mean, std_err) |>
    dplyr::mutate(cell = sprintf("%.3f (%.3f)", mean, std_err)) |>
    dplyr::select(model, .metric, cell) |>
    tidyr::pivot_wider(names_from = model, values_from = cell)

  knitr::kable(tab, caption = "Multiclass CV metrics: mean (std err)")
}
