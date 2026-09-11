# helper functions for NHSCR validation unit tests - used by Validation_tests.R
################################################################################

#load packages 
suppressPackageStartupMessages({library(haven)})

#-------------------------------------------------------------------------------
# Writes small dummy dataframe to a temp csv file
write_test_csv <- function(df, filename) {
  path <-  file.path(tempdir(), filename)
  write.csv(df, path, row.names=FALSE)
  path
}

#-------------------------------------------------------------------------------
# Writes small dummy dataframe to a temp sas7bdat file
write_test_sas <- function(df, filename) {
  path <-  file.path(tempdir(), filename)
  write_sas(df, path)
  path
}

#-------------------------------------------------------------------------------
# Wrapper function to run tests safely and catch any errors so the whole script 
# doesn't crash if any test fails. Prints PASS or FAIL and returns a list with name,
# passed and error fields so the summary can count total passes and failures
run_test <- function(test_name, test_fn) {
  cat(sprintf("Running: %-40s", test_name))
  result <- tryCatch({
    test_fn()
    cat("Pass\n")
    list(name = test_name, passed = TRUE, error = "none")
    
  }, error = function(e) {
    cat("FAIL\n")
    cat(sprintf(" Reason: %s\n", conditionMessage(e)))
    list(name = test_name, passed = FALSE, error = conditionMessage(e))
  })
  return(result)
}