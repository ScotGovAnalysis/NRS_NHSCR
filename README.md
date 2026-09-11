# Introduction

## NHSCR Core Pipeline

The pipeline reads in seven delimited text files, processing them to produce five extracts and four output files. The pipeline is split into those extracts produced monthly and those produced quarterly and those annually. Each section can be run individually or all at once based on settings within the main script.

# Getting Started

*NOTE* make sure you have added the credentials for all data folders via the command `cifscreds add lwhl3-lv-sa02` in the command line before executing the script.

Before running the launch script, NHSCR_run_pipeline.R, you will need to input some information: 'in_dirpath': Add the direct path to the input data - This is where the input files will be read from. It should contain all files starting GROSFE and NHSResgisteredpatients.txt. 'out_dir': Add the path to the desired output folder - This should be the location where you wish the output folders and files to be written to. Please ensure you have write permission to this path. It is best practice that this is different from the `in_dirpath` to avoid any overwriting. 'mig_month': Input the migration month - This is for the purpose of naming the output folders and files appropriately. It should follow the convention MonthYear i.e. Jan26 'mode' : This determines if you are running the script to generate the Monthly, Quarterly or Annual outputs Monthly mode, which produces the Migration extract can be selected by running 'M', 'm' or 'monthly' Quarterly mode, which produced both the Migration extract as well as Spine, historical tables and

Once the script has been updated the pipeline can be run by clicking the source button at the top right hand corner of the script pane or via Ctrl+Alt+R.

If this is the first time you have run the pipeline prerequisite packages (assertthat, here) will be automatically installed.

Input files:

```         
| Name                       |
| -------------------------- |
| GROFSEPersons              |
| GROFSENames                |
| GROFSENamesParts           |
| GROFSEPostings             |
| GROFSESurveys              |
| GROFSEAddresses            |
| NHSResgisteredpatients.txt |
```

# Outputs

Output files are separated by extract within the designated output folder. Currently all output files are in csv format.

Extracts produced: \| Name \| Timeline \| Team \| \| --------------------- \| ------------- \| -------------------------- \| \| Migration \| Monthly \| Pop migration team \| \| Basic Spine \| Quarterly \| Indexing team/data linkage \| \| Supplementary Spine \| Quarterly \| Indexing team/data linkage \| \| Historical tables \| Quarterly \| Admin team \|

Output files:

Sent to the SLS team via NRS MOVEit - zip and encrypt before sending.

```         
| Name            | Type           | Contents                                     |
| --------------- | -------------- | -------------------------------------------- |
| SLS1.txt        | Dilimited file | Information on persons and surveys           |
| SLS2.txt        | Dilimited file | Information on persons, surveys and postings |
| SLS3.txt        | Dilimited file | Information on surveys                       |
| SLSpostcode.txt | Dilimited file | Information on persons, surveys and postcode |
```

# Build and Test

The pipeline consists of: one pipeline script - NHSCR_run_pipeline.R four code scripts - NHSCR_Annual.R NHSCR_Monthly.R NHSCR_Quarterly.R Historical extract.R four function scripts - Dateformatting_functions.R filter_postings.R Read_in_data.R Test_functions.R five lookup scripts - Basic_spine_colnames.R Input_colnames.R Migration_colnames.R SLS_colnames.R Yearly_colnames.R

# Validation and Testing

The `Compare_outputs.R` script validates outputs produced by the R processing pipeline against the equivalent SAS outputs. Comparison results are displayed to the console and a CSV summary of the validation results is written to the `validation` folder.

The script uses configurable output paths for the SILC, SLS, Migrant and Annual datasets. These paths can be updated if output folder locations change.

**Dependencies**

`Compare_outputs.R` relies on the following scripts:

`Make_comparison.R` - creates the list of SAS and R output files to be compared. `Compare_outputs_functions.R` - contains the functions used to compare datasets and generate validation results.

**Inputs**

Enter the following parameters when running the script:

- extract_month_r - Extract month for the R output.

- extract_month_sas - Extract month for the SAS output.

**Validation checks**

The comparison identifies: row-level differences between datasets, variable-level value differences (data mismatches), metadata or attribute differences, columns containing mismatches and the number of mismatches in each column.

## Unit Tests

The `Validation_tests.R` script provides unit tests for the `compare_one()` function used by `Compare_outputs.R`. These tests use small controlled datasets to verify that identical outputs return the expected **PASS**, genuine data differences and row count mismatches are correctly detected, empty strings and `NA` values are handled appropriately and missing files are identified. This helps identify issues in the comparison logic before running validations on large production outputs.

**Dependency**

`Validation_tests_helper.R`

# Environment

Tested with:

- R version 4.4.3

- Platform: x86_64-redhat-linux-gnu

## Key Packages

```         
## Other Attached Packages

| Package    | Version |
|------------|---------|
| renv       | 1.2.3   |
| rmarkdown  | 2.25    |
| data.table | 1.18.4  |
| here       | 1.0.2   |
| glue       | 1.6.2   |
| assertthat | 0.2.1   |
| lubridate  | 1.9.3   |
| forcats    | 1.0.0   |
| stringr    | 1.6.0   |
| dplyr      | 1.2.1   |
| purrr      | 1.2.2   |
| readr      | 2.1.4   |
| tidyr      | 1.3.1   |
| tibble     | 3.2.1   |
| ggplot2    | 3.5.0   |
| tidyverse  | 2.0.0   |
| knitr      | 1.45    |
| callr      | 3.7.6   |
| janitor    | 2.2.1   |
```
