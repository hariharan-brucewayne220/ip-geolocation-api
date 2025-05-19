#* @apiTitle IP Geolocation API
#* @apiDescription Lightweight API that wraps ipapi.co to fetch city, country, and timezone info for a given IP

library(plumber)
library(httr)
library(jsonlite)
library(memoise)

# Setup cache
cache <- cache_memory()

# Core IP lookup function (no auth required)
lookup_ip <- function(ip) {
  url <- paste0("https://ipapi.co/", ip, "/json/")
  resp <- tryCatch(GET(url), error = function(e) NULL)
  if (!is.null(resp) && status_code(resp) == 200) {
    data <- fromJSON(rawToChar(resp$content))
    return(list(
      ip = ip,
      city = data$city,
      region = data$region,
      country = data$country_name,
      timezone = data$timezone,
      org = data$org
    ))
  }
  return(NULL)
}

# Memoized version for caching repeated lookups
cached_lookup <- memoise(lookup_ip, cache = cache)

#* Get location info for IP
#* @param ip:character IP address to lookup
#* @get /geolocate
function(ip = NULL) {
  if (is.null(ip)) {
    return(list(status = 400, message = "Please provide an IP using ?ip=..."))
  }
  result <- cached_lookup(ip)
  if (is.null(result)) {
    return(list(status = 404, message = "No data found for the given IP"))
  }
  list(status = 200, data = result)
}

#* Get cache metrics
#* @get /metrics
function() {
  list(status = 200, cache_keys = cache$keys())
}

#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
}

#* @plumber
function(pr) {
  pr$setErrorHandler(function(req, res, err) {
    list(status = 500, message = "Internal server error")
  })
}
