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

latestdatatotals <- filter(
  .data = m,
  formatteddate == max(formatteddate,na.rm = T)
)

latestdatatotals$casesper100k <- latestdatatotals$cases / latestdatatotals$X2020.Total.Population * 100000
latestdatatotals$deathsper100k <- latestdatatotals$deaths / latestdatatotals$X2020.Total.Population * 100000

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

