# Install required packages
required_packages <- c("plumber", "memoise", "profvis", "microbenchmark", "jsonlite", "httr", "dplyr")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos='https://cran.rstudio.com/')

# Load required packages
lapply(required_packages, library, character.only = TRUE)

# Run the API
pr <- plumb("app.R")
pr$run(port=8000) 