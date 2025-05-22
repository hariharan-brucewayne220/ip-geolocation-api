# Load required libraries
library(plumber)
library(httr)
library(jsonlite)
library(memoise)
library(RSQLite)
library(DBI)

# Initialize database connection
init_db <- function() {
  # Create/connect to SQLite database
  db <- dbConnect(SQLite(), "ip_geolocation.db")
  
  # Create table if it doesn't exist
  dbExecute(db, "
    CREATE TABLE IF NOT EXISTS ip_data (
      ip TEXT PRIMARY KEY,
      city TEXT,
      region TEXT,
      country TEXT,
      timezone TEXT,
      org TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  return(db)
}

# Get IP data from database
get_ip_data <- function(db, ip) {
  query <- "SELECT * FROM ip_data WHERE ip = ?"
  result <- dbGetQuery(db, query, params = list(ip))
  
  if (nrow(result) > 0) {
    return(list(
      ip = result$ip,
      city = result$city,
      region = result$region,
      country = result$country,
      timezone = result$timezone,
      org = result$org
    ))
  }
  return(NULL)
}

# Save IP data to database
save_ip_data <- function(db, data) {
  query <- "
    INSERT OR REPLACE INTO ip_data (ip, city, region, country, timezone, org, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
  "
  
  dbExecute(db, query, params = list(
    data$ip,
    data$city,
    data$region,
    data$country,
    data$timezone,
    data$org
  ))
  
  return(TRUE)
}

# Delete IP data from database
delete_ip_data <- function(db, ip) {
  query <- "DELETE FROM ip_data WHERE ip = ?"
  result <- dbExecute(db, query, params = list(ip))
  return(result > 0)
}

# Get all IP data from database
get_all_ip_data <- function(db) {
  query <- "SELECT ip FROM ip_data"
  result <- dbGetQuery(db, query)
  return(result$ip)
}

# Close database connection
close_db <- function(db) {
  dbDisconnect(db)
}

# Setup cache
cache <- cache_memory()

# Initialize database connection
db <- init_db()

# Core IP lookup function (no auth required)
lookup_ip <- function(ip) {
  # First try to get from database
  db_data <- get_ip_data(db, ip)
  if (!is.null(db_data)) {
    return(db_data)
  }
  
  # If not in database, fetch from API
  url <- paste0("https://ipapi.co/", ip, "/json/")
  resp <- tryCatch(GET(url), error = function(e) NULL)
  if (!is.null(resp) && status_code(resp) == 200) {
    data <- fromJSON(rawToChar(resp$content))
    result <- list(
      ip = ip,
      city = data$city,
      region = data$region,
      country = data$country_name,
      timezone = data$timezone,
      org = data$org
    )
    
    # Save to database
    save_ip_data(db, result)
    return(result)
  }
  return(NULL)
}

# Memoized version for caching repeated lookups
cached_lookup <- memoise(lookup_ip, cache = cache)

#* @apiTitle IP Geolocation API
#* @apiDescription Lightweight API that wraps ipapi.co to fetch city, country, and timezone info for a given IP

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

#* Add new IP data manually
#* @param ip:character IP address
#* @param city:character City name
#* @param region:character Region name
#* @param country:character Country name
#* @param timezone:character Timezone
#* @param org:character Organization
#* @post /geolocate
function(ip, city, region, country, timezone, org) {
  if (is.null(ip)) {
    return(list(status = 400, message = "IP address is required"))
  }
  
  # Create custom data
  custom_data <- list(
    ip = ip,
    city = city,
    region = region,
    country = country,
    timezone = timezone,
    org = org
  )
  
  # Save to database
  save_ip_data(db, custom_data)
  
  # Update cache
  cache$set(ip, custom_data)
  
  list(status = 201, message = "IP data added successfully", data = custom_data)
}

#* Update existing IP data
#* @param ip:character IP address
#* @param city:character City name
#* @param region:character Region name
#* @param country:character Country name
#* @param timezone:character Timezone
#* @param org:character Organization
#* @put /geolocate
function(ip, city, region, country, timezone, org) {
  if (is.null(ip)) {
    return(list(status = 400, message = "IP address is required"))
  }
  
  # Check if IP exists in database
  existing_data <- get_ip_data(db, ip)
  if (is.null(existing_data)) {
    return(list(status = 404, message = "IP data not found"))
  }
  
  # Create updated data
  updated_data <- list(
    ip = ip,
    city = city,
    region = region,
    country = country,
    timezone = timezone,
    org = org
  )
  
  # Update database
  save_ip_data(db, updated_data)
  
  # Update cache
  cache$set(ip, updated_data)
  
  list(status = 200, message = "IP data updated successfully", data = updated_data)
}

#* Delete IP data
#* @param ip:character IP address to delete
#* @delete /geolocate
function(ip) {
  if (is.null(ip)) {
    return(list(status = 400, message = "IP address is required"))
  }
  
  # Check if IP exists in database
  existing_data <- get_ip_data(db, ip)
  if (is.null(existing_data)) {
    return(list(status = 404, message = "IP data not found"))
  }
  
  # Delete from database
  delete_ip_data(db, ip)
  
  # Remove from cache
  cache$remove(ip)
  
  list(status = 200, message = "IP data deleted successfully")
}

#* Get cache metrics
#* @get /metrics
function() {
  # Get all IPs from database
  db_ips <- get_all_ip_data(db)
  
  list(
    status = 200,
    cache_keys = cache$keys(),
    database_ips = db_ips
  )
}

#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
} 