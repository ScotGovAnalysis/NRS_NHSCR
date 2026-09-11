# initialized 8 April 26 - FR
# NSHCR Monthly extracts
###############################################################################

#-------------------------------------------------------------------------------

# create migration extract folder 
# set directory path
mig_path <- glue(out_dir, paste0("/Migration_extract_", mig_month))

# Check directory exists

if (!dir.exists(mig_path)) {
  # Try to create the directory
  dir.create(mig_path, recursive = TRUE, showWarnings = FALSE)
} else {
  message("Directory already exists: ", mig_path)
}

#-------------------------------------------------------------------------------
#select output columns for postcodes 
postcodes <- read_files(here(in_dirpath, "GROSFEAddresses")) 
postcodes <- postcodes|>
  select(all_of(mig_post_cols))|>
  mutate(across(contains("date"), as.Date))

#write Postcodes
print("Writing Postcodes data")
write_csv(postcodes, 
          glue(mig_path, paste0("/Postcodes_", mig_month, ".csv")),
          col_names = TRUE,
          append = FALSE)
rm(postcodes)

#-------------------------------------------------------------------------------
#read in NRS registered patients 
chiprac <-read_files(here(in_dirpath, "NRSRegisteredPatients.txt"))

#write chiprac
print("Writing chiprac data")
write_csv(chiprac, 
          glue(mig_path, paste0("/chiprac_", mig_month, ".csv")),
          col_names = TRUE,
          append = FALSE)
rm(chiprac)

#-------------------------------------------------------------------------------
#read in postings file and select columns 
postings_migration <- read_files(here(in_dirpath, "GROSFEPostings")) 
postings_migration <- postings_migration |>
  select(all_of(mig_posting_cols)) |>
  mutate(across(contains("date"), as.Date))

# Write Postings
print("Writing Postings data")
write_csv(postings_migration, 
          glue(mig_path, paste0("/Postings_migration_", mig_month, ".csv")),
          col_names = TRUE,
          append = FALSE)

rm(postings_migration)

#-------------------------------------------------------------------------------
# calculate Person columns c13, c56 and nhs_imm

mon_persons <- persons |>
  mutate(
    c13 = substring(nhsnumber, 1, 3),
    c56 = substring(nhsnumber, 5, 6),
    nhs_imm = case_when(
      c13 %in% 900:949 & c56 %in% 60:61 ~ '1',
      TRUE ~ '0'
    )
  ) |>
  select(all_of(mig_per_cols))

# Write Persons
print("Writing Persons data")
  write_csv(mon_persons, 
            glue(mig_path, paste0("/Persons_", mig_month, ".csv")),
            col_names = TRUE,
            append = FALSE)

rm(mon_persons)

################################################################################
#clear memory 
rm(mig_path, mig_per_cols, mig_post_cols, mig_posting_cols)
gc()

print("Monthly extract complete")

