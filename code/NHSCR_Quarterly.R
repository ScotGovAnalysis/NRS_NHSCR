# Basic Spine

#create spine extract directory 
# set directory path
spine_path <- glue(out_dir, paste0("/SILC_Extract_", mig_month))

# Check directory exists
if (!dir.exists(spine_path)) {
  # Try to create the directory
  dir.create(spine_path, recursive = TRUE, showWarnings = FALSE)
} else {
  message("Directory already exists: ", spine_path)
}  

#------------------------------------------------------------------------------
print("Constructing Persons data for Basic Spine")

spine_person <- persons |>
  mutate(
    # create sex column and numerically categorize gender
    sex = case_when(
      gender == "M" ~ "1",
      gender == "F" ~ "2",
      TRUE ~ "3"
    ),
    #convert to character
    sex = as.character(sex),
    # format birth date and set as character 
    dob = as.character(format(birthdate, "%Y%m%d")),
    #rename and remove spaces and apostasies from first and last names
    forename = str_remove_all(firstname, "[ ']"),
    surname = str_remove_all(lastname,  "[ ']"),
  ) |>
  #select desired columns
    select(all_of(person_spine_col)) 

#------------------------------------------------------------------------------
# Filter postcodes to leave only most recent and select uprn from previous
# postcode entry if not available for more recent postcodes
print("Constructing Postcodes data for Basic Spine")

postcode <- read_files(here(in_dirpath, "GROSFEAddresses")) 

spine_post <- postcode |>
  group_by(personid) |>
  mutate(
        uprn = if (all(is.na(uprn))) {
          uprn
        } else {
          coalesce(uprn, first(na.omit(uprn)))
        }
      )|>
  slice_max(order_by = pcstartdate, with_ties = FALSE)|>
  #select only desired columns 
  select(c(personid, postcode, source, uprn))

# ----------------------------------------------------------------------------
# format survey code
addsurvref <- read_files(here(in_dirpath, "GROSFESurveys")) 
  
addsurvref <- addsurvref |>
  mutate(
    surveycode = ifelse(surveycode == "SR172", surveycode, ""),
    surveyreference = ifelse(surveycode == "SR172", surveyreference, "")
  )

# ----------------------------------------------------------------------------
# finalise  basic spine 
# merge Person_spine and Addresses Spine and addsurref
print("Writing Basic spines data")

basic_spine <- full_join(spine_person, spine_post, by = "personid") |>
  full_join(addsurvref, by = "personid") |>
  arrange(personid, desc(surveyreference)) |>
  select(-surveycode) |>
  rename(spineid = personid)


# basic spine
write_csv(basic_spine, 
          glue(spine_path, paste0("/basicsipine_", mig_month, ".csv")),
          col_names = TRUE,
          append = FALSE)


# ----------------------------------------------------------------------------
#finalise index postings 
# Separate Postings table into postings and postings_migration
# postings = recordtype P only
# positings migration = recordtype P and L
print("Writing Index Postings data")

postings<- read_files(here(in_dirpath, "GROSFEPostings")) 

index_post <- postings |>
  filter(recordtype == "P")

# test that only entries with record type P are present
assert_that(length(unique(pull(index_post, name = recordtype))) == 1)
assert_that(unique(pull(index_post, name = recordtype))[1] == "P")

index_post <- index_post |>
  rename(spineid = personid) |>
  mutate(
    postingcodedate = fmt_date(postingcodedate)
    )

#postings

write_csv(index_post, 
          glue(spine_path, paste0("/index_postings_", mig_month, ".csv")),
          col_names = TRUE,
          append = FALSE)
  


###############################################################################
# Supplementary Spine
print("Writing Supplementary Spine data")
write_csv(persons |> select(all_of(sup_spine_col)), 
            glue(spine_path, paste0("/suppspine_", mig_month, ".csv")),
            col_names = TRUE,
            append = FALSE)
  

###############################################################################
# SLS output 
print("Creating SLS extracts")

SLS_path <- glue(out_dir, paste0("/SLS_Extract_", mig_month))

# Check directory exists
if (!dir.exists(SLS_path)) {
  # Try to create the directory
  dir.create(SLS_path, recursive = TRUE, showWarnings = FALSE)
}

# SLS 1 - persons merged with surveys and filtered to only those with SR172
sls1 <- persons |>
  merge(addsurvref, by = "personid") |>
  filter(surveycode == "SR172") |>
  select(all_of(sls1_col))
  
# sls1
write_csv(sls1, 
          glue(SLS_path, paste0("/sls1_", mig_month, ".txt")),
          col_names = TRUE,
          append = FALSE)


sls2 <- sls1 |>
  merge(postings) |>
  select(all_of(sls2_col))
  
rm(sls1, sls2)

sls3 <- addsurvref |>
  filter(surveycode == "SR172") |>
  select(all_of(sls3_col))
  
slspostcode <- postcode |>
  merge(addsurvref, by = "personid") |>
  filter(surveycode == "SR172") |>
  select(all_of(slspostcode_col))
  
  # ----------------------------------------------------------------------------
  # Write out SLS files
  
print("Writing SLS output data")


  # set directory path
  SLS_path <- glue(out_dir, paste0("/SLS_Extract_", mig_month))
  
  # Check directory exists
  if (!dir.exists(SLS_path)) {
    # Try to create the directory
    dir.create(SLS_path, recursive = TRUE, showWarnings = FALSE)
    
    # sls1
    write_csv(sls1, 
              glue(SLS_path, paste0("/sls1_", mig_month, ".txt")),
              col_names = TRUE,
              append = FALSE)
    
    # sls2
    write_csv(sls2, 
              glue(SLS_path, paste0("/sls2_", mig_month, ".txt")),
              col_names = TRUE,
              append = FALSE)
    
    # sls3
    write_csv(sls3, 
              glue(SLS_path, paste0("/sls3_", mig_month, ".txt")),
              col_names = TRUE,
              append = FALSE)
    
    
    #slspostcode
    write_csv(slspostcode, 
              glue(SLS_path, paste0("/slspostcode_", mig_month, ".txt")),
              col_names = TRUE,
              append = FALSE)
  }
  
  

  ################################################################################

  print("Quarterly extract complete")


