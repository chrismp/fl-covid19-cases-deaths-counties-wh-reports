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

# latest data totals
latestdatatotals <- filter(
  .data = m,
  formatteddate == max(formatteddate,na.rm = T)
)

latestdatatotals$casesper100k <- latestdatatotals$cases / latestdatatotals$X2020.Total.Population * 100000
latestdatatotals$casesper100 <- latestdatatotals$cases / latestdatatotals$X2020.Total.Population * 100
latestdatatotals$deathsper100k <- latestdatatotals$deaths / latestdatatotals$X2020.Total.Population * 100000

# last 30 days of deaths and cases
thirtydaysagodata <- filter(
  .data = m,
  formatteddate == (max(m$formatteddate) - 30)
)

m30 <- merge(
  x = latestdatatotals,
  y = thirtydaysagodata,
  by = 'fips'
)

m30$casespast30days <- m30$cases.x - m30$cases.y
m30$deathspast30days <- m30$deaths.x - m30$deaths.y
m30$casespast30days_per100k <- m30$casespast30days / m30$X2020.Total.Population.x * 100000
m30$deathspast30days_per100K <- m30$deathspast30days / m30$X2020.Total.Population.x * 100000

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
  x = m30,
  file = paste0(o,'/covid-cases-deaths-fl-counties-past30days.csv'),
  na = '',
  row.names = F
)