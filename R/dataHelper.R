
## use PINs in the pin/river-forest* files to obtain data set
.getData <- function() {
    setwd(system.file("data", package="cook-county-tax-model")
    csvfiles <- dir("pin/", pattern="river-forest*.csv", full.name=TRUE)
    data <- files2data(csvfiles)
    fwrite(data, "riverforest.csv")
}
