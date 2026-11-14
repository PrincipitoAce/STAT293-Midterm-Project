# FUNCTION for creating lagged predictors and current responses
make_lagged_design <- function(Y, Z_retained = NULL) {
  Y <- as.matrix(Y)
  storage.mode(Y) <- "double"
  T_obs <- nrow(Y)
  num_series <- ncol(Y)
  stopifnot(T_obs >= 20, num_series >= 1)
  
  # Predict Y[t] using Y[t-1]
  x <- Y[seq_len(T_obs - 1), , drop = FALSE]
  y <- Y[2:T_obs, , drop = FALSE]
  if (is.null(colnames(x))) colnames(x) <- paste0("Y", seq_len(num_series))
  if (is.null(colnames(y))) colnames(y) <- paste0("Y", seq_len(num_series))
  
  if (!is.null(Z_retained)) {
    stopifnot(length(Z_retained) == T_obs)
    # Add Z[t-1] when fitting VARX
    x <- cbind(x, Z_lag1 = Z_retained[seq_len(T_obs - 1)])
  }
  
  list(x = x, y = y, p = num_series)
}

# FUNCTION for separting the training, validation, and testing obs
chronological_split <- function(N) {
  train_end <- floor(0.60 * N)
  validation_end <- floor(0.80 * N)
  stopifnot(train_end > 1, validation_end > train_end, validation_end < N)
  list(
    train = seq_len(train_end),
    validation = seq.int(train_end + 1, validation_end),
    test = seq.int(validation_end + 1, N),
    train_validation = seq_len(validation_end)
  )
}

# FUNCTION for estimating the VAR/VARX coeffs and eval test preds
fit_equations <- function(lagged, method = c("LASSO", "Ridge", "OLS")) {
  method <- match.arg(method)
  x <- lagged$x
  y <- lagged$y
  p <- lagged$p
  N <- nrow(x)
  split <- chronological_split(N)
  
  n_features <- ncol(x)
  coefficients <- matrix(NA_real_, nrow = n_features, ncol = p,
                         dimnames = list(colnames(x), colnames(y)))
  best_lambdas <- rep(NA_real_, p)
  
  # OLS needs enough independent predictor columns
  if (method == "OLS" &&
      qr(x[split$train_validation, , drop = FALSE])$rank < n_features) {
    stop("OLS coefficients are not uniquely identified for this design.")
  }
  
  for (j in seq_len(p)) {
    yj <- y[, j]
    
    # Fit the current response equation
    if (method == "OLS") {
      ols_fit <- lm.fit(x = x[split$train_validation, , drop = FALSE],
                        y = yj[split$train_validation])
      coefficients[, j] <- as.numeric(ols_fit$coefficients)
    } else {
      mix <- if (method == "LASSO") 1 else 0 # glmnet: 1 = LASSO, 0 = Ridge
      path_fit <- glmnet::glmnet(
        x = x[split$train, , drop = FALSE],
        y = yj[split$train],
        family = "gaussian", alpha = mix,
        intercept = FALSE, standardize = TRUE, nlambda = 70
      )
      
      # Predictions for each candidate lambda
      prediction_path <- as.matrix(predict(
        path_fit, newx = x[split$validation, , drop = FALSE],
        s = path_fit$lambda
      ))
      actual_matrix <- matrix(yj[split$validation],
                              nrow = length(split$validation),
                              ncol = ncol(prediction_path))
      validation_mse <- colMeans((prediction_path - actual_matrix)^2)
      lambda_selected <- path_fit$lambda[which.min(validation_mse)] # Lowest validation error
      best_lambdas[j] <- lambda_selected
      
      # Refit on train + validation with the selected lambda
      refit <- glmnet::glmnet(
        x = x[split$train_validation, , drop = FALSE],
        y = yj[split$train_validation],
        family = "gaussian", alpha = mix,
        intercept = FALSE, standardize = TRUE,
        lambda = path_fit$lambda
      )
      coefficients[, j] <- as.numeric(
        coef(refit, s = lambda_selected)
      )[-1]  # Drop intercept row (fixed at zero)
    }
  }
  
  # Predict one period ahead using the observed previous period
  # Not a multi-step forecast
  yhat_test <- x[split$test, , drop = FALSE] %*% coefficients
  test_mse <- mean((y[split$test, , drop = FALSE] - yhat_test)^2)
  
  # Transpose so row i = response and column j = lagged predictor
  A_hat <- t(coefficients[seq_len(p), , drop = FALSE])
  dimnames(A_hat) <- list(colnames(y), colnames(y))
  B_hat <- if (n_features > p) as.numeric(coefficients[p + 1, ]) else NULL
  
  list(
    method = method,
    A_hat = A_hat,
    B_hat = B_hat,
    coefficient_matrix = coefficients,
    chosen_lambdas = best_lambdas,
    test_mse = test_mse,
    split = split
  )
}
