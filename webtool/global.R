#-------------------------------------------
# This script sets out to load all things 
# required to build the app
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 29 September 2023
#-------------------------------------------

library(shiny)
library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tibble)
library(stats)
library(plotly)
library(shinyWidgets)
library(shinycssloaders)
library(markdown)
library(broom)
library(Rtsne)
library(MASS)
library(umap)

# Load in any HTML imports

import_files <- list.files("imports", full.names = TRUE, pattern = "\\.html")
for(f in import_files){
  object_name <- gsub("imports/", "", f)
  object_name <- gsub("\\.html", "", object_name)
  assign(object_name, readLines(f, warn = FALSE))
}

# Load in amp data

data_files <- list.files("data", full.names = TRUE, pattern = "\\.Rda")
for(d in data_files){
  load(d)
}

# Load in any R functions

r_files <- list.files("R", full.names = TRUE, pattern = "\\.[Rr]")
for(f in r_files){
  source(f)
}

# Define tab names

navtab0 <- "LOW DIMENSIONAL PROJECTION"
navtab1 <- "DATA MATRIX"
navtab2 <- "PAIRWISE CORRELATIONS"
navtab3 <- "ABOUT"

# Turn off scientific notation

options(scipen = 999)

# Define "not in" operator

"%ni%" <- Negate("%in%")

# Helper vectors

rescalers <- c("zScore", "Sigmoid", "RobustSigmoid", "MinMax", "MaxAbs")
dim_reds <- c("PCA", "tSNE", "ClassicalMDS", "KruskalMDS", "SammonMDS", "UMAP")
boolean <- c(FALSE, TRUE)
clusters <- c("average", "ward.D", "ward.D2", "single", "complete", "mcquitty", "median", "centroid")
cors <- c("pearson", "spearman")
