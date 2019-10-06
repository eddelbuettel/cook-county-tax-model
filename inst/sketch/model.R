
## sketch

library(data.table)
library(ggplot2)
library(GGally)
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
            CentAir              = as.factor(ifelse(CentAir == "Yes", 1L, 0L)),
            Frpl                 = as.factor(as.integer(Frpl)),
            Age                  = as.integer(Age),
            FullBaths            = as.factor(as.integer(FullBaths)),
            HalfBaths            = as.factor(as.integer(HalfBaths)),
            Basement             = as.factor(Basement),
            Garage               = as.factor(Garage),
            Attic                = as.factor(Attic),
            Use                  = as.factor(Use)
            )]
data[, `:=`(Basement  = stats::reorder(Basement, MktValCurrYear, FUN=median),
            Attic     = stats::reorder(Attic, MktValCurrYear, FUN=median))]
data[, `:=`(Basement  = stats::relevel(Basement, "None"),
            Attic     = stats::relevel(Attic, "None"))]
data


## histogram + density + rug
ggplot(data, aes(x=MktValCurrYear)) +
    geom_histogram(aes(y=..density..), bins=40, color="darkgrey", fill="lightblue") +
    geom_density(color="darkblue") + geom_rug(alpha=0.1)


## pairs -- CentAir,
ggpairs(data[, .(SqFt, BldgSqFt, Frpl, Age, FullBaths, HalfBaths, MktValCurrYear)],
        mapping = aes(alpha = 0.001),
        diag = list(continuous="densityDiag"),
        upper = list(continuous = "points",
                     discrete="facetbar"),
        lower = list(continuous = "points",
                     combo = "facetdensity"))

## minimal first fit, overall fairly weak
fit0 <- lm(log(MktValCurrYear) ~ log(SqFt) + log(BldgSqFt) + CentAir + Frpl + log(Age) +
              FullBaths + HalfBaths + Basement + Attic - 1, data)
#          data=data[Age > 0 & Use == "Single Family" & MktValCurrYear >= 100000,])
fit0

fit1 <- lm(log(MktValCurrYear) ~ log(SqFt) + log(BldgSqFt) + log(Age) + FullBaths + HalfBaths - 1, data)
#          data=data[Age > 0 & Use == "Single Family" & MktValCurrYear >= 100000,])
fit1


fit2 <- lm(log(MktValCurrYear) ~ log(SqFt) + log(BldgSqFt) + log(Age) - 1, data)
#data=data[Age > 0 & Use == "Single Family" & MktValCurrYear >= 100000,])
fit2

dd <- data[,.(log(MktValCurrYear))][[1]]
plot(predict(fit2), dd,  xlim=c(11.5,14.5), ylim=c(11.5,14.5))
abline(a=0,b=1)
summary(fit3 <- lm(log(MktValCurrYear) ~ log(SqFt) + log(BldgSqFt) + log(Age) - 1, data))
#data=data[Age > 0 & Use == "Single Family" & MktValCurrYear >= 100000,])
car::residualPlots(fit3, terms=~1)


fittedVsActual <- function(fitted, actual) {
    #print(str(fitted))
    #print(str(actual))
    #op <- par(pch=21)
    ll <- range( range(fitted), range(actual) )
    plot(fitted, actual,  xlim=ll, ylim=ll,
         pch=21, col="#0000ff40", bg="#10101010",
         xlab="Fitted Values", ylab="Actual Values")
    abline(a=0, b=1, col="lightgrey", lty="dashed")
    #par(op)
}

ggFittedVsActual <- function(fitted, actual) {
    ll <- range(range(fitted), range(actual))
    ggplot(data.frame(x=fitted, y=actual)) +
        geom_abline(intercept=0, slope=1, color="darkgrey") + #, style="dotted")
        geom_point(aes(x=fitted,y=actual),alpha=0.1,color="mediumblue") +
        coord_fixed(xlim=ll, ylim=ll) +
        xlab("Model Predictions") + ylab("Actual Values")
}


fit4 <- lm(MktValCurrYear ~ SqFt + BldgSqFt + Age - 1, data)
summary(fit4)
ggFittedVsActual(predict(fit4), data[,MktValCurrYear])

fit5 <- lm(log(MktValCurrYear) ~ log(SqFt) + 0*I(log(BldgSqFt)^2) + log(BldgSqFt) + Age - 1, data)
summary(fit5)
ggFittedVsActual(exp(predict(fit5)), data[,MktValCurrYear])


attic <- data[, .(Attic, MktValCurrYear)]
ggplot(attic, aes(y=MktValCurrYear, x=Attic, color=Attic)) +
    geom_boxplot(notch=TRUE) + geom_jitter(position=position_jitter(0.25), cex=0.75, alpha=0.5) +
    coord_flip() + theme(legend.position = "none")

attic2 <- data[, .(Attic, Resid=resid(fit4))]
ggplot(attic2, aes(y=Resid, x=Attic, color=Attic)) +
    geom_boxplot(notch=TRUE) + geom_jitter(position=position_jitter(0.25), cex=0.75, alpha=0.5) +
    coord_flip() + theme(legend.position = "none")

attic3 <- data[, .(Attic, Resid=exp(resid(fit5)))]
ggplot(attic3, aes(y=Resid, x=Attic, color=Attic)) +
    geom_boxplot(notch=TRUE) + geom_jitter(position=position_jitter(0.25), cex=0.75, alpha=0.5) +
    coord_flip() + theme(legend.position = "none")

data[, finishedAttic := grepl("Living", as.character(Attic))]
fit4a <- lm(MktValCurrYear ~ SqFt + BldgSqFt + Age + finishedAttic - 1, data)
summary(fit4a)

fit5a <- lm(log(MktValCurrYear) ~ log(SqFt) + log(BldgSqFt) + Age + finishedAttic - 1, data)
summary(fit5a)



bsmt <- data[, .(Basement, MktValCurrYear)]
ggplot(bsmt, aes(y=MktValCurrYear, x=Basement, color=Basement)) +
    geom_boxplot(notch=TRUE) + geom_jitter(position=position_jitter(0.25), cex=0.75, alpha=0.5) +
    coord_flip() + theme(legend.position = "none")

bsmt2 <- data[, .(Basement, Resid=resid(fit4))]
ggplot(bsmt2, aes(y=Resid, x=Basement, color=Basement)) +
    geom_boxplot(notch=TRUE) + geom_jitter(position=position_jitter(0.25), cex=0.75, alpha=0.5) +
    coord_flip() + theme(legend.position = "none")

bsmt3 <- data[, .(Basement, Resid=exp(resid(fit5)))]
ggplot(bsmt3, aes(y=Resid, x=Basement, color=Basement)) +
    geom_boxplot(notch=TRUE) + geom_jitter(position=position_jitter(0.25), cex=0.75, alpha=0.5) +
    coord_flip() + theme(legend.position = "none")
