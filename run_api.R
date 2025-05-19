# Load required packages
library(plumber)

# Print startup message
message("Starting IP Geolocation API...")

# Set working directory if needed
setwd("H:/nextproject")

# Create plumber object
pr <- plumber::plumb('app.R')
pr$setDebug(TRUE)  # Enable debug mode

# Print server start message
message("API server starting on http://localhost:8000")
message("Swagger docs at http://localhost:8000/__docs__ or /__swagger__")
message("Press Ctrl+C to stop the server")

# Start the API
pr$run(port=8000) 