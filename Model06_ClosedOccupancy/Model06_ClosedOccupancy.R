



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# RMark Workshop
# University of Wyoming
# Spring 2024

# Model 6 - Closed Occupancy model
# (aka Static Occupancy Model)
# (aka Single-Season Occupancy Model)
# (aka Site-Occupancy Model)

# Description: Steps thru an example analysis with detection/nondetection data
# using the occupancy model of MacKenzie et al. 2002 as 
# implemented in the package `RMark`.

# MacKenzie, D. I., J. D. Nichols, G. B. Lachman, S. Droege, J. Andrew Royle,
# and C. A. Langtimm. 2002. Estimating Site Occupancy Rates When Detection 
# Probabilities Are Less Than One. Ecology 83: 2248-2255.

# Addressing the question: 
# "How do forest cover and prey abundance influence the occurrence 
#  of brown tree snakes on pacific islands?

# Gabe Barrile - University of Wyoming
# Last updated 02/23/2024
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- Outline -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# This script contains the following sections:
# 1) Install and load packages
# 2) Read-in field data
# 3) Format data for RMark
# 4) Fit Closed (Static) Occupancy models
# 5) Prediction and plotting
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 1) Install and load packages -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Check if RMark and tidyverse are installed.
# If yes, load them.  If not, install, then load.

# RMark for fitting the Closed (Static) Occupancy Model
if("RMark" %in% rownames(installed.packages()) == FALSE) {
  install.packages("RMark")
}
require(RMark)

# tidyverse to format data
if("tidyverse" %in% rownames(installed.packages()) == FALSE) {
  install.packages("tidyverse")
}
require(tidyverse)

# if you needed to cite the RMark package
citation("RMark")
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 2) Read-in field data -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# you will need to set working directory to where you saved the 'BrownTreeSnake_IslandSurveys.csv'
setwd()

# read-in the brown tree snake data 
df <- read.csv("BrownTreeSnake_IslandSurveys.csv")

# We now have our data stored as 'df'
# check out our data
head(df)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# QUESTION: how many islands did we survey?
n_distinct(df$Island)

# QUESTION: how many surveys per island?
df %>% 
  group_by(Island) %>% 
  summarise(n=n()) %>% 
  rename(Number.of.Surveys=n) %>% 
  data.frame()
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 3) Format data for RMark -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# order the data frame by island, then survey
df <- df %>% arrange(Island, Survey)
df

# create matrix of detections/nondetections, with each site (island) as a row
# in other words, create detection histories for each island

# reduce dataframe to columns that we need
m <- df %>% select(Island, Survey, BTS)
# make Island a factor variable
m$Island <- as.factor(as.character(m$Island))
# order the data frame by Survey
m <- m %>% arrange(Survey)
# pivot data from long format to wide format
y <- m %>% pivot_wider(id_cols = Island, names_from = Survey, values_from = BTS, values_fill = 0)
y

# create detection history as character string
y <- y %>% unite("ch", c(2:ncol(.)), remove = FALSE, sep = "")
head(y)

# reduce dataframe to columns that we need
y <- y %>% select(Island, ch) %>% data.frame()
head(y)

# check if all detection histories are length = 6 (for each of our six visits to each island)
table(nchar(y$ch))

y # each island is a row (28 rows)
# each column indicates the survey at each island (six surveys at each island)

# Quick aside, and let's take island 2 as an example. Because we detected brown tree snakes
# at island 2 (during surveys 2, 3, 4, and 6), we assume that brown tree snakes were
# present on island 2 during all the other surveys -- it's just that we did not detect them
# (i.e., brown tree snakes were on island 2 during surveys 1 and 5, we just
# did not detect them during those surveys)

# Also note that detection/nondetection data at each island is sort of 
# analogous to our capture histories when we format our mark-recapture data.
# However, rather than individuals, here we deal with sites


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# QUESTION: Do our detection histories match our field data?
# let's look at islands 1 and 2
head(df, 12)
# Does the detection history match?
y[1:2,]
# Looks good
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

head(df)

# Next, format covariates for occupancy and detection probability
# hypothesized that forest cover and prey abundance influence occupancy
# hypothesized that temperature influences detection probability

# Refresher:
# Site covariates versus Observation covariates

# Site covariates do not change during each survey at a given site
# i.e., one value for a site covariate at each island
# e.g., twelve values for forest cover, one value for each island 

# Observation covariates can change during each survey at a given site
# Observation covariate data should match survey data 
# (i.e., matrix of detection/nondetection data)
# We can have a different detection probability for each survey
# e.g., different temperature for each survey.

# Format forest cover as a covariate on occupancy (as a 'site' covariate)
forest <- unique(df[,c("Island","ForestCover")])
forest <- as.matrix(forest[,"ForestCover"])
forest

# or just add it to y data frame
y$forest <- df$ForestCover[match(y$Island, df$Island)]

# Format prey abundance as a covariate on occupancy (as a 'site' covariate)
prey <- unique(df[,c("Island","Prey")])
prey <- as.matrix(prey[,"Prey"])
prey

# or just add it to y data frame
y$prey <- df$Prey[match(y$Island, df$Island)]

# Format region as a site-level covariate
df$Region <- as.factor(as.character(df$Region))
region <- unique(df[,c("Island","Region")])
region <- as.matrix(region[,"Region"])
region

# or just add it to y data frame
y$region <- df$Region[match(y$Island, df$Island)]


# bts will be our dataframe that we input into RMark
head(y)
bts <- data.frame(ch = y$ch, 
                  freq = 1, 
                  island = y$Island, 
                  forest = y$forest,
                  prey = y$prey,
                  region = y$region)

# remove unneeded objects
rm(y,m,forest,region,prey)

# so we have df and bts dataframes
head(df)
head(bts)

# make island a factor variable
bts$island <- as.factor(as.character(bts$island))

# make region a factor variable
bts$region <- as.factor(as.character(bts$region))

# are we missing any data?
table(is.na(bts)) # no missing data = good!



# Format temperature as a covariate on detection (as an 'observation' covariate)

# reduce dataframe to columns that we need
m <- df %>% select(Island, Survey, Temperature)
# make Island a factor variable
m$Island <- as.factor(as.character(m$Island))
# order the data frame by Survey
m <- m %>% arrange(Survey)
# pivot data from long format to wide format
y <- m %>% pivot_wider(id_cols = Island, names_from = Survey, values_from = Temperature, values_fill = NA)
# check out resulting dataframe
y

# match temperature data with bts data
head(bts)
bts$temp1 <- y$'1'[match(bts$island, y$Island)]
bts$temp2 <- y$'2'[match(bts$island, y$Island)]
bts$temp3 <- y$'3'[match(bts$island, y$Island)]
bts$temp4 <- y$'4'[match(bts$island, y$Island)]
bts$temp5 <- y$'5'[match(bts$island, y$Island)]
bts$temp6 <- y$'6'[match(bts$island, y$Island)]

# Note: RMark column names cannot be longer than ten characters!!

rm(m,y)

# look at bts data
head(bts)

# are we missing any data?
table(is.na(bts)) # no missing data = good!

# here is our data frame to put into RMark
bts


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 4) Fit Closed (Static) Occupancy models in RMark -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# first, process the data for RMark
# input the model that we want in the 'model =' argument of the process.data function

# here are the list of models in RMark
setup.model(model = "") # 91 models

# As you can see, RMark includes lots of models that can be input into the model= argument below
# Here we use the "Occupancy" model because we are interested in 
# a basic single-season occupancy model (i.e., with occupancy probability and detection probability)
# Visit this link for a full list of MARK models supported in RMark:
# https://github.com/jlaake/RMark/blob/master/RMark/inst/MarkModels.pdf


# now, process data in RMark format
t.proc = process.data(bts, model = "Occupancy", 
                      groups = "island", 
                      begin.time = 1)

# create design data
t.ddl = make.design.data(t.proc)

# look at design data
names(t.ddl)

t.ddl$Psi # probability of occupancy

t.ddl$p # detection probability


# Now let's fit a model
# Let's not worry about model selection here...
# Rather, let's just fit a model to test our a priori hypotheses regarding covariate relationships

# define p model
t.ddl$p # detection probability
head(t.proc)
# let's model detection probability as a function of temperature
p.temp = list(formula =  ~  temp)

# define Psi
t.ddl$Psi # occupancy probability
head(t.proc)
# let's model occupancy probability as the interactive function of forest cover and prey availability
Psi.int = list(formula =  ~  forest * prey)
Psi.int = list(formula =  ~  island)

# Now fit the model

# you will need (want) an output folder for the mark files, just so your
# directory does not get cluttered
# Create a new folder called 'models' in your working directory
# set working directory to that folder
setwd()

# fit model
occ <- mark(t.proc, # processed data
            t.ddl,  # design data
            model.parameters=list(Psi = Psi.int,   # occupancy
                                  p =   p.temp),   # detection
            delete = TRUE)     


# check out model output

# beta coefficients
occ$results$beta

# real estimates
occ$results$real

# derived parameters
occ$results$derived





#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# ---- 5) Prediction and plotting -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

# create plots

# just an fyi from covariate.predictions help file:
# "if data is not specified or all individual covariate values are not specified, 
# the mean individual covariate value is used for prediction."

# so we do not need to manually hold each predictor at mean values (those not being predicted),
# because covariate.predictions does that automatically. 


# let's plot the relationship between temperature and detection

# need to specify the indices correctly (very important!)
occ$pims$p # let's use indices = 1
t.ddl$p

# create sequence of values to predict over
head(bts)
range(bts[,7:12])
# notice that we specify temp1
newdat <- data.frame(temp6=seq(21, 40, length.out = 80))

# predict to newdata
pred.cov <- covariate.predictions(occ, data=newdat, indices=c(6))$estimates

# okay, plot it
head(pred.cov)
min(pred.cov$lcl)
max(pred.cov$ucl)
op <- par(mar = c(5,5,4,2) + 0.1) # default is 5,4,4,2
plot(x = pred.cov$covdata, y = pred.cov$estimate, pch=16, 
     ylab = "Detection Probability",
     xlab = "Air Temperature (°C)", cex.lab=1.5, cex.axis=1.2, 
     col="darkgray", ylim=c(0,1))
box(lwd = 4, col = 'black')
lines(pred.cov$covdata, pred.cov$estimate, lwd=8, col="blue")
lines(pred.cov$covdata, pred.cov$lcl, lwd=4, lty=2, col="black")
lines(pred.cov$covdata, pred.cov$ucl, lwd=4, lty=2, col="black")


# plot the interactive effect of forest cover and prey abundance on occupancy

# create sequence of covariate values for forest cover
range(bts$forest)
# create sequence of values to plot over
x2 <- seq(5,95,length.out=100)

# create sequence of covariate values for prey abundance
range(bts$prey)
# create sequence of values to plot over
y2 <- seq(10,94,length.out=100)

occ$pims$Psi # can use 7

# predict 
pred.matrix1 <- array(NA, dim = c(100, 100)) # Define arrays
for(i in 1:100){
  for(j in 1:100){
    newData1 <- data.frame(forest=x2[i], prey=y2[j])       
    pred <- covariate.predictions(occ, data=newData1, indices=7)$estimates
    pred.matrix1[i, j] <- pred$estimate
  }
}

# plot the values
par(mfrow = c(1,1), cex.lab = 1.2)
mapPalette <- colorRampPalette(c("grey", "yellow", "orange", "red"))
image(x=x2, y=y2, z=pred.matrix1, col = mapPalette(100), 
      xlab = "Forest Cover (%)", ylab = "Prey Abundance")
contour(x=x2, y=y2, z=pred.matrix1, add = TRUE, lwd = 1, 
        col = "blue", labcex = 1, method = "edge")
box()
title(main = "Expected occupancy probability", font.main = 1)
points(bts$forest, bts$prey, pch="+", cex=1)

# One interpretation of this plot: we would expect brown tree snakes to occur on islands
# with high forest cover, but only if that island also had high prey abundance



# plot with ggplot
xy <- expand.grid(forest=x2, prey=y2)

predictis=covariate.predictions(occ, data=xy, indices=7)$estimates
head(predictis)

# use color-blind friendly fill for plot
library(viridis)

ggplot(predictis, aes(forest, prey, fill= estimate)) + 
  geom_tile() +
  scale_fill_viridis(discrete=FALSE) +
  guides(fill = guide_colourbar(title = "Occupancy"))


# One interpretation of this plot: we would expect brown tree snakes to occur on islands
# with high forest cover, but only if that island also had high prey abundance


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# END
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#



