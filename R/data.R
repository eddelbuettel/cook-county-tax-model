## see
##  https://tanyaschlusser.github.io/posts/property-tax-cook-county/
##  https://github.com/tanyaschlusser/tanyaschlusser.github.io/blob/src/posts/property-tax-cook-county.ipynb
##  https://maps.cookcountyil.gov/cookviewer
##  http://www.cookcountyassessor.com/Property.aspx?mode=details&pin=15122020270000

library(rvest)
library(data.table)

.simpleTest <- function() {
    page <- read_html("http://www.cookcountyassessor.com/Property.aspx?mode=details&pin=16063200610000")
    nodes <- html_nodes(page, xpath='//div[@id="details"]//span/@id')
    nodesvec <- html_text(nodes)
    nodesnames <- gsub("ctl00_phArticle_ctlPropertyDetails_lbl", "", nodesvec)
}

## given one pin, return corresponding (one-row) data.table
pin2dt <- function(pin) {
    ## url from article
    url <- "http://www.cookcountyassessor.com/Property.aspx?mode=details&pin="
    req <- paste0(url, format(pin, digits=14))
    #print(req)
    res <- read_html(req)

    ## xpath trick from article
    nodes <- html_nodes(res, xpath='//div[@id="details"]//span/@id')
    nodesvec <- html_text(nodes)
    nodesnames <- gsub("ctl00_phArticle_ctlPropertyDetails_lbl", "", nodesvec)

    ## css="#sometext" trick from rvest article
    rl <- lapply(nodesvec, function(v) { html_text(html_node(res, css=paste0("#", v))) } )
    names(rl) <- nodesnames

    dt <- data.table(as.data.frame(rl))
    dt
}

## helper function for a single file with PINs
onefile2data <- function(csvfile) {
    ## we use read.table as it skips the # we interweave between pages
    cat("... reading ", csvfile, "\n")
    pins <- read.table(csvfile, header=TRUE)
    data <- rbindlist(lapply(pins[,1], function(f) tryCatch(pin2dt(f), warning = function(w) NULL, error = function(e) NULL)))
    #saveRDS(data, paste0(csvfile, ".rds"))
    data
}

## loop over several csv fiiles
files2data <- function(csvfiles) {
    rl <- lapply(csvfiles, onefile2data)
    #print(length(rl))
    res <- rbindlist(rl)
    #print(dim(res))
    res
}
