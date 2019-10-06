
## Cook County Property Tax Model in R

### What is it?

A while back [Tanya Schlusser](http://tanyaschlusser.github.io/) published an [excellent blog
post](http://tanyaschlusser.github.io/posts/property-tax-cook-county/) along with a [very accomplished Python
Notebook](https://github.com/tanyaschlusser/tanyaschlusser.github.io/blob/src/posts/property-tax-cook-county.ipynb)
modeling property taxes in her neighborhood. Turns out her neighborhood is next to mine, and Python is close to R so
figured I should examine / replicate / extend this.

This repo is my current crack at it. All this _is work in progress_ but a [_draft
writeup_](https://eddelbuettel.github.io/cook-county-tax-model/index.html) is available.

### Why?

Instead of having endless discussions comparing Python to R, or numpy to pandas, or base R to data.table to some verses,
... why not study different approaches next to each other allowing for comparisons in terms of length, legibility, run
time, dependencies, maintainability ... or whatever _your_ favorite criterion is?  This repo hopes
to eventually one of many that allow us to compare and contrast different approaches in order to
judge their respective merits, styles and maybe even performance. But that is as of right now a
fairly distant goal...

### Resources

#### Data: PINs

The following is mostly due to [Tanya's excellent write-up](http://tanyaschlusser.github.io/posts/property-tax-cook-county/).

- Cook County Tax Data via GIS interface / map view to obtain individual PINs or browse: https://maps.cookcountyil.gov/cookviewer/mapviewer.html
- Property Search at http://www.cookcountyassessor.com/Search/Property-Search.aspx -- Tanya's example is _Township="Oak
  Park", neighborhood="70 -", and property class="2+ story, over 62 years old, 2201-4999 sq ft"_.
- This gets a table of properties with in the requested township and neighborhood subject to the further constraints.
- We can copy and paste the PINs. Because we can later scrape the individual properties identified by their PINs.

#### Data: Scraping

Tanya describes a somewhat manual process via Selenium. I reckoned that something more automated would be desirable.

Given a set of PINs for a neighorhood and parameter selection, we can construct the per-property URLs. And using the
[rvest](https://cloud.r-project.org/web/packages/rvest/index.html) package makes fetching the page easy.  The remaining
difficulty is then to find which kind of `id` tag has the data, and which type of query extracts it.  Starting _e.g._
with the _Inspect_ tool in Chrome lets us 'see' where the data from the website resides in the html code / object
model.

This post at [ProgrammingR](http://www.programmingr.com/content/webscraping-rvest-easy-mba-can/) with the fetching title
_Webscraping with rvest: So Easy Even An MBA Can Do It!_ has the required next piece.  Based on the object inspection,
we can then select the query type.  Quoting from the page:

> In simple terms:
>
> Target by Class ID =>  appears as `<div class=’target’></div>` => you target this as: “.target”  
> Target by Element ID =>  appears as `<div id=’target’></div>` => you target this as: “#target”  
> Target by HTML tag type => appears as `<table></table>`  => you target this as “table”  
> Target child of another tag => appears as `<ol class=’sources’><li></li><ol>` => you target this as “sources li”

This leads us to the folling 'data per PIN' function:

```r
pin2dt <- function(pin) {
    ## url from article
    url <- "http://www.cookcountyassessor.com/Property.aspx?mode=details&pin="
    req <- paste0(url, pin)
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
```

Now we call just `lapply()` (or, in parallel, `mclapply()`) over the PINs and use `data.table::rbindlist` to glue all
records into a one `data.table` per PIN vector.

### Model

This is descibed well in the original write-up by Tanya.  We replicate it in R.

### Plots

This is also described well in the original write-up by Tanya. We can also replicate it. See [the
draft writeup](https://eddelbuettel.github.io/cook-county-tax-model/index.html) for more.

### Comparison

TBD

### Author 

Code in this repo was written by Dirk Eddelbuettel

### License

GPL (>= 2)

### Credits

This would not have gotten started and done without [the prior
work](http://tanyaschlusser.github.io/posts/property-tax-cook-county/) done by [Tanya
Schlusser](http://tanyaschlusser.github.io/).
