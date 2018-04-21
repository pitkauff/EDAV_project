# server.R
library(ggmap)
library(ggplot2)
library(readr)
library(shiny)
library(dplyr)
library(plotly)
library(rlang)

Sys.setenv('MAPBOX_TOKEN' = 'pk.eyJ1IjoicGl0a2F1ZmYiLCJhIjoiY2pnNG10OWkxMG5jZjJ3cWQ2N2JlbnVhayJ9.ZS4VPpOc5iBycmkEkAVf-w')
setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/Data")
data <- read_csv("Toronto_revs_area.csv")
colnames(data)[10] <- "sentiment"
colnames(data)[19] <- "rating"
data <- data %>% dplyr::group_by(id) %>% mutate(sent = mean(sentiment)) %>% mutate(rat = mean(rating))
stuff <- data[!duplicated(data$id),]
setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/Data")
geo <- read.delim("GeoHash.txt", sep = ",")
geo <- prepend(levels(geo$Area), "All")
setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/Data")
categories <- read.delim("Cat_reduced.txt", sep = ",")
categories <- prepend(levels(categories$Category), "All")

function(input, output) {
  
  output$TorontoMap <- renderPlotly({
    
    if (input$area == "All" & input$cuisine == "All") {
      subset <- reactive({stuff
      })
    } else if (input$area == "All") {
      subset <- reactive({dplyr::filter(stuff, category == input$cuisine)})
    } else if (input$cuisine == "All") {
      subset <- reactive({dplyr::filter(stuff, geohash == input$area)
      })
    } else {
      subset <- reactive({dplyr::filter(stuff, geohash == input$area &
                                        category == input$cuisine)
      })
    }
    
    tmp <- subset()
    lon_range <- extendrange(tmp$longitude)
    lat_range <- extendrange(tmp$latitude)
    zo <- calc_zoom(lon_range, lat_range)
    p <- plot_mapbox(subset(), x = ~longitude, y = ~latitude, mode = "markers", type = "scatter") %>%
      add_markers(
        color = ~sent, size = I(8), alpha = 0.7, hoveron = "text",
        text = ~paste(paste("Name: ",name),
                      paste("Sentiment: ", round(as.numeric(sent),2)), 
                      paste("Rating: ", rating), sep = "<br />")) %>%
      colorbar(title = "Average Review Sentiment") %>%
      layout(mapbox = list(zoom = zo - 2,
                           center = list(lat = ~median(latitude),
                                         lon = ~median(longitude))
      ))
    

  })# height = 600, width = 800)
 
  output$barchart <- renderPlot({
    
    }) #height = 300, width = 825)
  
  output$surpriseNote <- renderText({
  
  })
}
