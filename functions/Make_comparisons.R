# Helper functions for Compare_outputs to make a list of file paths used to compare
# R outputs against sas outputs
################################################################################

make_comparison <- function(name, r_name, sas_name, r_path, sas_path) {
  list(
    name,
    here(file.path(r_path, paste0(r_name, "_", extract_month_r, ".csv"))),
    here(file.path(sas_path, paste0(sas_name, extract_month_sas, ".sas7bdat")))
    
  )
}

make_text_comparison <- function(name, r_name, sas_name, r_path, sas_path, is_text) {
  list(
    name,
    here(file.path(r_path, paste0(r_name, "_", extract_month_r, ".txt"))),
    here(file.path(sas_path, paste0(sas_name, ".txt"))),
    is_text
    
  )
}