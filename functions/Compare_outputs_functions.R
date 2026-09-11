# Function to compute one R output against its SAS baseline
# Used by Compare_outputs.R for parallel run test and Validation_tests for 
# testing the functions error
################################################################################

#Install packages if not not installed
required_packages <- c("haven", "diffdf", "tidyverse")
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, 
                                              quietly = TRUE)]
if(length(missing_packages) > 0) {
  install.packages(missing_packages, quiet = TRUE)
}

#Packages load silently
suppressPackageStartupMessages({
  library(diffdf)
  library(tidyverse)
  library(stringr)
  library(haven)
  library(readr)
  library(dplyr)
})

# Clean the dataframes by removing SAS metadata labels from all columns and 
# converting empty strings to NA so SAS and R match for NA values
strip_attrs <- function(df) {
  for (col in names(df)) {
    attributes(df[[col]]) <- NULL
    # Normalise character empty string <-> NA
    if (is.character(df[[col]])) {
      df[[col]][df[[col]] == ""] <- NA_character_
    }
  }
  as.data.frame(df)
}

# Main comparison function, takes R output and SAS output and returns a list 
# of results including: status, row counts, col counts, value diffs, type diffs 
compare_one <- function(label, r_path, sas_path, is_text = FALSE) {
  #early exit if R output file not found
  if (!file.exists(r_path))  return(list(label = label, status = "R-MISSING", 
                                         r_rows=NA, sas_rows=NA, r_cols=NA, 
                                         sas_cols=NA, value_diffs=NA, 
                                         attr_only=NA, mismatched_cols="none", 
                                         col_row_diffs="none", type_mismatches="none"))
  # early exit if SAS output file not found
  if (!file.exists(sas_path)) return(list(label = label, status = "SAS-MISSING", 
                                          r_rows=NA, sas_rows=NA, r_cols=NA, 
                                          sas_cols=NA, value_diffs=NA, 
                                          attr_only=NA, mismatched_cols="none", 
                                          col_row_diffs="none", type_mismatches="none"))
  
  # Read files
  # is_text for = true for pipe delimited text files (SLS outputs), 
  # is_text = false for csv, sas7bdat
  if (is_text) {
    r_out <- read_delim(r_path, delim = ",", show_col_types = FALSE,
                        progress = FALSE) |> 
      suppressWarnings()
    sas_out <- read_delim(sas_path, delim = "|", show_col_types = FALSE,
                          progress = FALSE)
  } else {
    r_out <- read_csv(r_path, show_col_types = FALSE, progress = FALSE)
    sas_out <- read_sas(sas_path, encoding = "UTF-8")
    
  }
  
  # Normalise column names to lowercase
  names(r_out) <- tolower(names(r_out))
  names(sas_out) <- tolower(names(sas_out))
  common <- intersect(names(r_out), names(sas_out))
  
  #check column types for common columns
  type_mismatches <- c()
  for (col in common) {
    r_type <- class(r_out[[col]])
    sas_type <- class(sas_out[[col]])
    if (!identical(r_type, sas_type)) {
      type_mismatches <- c(type_mismatches,
                           paste0(col, "(R:", r_type, " SAS:", sas_type, ")"))
    }
  }
  
  # subset both outputs to shared columns only and strip metadata attributes
  # before comparing
  r_sub <- strip_attrs(as.data.frame(r_out)[, common, drop = FALSE])
  sas_sub <- strip_attrs(as.data.frame(sas_out)[, common, drop = FALSE])
  
  # Align column order
  sas_sub <- sas_sub[, common, drop = FALSE]
  r_sub <- r_sub[, common, drop = FALSE]
  
  # Row count check before diffdf runs and exit early if row counts do not match
  if (nrow(r_sub) != nrow(sas_sub)) {
    return(list(label = label, status = "ROW COUNT MISMATCH", 
                r_rows=nrow(r_sub), sas_rows=nrow(sas_sub), r_cols=ncol(r_out), 
                sas_cols=ncol(sas_out), value_diffs=NA, attr_only=NA, 
                mismatched_cols="none", col_row_diffs="none", type_mismatches="none"))
  }

  #-----------------------------------------------------------------------------
  # diffdf comparison - compares every value in every shared column row by row,
  # SAS is the base and R is the compare
  
  # Wrapped in trycatch so errors do not crash the whole script
  res <- tryCatch(
    diffdf(base = sas_sub, compare = r_sub, suppress_warnings = TRUE),
    error = function(e) list(error = conditionMessage(e))
  )
  
  # If diffdf errors return ERROR status 
  if (!inherits(res, "diffdf")) {
    return(list(label = label, status = paste("ERROR:", res$error), 
                r_rows=nrow(r_out), sas_rows=nrow(sas_out), r_cols=ncol(r_out), 
                sas_cols=ncol(sas_out), value_diffs=NA, attr_only=NA, 
                mismatched_cols="none", col_row_diffs="none", type_mismatches="none"))
  }
  
  
  # Count value diffs (variables with actual row-level diffs)
  summary_obj <- summary(res)
  # diffdf stores issues in its list body
  issue_names <- names(res)
  # Items beginning with "VarDiff" are variable-level value diffs 
  # (real data mismatches)
  value_diff_items <- issue_names[grepl("^VarDiff_", issue_names)]
  # Items for attr differences - metadata level, not actual values
  attr_diff_items <- issue_names[grepl("attr", issue_names, ignore.case = TRUE)]
  
  #-----------------------------------------------------------------------------
  # Status classification
  # PASS             - no issues 
  # PASS(attrs only) - metadata differences, values match
  # MISMATCH         - actual data value differences found
  status <- if (length(issue_names) == 0) "PASS"
  else if (length(value_diff_items) == 0) "PASS (attrs only)"
  else "MISMATCH"
  
  # Extract which columns have value differences
  mismatched_cols <- if (length(value_diff_items) > 0) {
    gsub("^VarDiff_", "", value_diff_items)
  } else {
    character(0)
  }
  
  #Extract how many rows differ in each mismatched column
  col_row_diffs <- if (length(value_diff_items) > 0) {
    paste(sapply(value_diff_items, function(item) {
      col_names <- gsub("^VarDiff_", "", item)
      n_rows <- nrow(res[[item]])
      paste0(col_names, ":", n_rows)
    }), collapse = ", ")
  } else {
    "none"
  }
  
  
  # Returns results as list
  list(label=label, 
       status=status, 
       r_rows=nrow(r_out), 
       sas_rows=nrow(sas_out),
       r_cols=ncol(r_out),
       sas_cols=ncol(sas_out),
       value_diffs=length(value_diff_items), 
       attr_only=length(attr_diff_items),
       mismatched_cols = if(length(mismatched_cols) > 0) 
         paste(mismatched_cols, collapse=", ") else "none",
       col_row_diffs = col_row_diffs,
       type_mismatches = if(length(type_mismatches) > 0) 
         paste(type_mismatches, collapse=", ") else "none"
  )
  
}