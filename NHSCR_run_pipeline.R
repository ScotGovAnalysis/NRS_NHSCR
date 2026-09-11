# initialized 8 April 26 - FR
# NSHCR pipeline
###############################################################################

# check prerequisite packages
# Install packages if not already installed
if (!requireNamespace("assertthat", quietly = TRUE)) install.packages("assertthat")
if (!requireNamespace("here", quietly = TRUE)) install.packages("here")

# load packages
library(tidyverse)
library(dplyr)
library(lubridate)
library(readr)
library(assertthat)
library(glue)
library(here)
library(parallel)
library(data.table)
library(rmarkdown)

# Set number of threads for readr
cores <- detectCores(logical = TRUE)
cat("Detected CPU cores:", cores, "\n")
options(readr.num_threads = min(4, cores))  # Use up to 4 threads

###############################################################################
# user input
start <- Sys.time()
print(start)

# Input the full path to input files location. Must be in "" 
in_dirpath <- ""

# Input the desired path to the out folder location. 
# It is good practice that this is a separate folder to the input files to 
# avoid accidental overwriting. Must be in "" 
out_dir <- ""

# Input the migration month. This is for naming output files. It should follow
# the convention MonthYear i.e "Jan26" 
mig_month <- ""

# Input determines wither to run Monthly or Quarterly extracts
# Set as "Monthly" or "M" to run just the monthly extract
# Set as "Quarterly" or "Q" to create both monthly and quarterly extracts
# Set as "Annual" or "A" to create the complete extract
mode <- ""

save.image(here("input_data.RData"))

###############################################################################

#-------------------------------------------------------------------------------
# Import source files
#-------------------------------------------------------------------------------

files_source <- list.files(
  path = glue(here::here(), "/functions"), 
  pattern = "\\.R$",
  recursive = TRUE,
  full.names = TRUE
)

sapply(files_source, source)

files_lookup <- list.files(
  path = glue(here::here(), "/lookup"),
  pattern = "\\.R$",
  recursive = TRUE,
  full.names = TRUE
)

sapply(files_lookup, source)

###############################################################################

# normalize and check paths 
in_dirpath <- normalizePath(in_dirpath)
safe_path_exists(in_dirpath)

out_dir <- normalizePath(out_dir)
safe_path_exists(out_dir)

mode <- tolower(mode)

# Persons is only dataset used by all three scripts and takes the longest to read

persons <- read_files(here(in_dirpath, "GROSFEPersons")) 

#run the selected mode 
if (mode == "monthly" || mode == "m") {
  print("Running Monthly pipeline")
  source("code/NHSCR_Monthly.R")
  print("Monthly extracts completed")
} else if (mode == "quarterly" || mode == "q") {
  print("Running Monthly pipeline")
  source("code/NHSCR_Monthly.R")
  print("Monthly extracts completed")
  print("Running Quarterly pipeline")
  source("code/NHSCR_Quarterly.R")
  source("code/Historical_extract.R")
  print("Quarterly extracts completed")
} else if (mode == "annual" || mode == "a"){ 
  print("Running Monthly pipeline")
  source("code/NHSCR_Monthly.R")
  print("Monthly extracts completed")
  print("Running Quarterly pipeline")
  source("code/NHSCR_Quarterly.R")
  source("code/Historical_extract.R")
  print("Quarterly extracts completed")
  source("code/NHSCR_Annual.R")
  print("Annual extracts completed")
} else {
  print("No valid mode has been selected")
}

render("metadata/metadata.Rmd")

end <- Sys.time()
print(end - start)
