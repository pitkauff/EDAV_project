#ui.R
library(ggmap)
library(ggplot2)
library(shiny)
library(dplyr)
library(shinydashboard)
  
#setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/EDAV_project-master/Data")
#stuff <- read.csv("Toronto_revs_area.csv", header = TRUE, sep = ",")

ui <- dashboardPage(skin = "yellow",
  dashboardHeader(
    title = tags$img(src = 'ds.png', height = 30, width = 180)
  ),
  dashboardSidebar(
    tags$head(tags$style(HTML('.shiny-server-account { display: none; }'))),
    uiOutput("userpanel"),
    sidebarMenu(
      menuItem("Introduction", tabName = "intro", icon = icon("dashboard")),
      menuItem("Data Description", tabName = "data", icon = icon("table"),
        menuSubItem("Methodolody", tabName = "meth1", icon = icon("chevron-circle-right")),
        menuSubItem("Data", tabName = "data1", icon = icon("chevron-circle-right"))),
      menuItem("Data Quality Analysis", tabName = "quality", icon = icon("map")),
      menuItem("Main Analysis", tabName = "main", icon = icon("map-marker")),
      menuItem("Exective Summary", tabName = "revs", icon = icon("thumbs-up")),
      menuItem("Interactive", tabName = "interactive", icon = icon("mouse-pointer")),
      menuItem("Conclusion", tabName = "conclusion", icon = icon("table"))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "intro",
          box(
          h2("Welcome to the Toronto Restaurant Explorer", style = "font-weight: bold"),
          p(HTML(paste0('For this project, we have focused our attention on the Yelp dataset, found ',
                        a(href = 'https://www.yelp.com/dataset', 'here. '), 
                        "After careful consideration of multiple dataset, we concluded that
                        certain ones, such as Citibike or the Million Songs dataset have been
                        overly analyzed and dissected, thereby limiting the vlaue we could add. We then
                        started searchin for more low-key datasets and eventually came across the Yelp dataset. 
                        Given our own experiences, we felt Yelp reviews were very tangible, widely 
                        used and appreciated, and so we decided to dive deep into the dataset 
                        in the hope of discovering interesting insights and patterns. Given the size 
                        size of the full datset (over 100o cities across the US and Canada), we 
                        decided to focus on a specific city, namely Toronto. Some high-level 
                        questions we attempted to answer were as follows:")), style = "font-size:16px", align = "justify"),
          width = 9,
          tags$ul(tags$li("Where are the best restaurants of a particular cuisine located?"),
                  tags$li("Which areas are most diverse in terms of cuisine?"),
                  tags$li("Does a business with a high number of check-ins have a higher average rating?"),
                  tags$li("How are rating and review sentiment related?"),
                  tags$li("How do elite users affect rating and customer flow?"),
                  tags$li("How do check-ins vary over the course of the week?")), style = "font-size:16px"),
          fluidRow(
          #box(plotOutput("plot1", height = 250)),
          #box(
          #  title = "Controls",
          #  sliderInput("slider", "Number of observations:", 1, 100, 50)
          #)
        )
      ),
      
      # Second tab content
      tabItem(tabName = "meth1",
          box(
          h2("Data Collection / Preprocessing Overview", style = "font-weight: bold"),
          p("Our dataset was directly queried from the Yelp database using SQLite. This ensured that 
            the data came with a pre-defined schema, saving us a lot of data cleaning time. A high-
            level outline of the schema is depcited below: ", align = "justify"),
          img(src = 'yelp_dataset_schema.png', width = 600, height = 300, align = "center"),
          width = 9)
      )
    )
  )
)
