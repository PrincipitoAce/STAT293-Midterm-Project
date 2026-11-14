# FUNCTION for simulating data
sim_data_VARX <- function(A, B, Z, errors, burn_in){
  # Num of obs and variables from error matrix
  total_n <- nrow(errors)
  p <- ncol(errors)
  # Start the Y time series at zero
  Y <- matrix(0, nrow = total_n, ncol=p)
  
  # Generate Y[t] using its past value, lagged Z and new shock
  for (t in 2:total_n) {
    Y[t, ] <- as.vector(A %*% Y[t-1, ] + # Lagged Y effects
                          B*Z[t-1] + # Lagged Z effect
                          errors[t, ]) # Random shock
  }
  # Remove first burn_in rows
  Y <- Y[(burn_in + 1):total_n, , drop=FALSE] # Keep last n obs
  # Name each time series
  colnames(Y) <- paste0("Y", 1:p)
  
  # Return simulated data
  return(Y)
}