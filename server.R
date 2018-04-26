# server.R
library(dplyr)
library(ggplot2)
library(ggmap)
library(readr)
library(zoo)
library(wordcloud)
library(GGally)
library(plotly)
library(shinyjs)
library(geosphere)
library(stringr)
library(rlang)
library(shiny)
library(shinydashboard)
library(rsconnect)
#library(parcoords)

Sys.setenv('MAPBOX_TOKEN' = 'pk.eyJ1IjoicGl0a2F1ZmYiLCJhIjoiY2pnNG10OWkxMG5jZjJ3cWQ2N2JlbnVhayJ9.ZS4VPpOc5iBycmkEkAVf-w')
#setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/shiny/Data")
data <- read_csv("data/Toronto_revs_area.csv")#read_csv("Toronto_revs_area.csv")
colnames(data)[c(10, 19)] <- c("sentiment", "rating")
data_1 <- data %>% dplyr::group_by(id) %>% mutate(sent = mean(sentiment)) %>% mutate(rat = mean(rating))
df <- data_1[!duplicated(data_1$id),]

#setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/shiny/Data")
categories2 <- read.delim("data/Cat_reduced.txt", sep = ",")#read.delim("Cat_reduced.txt", sep = ",")
categories1 <- prepend(levels(categories2$Category), "All")

#setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/shiny/Data")
check_in <- read_csv("data/restaurants checkins Toronto.csv") #read_csv("restaurants checkins Toronto.csv")
check_in_1 <- check_in %>% group_by(check_in$business_id) %>% summarise(avg = mean(count))
colnames(check_in_1)[1] <- "id"
data_check_ins <- plyr::join(data, check_in_1, by = "id")
data_check_ins <- subset(data_check_ins, !is.na(data_check_ins$avg))
ma_rating <- as.data.frame(rollmeanr(data_check_ins[,3],7,fill = NA)) 
names(ma_rating) <- c("ma_stars")
data_check_ins <- cbind(data_check_ins, ma_rating)
data_check_ins$ma_stars[is.na(data_check_ins$ma_stars)] <- mean(data_check_ins$ma_stars, na.rm = TRUE)
data_check_ins$sentiment <- as.numeric(data_check_ins$sentiment)
df1 <- data_check_ins %>% group_by(id, category, geohash) %>% 
  summarise(avg_checkin = mean(avg), avg_sentiment = mean(sentiment), rolling_avg_rating = mean(ma_stars))
colnames(df1)[c(1,2,3,4,5,6)] <- c("id", "category", "geohash", "Average Check-ins", "Average Sentiment", "Average Star Rating")

#setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/shiny/Data")
restaurants <- read_csv("data/restaurants in Toronto.csv")#read_csv("restaurants in Toronto.csv")
#setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/shiny/Data")
toronto = read_csv("data/reviews_in_Toronto.csv")#read_csv("reviews_in_Toronto.csv")
toronto <- toronto[-1]
colnames(toronto)[1] <- "id"
restaurants <- restaurants[restaurants$category %in% categories2$Category,]
revs_cat <- plyr::join(toronto, restaurants, by = "id")
revs_cat <- subset(revs_cat, !is.na(revs_cat$category))
revs_cat$stars <- as.numeric(revs_cat$stars)
revs_cat <- revs_cat[order(as.Date(revs_cat$date, format="%Y-%m-%d")),]
revs_cat$ma_rating <- rollmeanr(revs_cat[,3],7,fill = NA)
revs_cat$ma_rating[is.na(revs_cat$ma_rating)] <- mean(revs_cat$ma_rating, na.rm = TRUE)
rating_by_cuisine <- revs_cat %>% group_by(revs_cat$category) %>% summarise(avg_rating = mean(ma_rating, na.rm = TRUE)) %>% arrange(desc(avg_rating))
top_5 <- head(rating_by_cuisine, 5)[1]
top_5$indicator <- "Top_10"
bottom_5 <- tail(rating_by_cuisine, 5)[1]
bottom_5$indicator <- "Bottom_10"
df2 <- rbind(bottom_5, top_5)
colnames(df2)[1] <- "category"

df3 <- restaurants[!duplicated(restaurants$id),]
df4 <- check_in
a <- str_split_fixed(df4$date, "-", 2)
df4 <- cbind(df4, a[,1])
colnames(df4)[8] <- "day"

server <- function(input, output, session) {
  output$TorontoMap <- renderPlotly({
    
    if (input$area == "All" & input$cuisine1 == "All") {
      subset <- reactive({df
      })
    } else if (input$area == "All") {
      subset <- reactive({dplyr::filter(df, category == input$cuisine1)})
    } else if (input$cuisine1 == "All") {
      subset <- reactive({dplyr::filter(df, geohash == input$area)
      })
    } else {
      subset <- reactive({dplyr::filter(df, geohash == input$area &
                                          category == input$cuisine1)
      })
    }
    
    tmp <- subset()
    
    validate(
      need(nrow(tmp) != 0, paste("Oops, it looks like there are no", input$cuisine1, "restaurants in the", input$area, "area. Please select a different Cuisine / Area combination"))
    )
    
    lon_range <- extendrange(tmp$longitude)
    lat_range <- extendrange(tmp$latitude)
    zo <- calc_zoom(lon_range, lat_range)
    p <- plot_mapbox(subset(), x = ~longitude, y = ~latitude, mode = "markers", type = "scatter") %>%
      add_markers(
        color = ~sent, size = I(8), alpha = 0.7, hoveron = "text",
        text = ~paste(paste("Name: ", name),
                      paste("Cuisine: ", category),
                      paste("Sentiment: ", round(as.numeric(sent),2)), 
                      paste("Rating: ", rating), sep = "<br />")) %>%
      colorbar(title = "Average Review Sentiment") %>%
      layout(mapbox = list(zoom = zo - 2,
                           center = list(lat = ~median(latitude),
                                         lon = ~median(longitude))
      ))
  })
  
  output$TorontoFind <- renderPlotly({
    
    if (input$do) {
      coords = geocode(as.character(input$address))
      
      df3$distFromCurr <- sapply(1:nrow(df3), function(rownumber) {distGeo(coords,  
                               c(df3$longitude[rownumber], 
                                  df3$latitude[rownumber]))})
      
      closeRests <- head(arrange(df3, distFromCurr), n = 20)
      
      validate(
        need(nrow(closeRests) != 0, paste("Oops, it looks like there are no", input$cuisine1, "restaurants in your neighborhood. Please select a different Cuisine / Area combination"))
      )
      
      lon_range <- extendrange(closeRests$longitude)
      lat_range <- extendrange(closeRests$latitude)
      zo <- calc_zoom(lon_range, lat_range)
      
      plot_mapbox(closeRests, x = ~longitude, y = ~latitude, mode = "markers", type = "scatter") %>%
        add_markers(
          color = ~stars, size = I(8), alpha = 0.7, hoveron = "text",
          text = ~paste(paste("Name: ", name),
                        paste("Cuisine: ", category), sep = "<br />")) %>%
        colorbar(title = "Average Rating <br /> &nbsp;") %>%
        layout(mapbox = list(zoom = zo - 4,
                             center = list(lat = ~median(latitude),
                                           lon = ~median(longitude))
        ))
    } else {
      map_data("world", "canada") %>% plot_mapbox(x = -79.3841, y = 43.6534) %>%
        layout(mapbox = list(zoom = 10,
                             center = list(lat = 43.6534,
                                           lon = -79.3841)
        ))
    }
  })

  output$plotClickOutput <- renderPlot({
    coords = geocode(as.character(input$address))
    
    df3$distFromCurr <- sapply(1:nrow(df3), function(rownumber) {distGeo(coords,  
                                                                        c(df3$longitude[rownumber], 
                                                                           df3$latitude[rownumber]))})
    
    closeRests <- head(arrange(df3, distFromCurr), n = 20)
    d <- event_data("plotly_click")
    if (is.null(d)) "Please select a restaurant" else {
      a <- closeRests[as.numeric(d$pointNumber) + 1,]
      rest_name <- as.character(a$name)
      #rest_long <- as.numeric(a$longitude)
      
      subset_1 <- dplyr::filter(df4, name == rest_name)
      
      validate(
        need(nrow(subset_1) != 0, paste("Oops, it looks like there is no check-in data for", rest_name, ". Please select a different restaurant."))
      )
      
      subset_1 <- subset_1 %>% group_by(day) %>% summarise(cnt = n())
      #subset_1 <- closeRests[rownum,]
      
      subset_1 <- subset_1 %>% mutate(weekday = forcats::fct_relevel(day, "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
      
      ggplot(subset_1, aes(weekday, cnt)) + 
        geom_col(color = "darkblue", fill = "darkblue") + 
        ggtitle(paste(rest_name,": Check-ins by Day of Week")) +
        ylab("")
    }
  })
  
  output$pcp <- renderPlotly({
    
    if (input$area == "All" & input$cuisine1 == "All") {
      subset_2 <- reactive({df1
      })
    } else if (input$area == "All") {
      subset_2 <- reactive({dplyr::filter(df1, category == input$cuisine1)})
    } else if (input$cuisine1 == "All") {
      subset_2 <- reactive({dplyr::filter(df1, geohash == input$area)
      })
    } else {
      subset_2 <- reactive({dplyr::filter(df1, geohash == input$area &
                                            category == input$cuisine1)
      })
    }
    
    validate(
      need(nrow(subset_2()) != 0, paste("Oops, it looks like there is no check-in data for", input$cuisine1, "restaurants in the", input$area, "area available. Please select a different Cuisine / Area combination"))
    )
    
    #paralell_data = subset_2()[4:6]
    #parcoords(parallel_data, 
    #          rownames = F, 
    #          brushMode = "1d-axes", 
    #          reorderable = T, 
    #          color = list(
    #            colorBy = "Average Star Rating", 
    #            colorScale = htmlwidgets::JS("d3.scale.category10()")))
    
    ggparcoord(subset_2(), columns = 4:6, alphaLines = .1, scale = "uniminmax") + xlab("") + 
      ylab("Standardized Value") + theme(axis.title.y = element_text(size = 8)) 
    
  })
  
  output$boxplot <- renderPlotly({
    df2 <- rbind(df2, list(input$cuisine2, "Selected Cuisine"))
    subset_3 <- dplyr::filter(revs_cat, revs_cat$category %in% df2$category | 
                                          revs_cat$category %in% input$cuisine2)
    subset_3 <- plyr::join(subset_3, df2, by = "category")
    
    validate(
      need(nrow(subset_3) != 0, paste("Oops, it looks like there is no data for", input$cuisine, ". Please select a different Cuisine / Area combination"))
    )
    
    ggplot(subset_3) + geom_boxplot(aes(reorder(category, ma_rating, FUN = median), ma_rating, fill = indicator)) + 
      coord_flip() + labs(y = "Average Rating", x = "Cuisine Type") + 
      scale_fill_manual(values = c("darkred", "white", "darkgreen"))
  })
  
  tab_id <- c("intro", "meth1", "data1", "data2", "data3", "data4", "data5", "qual1", 
              "qual2", "main1", "main2", "main3", "main4", "main5", "main6", "main7", 
              "main8", "main9", "main10", "main11", "main12", "main13", "revs1", "revs2",
              "revs3","revs4", "revs5", "geo_1", "geo_2", "finder", "conclusion")
  
  observe({
    lapply(c("Next", "Previous"),
           toggle,
           condition = input[["sections"]] != "intro")
  })
  
  Current <- reactiveValues(
    Tab = "intro"
  )
  
  observeEvent(
    input[["sections"]],
    {
      Current$Tab <- input[["sections"]]
    }
  )
  
  observeEvent(
    input[["Previous"]],
    {
      tab_id_position <- match(Current$Tab, tab_id) - 1
      if (tab_id_position == 0) tab_id_position <- length(tab_id)
      Current$Tab <- tab_id[tab_id_position]
      updateTabItems(session, "sections", tab_id[tab_id_position]) 
    }
  )
  
  observeEvent(
    input[["Next"]],
    {
      tab_id_position <- match(Current$Tab, tab_id) + 1
      if (tab_id_position > length(tab_id)) tab_id_position <- 1
      Current$Tab <- tab_id[tab_id_position]
      updateTabItems(session, "sections", tab_id[tab_id_position]) 
    }
  )
  
}