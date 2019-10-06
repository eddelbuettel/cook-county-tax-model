
## use PINs in the pin/river-forest* files to obtain data set
.getData <- function() {
    setwd(system.file("extdata", package="ccptm"))
    csvfiles <- dir("pin/", pattern="river-forest*.csv", full.names=TRUE)
    data <- files2data(csvfiles)
    fwrite(data, system.file("data", "riverforest.csv", package="ccptm"))
}

#' River Forest, IL, Property Tax Data
#'
#' Data has been scraped downloaded from the Cook County, IL, property tax website
#' at <https://www.cookcountyassessor.com/Search/Property-Owner-Search.aspx> using
#' combination of a) Property Index Number (PIN) search via the URL
#' \url{http://www.cookcountyassessor.com/Search/Property-Search.aspx} and
#' b) per-prortery access given a pin (as final argument) via
#' \url{http://www.cookcountyassessor.com/Property.aspx?mode=details&pin=...}.
#' The resulting data set contains all columns provided by the website.
#' @name riverforest
#' @docType data
#' @usage data(riverforest)
#' @format An data.frame (or data.table) object
#' @keywords datasets
NULL
