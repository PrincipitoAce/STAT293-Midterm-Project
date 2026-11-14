# FUNCTION for generating VAR(1) obs using transition matrix and innovations
simulate_var1 <- function(A, innovations, burn_in) {
  total <- nrow(innovations) # Total time points
  p <- ncol(innovations) # Num of vars
  
  # Check enough obs for burn-in
  if (total <= burn_in + 2L) stop("Not enough innovations")
  
  # Empty matrix for simulated Y values
  Y <- matrix(0, nrow = total, ncol = p)
  
  # Generate Y[t] using A, Y[t-1], and random shocks
  for (t in 2:total) {
    Y[t, ] <- as.numeric(A %*% Y[t - 1L, ]) + innovations[t, ]
  }
  
  # Remove initial burn-in observations
  out <- Y[(burn_in + 1L):total, , drop = FALSE]
  colnames(out) <- paste0("Y", seq_len(p)) # Name variables Y1, Y2,...
  
  out
}

# FUNCTION for approximating the upper and lower spectral stability measures
#         with frequency grid
spectral_extrema <- function(A, n_frequency = 121L) {
  p <- nrow(A) # Num of vars
  I <- diag(p) # Identity matrix
  
  maximum <- -Inf # Starting value for largest eigenvalue
  minimum <- Inf # Starting value for smallest eigenvalue
  
  # Loop through frequencies between -pi and pi
  for (theta in seq(-pi, pi, length.out = n_frequency)) {
    
    # Calculate spectral density matrix at frequency theta
    H <- solve(I - A * exp(-1i * theta))
    f <- H %*% Conj(t(H)) / (2 * pi)
    
    # Eigenvalues of spectral density matrix
    eigenvalues <- Re(eigen(f, only.values = TRUE)$values)
    
    # Update largest and smallest eigenvalues across frequencies
    maximum <- max(maximum, eigenvalues)
    minimum <- min(minimum, eigenvalues)
  }
  
  # Return approx spectral stability measures
  c(M_approx = maximum, m_approx = minimum)
}

