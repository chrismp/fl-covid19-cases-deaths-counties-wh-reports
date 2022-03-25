library(DatawRappr)

source('download-process.r')

print("Starting chart updater")

updateDateFormat <- gsub(
  pattern = " 0",
  replacement = ' ',
  x = format(
    x = m30$formatteddate.x[[1]],
    format = "%B %d, %Y"
  )
)

chartIDs <- c(
  'NyRfc', # past 30 days' death rates map
  'lNr0E', # ifections past 30 days' map
  'D0oqp', # total death tolls by fl county table
  'HH5nw' # infections by fl county table
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



