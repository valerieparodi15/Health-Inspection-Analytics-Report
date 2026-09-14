#load dataset
inspections<-read.csv("inspection.csv")
violations<-read.csv("violations.csv")
inventory<-read.csv("inventory.csv")

## CLEAN DATA
#--------------------------
str(inspections)

#convert dates from chr to date
#inspections$ACTIVITY.DATE<-as.Date(inspections$ACTIVITY.DATE,format="%m/%d/%y")
#inspections$ACTIVITY.DATE

#not all dates were formatted the same
#use lubridate
library(lubridate)
inspections$ACTIVITY.DATE<-mdy(inspections$ACTIVITY.DATE)
inspections$ACTIVITY.DATE

#check for any issues
any(is.na(inspections$ACTIVITY.DATE))

#check for na values
colSums(is.na(inspections))

# which facility has a missing program name
inspections$FACILITY.NAME[which(is.na(inspections$PROGRAM.NAME))]

#violations dataset:
str(violations)

#check for missing data
colSums(is.na(violations))

## EXPLORATORY ANALYSIS
#--------------------------

summary(inspections$SCORE)

table(inspections$GRADE)

#go back and investigate the empty grades
inspections[inspections$GRADE=='',] # scores below 70 don't receive a grade

#reassign those values
for(i in 1:length(inspections$SCORE)){
  if(inspections$GRADE[i]==''){
   inspections$GRADE[i]<-"NO_GRADE"
  }
}

#visualizations
hist(inspections$SCORE) #skewed right

barplot(table(inspections$GRADE))

library(dplyr)
owner_facility_counts<-inspections|>
  group_by(OWNER.NAME)|>
  summarize(
    facilities_owned=n_distinct(FACILITY.ID)
  )|>
  arrange(desc(facilities_owned))

head(owner_facility_counts)

#OWNER NAMES
#through inspection noticed slight variation in owner names 
#more investigations
unique_owners<-unique(inspections$OWNER.NAME)

#testing
temp<-inventory$OWNER.NAME[agrepl("STARBUCKS", inventory$OWNER.NAME, 
                                  ignore.case = TRUE) ]
unique(temp)

#remove commas
unique_owners$sort.unique_owners.<- gsub(",", "", unique_owners$sort.unique_owners.)
#bring together the owners that now match
unique_owners$sort.unique_owners.<-unique(unique_owners$sort.unique_owners.)
#remove INC and LLC
unique_owners$sort.unique_owners.<- gsub("\\b(inc|llc|l l c|corp|corporation|company|co|ltd)\\b", "", 
                        unique_owners$sort.unique_owners., ignore.case = TRUE)
new_unique_owners<-data.frame(unique(trimws(unique_owners$sort.unique_owners.)))


#PROGRAM NAME
unique_program<-data.frame(unique(inspections$PROGRAM.NAME))

#credit Microsoft Copilot
normalize_owner <- function(x) {
  x <- toupper(x)
  x <- gsub("[.,]", " ", x)  # turn punctuation into spaces
  x <- gsub("\\b(LP|LTD|LLC|INC|CORP|CO)\\b", "", x, perl = TRUE)
  x <- gsub("\\s+", " ", x)  # collapse multiple spaces
  trimws(x)
}
inspections$OWNER_NORM<-normalize_owner(inspections$OWNER.NAME)

#testing code to standardize
chains <- list(
  "STARBUCKS"              = "STARBUCKS",
  "7-ELEVEN"               = "7[- ]?ELEVEN",
  "DOMINO'S"               = "DOMINO",
  "AFC"                    = "AFC",
  "CVS"                    = "CVS",
  "KRAB QUEENZ"            = "KRAB QUEENZ",
  "L'ANTICA PIZZERIA"      = "L'ANTICA PIZZERIA",
  "LAYLA BAGELS"           = "LAYLA BAGELS",
  "YUM YUM DONUTS"         = "YUM YUM DONUTS",
  "WILLIAMS-SONOMA"        = "WILLIAMS-SONOMA",
  "WHOLE FOODS"            = "WHOLE\\s*FOODS",
  "PIZZA HUT"              = "PIZZA HUT",
  "BEVMO"                  = "BEVMO",
  "IN-N-OUT"               = "IN\\s*[-']?\\s*N\\s*[-']?\\s*OUT",
  "WALGREENS"              = "WALGREEN",
  "MCDONALD'S"             = "MCDONALD",
  "WENDY'S"                = "WENDY'S",
  "CARL'S JR"              = "CARLS JR",
  "BURGER KING"            = "BURGER KING",
  "JACK IN THE BOX"        = "JACK IN THE BOX",
  "EL POLLO LOCO"          = "EL POLLO LOCO",
  "THE HABIT"              = "THE HABIT",
  "PANDA EXPRESS"          = "PANDA EXPRESS",
  "PAPA JOHN'S"            = "PAPA JOHNS",
  "LITTLE CAESARS"         = "LITTLE CEASARS",
  "DOMINO'S"               = "DOMINOS",
  "DOLLAR TREE"            = "DOLLAR TREE",
  "TACO BELL"              = "TACO BELL",
  "FIVE GUYS"              = "FIVE GUYS",
  "FIVE BELOW"             = "FIVE BELOW",
  "RAISING CANE'S"         = "RAISING CANE",
  "YOSHINOYA"              = "YOSHINOYA",
  "WINGSTOP"               = "WINGSTOP",
  "WIENERSCHNITZEL"        = "WIENERSCHNITZEL",
  "UNITED OIL"             = "UNITED OIL",
  "TRADER JOE'S"           = "TRADER JOE'S",
  "THE HOME DEPOT"         = "THE HOME DEPOT",
  "COFFEE BEAN & TEA LEAF" = "THE COFFEE BEAN & TEA LEAF",
  "SUBWAY"                 = "SUBWAY",
  "SEE'S CANDIES"          = "SEE'S CANDIES",
  "ROSS"                   = "ROSS",
  "RITE AID"               = "RITE AID",
  "ROCKET"                 = "ROCKET",
  "POPEYES"                = "POPEYES",
  "OLIVE GARDEN"           = "OLIVE GARDEN",
  "JAMBA JUICE"            = "JAMBA JUICE",
  "IHOP"                   = "IHOP",
  "G&M OIL"                = "G\\s*(AND\\s*)?&?\\s*M",
  "DENNY'S"                = "DENNY'S",
  "DEL TACO"               = "DEL TACO",
  "DD'S DISCOUNTS"         = "DD'S DISCOUNT",
  "CHUCK E CHEESE'S"       = "CHUCK E CHEESE'S",
  "CHIPOTLE"               = "CHIPOTLE",
  "BASKIN ROBBINS"         = "BASKIN ROBBINS",
  "99 CENTS ONLY STORE"    = "99 CENTS ONLY",
  "LASSENS"                = "LASSENS"
)
hosts <- list(
  "ALBERTSON'S"="ALBERTSON'?S?",
  "RALPHS"= "RALPHS",
  "LA CONVENTION CENTER" = "LA CONVENTION CENTER",
  "B W HOTEL"="B\\. W\\. HOTEL",
  "H MART" = "H MART",
  "ZION MARKET" = "ZION MARKET",
  "SMART & FINAL" = "SMART\\s*(AND|&)?\\s*FINAL",
  "WHOLE FOODS"= "WHOLE FOODS",
  "VALLARTA"= "VALLARTA",
  "SAM'S CLUB"= "SAM'S CLUB",
  "VONS" = "VONS",
  "PAVILLIONS" = "PAVILLIONS",
  "SPROUTS" = "SPROUTS",
  "GELSON" = "GELSON",
  "FOOD 4 LESS" = "FOOD 4 LESS",
  "EREWHON" = "EREWHON",
  "EL SUPER" = "EL SUPER",
  "COSTCO" =  "COSTCO",
  "BRISTOL FARM" = "BRISTOL FARM",
  "AMAPOLA DELI & MARKET"=  "AMAPOLA DELI & MARKET",
  "99 RANCH MARKET"= "99 RANCH MARKET",
  "WALMART"="WAL\\s*-?\\s*MART",
  "SUPERIOR GROCERS"="SUPERIOR GROCERS",
  "NORTHGATE MARKET"= "NORTHGATE",
  "WINCO"= "WINCO",
  "TARGET"= "TARGET",
  "UNITED PACIFIC"= "UNITED PACIFIC",
  "STATER BROS MARKET"= "STATER BROS",
  "JONS MARKET" = "JONS MARKET",
  "CIRCLE K"= "CIRCLE K",
  "CHEVRON"= "CHEVRON",
  "ARCO"="ARCO",
  "ALDI"= "ALDI"
  
)

assign_parent <- function(program_name,owner_norm) {
  pn <- toupper(program_name)
  pn <- gsub("\\b#?\\d+\\b", " ", pn)
  pn <- trimws(pn)
  
  # 1. Host store detection (kiosks)
  if (grepl("@", pn)) {
    host <- sub(".*@\\s*", "", pn)
    host <- gsub("#.*", "", host)
    host <- trimws(host)
    
    if (grepl("ALBERTSON", host)) {
      return("ALBERTSON'S")
    }
    
    if (grepl("RALPHS", owner_norm)) {
      return("RALPHS")
    }
    return(host)
  }
  if (grepl("WENDY'?S\\s*#?\\s*\\d+", pn)) {
    return("WENDY'S")
  }
  
  if (grepl("RALPHS", owner_norm)) {
    return("RALPHS")
  }
  
  
  # 2. Direct host store match
  for (host in names(hosts)) {
    pattern <- hosts[[host]]
    if (grepl(pattern, pn)) {
      return(host)   # return the NAME, not the pattern
    }
  }
  # 3. Chain detection
  for (brand in names(chains)) {
    pattern <- chains[[brand]]
    if (grepl(pattern, pn)) return(brand)
  }
  # 4. Default: independent business 
  return(owner_norm)
}


inspections$parent_company <- mapply(assign_parent,inspections$program_name,
                                                   inspections$owner_norm)


#continue explorations

#Column Parsing
# create new columns splitting pe description
program_types<-unique(inspections$PE.DESCRIPTION)

inspections$PROGRAM.TYPE<-sub("\\(.*","",inspections$PE.DESCRIPTION)

#using capture groupr from regex
inspections$SIZE<-ifelse(grepl("\\(",inspections$PE.DESCRIPTION),
                         sub(".*\\((.*)\\).*","\\1",inspections$PE.DESCRIPTION)
                         ,NA)
inspections$RISK.LEVEL<-ifelse(grepl("LOW RISK|MODERATE RISK|HIGH RISK",inspections$PE.DESCRIPTION),
                              sub(".*(LOW RISK|MODERATE RISK|HIGH RISK).*",
                                  "\\1",inspections$PE.DESCRIPTION),
                              NA)

# we know have three new columns that were derives from PE.DESCRIPTION
# better analysis

#change colnames to lower case
inspections <- janitor::clean_names(inspections)
violations <- janitor::clean_names(violations)


#alter violations table
violations$violation_description<-gsub("^#\\s*[0-9A-Za-z]+\\.\\s*","",violations$violation_description)


#Prepare for Microsoft SQL Server
#----------------------------------
write.csv(inspections,"inspections_clean.csv",row.names=FALSE)
write.csv(violations,"violations_clean.csv",row.names=FALSE)


