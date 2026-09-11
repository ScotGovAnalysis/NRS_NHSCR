# Validation test: compares SAS output and R output.
# Checks for structural and value differences and flags mismatches.
################################################################################

# Record start time
start_time <- Sys.time()

# Packages load
suppressPackageStartupMessages({library(here)})

source(here::here("functions", "Compare_outputs_functions.R"), echo = FALSE)
source(here::here("functions", "Make_comparisons.R"), echo = FALSE)

# Input the extract month to test for R and SAS
extract_month_r <- "Jan26"
extract_month_sas <- "jan26"

# Base paths for migration, silc, sls and annual r and sas outputs
base_r_path <- here("/mnt", "dl_acp79_modify", paste0("SAS to R - Testing"), 
                            "Testing_R_code")

base_sas_path <- here("/mnt", "dl_acp79_modify", paste0("SAS to R - Testing"))

base_migrant_r_path <- here(base_r_path, paste0("Migration_extract_", extract_month_r))

base_silc_r_path <- here(base_r_path, paste0("SILC_Extract_", extract_month_r))

base_sls_r_path <- here(base_r_path, paste0("SLS_Extract_", extract_month_r))

base_annual_r_path <- here("/mnt", "dl_acp79_modify", paste0("SAS to R - Testing"), 
                           paste0("Testing_R_codeAnnual_extract_", extract_month_r))

base_migrant_sas_path <- here(base_sas_path, paste0("SAS to R - Migrants Extract"))

base_silc_sas_path <- here(base_sas_path, paste0("SAS to R - SILC Extract"))

base_sls_sas_path <- here(base_sas_path, paste0("SAS to R - Download - Jan 26"))

base_annual_sas_path <- here("/mnt", "dl_acp79_modify", "Adminteam_extract", "Output")

# Check if validation directory exists and create one if not
if (!dir.exists(here(base_r_path, "validation"))) {
  dir.create(here(base_r_path, "validation"), 
             recursive = TRUE, showWarnings = FALSE)
}

# list of SAS and R outputs for comparison, each entry contains label, r_path,
# and sas_path
comparisons <- list(
  make_comparison("postings_migration", "Postings_migration", "mig_postings",
                  base_migrant_r_path, base_migrant_sas_path),
  make_comparison("postings_postcode", "Postcodes", "mig_postcode",
                  base_migrant_r_path, base_migrant_sas_path),
  make_comparison("persons", "Persons", "mig_person",
                  base_migrant_r_path, base_migrant_sas_path),
  make_comparison("chiprac", "chiprac", "mig_chiprac",
                  base_migrant_r_path, base_migrant_sas_path),
  make_comparison("surhisttab", "surhisttab", "surhisttab",
                  base_silc_r_path, base_silc_sas_path),
  make_comparison("suppspine", "suppspine", "suppspine",
                  base_silc_r_path, base_silc_sas_path),
  make_comparison("pchistab", "pchistab", "pchisttab",
                  base_silc_r_path, base_silc_sas_path),
  make_comparison("index_postings", "index_postings", "index_postings",
                  base_silc_r_path, base_silc_sas_path),
  make_comparison("forhisttab", "forhisttab", "forhisttab",
                  base_silc_r_path, base_silc_sas_path),
  make_comparison("basicspine", "basicsipine", "basicspine",
                  base_silc_r_path, base_silc_sas_path),
  make_text_comparison("sls1", "sls1", "sls1",
                  base_sls_r_path, base_sls_sas_path, TRUE),
  make_text_comparison("sls2", "sls2", "sls2",
                       base_sls_r_path, base_sls_sas_path, TRUE),
  make_text_comparison("sls3", "sls3", "sls3",
                       base_sls_r_path, base_sls_sas_path, TRUE)
)

# Run comparison for each output pair using compare_one()
results <- lapply(comparisons, function(c) {
  is_text <- length(c) > 3 && isTRUE(c[[4]])
  compare_one(c[[1]], c[[2]], c[[3]], is_text)
})

#-------------------------------------------------------------------------------
# Output summary table of validation results
cat("\n========== NHSCR VALIDATION SUMMARY  ==========\n\n")
cat(sprintf("%-25s  %-22s  %6s  %6s  %6s  %6s  %8s  %5s\n", "Output", "Status", 
            "R rows", "SAS rows", "R cols", "SAS cols", "ValDiffs", "Attr"))
cat(strrep("-", 82), "\n")
for (r in results) {
  cat(sprintf("%-25s  %-22s  %6s  %6s  %6s  %6s  %8s  %5s\n",
              substr(r$label, 1, 25),
              substr(r$status, 1, 22),
              as.character(r$r_rows),
              as.character(r$sas_rows),
              as.character(r$r_cols),
              as.character(r$sas_cols),
              as.character(r$value_diffs),
              as.character(r$attr_only)
  ))
  #Print mismatched cols on the line below if there are any
  if (!is.null(r$mismatched_cols) && r$mismatched_cols != "none") {
    cat(sprintf(" -> Mismatched cols: %s\n", r$mismatched_cols))
  }
  
  #Print how many value differences found in columns with mismatches
  if(!is.null(r$col_row_diffs) && r$col_row_diffs != "none") {
    cat(sprintf(" -> Row diff per col: %s\n", r$col_row_diffs))
  }
  
  #Print data type mismatches on the line below if there are any
  if (!is.null(r$type_mismatches) && r$type_mismatches != "none") {
    cat(sprintf(" -> Data type mismatches: %s\n", r$type_mismatches))
  }
}
cat("\n")
s <- sapply(results, function(r) r$status)
cat("Clean PASS:",       sum(s == "PASS"), "\n")
cat("PASS (attrs only):", sum(s == "PASS (attrs only)"), "\n")
cat("MISMATCH (value):",  sum(s == "MISMATCH"), "\n")
cat("ROW COUNT MISMATCH:", sum(s == "ROW COUNT MISMATCH"), "\n")
cat("Other:",             sum(!s %in% c("PASS","PASS (attrs only)",
                                        "MISMATCH", "ROW COUNT MISMATCH")), "\n")
cat()

# Save the validation result as a csv file 
results_df <- do.call(rbind, lapply(results, function(r) {
  data.frame(
    Output = r$label,
    Status = r$status,
    R_rows = r$r_rows,
    Sas_rows = r$sas_rows,
    R_cols = r$r_cols,
    Sas_cols = r$sas_cols,
    Value_Diffs = r$value_diffs,
    Attr = r$attr_only,
    Mismatched_cols = r$mismatched_cols,
    Row_diffs_per_col = r$col_row_diffs,
    Type_mismatches = r$type_mismatches,
    stringsAsFactors = FALSE
    )
}))

write.csv(
  results_df, here(base_r_path, "validation", "Validation_results.csv"),
  row.names = FALSE
)

cat("Validation results saved to Validation_results.csv\n")

# Record end time and calculate duration
end_time <- Sys.time()
duration <- difftime(end_time, start_time, units = "mins")
cat(sprintf("Total run time: %.2f minutes\n", as.numeric(duration)))
