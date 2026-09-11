# general date formatting for columns which converts NA - blank
fmt_date <- function(x) {
  ifelse(is.na(x), "",
         format(x, "%Y%m%d"))
}


#Fix dates for historical tables

his_fix_dates <- function(df) {
    
    if (nrow(df) <= 1) {
      return(df)
    }
    
    df <- arrange(df, nmstartdate)
    
    # Fill missing end dates
    for(i in seq_len(nrow(df) - 1)) {
      
      if(is.na(df$nmenddate[i])) {
        df$nmenddate[i] <- df$nmstartdate[i + 1] - days(1)
      }
    }
    
    # Fix gaps
    for(i in 2:nrow(df)) {
      
      if(!is.na(df$nmenddate[i - 1])) {
        
        expected_start <- df$nmenddate[i - 1] + days(1)
        
        if(is.na(df$nmstartdate[i]) ||
           df$nmstartdate[i] != expected_start) {
          
          df$nmstartdate[i] <- expected_start
        }
      }
    }
    
    df
  }




# using data.table to potentially speed up over dplyr 
his_fix_dates_dt <- function(df) {
  setDT(df)
  setorder(df, personid, nmstartdate)
  
  df[, prevenddate := shift(nmenddate), by = personid]
  
  df[, imputed :=
       (seq_len(.N) > 1) &
       (nmenddate > prevenddate | is.na(nmenddate)) &
       (nmstartdate != prevenddate + 1),
     by = personid]
  
  df[imputed == TRUE,
     nmstartdate := prevenddate + 1]
  
  df[, imputed := as.integer(imputed)]
  
  df[]
}


