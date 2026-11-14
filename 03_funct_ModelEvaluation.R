# FUNCTION for comparing coeff error
score_fit <- function(fit, A_true, scenario, fitted_model,
                      B_true = NULL, tolerance = 1e-7) {
  stopifnot(all(dim(fit$A_hat) == dim(A_true)))
  # Check which A entries are truly nonzero and which were selected
  actual_nonzero <- abs(A_true) > tolerance
  selected_nonzero <- abs(fit$A_hat) > tolerance
  
  # Compute TPR/FPR for LASSO only
  if (fit$method == "LASSO") {
    TPR <- sum(selected_nonzero & actual_nonzero) / sum(actual_nonzero)
    FPR <- sum(selected_nonzero & !actual_nonzero) / sum(!actual_nonzero)
  } else {
    TPR <- NA_real_
    FPR <- NA_real_
  }
  
  data.frame(scenario = scenario,
             fitted_model = fitted_model,
             method = fit$method,
             relative_A_error = norm(fit$A_hat - A_true, type = "F") /
      norm(A_true, type = "F"),
      test_one_step_MSE = fit$test_mse,
      A_true_nonzero = sum(actual_nonzero),
      A_estimated_nonzero = sum(selected_nonzero),
      TPR = TPR,
      FPR = FPR,
      exogenous_B_L2_error = if (!is.null(fit$B_hat) && !is.null(B_true))
      sqrt(sum((fit$B_hat - B_true)^2)) else NA_real_,
    stringsAsFactors = FALSE)
}
# FUNCTION for adjusting matrices for plotting
coef_to_long <- function(mat, panel) {
  grid <- expand.grid(response = seq_len(nrow(mat)), predictor = seq_len(ncol(mat)))
  grid$value <- as.vector(mat)
  # R stores matrix values column by column
  grid$panel <- panel
  grid
}