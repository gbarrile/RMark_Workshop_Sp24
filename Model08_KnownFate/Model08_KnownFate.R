
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# RMark Workshop
# University of Wyoming
# Spring 2024

# Model 8 - Known Fate Model

# Description: Steps thru an example analysis of a
# known fate model as implemented in the package `RMark`.

# Some references:

# Program MARK – a ‘gentle introduction.’ Chapter 16: Known-fate models. 
# Go to http://www.phidot.org/software/mark/docs/book/ and select Chapter 16 from the dropdown menu.
# 
# Walker, J., & Lindberg, M. S. (2005). Survival of scaup ducklings in the boreal forest of Alaska. 
# The Journal of wildlife management, 69(2), 592-600.
# 
# Schwartz, C. C., Haroldson, M. A., White, G. C., Harris, R. B., Cherry, S., Keating, K. A., 
# ... & Servheen, C. (2006). Temporal, spatial, and environmental influences on the demographics of 
# grizzly bears in the Greater Yellowstone Ecosystem. Wildlife Monographs, 161(1), 1-8.

# The code below addresses the question: 
# How does body condition influence the survival of ducks that we tracked via radio-telemetry?

# Gabe Barrile - University of Wyoming
# Last updated 02/21/2024
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- Outline -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# This script contains the following sections:
# 1) Install and load packages
# 2) Read-in field data
# 3) Format data for RMark
# 4) Fit Known Fate models
# 5) Prediction and plotting
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 1) Install and load packages -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Check if RMark and tidyverse are installed.
# If yes, load them.  If not, install, then load.

# RMark for fitting the Dynamic Occupancy model
if("RMark" %in% rownames(installed.packages()) == FALSE) {
  install.packages("RMark")
}
require(RMark)

# ggplot2 for plotting
if("ggplot2" %in% rownames(installed.packages()) == FALSE) {
  install.packages("ggplot2")
}
require(ggplot2)

# tidyverse to format data
if("tidyverse" %in% rownames(installed.packages()) == FALSE) {
  install.packages("tidyverse")
}
require(tidyverse)

# if you needed to cite the RMark package
citation("RMark")
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 2) Read-in input data -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# let's use the blackduck dataset that's included in the RMark package
data("Blackduck")

# shorten the name of the data frame
bd <- Blackduck

# let's look at the df
head(bd)

# format of Known-Fate data (important!)

# The fate of each individual is entered using a live-dead format: 
# the 1st number indicates if the animal was alive and studied in a given time
# interval (1 = yes it was alive and studied) and the 2nd number indicates
# if the animal died or not in that interval (1 = yes, it died): 
# 10 indicates it was studied and survived; a 11 indicates it was studied and died.

# With multiple intervals (say 3 years), you could  enter new animals as the study goes along,
# e.g., 001011 = not studied the 1st year, studied and survived the 2nd year, and died in the 3rd year) 
# or 000010 (not studied the 1st or 2nd years; studied and survived the 3rd year).

# by looking at the encounter histories, you might notice three typical scenarios:
# for each animal tagged, it...
# 1. survives to end of study and is detected at each sampling occasion after its release
# 2. dies sometime during the study and its carcass is found on the first sampling occasion after its death
# 3. survives up to the point at which time it is censored.

# Censoring
# it might be rare to observe the time of death for every individual in the study.
# Animals are 'lost' (i.e., censored) due to radio failure or other reasons like emigration.
# We estimate the survival function in the presence of censoring.
# Note: it is recommended that, if animals go missing and are found later, then do
# not reconstruct unobserved observation times. Rather, censor from dataset and then
# re-enter under staggered entry.

# also, if animals are monitored at irregular intervals, then use Nest Survival models,
# which is a special type of known fate analysis that we will cover in the final mini lesson of this workshop

# let's add a covariate of interest to our dataset
# fake covariate for body condition at the beginning of the study
# i.e., body condition when transmitter was placed on an individual bird
bd$bodycond <- NA
bd$bodycond[1:24] <- sample(1:7, 24, replace=T)
bd$bodycond[25:48] <- sample(3:10, 24, replace=T)

head(bd)
# how many known to be dead?
# value <- "11"
# chars <- bd$ch
# table(grepl(value, chars, fixed = TRUE)) # 18 of 48 birds are known to have died
# we likely don't know whether every animal died or not...some animals are 'censored'

rm(Blackduck)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 3) Format data for RMark -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# duck will be our dataframe that we input into RMark
duck <- data.frame(ch = bd$ch, 
                  freq = 1, 
                  bodycond = bd$bodycond) # Note: column names in RMark cannot be longer than ten characters!!

# are we missing any data
table(is.na(duck)) # no missing data = good!

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 4) Fit Known Fate Models in RMark -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# first, process the data for RMark
# input the model that we want in the 'model =' argument of the process.data function

# here are the list of models in RMark
setup.model(model = "") # 91 models

# As you can see, RMark includes lots of models that can be input into the model= argument below
# Here we use the "Known" model because we are interested in Known-Fate analysis for survival

# Visit this link for a full list of MARK models supported in RMark:
# https://github.com/jlaake/RMark/blob/master/RMark/inst/MarkModels.pdf


# now, process data in RMark format
t.proc = process.data(duck, model = "Known")

# create design data
t.ddl = make.design.data(t.proc)

# look at design data
names(t.ddl)

# known-fate data format for encounter histories
t.proc
t.proc$nocc
table(nchar(t.proc$data$ch)) # capture histories are double the length of the number of occasions, which
# is how known-fate data are structured

# Known-Fate model has only one parameter: Survival probability
t.ddl$S # true survival because mortality is known for each bird (at least the birds that weren't censored)


# Now let's fit a model
# I usually do this in 2 steps
# First, specify the formula for each model parameter and save as an object
# Then insert these objects for each parameter in the model fitting function 'mark'

# define S model
t.ddl$S # survival probability
head(t.proc$data)
# let's model survival as a function of body condition at the beginning of the study
S.body = list(formula =  ~  bodycond)


# Now fit the model

# you will need (want) an output folder for the mark files, just so your
# directory does not get cluttered
# Create a new folder called 'models' in your working directory
# set working directory to that folder
setwd()

# fit model
mod1 <- mark(t.proc, # processed data
            t.ddl,  # design data
            model.parameters=list(S = S.body), # survival probability
            delete = TRUE)  


# check out model output

# beta coefficients
mod1$results$beta

# real estimates
mod1$results$real # this is survival over whatever interval the study was conducted 
# (e.g., how often were birds tracked? Daily, weekly, monthly, etc.)

# derived parameters
mod1$results$derived # probability an animal survives the entire study period (I think)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 5) Prediction and plotting -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# let's plot the relationship between body condition and survival

# need to specify the indices correctly (very important!)
mod1$pims$S # let's use indices = 1

# create sequence of values to predict over
head(bd)
range(bd$bodycond)
# set new data
newdat <- data.frame(bodycond=seq(1, 10, length.out = 40))

# predict to newdata
pred.cov <- covariate.predictions(mod1, data=newdat, indices=c(1))$estimates

# okay, plot it
min(pred.cov$lcl)
max(pred.cov$ucl)
op <- par(mar = c(5,5,4,2) + 0.1) # default is 5,4,4,2
plot(x = pred.cov$covdata, y = pred.cov$estimate, pch=16, 
     ylab = "Survival Probability (e.g., weekly)",
     xlab = "Body Condition", cex.lab=1.5, cex.axis=1.2, 
     col="darkgray", ylim=c(0,1))
box(lwd = 4, col = 'black')
lines(pred.cov$covdata, pred.cov$estimate, lwd=8, col="blue")
lines(pred.cov$covdata, pred.cov$lcl, lwd=4, lty=2, col="black")
lines(pred.cov$covdata, pred.cov$ucl, lwd=4, lty=2, col="black")


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# END
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


























