#NHSCR Validation tests
# Unit tests for Compare_one function
# Uses Test_helpers.R 
################################################################################
source(here::here("functions", "Compare_outputs_functions.R"), echo = FALSE)
source(here::here("functions", "Validation_test_helpers.R"), echo = FALSE)

test_results <- list()

#===============================================================================
# TEST 1 = Clean PASS (Test script does not flag false positives, 
# when both outputs are identical it returns PASS)
#===============================================================================
test_results[[1]] <- run_test("test_clean_pass", function() {
  df <- data.frame(id = 1:5, name = c("a", "b", "c", "d", "e"))
  r_path <- write_test_csv(df, "test_r.csv")
  sas_path <- write_test_sas(df, "test_sas.sas7bdat")
  
  result <- compare_one("test_clean_pass", r_path, sas_path)
  
  stopifnot("Should be PASS"          = result$status == "PASS")
  stopifnot("Should have 0 val diffs" = result$value_diffs == 0)
})

#===============================================================================
# TEST 2 = Value Mismatch (Tests script can catch real data differences, when 
# one value differs between SAS and R, it returns MISMATCH)
#===============================================================================
test_results[[2]] <- run_test("test_value_mismatch", function() {
  sas_df <- data.frame(id = 1:5, value = c(1, 2, 3, 4, 5))
  r_df <- data.frame(id = 1:5, value = c(1, 2, 99, 4, 5))
  r_path <- write_test_csv(r_df, "test_r.csv")
  sas_path <- write_test_sas(sas_df, "test_sas.sas7bdat")
  
  result <- compare_one("test_value_mismatch", r_path, sas_path)
  
  stopifnot("Should be MISMATCH"            = result$status == "MISMATCH")
  stopifnot("Should have val diffs"         = result$value_diffs> 0)
  stopifnot("Should report mismatched cols" = result$mismatched_cols != "none")
})

#===============================================================================
# TEST 3 = Row Count Mismatch (Tests the script catches missing rows before
# diffdf runs, when SAS has more rows than R, it returns ROW COUNT MISMATCH)
#===============================================================================
test_results[[3]] <- run_test("test_row_count_mismatch", function() {
  sas_df <- data.frame(id = 1:10, value = 1:10)
  r_df <- data.frame(id = 1:4, value = 1:4)
  r_path <- write_test_csv(r_df, "test_r.csv")
  sas_path <- write_test_sas(sas_df, "test_sas.sas7bdat")
  
  result <- compare_one("test_row_count_mismatch", r_path, sas_path)
  
  stopifnot("Should be MISMATCH"         = result$status == "ROW COUNT MISMATCH")
  stopifnot("R rows should be 4"         = result$r_rows == 4)
  stopifnot("SAS rows should be 10"      = result$sas_rows == 10)
})

#===============================================================================
# TEST 4 = Empty String vs NA (Tests script correctly treats SAS blank strings
# as equivalent to R represents missing value as NA)
#===============================================================================
test_results[[4]] <- run_test("empty_string_na", function(){
  sas_df <- data.frame(id = 1:3,
                       name = c("Bob", "", "Jack"),
                       stringsAsFactors = FALSE)
  r_df <- data.frame(id = 1:3,
                     name = c("Bob", NA, "Jack"))
  r_path <- write_test_csv(r_df, "test_r.csv")
  sas_path <- write_test_sas(sas_df, "test_sas.sas7bdat")
  
  result <- compare_one("empty_string_na", r_path, sas_path)
  
  stopifnot("Should be PASS"    = result$status == "PASS")

})

#===============================================================================
# TEST 5 = Missing File (Tests the script handles files, when R output does not 
# exist, it prints R-Missing)
#===============================================================================
test_results[[5]] <- run_test("test_missing_R_file", function(){
  sas_df <- data.frame(id = 1:5, value = c(1, 2, 3, 4, 5))
  sas_path <- write_test_csv(sas_df, "test_sas.sas7dbat")
  
  result <- compare_one("test_missing_R_file", "/temp/does_not_exist.csv", 
                        sas_path)
  
  stopifnot(result$status == "R-MISSING")
  stopifnot(is.na(result$r_rows))
})

#===============================================================================
# SUMMARY - Print overall PASS/FAIL count
#===============================================================================
cat("\n==================== TEST SUMMARY ===========================\n")

passed <- sum(sapply(test_results, function(t) t$passed))
failed <- sum(sapply(test_results, function(t) !t$passed))

cat(sprintf("Total:  %d\n", length(test_results)))
cat(sprintf("Passed: %d\n", passed))
cat(sprintf("Failed: %d\n", failed))

if (failed > 0) {
  cat("\nFailed tests:\n")
  for (t in test_results) {
    if (!t$passed) {
      cat(sprintf("  - %-40s %s\n", t$name, t$error))
      }
  }
  cat("\n VALIDATION SCRIPT HAS ISSUES \n")
} else {"\n ALL TESTS PASSED \n"
  
}


