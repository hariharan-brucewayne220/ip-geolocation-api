# IP Geolocation API

A lightweight RESTful API built with R Plumber that provides IP geolocation services with local caching and database persistence.

## Features

- IP geolocation lookup with caching
- SQLite database for data persistence
- RESTful endpoints (GET, POST, PUT, DELETE)
- Modern web interface
- CORS support
- Error handling
- Cache metrics

## Prerequisites

- R (version 4.0.0 or higher)
- Required R packages:
  - plumber
  - httr
  - jsonlite
  - memoise
  - RSQLite
  - DBI

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ip-geolocation-api
```

2. Install required R packages:
```R
Rscript install_packages.R
```

## Running the API

1. Make sure you have all the required R packages installed. You can install them using:
```R
install.packages(c("plumber", "httr", "jsonlite", "memoise", "RSQLite", "DBI"))
```

2. Start the API server using one of these methods:

   a. Using R console:
   ```R
   library(plumber)
   pr <- plumber::plumb("api.R")
   pr$run(port=8000)
   ```

   b. Using Rscript from command line:
   ```bash
   Rscript -e "library(plumber); pr <- plumber::plumb('api.R'); pr$run(port=8000)"
   ```

3. The API will be available at `http://localhost:8000`

4. To serve the web interface, open a new terminal window and run:
   ```bash
   python -m http.server 8001
   ```
   Then open your web browser and visit `http://localhost:8001` to access the web interface.

5. To test if the API is running, open your web browser and visit:
   - `http://localhost:8000/geolocate?ip=8.8.8.8` for a test lookup
   - `http://localhost:8000/metrics` to check the API status

6. To stop the servers:
   - Press `Ctrl+C` in the terminal where the API is running
   - Press `Ctrl+C` in the terminal where the web server is running

Note: Make sure you're in the correct directory where `api.R` and `index.html` are located when running these commands.

## API Endpoints

### GET /geolocate
Look up geolocation data for an IP address.

**Query Parameters:**
- `ip`: IP address to look up

**Example:**
```bash
curl "http://localhost:8000/geolocate?ip=8.8.8.8"
```

### POST /geolocate
Add new IP geolocation data manually.

**Parameters:**
- `ip`: IP address
- `city`: City name
- `region`: Region name
- `country`: Country name
- `timezone`: Timezone
- `org`: Organization

**Example:**
```bash
curl -X POST "http://localhost:8000/geolocate" \
  -H "Content-Type: application/json" \
  -d '{
    "ip": "1.1.1.1",
    "city": "Sydney",
    "region": "NSW",
    "country": "Australia",
    "timezone": "Australia/Sydney",
    "org": "Cloudflare"
  }'
```

### PUT /geolocate
Update existing IP geolocation data.

**Parameters:**
- Same as POST endpoint

**Example:**
```bash
curl -X PUT "http://localhost:8000/geolocate" \
  -H "Content-Type: application/json" \
  -d '{
    "ip": "1.1.1.1",
    "city": "Sydney",
    "region": "NSW",
    "country": "Australia",
    "timezone": "Australia/Sydney",
    "org": "Cloudflare"
  }'
```

### DELETE /geolocate
Delete IP geolocation data.

**Query Parameters:**
- `ip`: IP address to delete

**Example:**
```bash
curl -X DELETE "http://localhost:8000/geolocate?ip=1.1.1.1"
```

### GET /metrics
Get cache and database metrics.

**Example:**
```bash
curl "http://localhost:8000/metrics"
```

## Web Interface

A modern web interface is provided at `index.html`. Open this file in a web browser to interact with the API through a user-friendly interface.

Features:
- IP lookup
- Add new IP data
- Update existing IP data
- Delete IP data
- View cache metrics
- Beautiful postcard-style results display

## Database

The API uses SQLite for data persistence. The database file `ip_geolocation.db` is created automatically when the API starts.

## Caching

The API implements a two-level caching strategy:
1. In-memory cache for fast repeated lookups
2. SQLite database for persistent storage

## Error Handling

The API provides proper error handling with appropriate HTTP status codes:
- 200: Success
- 201: Created
- 400: Bad Request
- 404: Not Found
- 500: Internal Server Error

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 