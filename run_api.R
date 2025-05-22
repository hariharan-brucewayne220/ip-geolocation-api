# Print startup message
cat("Starting IP Geolocation API...\n")

# Create and run the Plumber API
tryCatch({
  # Create the Plumber router
  pr <- plumber::plumb("api.R")
  
  # Run the API
  pr$run(port = 8000, host = "0.0.0.0")
}, error = function(e) {
  cat("Error starting API:", e$message, "\n")
  # Close database connection if it exists
  if (exists("db")) {
    try(close_db(db))
  }
  quit(status = 1)
}) 