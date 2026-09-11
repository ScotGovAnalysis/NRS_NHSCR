# Persons
mig_per_cols <- c("personid", "gender", "birthdate", "immigrantflag", 
                  "birthcountry", "birthplace", "isdead", "deathdate", 
                  "isclosed", "isregistered", "nhsnumber", "mothersbirthname",
                  "chinumber", "c13", "c56", "nhs_imm")

# Postings
mig_posting_cols <- c("personid", "postingcode", "recordtype",
                      "postingcodedate", "postingid")

# Postcodes
mig_post_cols <- c("personid", "postcode", "pcstartdate", "pcenddate", 
                    "postcodeid", "source")
