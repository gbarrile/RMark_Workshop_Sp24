
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# RMark Workshop
# University of Wyoming
# Spring 2024

# Model 9 - Nest Survival Model

# Description: Steps thru an example analysis of a
# nest survival analysis as implemented in the package `RMark`.

# Some references:

# Program MARK – a ‘gentle introduction.’ Chapter 17: Nest survival models, written by Jay Rotella. 
# Go to http://www.phidot.org/software/mark/docs/book/ and select Chapter 17 from the dropdown menu.

# Rotella, J. 2007. Modeling nest-survival data: recent improvements and future directions. 
# Studies in Avian Biology 34: 145–148.

# Dinsmore, S. J., White, G. C., & Knopf, F. L. (2002). Advanced techniques for modeling avian nest survival. 
# Ecology, 83(12), 3476-3488. 

# Devineau, O., Kendall, W. L., Doherty Jr, P. F., Shenk, T. M., White, G. C., Lukacs, P. M., & Burnham, K. P. (2014).
# Increased flexibility for modeling telemetry and nest‐survival data using the multistate framework. 
# The Journal of wildlife management, 78(2), 224-230. 

# The code below addresses the question: 
# How does the age of the nest and the amount of vegetation surrounding the nest influence nest survival?

# Gabe Barrile - University of Wyoming
# Last updated 02/25/2024
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- Outline -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# This script contains the following sections:
# 1) Install and load packages
# 2) Read-in field data
# 3) Format data for RMark
# 4) Fit Nest Survival models
# 5) Prediction and plotting
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 1) Install and load packages -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Check if RMark and tidyverse are installed.
# If yes, load them.  If not, install, then load.

# RMark for fitting the nest survival model
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

# First, if we know how many nests we found and we know the fate of every nest, 
# why not just compare the proportion of successful nests among groups
# with different attributes? Well, as Harold Mayfield pointed out several decades
# ago, such an analysis is only valid if destroyed nests can be found with the same
# probability as active ones. In most studies successful and unsuccessful nests are not found with equal
# probability, and most nests are found after egg laying has commenced. Mayfield pointed out that under
# these circumstances the proportion of successful nests, which he termed apparent nesting success, is
# biased high relative to actual nesting success, the proportion of nests that survive from initiation to
# completion (the above text is from Chapter 17 in the Program MARK book)

# So, we can use Nest Survival models, which are a special type of known fate analysis and
# especially useful if animals are monitored at irregular intervals

# let's use the mallard dataset that's included in the RMark package
data("mallard")
# this is a nest survival data set on mallards. The data set and analysis is described by Rotella et al.(2004).
# In short, 565 nests that were monitored on 18 sites during a 90 day nesting season. 
# Nests of various ages were found during periodic nest searches conducted throughout the
# nesting season. Once a nest was found, it was re-visited every 4 to 6 days to determine its fate (a binary
# outcome). For each nest, several covariates of interest were measured: (1) the date the nest was found;
# (2) the nest’s initiation date, which provides information about the age of the nest when it was found,
# its age during each day of the nesting season, and its expected hatch date (35 days after nest initiation,
# which is when young typically leave the nest in this species); (3) a measure of how much the vegetation
# around the nest site visually obscured the nest; (4) the proportion of grassland cover on the 10.4-km2
# study site that contained the nest; and (5-7) the habitat type in which the nest was located (3 indicator
# variables, each coded as 0 or 1, that were used to distinguish among nests found in 4 different habitat
# types: native grassland, planted nesting cover, wetland vegetation, and roadside right-of-ways).

# shorten the name of the data frame
bd <- mallard
# FirstFound: the day the nest was first found
# LastPresent: the last day that chicks were present
# LastChecked: the last day the nest was checked
# Fate :the fate of the nest; 0=hatch and 1 depredated
# Freq: the frequency of nests with this data; always 1 in this example
# Robel: Robel reading of vegetation thickness
# PpnGrass: proportion grass in vicinity of nest
# Native: dummy 0/1 variable; 1 if native vegetation
# Planted: dummy 0/1 variable; 1 if planted vegetation
# Wetland: dummy 0/1 variable; 1 if wetland vegetation
# Roadside: dummy 0/1 variable; 1 if roadside vegetation
# AgeFound: age of nest in days the day the nest was found
# AgeDay1: age of nest at beginning of study

# The first 5 fields must be named as they are shown for nest survival models. 
# Freq and the remaining fields are optional. 

# You can have an 'id' column for each nest if you want, just make sure the column name is 'id'

# let's look at the df
head(bd) # completely different than our other capture-mark-recapture models


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 3) Format data for RMark -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# we can process our dataset for RMark directly, so let's skip this step

# are we missing any data
table(is.na(bd)) # no missing data = good!

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 4) Fit Nest Survival Models in RMark -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# first, process the data for RMark
# input the model that we want in the 'model =' argument of the process.data function

# here are the list of models in RMark
setup.model(model = "") # 91 models

# As you can see, RMark includes lots of models that can be input into the model= argument below
# Here we use the "Nest" model because we are interested in a nest survival analysis

# Visit this link for a full list of MARK models supported in RMark:
# https://github.com/jlaake/RMark/blob/master/RMark/inst/MarkModels.pdf


# now, process data in RMark format
mallard.pr <- process.data(bd,
                           nocc=90, # this was the number of days of the study
                           model="Nest")
#head(mallard.pr$data)


# create design data
mallard.ddl = make.design.data(mallard.pr)

# look at design data
names(mallard.ddl)

# nest survival model has only one parameter: Survival probability
mallard.ddl$S

# Now let's fit a model
# I usually do this in 2 steps
# First, specify the formula for each model parameter and save as an object
# Then insert these objects for each parameter in the model fitting function 'mark'

# define a couple model for survival
mallard.ddl$S # survival probability
head(mallard.pr$data)
# let's model survival as a function of the proportion grass in vicinity of nest
S.PpnGr = list(formula =  ~  PpnGrass)

# we can also use a NestAge covariate because we had AgeDay1 column in the data
# this is a strange but useful 'trick' in nest survival models in RMark

# So, daily nest survival varies with nest age & amount of native vegetation in
#  surrounding area
S.AgePpnGrass = list(formula = ~ NestAge + PpnGrass)

# Now fit the model

# you will need (want) an output folder for the mark files, just so your
# directory does not get cluttered
# Create a new folder called 'models' in your working directory
# set working directory to that folder
setwd()

# fit model
grass <- mark(mallard.pr, # processed data
              mallard.ddl,  # design data
              model.parameters=list(S = S.PpnGr), # survival probability
              delete = TRUE)  

agegrass <- mark(mallard.pr, # processed data
              mallard.ddl,  # design data
              model.parameters=list(S = S.AgePpnGrass), # survival probability
              delete = TRUE)


# check out model outputs

# beta coefficients
grass$results$beta
agegrass$results$beta

# real estimates
grass$results$real # remember that this is daily survival because our data was organized in days
agegrass$results$real # remember that this is daily survival because our data was organized in days

# derived parameters
grass$results$derived # overall probability of nest success (I think...)...on average over the entire study
agegrass$results$derived # overall probability of nest success (I think...)...on average over the entire study period


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 5) Prediction and plotting -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# Here is some code from the example in RMark documentation, just in case you like it better than
# our way of doing things:

# To obtain estimates of DSR for various values of 'NestAge' and 'PpnGrass'
# some work additional work is needed.

# Store model results in object with simpler name
AgePpnGrass <- agegrass
# Build design matrix with ages and ppn grass values of interest
# Relevant ages are age 1 to 35 for mallards
# For ppngrass, use a value of 0.5
fc <- find.covariates(AgePpnGrass,mallard)
fc$value[1:35] <- 1:35                      # assign 1:35 to 1st 35 nest ages
fc$value[fc$var == "PpnGrass"] <- 0.9       # assign new value to PpnGrass
design <- fill.covariates(AgePpnGrass, fc)  # fill design matrix with values
# extract 1st 35 rows of output
AgePpn.survival <- compute.real(AgePpnGrass, design = design)[1:35, ]
# insert covariate columns
AgePpn.survival <- cbind(design[1:35, c(2:3)], AgePpn.survival)     
colnames(AgePpn.survival) <- c("Age", "PpnGrass","DSR", "seDSR", "lclDSR",
                               "uclDSR")
# view estimates of DSR for each age and PpnGrass combo
AgePpn.survival

# plot it
ggplot(AgePpn.survival, aes(x = Age, y = DSR)) +
  geom_line() +
  geom_ribbon(aes(ymin = lclDSR, ymax = uclDSR), alpha = 0.3) +
  xlab("Nest Age (days)") +
  ylab("Estimated DSR") +
  theme_bw()

# assign 17 to 1st 50 nest ages
fc$value[1:89] <- 35 # can change this and see how relationship changes                    
# assign range of values to PpnGrass
fc$value[fc$var == "PpnGrass"] <- seq(0.01, 0.99, length = 89)
# fill design matrix with values
design <- fill.covariates(AgePpnGrass,fc)
AgePpn.survival <- compute.real(AgePpnGrass, design = design)
# insert covariate columns
AgePpn.survival <- cbind(design[ , c(2:3)], AgePpn.survival)     
colnames(AgePpn.survival) <-
  c("Age", "PpnGrass", "DSR", "seDSR", "lclDSR", "uclDSR")
# view estimates of DSR for each age and PpnGrass combo   
AgePpn.survival   

# Plot results
ggplot(AgePpn.survival, aes(x = PpnGrass, y = DSR)) +
  geom_line() +
  geom_ribbon(aes(ymin = lclDSR, ymax = uclDSR), alpha = 0.3) +
  #ylim(0.92,0.97)+
  xlab("Proportion Grass on Site") +
  ylab("Estimated DSR") +
  theme_bw()



# what if we did not account for nest age
grass$pims$S

# create sequence of values to predict over
range(bd$PpnGrass)
# new data
newdat <- data.frame(PpnGrass=seq(0.01, 0.99, 
                                  length.out = 89))

# predict to newdata
pred.cov <- covariate.predictions(grass, data=newdat, indices=c(1))$estimates

# Plot results
ggplot(pred.cov, aes(x = covdata, y = estimate)) +
  geom_line() +
  geom_ribbon(aes(ymin = lcl, ymax = ucl), alpha = 0.3) +
  ylim(0.92,0.97)+
  xlab("Proportion Grass on Site") +
  ylab("Daily Survival Probability") +
  theme_bw()



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# END
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


























