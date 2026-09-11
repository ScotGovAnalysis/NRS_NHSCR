# Read in data files

read_files <- function(file_path, col_names = col_names_list) {
  base_name <- basename(file_path)

  if (base_name == "NRSRegisteredPatients.txt"){
   full_data <- read_delim(
      file = file_path,
      delim = ";",
      col_names = col_names_list[[base_name]],
      col_types = coltype_list[[base_name]],
      skip_empty_rows = TRUE
    )
  } else if (base_name == "GROSFEPersons" ){
    chunks_list <- list()
    
    accumulate_chunks <- function(chunk, pos) {
      chunks_list[[length(chunks_list) + 1]] <<- chunk
    }
    
    persons_data <- read_delim_chunked(
      file = file_path,
      delim = "|",
      chunk_size = 100000,
      col_names = col_names_list[[base_name]],
      col_types = coltype_list[[base_name]],
      callback = DataFrameCallback$new(accumulate_chunks),
      skip_empty_rows = TRUE
    )
    full_data <- rbindlist(chunks_list, 
                           use.names = TRUE, 
                           fill = FALSE)
    
  } else {
    full_data <-  suppressWarnings(read_delim(
      file = file_path,
      delim = "|",
      col_names = col_names_list[[base_name]],
      col_types = coltype_list[[base_name]],
      skip_empty_rows = TRUE
    ))
  }
  
  return(full_data)
}
