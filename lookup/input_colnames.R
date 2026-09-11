################################################################################
# Create key value pairs for column names and column types for input data

col_names_list <- list(
  GROSFEPersons = c('personid', 'ucrn', 'nhsnumber',
                    'ewnumber', 'ninumber', 'gender',
                    'posting', 'postingdate', 'birthdate',
                    'birthcountry', 'birthplace',
                    'mothersbirthname', 'isdead',
                    'deathdate', 'deathcountry',
                    'deathdistrict', 'deathsubdistrict',
                    'deathentrynumber', 'deathlocation',
                    'isclosed',  'isregistered',
                    'firstname',  'middlename',
                    'lastname', 'lastupdated',
                    'immigrantflag', 'chinumber'),
  GROSFENames = c('nameid', 'personid', 'nmstartdate',
                  'nmenddate'),
  GROSFENamesParts = c('namepartid', 'nameid',
                       'personid', 'nameposn',
                       'nametext', 'nametype'),
  GROSFEPostings = c('postingid', 'personid',
                     'postingcode', 'postingcodedate',
                     'recordtype'),
  GROSFESurveys = c('surveyid', 'personid', 'surveycode',
                    'surveyreference','srvstartdate',
                    'srvenddate'),
  GROSFEAddresses = c('postcodeid', 'personid', 'uprn',
                      'postcode', 'source',
                      'pcstartdate', 'pcenddate'),
  NRSRegisteredPatients.txt = c('chinumber', 'practicecode',
                                'practicepostcode')
)

#= col_date("%Y-%m-%d")
#= col_character()

coltype_list = list(
  GROSFEPersons = cols(
    personid = col_character(), 
    ucrn = col_character(), 
    nhsnumber = col_character(),
    ewnumber = col_character(), 
    ninumber = col_character(), 
    gender = col_character(),
    posting = col_character(), 
    postingdate = col_datetime(format = ""), 
    birthdate = col_datetime(format = ""),
    birthcountry = col_character(), 
    birthplace = col_character(),
    mothersbirthname = col_character(), 
    isdead = col_character(),
    deathdate = col_datetime(format = ""), 
    deathcountry = col_character(),
    deathdistrict = col_character(), 
    deathsubdistrict = col_character(),
    deathentrynumber = col_character(), 
    deathlocation = col_character(),
    isclosed = col_character(),  
    isregistered = col_character(),
    firstname = col_character(),  
    middlename = col_character(),
    lastname = col_character(), 
    lastupdated = col_datetime(format = ""),
    immigrantflag = col_character(), 
    chinumber = col_character()
  ),
  GROSFENames = "ccDD",
  GROSFENamesParts = "cccccc",
  GROSFEPostings = cols(
    postingid = col_character(), 
    personid = col_character(),
    postingcode = col_character(), 
    postingcodedate = col_datetime(format = ""),
    recordtype = col_character()
  )
  ,
  GROSFESurveys = "ccccDD",
  GROSFEAddresses = cols(
    postcodeid = col_character(), 
    personid = col_character(), 
    uprn = col_character(),
    postcode = col_character(), 
    source = col_character(),
    pcstartdate = col_datetime(format = ""), 
    pcenddate = col_datetime(format = "")
  ),
  NRSRegisteredPatients.txt = cols(
    chinumber = col_character(),
    practicecode = col_character(),
    practicepostcode = col_character()
  )
)
