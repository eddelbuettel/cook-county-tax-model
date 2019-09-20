
library(rvest)
library(data.table)
source("../R/data.R")

csvfiles <- dir("~/git/cook-county-tax-model/data/pin/", pattern="*.csv", full.name=TRUE)
#csvfiles <- dir(system.file("data", "pin", package="cook-county-tax-model"),  # base directory
#                pattern="*.csv", full.name=TRUE)
data <- files2data(csvfiles)

print(dim(data))
fwrite(data, "data.csv")
