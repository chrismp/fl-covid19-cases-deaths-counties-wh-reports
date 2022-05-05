library(dplyr)

# Download
url <- 'https://irma.gatehousemedia.com/misc/20200417-covid-county-analysis/white-house-reports/FL.csv'
d <- read.csv(
  file = url,
  colClasses = c(
    'filedate'='character',
    'fips'='character'
  )
)

# process
d$formatteddate <- as.Date(
  x = d$filedate,
  format = '%Y%m%d'
)

# merge with 2020 census population data
m <- merge(
  x = d,
  y = read.csv(
    file = 'fl-counties-2020-pop.csv',
    colClasses = c('X2010.GeoID'='character')
  ),
  by.x = 'fips',
  by.y = 'X2010.GeoID',
  all = T
)

m$countyformatted <- gsub(
  pattern = 'County, FL',
  replacement = '',
  x = m$county
)

m <- relocate(
  .data = m,
  countyformatted,
  fips
)

# last X days of deaths and cases, where we have data for the latest date and X days prior
maxdateoffset <- 0
while (T) {
  xdaysagodata <- filter(
    .data = m,
    formatteddate == ((max(formatteddate, na.rm=T)-maxdateoffset) - 7)
  )
  
  latestdatatotals <- filter(
    .data = m,
    formatteddate == max(formatteddate,na.rm=T) - maxdateoffset
  )
  
  if(nrow(xdaysagodata)>1 && nrow(latestdatatotals)>1) break
  maxdateoffset <- maxdateoffset + 1
}

latestdatatotals$casesper100k <- latestdatatotals$cases / latestdatatotals$X2020.Total.Population * 100000
latestdatatotals$casesper100 <- latestdatatotals$cases / latestdatatotals$X2020.Total.Population * 100
latestdatatotals$deathsper100k <- latestdatatotals$deaths / latestdatatotals$X2020.Total.Population * 100000
latestdatatotals$casedeathratio <- latestdatatotals$deaths / latestdatatotals$cases * 100

mXdays <- merge(
  x = latestdatatotals,
  y = xdaysagodata,
  by = 'fips'
)

mXdays$casespast30days <- mXdays$cases.x - mXdays$cases.y
mXdays$deathspast30days <- mXdays$deaths.x - mXdays$deaths.y
mXdays$casespast30days_per100k <- mXdays$casespast30days / mXdays$X2020.Total.Population.x * 100000
mXdays$deathspast30days_per100K <- mXdays$deathspast30days / mXdays$X2020.Total.Population.x * 100000
mXdays$casedeathratio <- mXdays$deathspast30days / mXdays$casespast30days * 100

# Write to file
o <- 'output'
dir.create(o)

write.csv(
  x = m,
  file = paste0(o,'/covid-cases-deaths-fl-counties-date.csv'),
  na = '',
  row.names = F
)

write.csv(
  x = latestdatatotals,
  file = paste0(o,'/covid-latest-total-cases-deaths-fl-counties.csv'),
  na = '',
  row.names = F
)

write.csv(
  x = mXdays,
  file = paste0(o,'/covid-cases-deaths-fl-counties-past30days.csv'),
  na = '',
  row.names = F
)

