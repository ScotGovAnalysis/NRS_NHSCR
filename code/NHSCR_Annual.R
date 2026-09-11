# Annual extract processing 

# create annual extract folder 
# set directory path
ann_path <- glue(out_dir, paste0("Annual_extract_", mig_month))


# Check directory exists
if (!dir.exists(ann_path)) {
  # Try to create the directory
  dir.create(ann_path, recursive = TRUE, showWarnings = FALSE)
} else {
  message("Directory already exists: ", ann_path)
}

#-------------------------------------------------------------------------------
# Person table processing 
print("Processing Annual Persons table")

ann_persons <- persons |>
              select(all_of(ann_per_cols)) |>
                arrange(personid) |>
                mutate(
                  per_createdate = today(),
                  per_modifydate = as.Date(NA)
                )|>
                filter(posting != "DCAN")

# Write Persons
write_csv(ann_persons, 
          glue(ann_path, paste0("/Persons_", mig_month, ".csv")),
          col_names = TRUE,
          append = FALSE)

 rm(ann_persons)
 gc()

#-------------------------------------------------------------------------------
# Name tables

# It was noted in the SAS file that a number of the start dates are logged as 
# 29/9/1939 the default date. 
# This is applied to all dates which were taken from the 'old system' It is to
# be known that this is dummy data
 print("Processing Annual Names table")
 
ann_names <- read_files(here(in_dirpath, "GROSFENames")) 
 
# Original script output all columns and would calculate the end date for names.
# Within the 2025 data dictionary the end date column was removed from the output
# so end date is no longer calculated. 

ann_names <- ann_names |>
             arrange(personid, desc(nmstartdate), desc(nameid)) |>
             select(all_of(ann_nam_cols))

# Write Names
write_csv(ann_names, 
          glue(ann_path, paste0("/Names_", mig_month, ".csv")),
          col_names = TRUE,
          append = FALSE)

rm(ann_names)
gc()

#-------------------------------------------------------------------------------
# Name Parts tables
print("Processing Annual Nameparts table")
  
ann_namepart <- read_files(here(in_dirpath, "GROSFENamesParts")) 

ann_namepart <- ann_namepart |>
                arrange(personid, nameid, namepartid) |>
                select(all_of(ann_nampar_cols))

# Write Names
write_csv(ann_namepart, 
          glue(ann_path, paste0("/NamesParts_", mig_month, ".csv")),
          col_names = TRUE,
          append = FALSE)

rm(ann_namepart)
gc()

#-------------------------------------------------------------------------------
# Postcodes

print("Processing Annual Postcode table")

ann_postcode <-  read_files(here(in_dirpath, "GROSFEAddresses")) 

ann_postcode <- ann_postcode |>
                arrange( personid, desc(pcstartdate),desc(postcodeid)) |>
                mutate(
                  pcenddate = case_when(
                    is.na(pcenddate) ~ as.Date(NA),
                    pcenddate == as.Date("1939-09-29") ~ pcenddate,
                    TRUE ~ pcenddate - 1
                    )
                  )

# Write Names
write_csv(ann_postcode, 
          glue(ann_path, paste0("/Postcodes_", mig_month, ".csv")),
          col_names = TRUE,
          append = FALSE)

rm(ann_postcode)
gc()
