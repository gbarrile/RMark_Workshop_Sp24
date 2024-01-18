# RMark Workshop (Spring 2024)

Welcome to the RMark workshop! We will introduce key software packages and fundamental models used in fish and wildlife population analysis. Course content includes the parameterization of models used to estimate ecological state variables (occupancy, abundance) and population vital rates (survival, recruitment, dispersal) of both marked and unmarked populations, accounting for imperfect capture/detection probability. The course will cover closed population models, Cormack-Jolly-Seber models, multistate models, reverse-time Pradel models, and Robust Design models with capture-mark-recapture data, closed and open N-mixture models with repeated count data, and site-occupancy models with detection/nondetection data. Models will be fit using the ‘RMark’ and ‘unmarked’ packages in Program R. Each class will begin with an introduction to the subject material through a brief lecture followed by the application of the concepts through exercises in R (e.g., formatting data, fitting and selecting models, visualizing predicted relationships) using simulated or real datasets. Students will be encouraged to use their own data when possible.

I will post a video lesson each week to introduce the topic that we will cover in the following week. Please watch each weekly video prior to the start of class in the following week. Search for videos under **'Video Lessons'** below. Videos will appear under the date on which they were posted. Finally, please read the **'Additional Instructions'** below on downloading/installing the software and packages required to execute the R scripts that accompany each lesson. 

## Instructor
[Gabriel Barrile](https://gabrielbarrile.weebly.com/)
(Please email **gbarrile@uwyo.edu** with any questions, comments, or requests.)

---
  
## Video Lessons

### Accessing Course Materials
[Downloading Individual Folders from GitHub](https://youtu.be/nD1DptRuBeE)

---

## Please complete before coming to the workshop

Download and install the following programs for your platform:

[R](https://cran.r-project.org/) and [RStudio Desktop](http://www.rstudio.com/ide/download/)

[Program MARK](http://www.phidot.org/software/mark/downloads/)

### Installing packages
Once you have R and RStudio set up on your device, install the following packages via pasting these commands into your prompt (i.e., copy and paste the code into the "Console" of RStudio and hit enter):

```coffee
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("RMark") # you first will need Program MARK installed on your computer
```

### Downloading code/data from this repository 
Simply click the **Code** dropdown button at the top-right of this page (scroll up to see it). Then hit **Download ZIP** in the dropdown menu. If you're not sure where to save it, just download and unzip to your Desktop.

---

## Acknowledgments

This workshop at the University of Wyoming was made possible by the Wyoming Bird Initiative for Resilience and Diversity (WYOBIRD). A special thank you Dr. Corey Tarwater for assisting with logistics, support, and conceptualization.


---

# License  
<a rel="license" href="http://creativecommons.org/licenses/by/2.0/">Creative Commons Attribution 2.0 Generic License</a>.

