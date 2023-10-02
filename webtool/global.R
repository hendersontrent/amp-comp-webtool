#-------------------------------------------
# This script sets out to load all things 
# required to build the app
#-------------------------------------------

#-------------------------------------------
# Author: Trent Henderson, 29 September 2023
#-------------------------------------------

library(shiny)
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
library(reshape2)

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

navtab0 <- "PAIRWISE CORRELATIONS"
navtab1 <- "LOW DIMENSIONAL PROJECTION"
navtab2 <- "DATA MATRIX"
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

amplifiers <- c('Neural DSP Abasi 1', 'Neural DSP Abasi 2', 'Neural DSP Abasi 3', 
                'Neural DSP Cory Wong 1', 'Neural DSP Cory Wong 2', 'Neural DSP Cory Wong 3', 
                'Neural DSP Fortin Nameless', 'Neural DSP Fortin Cali Clean', 
                'Neural DSP Fortin Cali Overdrive 1', 'Neural DSP Fortin Cali Overdrive 2', 
                'Neural DSP Fortin NTS Clean', 'Neural DSP Fortin NTS Overdrive', 
                'Neural DSP Gojira 1', 'Neural DSP Gojira 2', 'Neural DSP Gojira 3', 
                'Neural DSP Omega Granophyre_6L6', 'Neural DSP Omega Granophyre_EL34', 'Neural DSP Omega Granophyre_KT66', 
                'Neural DSP Nolly 1', 'Neural DSP Nolly 2', 'Neural DSP Nolly 3', 'Neural DSP Nolly 4', 
                'Neural DSP Petrucci 1', 'Neural DSP Petrucci 2', 'Neural DSP Petrucci 3', 'Neural DSP Petrucci 4', 
                'Neural DSP Plini 1', 'Neural DSP Plini 2', 'Neural DSP Plini 3', 
                'Neural DSP Rabea 1', 'Neural DSP Rabea 2_6L6', 'Neural DSP Rabea 2_EL34', 'Neural DSP Rabea 3_6L6', 'Neural DSP Rabea 3_EL34', 
                'Neural DSP Soldano Normal', 'Neural DSP Soldano Overdrive', 
                'Neural DSP Tim Henson 1', 'Neural DSP Tim Henson 2', 'Neural DSP Tim Henson 3', 
                'Neural DSP Tone King Lead', 'Neural DSP Tone King Rhythm', 
                'STL Tonality Will Putney 1_6L6', 'STL Tonality Will Putney 1_EL34', 'STL Tonality Will Putney 1_KT88', 
                'STL Tonality Will Putney 2_6L6', 'STL Tonality Will Putney 2_EL34', 'STL Tonality Will Putney 2_KT88', 
                'STL Tonality Will Putney 3_6L6', 'STL Tonality Will Putney 3_EL34', 'STL Tonality Will Putney 3_KT88', 
                'STL Tonality Will Putney 4_6L6', 'STL Tonality Will Putney 4_EL34', 'STL Tonality Will Putney 4_KT77', 'STL Tonality Will Putney 4_KT88', 
                'STL Tonality Andy James 1_6L6', 'STL Tonality Andy James 1_EL34', 'STL Tonality Andy James 1_KT88', 
                'STL Tonality Andy James 2_6L6', 'STL Tonality Andy James 2_EL34', 'STL Tonality Andy James 2_KT88', 
                'STL Tonality Andy James 3_Hi', 'STL Tonality Andy James 3_Lo', 
                'STL Tonality Howard Benson 1', 'STL Tonality Howard Benson 2_Clean', 'STL Tonality Howard Benson 2_Lead', 'STL Tonality Howard Benson 3', 
                'STL Tonality Howard Benson 4', 'STL Tonality Howard Benson 5', 
                'STL Tonality Lasse Lammert 1', 'STL Tonality Lasse Lammert 2', 'STL Tonality Lasse Lammert 3')

# Custom colour palette (https://coolors.co/d87cac-e5e6e4-084c61-c03221-773344)

custom_palette <- c("#D87CAC", # Thulian pink
                    "#E5E6E4", # Platinum
                    "#084C61", # Midnight green
                    "#C03221", # Engineering orange
                    "#773344") # Wine
