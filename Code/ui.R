# ui.R
library(ggmap)
library(readr)
library(ggplot2)
library(shiny)
library(dplyr)
library(plotly)
library(rlang)

Sys.setenv('MAPBOX_TOKEN' = 'pk.eyJ1IjoicGl0a2F1ZmYiLCJhIjoiY2pnNG10OWkxMG5jZjJ3cWQ2N2JlbnVhayJ9.ZS4VPpOc5iBycmkEkAVf-w')
setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/Data")
data <- read_csv("Toronto_revs_area.csv")
colnames(data)[10] <- "sentiment"
colnames(data)[19] <- "rating"
data <- data %>% group_by(id) %>% mutate(sent = mean(sentiment))
stuff <- data[!duplicated(data$id),]
setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/Data")
geo <- read.delim("GeoHash.txt", sep = ",")
geo <- prepend(levels(geo$Area), "All")
setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/Data")
categories <- read.delim("Cat_reduced.txt", sep = ",")
categories <- prepend(levels(categories$Category), "All")

shinyUI(fluidPage(
  titlePanel("New York City Felony Visualizer"),
  
  sidebarLayout(
    sidebarPanel(
      h3("This application lets you explote Toronto's reatsurant scene"),
      selectInput("area", label = h4("Select an Area"), 
                  choices =  geo, selected = "Downtown"),
      br(),
      selectInput("cuisine", label = h4("Select a Cuisine"), 
                  choices = categories, selected = "Chinese")
      #br(),
      #radioButtons("month", label = h4("Select a month (Oct., Nov., Dec. not available",icon("thumbs-o-down"),")"), 
      #             choices = c("Jan" = "Jan", "Feb" = "Feb", "Mar" = "Mar", "Apr" = "Apr", "May" = "May",
      #                         "Jun" = "Jun", "Jul" = "Jul", "Aug" = "Aug", "Sep" = "Sep"), selected = "Jan"),
      #br(),
      #h4("Surprise Message"),
      #checkboxInput("checkbox", label = "Check this box for a surprise message", value = FALSE),
      #img(src = "picture.jpg", height = 250, width = 410)
    ),
    # mainPanel(leafletOutput("map", width="100%", height="100%"))
    mainPanel(
      plotlyOutput("TorontoMap", width="100%", height="100%"),
      br(),
      plotOutput("barchart", width="100%", height="100%"),
      br(),
      textOutput("surpriseNote"),
      tags$head(tags$style("#surpriseNote{color: green;
                                 font-size: 25px;
                                 font-style: bold;
                                 }"
      )
      )
    )
  )
))