# server.R
library(ggmap)
library(ggplot2)
library(shiny)
library(dplyr)

setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/EDAV_project-master/Data")
stuff <- read.csv("Toronto_revs_area.csv", header = TRUE, sep = ",")

server <- function(input, output, session) {
  output$userpanel <- renderUI({
    if (!is.null(session$user)) {
      sidebarUserPanel(
        span("Logged in as ", session$user),
        subtitle = a(icon("sign-out"), "Logout", href="__logout__"))
    }
  })
}