
## sketch

library(data.table)
data <- fread("data/riverforest.csv")

nm <- names(data)
setnames(data, nm, gsub("^Prop", "", nm))
setnames(data, nm, gsub("^Char", "", nm))
setnames(data, nm, gsub("^Info", "", nm))

## minimal transformation
data[, `:=`(MktValCurrYear       = as.numeric(gsub("[$,]", "", MktValCurrYear)),
            MktValPrevYear       = as.numeric(gsub("[$,]", "", MktValPrevYear)),
            AsdValTotalCertified = as.numeric(gsub("[$,]", "", AsdValTotalCertified)),
            AsdValTotalFirstPass = as.numeric(gsub("[$,]", "", AsdValTotalFirstPass)),
            SqFt                 = as.numeric(gsub("[,]", "", SqFt)),
            BldgSqFt             = as.numeric(gsub("[,]", "", BldgSqFt)),
            CentAir              = ifelse(CentAir == "Yes", 1L, 0L),
            Frpl                 = as.integer(Frpl),
            Age                  = as.integer(Age),
            FullBaths            = as.integer(FullBaths),
            HalfBaths            = as.integer(HalfBaths),
            Basement             = as.factor(Basement),
            Garage               = as.factor(Garage),
            Attic                = as.factor(Attic),
            Use                  = as.factor(Use)
            )]
data

## minimal first fit, overall fairly week, some outliers to examine
fit <- lm(log(MktValCurrYear) ~ log(SqFt) + log(BldgSqFt) + CentAir + Frpl + log(Age) +
              FullBaths + HalfBaths + Basement + Attic,
          data=data[Age > 0 & Use == "Single Family" & MktValCurrYear >= 100000,])
fit
