# tests that diresctories exist
safe_path_exists <- function(path) {
  tryCatch(
    {
      # Validate input type
      if (!is.character(path) || length(path) != 1) {
        stop("Path must be a single string.")
      }

      # Check if file or directory exists
      exists <- file.exists(path)
      return(exists)
    },
    error = function(e) {
      # Handle any unexpected errors
      message("Error checking path: ", e$message)
      return(FALSE)
    }
  )
}
