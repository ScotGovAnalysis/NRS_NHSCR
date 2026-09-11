###############################################################################
# Historical tables

names <- read_files(here(in_dirpath, "GROSFENames"))
name_parts <- read_files(here(in_dirpath, "GROSFENamesParts"))

merge_name <- names |>
  merge(name_parts, by = c("nameid", "personid")) |>
  mutate(
    thisname = str_replace_all(nametext, "[ ']", "")
  )

rm(names)
rm(name_parts)
gc()

# split by name type
surhisttab <- merge_name |>
  filter(nametype == "0") |>
  rename(
    prevsur = thisname
  ) 

#test that only nametypes of zero are recorded
assert_that(unique(surhisttab$nametype) == "0")


if(all(is.na(surhisttab$nmstartdate))){
  surhisttab <- surhisttab |>
      mutate(
        surstartdate = fmt_date(nmstartdate),
        surenddate = fmt_date(nmenddate)
      ) |>
      select(personid, prevsur, surstartdate, surenddate)
    
  } else {
  start <- Sys.time()
  #split by person id to run 
  surhisttab_split <- split(
    surhisttab,
    surhisttab$personid
  )

  #run imputation across all each person grouping 
  #this takes a long time and may cause R session to time out, if session is not 
  #kept active 

  n_cores <- max(1, detectCores() - 2)
  cl <- makeCluster(n_cores)

  #This section sets up the parallell machines. Passing all required libraies and settings to each cluster.
  clusterEvalQ(cl, c(library(tidyverse),
                    library(dplyr),
                    library(lubridate),
                    library(readr),
                    library(assertthat),
                    library(glue),
                    library(here),
                    library(parallel),
                    library(data.table)))
  clusterExport(cl, "his_fix_dates_dt")
  
  surhisttab_list <- 
    parLapply(
      cl,
      surhisttab_split, 
      his_fix_dates)
  end <- Sys.time()
  cat("Run time:", end - start) 
  
  surhisttab <- do.call(rbind, surhisttab_list) |>
    mutate(
      surstartdate = fmt_date(nmstartdate),
      surenddate = fmt_date(nmenddate)
    ) |>
    select(personid, prevsur, surstartdate, surenddate)
  
}


forhisttab <- merge_name |>
  filter(nametype %in% c(1,3,4)) |>
  rename(
    prevfor = thisname
  ) |> 
  mutate(
    forstartdate = fmt_date(nmstartdate),
    forenddate = fmt_date(nmenddate)
  ) |>
  select(personid, prevfor, forstartdate, forenddate)


#test that only nametypes 1,3,4 are present
assert_that(!"0" %in% unique(forhisttab$nametype))
assert_that(!"2" %in% unique(forhisttab$nametype))


# Adressess

adresses <- read_files(here(in_dirpath, "GROSFEAddresses"))

pchistab <-  adresses |>
  mutate(
    prevpc = str_replace_all(postcode, " ", ""),
    prevuprn = uprn,
    postcodestartdate = fmt_date(pcstartdate),
    postcodeenddate = fmt_date(pcenddate)
  ) |>
  select(personid, prevpc, prevuprn, postcodestartdate, postcodeenddate)


# ----------------------------------------------------------------------------
# Write out history tables

if (dir.exists(spine_path)) {
  
  #Surname history
  write_csv(surhisttab,
            glue(spine_path, paste0("/surhisttab_", mig_month, ".csv")),
            col_names = TRUE,
            append = FALSE)
  
  #Forename history
  write_csv(forhisttab,
            glue(spine_path, paste0("/forhisttab_", mig_month, ".csv")),
            col_names = TRUE,
            append = FALSE)
  
  #Postcode history 
  write_csv(pchistab,
            glue(spine_path, paste0("/pchistab_", mig_month, ".csv")),
            col_names = TRUE,
            append = FALSE)
} else {
  message("Run basic spine before supplementary spine")
}
