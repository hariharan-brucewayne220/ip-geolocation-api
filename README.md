# IP Geolocation API

A lightweight R Plumber API that wraps [ipapi.co](https://ipapi.co/) to fetch city, country, timezone, and organization info for a given IP address. Includes a modern HTML frontend for easy testing.

---

## Features
- Lookup geolocation info for any IP address via `/geolocate` endpoint
- Caching for repeated lookups
- CORS enabled for easy frontend integration
- Swagger docs for API exploration
- Simple, modern HTML UI (see `index.html`)

---

## Setup

### Requirements
- R (with packages: plumber, httr, jsonlite, memoise)
- Python (optional, for serving the HTML file)

### Install R packages (in R):
```r
install.packages(c("plumber", "httr", "jsonlite", "memoise"))
```

---

## Running the API

1. **Start the API in R:**
   ```r
   source("run_api.R")
   ```
   - The API will run at [http://localhost:8000](http://localhost:8000)
   - Swagger docs: [http://localhost:8000/__docs__](http://localhost:8000/__docs__)

2. **Endpoints:**
   - `GET /geolocate?ip=8.8.8.8`  
     Returns geolocation info for the given IP.
   - `GET /metrics`  
     Returns cache info.

---

## Using the HTML Frontend

1. **Serve the HTML file:**
   - Easiest: In your project folder, run:
     ```bash
     python -m http.server 8001
     ```
   - Then open [http://localhost:8001/index.html](http://localhost:8001/index.html) in your browser.

2. **How to use:**
   - Enter an IP address (e.g., `8.8.8.8`) and click "Lookup IP"
   - See the geolocation details in a modern card UI
   - Click "Show Cache Metrics" to view cache info

---

## Example API Response
```json
{
  "status": [200],
  "data": {
    "ip": "8.8.8.8",
    "city": "Mountain View",
    "region": "California",
    "country": "United States",
    "timezone": "America/Los_Angeles",
    "org": "GOOGLE"
  }
}
```

---

## Notes
- The API uses [ipapi.co](https://ipapi.co/) for geolocation data (no API key required for basic usage).
- CORS is enabled for local development and browser testing.
- For any issues, check your R console for errors or inspect network requests in your browser.

---

## License
MIT 