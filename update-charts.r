library(DatawRappr)

source('download-process.r')

print("Starting chart updater")

updateDateFormat <- gsub(
  pattern = " 0",
  replacement = ' ',
  x = format(
    x = max(latestdatatotals$formatteddate),
    format = "%B %d, %Y"
  )
)

chartIDs <- c(
  'SE3YD',
  'LPOSr',
  'eV6oK'
)

apikey <- Sys.getenv("DATAWRAPPER_API")

for (id in chartIDs) {
  dw_edit_chart(
    chart_id = id,
    api_key = apikey,
    annotate = paste0("Updated ",updateDateFormat,'.')
  )
  print("Publishing chart")  
  dw_publish_chart(
    chart_id = id,
    api_key = apikey,
    return_urls = TRUE
  )  
}



