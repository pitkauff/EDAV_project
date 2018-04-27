#ui.R
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
devtools::install_github("timelyportfolio/parcoords")
library(parcoords)

Sys.setenv('MAPBOX_TOKEN' = 'pk.eyJ1IjoicGl0a2F1ZmYiLCJhIjoiY2pnNG10OWkxMG5jZjJ3cWQ2N2JlbnVhayJ9.ZS4VPpOc5iBycmkEkAVf-w')
#setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/shiny/Data")
data <- read_csv("data/Toronto_revs_area.csv")#read_csv("Toronto_revs_area.csv")#
colnames(data)[10] <- "sentiment"
colnames(data)[19] <- "rating"
data <- data %>% group_by(id) %>% mutate(sent = mean(sentiment))
stuff <- data[!duplicated(data$id),]
#setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/shiny/Data")
geo <- read.delim("data/GeoHash.txt", sep = ",")#read.delim("GeoHash.txt", sep = ",")#
geo <- prepend(levels(geo$Area), "All")
cats_1 <- as.data.frame(unique(stuff$category))
#setwd("~/Desktop/Columbia Files/Spring 2018/Exploratory Data Analysis/Project/shiny/Data")
cats_2 <- read.delim("data/Cat_reduced.txt", sep = ",")#read.delim("Cat_reduced.txt", sep = ",")#
categories_2 <- sort(intersect(cats_1$`unique(stuff$category)`, cats_2$Category))
categories_1 <- prepend(sort(categories_2), "All")

ui <- dashboardPage(skin = "yellow",
  dashboardHeader(
    title = "Toronto Restaurant Explorer",
    tags$li(class = "dropdown", actionButton(inputId ="Previous", label = icon("arrow-left"), style = "margin-right: 5px; margin-top: 7px;")),
    tags$li(class = "dropdown", actionButton(inputId ="Next", label = icon("arrow-right"), style = "margin-right: 20px; margin-top: 7px;"))
  ),
  
  dashboardSidebar(
    tags$head(tags$style(HTML('.shiny-server-account { display: none; }'))),
    uiOutput("userpanel"),
    sidebarMenu(id = "sections",
      menuItem("Introduction", tabName = "intro", icon = icon("table")),
      menuItem("Data Description", tabName = "data", icon = icon("database"),
        menuSubItem("Methodolody", tabName = "meth1", icon = icon("chevron-circle-right")),
        menuSubItem("Data Overview 1", tabName = "data1", icon = icon("chevron-circle-right")),
        menuSubItem("Data Overview 2", tabName = "data2", icon = icon("chevron-circle-right")),
        menuSubItem("Data Overview 3", tabName = "data3", icon = icon("chevron-circle-right")),
        menuSubItem("Data Overview 4", tabName = "data4", icon = icon("chevron-circle-right")),
        menuSubItem("Data Overview 5", tabName = "data5", icon = icon("chevron-circle-right"))),
      menuItem("Data Quality Analysis", tabName = "quality", icon = icon("medkit"),
        menuSubItem("Data Quality 1", tabName = "qual1", icon = icon("chevron-circle-right")),
        menuSubItem("Data Quality 2", tabName = "qual2", icon = icon("chevron-circle-right"))),
      menuItem("Main Analysis", tabName = "main", icon = icon("signal"),
        menuItem("Geographic Distribution", tabName = "main", icon = icon("chevron-circle-right"),
          menuSubItem("Geographic Distribution", tabName = "main1", icon = icon("chevron-circle-right")),       
          menuSubItem("Geographic Distribution 1", tabName = "main2", icon = icon("chevron-circle-right")),
          menuSubItem("Geographic Distribution 2", tabName = "main3", icon = icon("chevron-circle-right")),
          menuSubItem("Geographic Distribution 3", tabName = "main4", icon = icon("chevron-circle-right")),
          menuSubItem("Geographic Distribution 4", tabName = "main5", icon = icon("chevron-circle-right")),
          menuSubItem("Geographic Distribution 5", tabName = "main6", icon = icon("chevron-circle-right")),
          menuSubItem("Geographic Distribution 6", tabName = "main7", icon = icon("chevron-circle-right"))),
        menuItem("Sent, Ratings & Check-Ins", tabName = "main", icon = icon("chevron-circle-right"),
          menuSubItem("Sent, Ratings & Check-Ins", tabName = "main8", icon = icon("chevron-circle-right")),
          menuSubItem("Sent, Ratings & Check-Ins 1", tabName = "main9", icon = icon("chevron-circle-right")),
          menuSubItem("Sent, Ratings & Check-Ins 2", tabName = "main10", icon = icon("chevron-circle-right")),
          menuSubItem("Sent, Ratings & Check-Ins 3", tabName = "main11", icon = icon("chevron-circle-right")),
          menuSubItem("Sent, Ratings & Check-Ins 4", tabName = "main12", icon = icon("chevron-circle-right"))),
        menuItem("Case Study", tabName = "main13", icon = icon("chevron-circle-right"))),
      menuItem("Exective Summary", tabName = "revs", icon = icon("list-alt"),
        menuSubItem("Exective Summary", tabName = "revs1", icon = icon("chevron-circle-right")),
        menuSubItem("Exective Summary", tabName = "revs2", icon = icon("chevron-circle-right")),
        menuSubItem("Exective Summary", tabName = "revs3", icon = icon("chevron-circle-right")),
        menuSubItem("Exective Summary", tabName = "revs4", icon = icon("chevron-circle-right")),
        menuSubItem("Exective Summary", tabName = "revs5", icon = icon("chevron-circle-right"))),
      menuItem("Interactive", tabName = "interactive", icon = icon("mouse-pointer"),
        menuSubItem("Geographical Analysis", tabName = "geo_1", icon = icon("chevron-circle-right")),
        menuSubItem("Geographical Explorer", tabName = "geo_2", icon = icon("chevron-circle-right")),
        menuSubItem("Cuisine Explorer", tabName = "finder", icon = icon("chevron-circle-right"))),
      menuItem("Conclusion", tabName = "conclusion", icon = icon("table")))
  ),

  dashboardBody(
    tags$head(tags$style(HTML('
      .main-header .logo {
                          font-size: 15px;
                          }
                  '))),
    tabItems(
      # First tab content
      tabItem(tabName = "intro",
          box(
          h2("Welcome to the Toronto Restaurant Explorer", style = "font-weight: bold"),
          p(HTML(paste0('For this project, we have focused our attention on the Yelp dataset, found ',
                        a(href = 'https://www.yelp.com/dataset', 'here. '), 
                        "After careful consideration of multiple datasets, such as Citibike 
                        or the Million Songs dataset, we decided to use this one because it had
                        real-life, comprehensive data which is being used by Yelp for their 
                        business. During our search for less analyzed datasets, we eventually
                        came across the Yelp dataset. We decided to dive deeper into the dataset
                        in the hope of discovering interesting insights and patterns for several
                        reasons:")), align = "justify"),
          tags$ul(tags$li("Given our experience, Yelp data is widely used (including by ourselves)"),
                  tags$li("Yelp data is very tangible and easily relatable to a majority of the population"),
                  tags$li("People always struggle to find good restaurants, so we can actually add value"),
                  tags$li("The dataset is relatively clean and structured"),
                  tags$li("By coming up with useful visualizations, we can help both Yelp users 
                          and local businesses to get more information about the distribution of 
                          restaurants across the cities and neighborhoods, and the sentiment 
                          towards individual restaurants and cuisines")),
          p("Due to the size of the full data available (over 1000 cities across the US and 
            Canada), we decided to focus on a specific city, namely Toronto. We will go into
            further detail about why we chose Toronto a little later in the presentation. 
            Some high-level questions we attempted to answer were as follows:", align = "justify"),
          width = 10,
          tags$ul(tags$li("Where are the best restaurants of a particular cuisine located?"),
                  tags$li("Which cuisines do people like the most?"),
                  tags$li("Which areas have the most diverse food profile?"),
                  tags$li("Does a business with a high number of check-ins have a higher average rating?"),
                  tags$li("Which areas have the best restaurants?"),
                  tags$li("How are rating and review sentiment related?"),
                  tags$li("How do elite users affect review sentiment?"),
                  tags$li("How do check-ins vary over the course of the week?")),
          p("Throughout the project, we divided up tasks as follows:"),
          tags$table(align = "center",
            tags$tr(
              tags$th("Name", style = "border: 1px solid black; text-align: left; padding: 4px;"),
              tags$th("Task", style = "border: 1px solid black; text-align: left; padding: 4px;")
            ),
            tags$tr(
              tags$td("Nandini Malik", style = "border: 1px solid black; text-align: left; padding: 4px;"),
              tags$td("Executive Summary Manager", style = "border: 1px solid black; text-align: left; padding: 4px;")
            ),
            tags$tr(
              tags$td("Mrinalini Tavag", style = "border: 1px solid black; text-align: left; padding: 4px;"),
              tags$td("Main Analysis Coordinator", style = "border: 1px solid black; text-align: left; padding: 4px;")
            ),
            tags$tr(
              tags$td("Pit Kauffmann", style = "border: 1px solid black; text-align: left; padding: 4px;"),
              tags$td("Chief Animator", style = "border: 1px solid black; text-align: left; padding: 4px;")
            ),
            tags$tr(
              tags$td("Carlo Provinciali", style = "border: 1px solid black; text-align: left; padding: 4px;"),
              tags$td("Chief Data Engineer", style = "border: 1px solid black; text-align: left; padding: 4px;")
            )
          )
        )
      ),
      
      # Second tab content
      tabItem(tabName = "meth1",
          box(
          h2("Data Collection / Preprocessing Overview", style = "font-weight: bold"),
          p("For this project, we decided to use the Yelp Open Dataset, which contains 
            5,200,000 reviews and information about 174,000 businesses across 11 different 
            metropolitan areas. This dataset provides a number of attributes such as hours 
            of a business, location, star rating of each individual review, and business 
            categories. The data was downloaded in SQL format and imported into a local 
            database for preprocessing. Here's a representation of the schema: ", 
            align = "justify"),
          br(),
          img(src = 'fig1.png', width = 600, height = 300, 
              style="display: block; margin-left: auto; margin-right: auto;"),
          br(),
          br(),
          p("We decided to start our exploration by focusing on the business table. 
            Particularly, we were interested in the distribution of businesses by location
            and category. Since the initial dataset contains several GBs worth of data, 
            we figured we could find a way to subset it by business location and category 
            to make it more manageable.",
            align = "justify"),
          width = 10),
          fluidRow(
          )
      ),
      
      tabItem(tabName = "data1",
              box(
                h2("Data Overview: Part 1", style = "font-weight: bold"),
                p("For this purpose, we plotted the distribution of businesses by city along 
                  with the number of reviews. We immediately noticed that the distribution of 
                  these two variables was not homogeneous across cities; rather a few cities had 
                  significantly more reviews and businesses than other (unsurprisingly, these 
                  two variables are strongly correlated with each other).", align = "justify"),
                br(),
                fixedRow(
                  column(5,
                    img(src = 'fig3.png', width = 400, height = 400)
                  ),
                  column(5, offset = 1,
                    img(src = 'fig5.png', width = 400, height = 400)
                  )
                ),
                br(),
                br(),
            width = 10)
      ),
      
      tabItem(tabName = "data2",
              box(
                h2("Data Overview: Part 2", style = "font-weight: bold"),
                br(),
                img(src = 'fig6.png', width = 400, height = 400, align = "center", 
                    style="display: block; margin-left: auto; margin-right: auto;"),
                br(),
                br(),
                p("We decided to focus our analysis on one of the cities with the highest 
                  number of reviews and businesses. Las Vegas, Phoenix, Toronto, Scottsdale, 
                  and Charlotte seemed like good candidates since they were in the top 5 list
                  for both reviews and businesses.", align = "justify"),
                p("In order to further narrow down this list, we decide to look more closely
                  at the distribution of categories for businesses. We found out the dataset 
                  has 1293 unique categories, and one business might be assigned to more than
                  one category as the data schema suggests. At this point, our group thought 
                  it would be interesting to focus on Restaurants, since this type of business
                  seemed to have the most reviews and is fairly popular in the dataset.", 
                  align = "justify"),
            width = 10)
      ),
      
      tabItem(tabName = "data3",
              box(
                h2("Data Overview: Part 3", style = "font-weight: bold"),
                br(),
                img(src = 'fig7.png', width = 450, height = 400, align = "center", 
                    style="display: block; margin-left: auto; margin-right: auto;"),
                br(),
                br(),
                p("From the graph above, we thought Toronto would be a good option since it 
                  has the highest number of restaurants. Although we focused on businesses with
                  the \"restaurant\" category, after further inspecting the dataset we realized 
                  that the most restaurants had additional \"category\" tags that descibed the 
                  type of food or cuisine being served. We wanted to make sure for the final choice
                  to have a good variety of different cuisines so we could potentially compare 
                  across categories.", 
                  align = "justify"),
            width = 10)
      ),
      
      tabItem(tabName = "data4",
              box(
                h2("Data Overview: Part 4", style = "font-weight: bold"),
                br(),
                p("For this reason, we decided to look at the Gini index of 
                  the categories other than \"Restaurant\" for the restaurants in each city. The
                  generic Gini Index is calculated as follows:", 
                  align = "justify"),
                withMathJax(),
                helpText('$$Gini = 1-\\sum_{y \\in Cuisine} p_y^2$$'),
                p(HTML(paste("where p", tags$sub("y"), " is the fraction of all restaurants that belong to cuisine type y. 
                             In order to incorporate the size of the dataset for each city, we
                             developed the weighted Gini Index shown in the table and graph below. That version
                             of the Index was calculated by simply scaling the generic Index by the total number
                             of restaurants in each city, which benfits cities.
                             with more distinct restaurants", sep = "")), align = "justify"),
                p("The Gini index would hence, be higher for cities with a good mix of category labels and 
                  lower for cities where many restaurants share the same category.", 
                  align = "justify"),
                br(),
                fixedRow(
                  column(5, align = "center",
                         img(src = 'fig6.1.png', width = 300, height = 150, 
                             style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;")
                  ),
                  column(5, offset = 1,
                         img(src = 'fig8.png', width = 400, height = 380)
                  )
                ),
                
            width = 10)
      ),
      
      tabItem(tabName = "data5",
              box(
                h2("Data Overview: Part 5", style = "font-weight: bold"),
                br(),
                p("In order to evaluate the diversity of ethnic cuisines in each of the cities, 
                  we hand-picked a few categories that we thought were the most appropriate 
                  to describe specific regional cuisines (such as Italian, French, Japanese, 
                  etc.) and compared the distribution of these categories across cities.", 
                  align = "justify"),
                br(),
                img(src = 'fig9.png', width = 470, height = 470, 
                   style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
                br(),
                p("These graphs confirmed that Toronto had the best variety in terms of cuisines
                  so we decided to focus on this city for our main analysis.\n 
                  Once we decided to focus our analysis on restaurants in Toronto and created a subset of the 
                  restaurant dataset, we notice two main issues with out data.", align = "justify"),
            width = 10)
      ),
      
      tabItem(tabName = "qual1",
              box(
                h2("Problem 1: Restaurants might have more than one category", style = "font-weight: bold"),
                br(),
                p("This made the creation of a business dataset that included category or 
                  cuisine information difficult as each business would be represented multiple
                  times for each one of its categories. We came to the conclusion that this was
                  acceptable in the cases we wanted to compare the distribution of different 
                  cuisines; after all, we had no way to tell which cuisine or category is 
                  predominant for each restaurant, and when grouping by a specific category 
                  we wanted all the respective restaurant to be represented. On the other 
                  hand, we decided to remove duplicate businesses when category was not taken 
                  into consideration.", 
                  align = "justify"),
                h2("Problem 2: Neighborhood information is missing", style = "font-weight: bold"),
                img(src = 'fig10.png', width = 400, height = 400, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
                br(),
                p("We notice that around 20% of businesses in Toronto were missing the variable
                  \"neighborhood\", as the graph above shows.", align = "justify"),
            width = 10)
      ),
      
      tabItem(tabName = "qual2",
              box(
                h2("Problem 2 (cont.): Neighborhood information is missing", style = "font-weight: bold"),
                br(),
                p("Since we will be  using geographical data quite a lot in our main analysis 
                  and interactive sections of the report, we wanted to further investigate the 
                  missing \"neighborhoods\", in order to determine whether or not there was a 
                  trend towards missing values in certain areas of Toronto that might impact the
                  validty of further analysis.", 
                  align = "justify"),
                img(src = 'fig11.png', width = 550, height = 325, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
                br(),
                p("Upon further inspection, we realized that the missing \"neighborhood\" values
                  seem to be clustered in specific geographic location. Judging form the graph
                  above, entire neighborhoods seem to be missing from the dataset. We concluded
                  that the provided \"neighborhood\" variable was not reliable and we would need to rely
                  on the latitude and longitude variables to represent the location of a 
                  business. However, since \"neighborhood\" is a simple way of clustering restaurants and
                  simplify our analysis, we decided to create our own neighborhoods using the
                  following method:", align = "justify"),
                tags$ul(tags$li(HTML(paste0("We manually selected certain areas in downtown Toronto and assigned
                                them unique area codes using python's ", a(href = 'http://geohash.gofreerange.com/', "geohash library")))),
                        tags$li("We subsequentially mapped each restaurant to an area code and assigned it a \"neighborhood name\""),
                        tags$li(HTML(paste0("The code can be found ", a(href = 'https://github.com/thegreatwarlo/EDAV_project/blob/master/Code/geo_hash.py', "here"))))),
            width = 10)
      ),
      
      tabItem(tabName = "main1",
              box(
                h2("Geographical Distribution of Restaurants", style = "font-weight: bold"),
                br(),
                p("We started our analysis of Toronto restaurants by filtering out all 
                  restaurants except those categorized under the top 20 most common cuisines. 
                  An initial visualization of the geographical distribution of these restaurants
                  showed that restaurants were most concentrated in the downtown area and became
                  more sparsely distributed the further one moves away from the downtown area.", 
                  align = "justify"),
                img(src = 'fig12.png', width = 550, height = 400, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
                br(),
                p("To fully understand the geographical distribution of restaurants around 
                  Toronto and the various factors that might affect it, we explored the other
                  attributes of the restaurants available to us from the dataset.", 
                  align = "justify"),
            width = 10)
      ),
      
      tabItem(tabName = "main2",
              box(
                h2("1) Geographic Distribution of Restaurants in Toronto by Cuisine", style = "font-weight: bold"),
                br(),
                p("Most cuisines follow the same general pattern of being more concentrated in 
                  the downtown area and more dispersed outside of that area. However, the 
                  Chinese restaurant distribution is noticeable in that it has two separate 
                  areas of concentration, one in the downtown area and another a considerable
                  distance to the northeast of the downtown area.", 
                  align = "justify"),
                img(src = 'fig13.png', width = 550, height = 400, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
            width = 10)
      ),
      
      tabItem(tabName = "main3",
              box(
                h2("2) Geographic Distribution of Restaurants in Toronto by Rating", style = "font-weight: bold"),
                br(),
                p("For the purposes of mapping, \"Bad\" restaurants had a rating below 3 stars, 
                  and \"Good\" restaurants had a rating greater than or equal to 3 stars. 
                  \"Very Bad\" restaurants had less than 2 stars and \"Very Good\" restaurants 
                  had a 4-star rating or higher. There is no noticeable pattern in the 
                  distribution of restaurants by rating that departs from the general pattern
                  of restaurant distribution.", 
                  align = "justify"),
                img(src = 'fig14.png', width = 550, height = 425, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
                width = 10)
      ),
      
      tabItem(tabName = "main4",
              box(
                h2("3) Geographic distribution of restaurants with \"Good\" and \"Very Good\" rating by cuisine", style = "font-weight: bold"),
                br(),
                p("There is no discernible departure from the general restaurant distribution
                  by cuisine when only \"Good\" and \"Very Good\" restaurants were visualized.", 
                  align = "justify"),
                img(src = 'fig15.png', width = 550, height = 410, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
            width = 10)
      ),
      
      tabItem(tabName = "main5",
              box(
                h2("4) Geographic Distribution of Restaurants in Toronto by Number of Check-ins", style = "font-weight: bold"),
                br(),
                p("In order to visualize this distribution, we had to join check-in data with 
                  restaurant data, and we decided to remove all the rows that had NA values 
                  in the check-in column. Less than 44 check-ins was considered \"Low\", and 44 
                  check-ins or more was considered \"High\" for the purposes of these mappings.
                  Less than 13 check-ins was considered \"Very Low\" and 137 check-ins or more 
                  was considered \"Very High\". The restaurant distributions by number of 
                  check-ins showed the same general pattern as all restaurants.", 
                  align = "justify"),
                fixedRow(
                  column(5, align = "center",
                         img(src = 'fig16.1.png', width = 375, height = 190, 
                             style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;")
                  ),
                  column(5, offset = 1,
                         img(src = 'fig16.png', width = 400, height = 325)
                  )
                ),
            width = 10)
      ),
      
      tabItem(tabName = "main6",
              box(
                h2("5) Geographic Distribution of Restaurants with \"High\" and \"Very High\" Number of Check-ins by Cuisine", style = "font-weight: bold"),
                br(),
                p("Here, again, there is no discernible departure from the general restaurant 
                  distribution by cuisine when only restaurants with \"High\" or \"Very High\" 
                  number of check-ins were visualized.", 
                  align = "justify"),
                fixedRow(
                  column(5, align = "center",
                         img(src = 'fig17.1.png', width = 375, height = 110, 
                             style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;")
                  ),
                  column(5, offset = 1,
                         img(src = 'fig17.png', width = 400, height = 325,
                             style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;")
                  )
                ),
            width = 10)
      ),
      
      tabItem(tabName = "main7",
              box(
                h2("6) Cuisine Diversity by Area", style = "font-weight: bold"),
                br(),
                p("A final geographic analysis that we wanted to perform is understand which areas of Toronto have
                  the highest culinary diversity. As mentioned in the \"Data Description\" section, 
                  we resorted to creating our own areas using Python's geaohash library. We then applied
                  a methodology similar to that relating to our effort to indentify which city has the 
                  highest cuisine diversity. Namely, we calculated the Gini index for each area and subsequently, 
                  investogated which area would have the highest non-weighted index. The result is shown below", 
                  align = "justify"),
                  img(src = 'fig18.png', width = 400, height = 400, 
                      style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
                br(),
                p("We can observe that all 10 areas are about equally diverse, with their Gini index
                  ranging from 90% to 97%. However we can see that one area, namely the Garden District
                  has a significantly lower diversity score (80%) than the remining areas. Further analysis
                  would be require to identify what could be the reasons for this patterns."),
            width = 10)
      ),
      
      tabItem(tabName = "main8",
              box(
                h2("Sentiment, Rating, and Check-ins", style = "font-weight: bold"),
                br(),
                p("Our next step was to go deeper into the analysis of the popularity of the 
                  restaurants in Toronto. We attempted to gauge the popularity of restaurants
                  and cuisines using ratings, check-ins, and sentiment scores of reviews. We 
                  obtained a sentiment score for each review (a value between -1 and 1) using 
                  Python's TextBlob library, and we used these values to get the 
                  average sentiment score for each restaurant.", 
                  align = "justify"),
                h3("Relationship Between Rating, Number of Check-ins and Average Sentiment", style = "font-weight: bold"),
                p("In the following bar chart, we can clearly see a positive correlation
                  between average sentiment scores and ratings:", 
                  align = "justify"),
                img(src = 'fig19.png', width = 400, height = 300, 
                  style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
                p("Having established a strong correlation between sentiment and rating, we
                  wanted to see sentiment and rating distributions for different cuisines.", 
                  align = "justify"),
            width = 10)
      ),
  
      tabItem(tabName = "main9",
              box(
                h2("Sentiment, Rating, and Check-ins 1", style = "font-weight: bold"),
                br(),
                p("We visualized the distribution of restaurants by ratings under each cuisine. 
                  For the purpose of this analysis, we restricted our analysis to the top 20 
                  most frequent cuisines only. In general, the ratings distributions for all 
                  cuisines were left skewed, with peaks at either 4 or 5 stars. We saw that 
                  French, Mediterranean, Middle Eastern, and Tapas Bars were among the highly
                  rated cuisines.", 
                  align = "justify"),
                img(src = 'fig20.png', width = 400, height = 400, 
                  style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
            width = 10)
      ),
  
      tabItem(tabName = "main10",
              box(
                h2("Sentiment, Rating, and Check-ins 2", style = "font-weight: bold"),
                br(),
                p("Below we visualized the distribution of review sentiment scores for
                  each of the top 20 most frequent cuisines using boxplots. The review 
                  sentiment scores are generally centered at a sentiment score between 
                  0.2 and 0.3 and show a similar spread for all cuisines. The sentiment 
                  scores for the French cuisine sentiment scores are more tightly distributed 
                  about its center (which is on the higher end of the 0.2 - 0.3 interval) 
                  than other cuisines.", 
                  align = "justify"),
                img(src = 'fig21.png', width = 375, height = 375, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
            width = 10)
      ),
      
      tabItem(tabName = "main11",
              box(
                h2("Sentiment, Rating, and Check-ins 3", style = "font-weight: bold"),
                br(),
                p("We then took a closer at the actual reviews themselves and see what
                  insights we can gain from them. In order to do so, we reverted to a traditional
                  method, term frequency, to see which words would most appear in certain reviews.
                  For this purpose, we defined two categories of reviews: those that have an average
                  sentiment above 0.5 (\"Good Reviews\") and below -0.5 (\"Bad Reviews\"). 
                  We subsequently created a set of wordclouds to understand which words are 
                  most prevalent in each type of review and hence potentially predictive
                  of the type of review. The result can be seen below", 
                  align = "justify"),
                fixedRow(
                  column(5, align = "center",
                         h5("Wordcloud for \"Good Reviews\"", style = "font-weight: bold", align = "center"),
                         img(src = 'fig22.png', width = 300, height = 200, 
                             style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;")
                  ),
                  column(5, offset = 1, align = "center",
                         h5("Wordcloud for \"Bad Reviews\"", style = "font-weight: bold", align = "center"),
                         img(src = 'fig23.png', width = 300, height = 200,
                             style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;")
                  )
                ),
                p("As expected, good reviews include words such as \"great\", \"excellent\" and \"awesome\", 
                  while bad reviews contain more negative words, such as \"worst\", \"terrible\" and \"disappointed\".
                  Althouth we expected a result akin to this, we did not predict such a strong 
                  polarization between reviews, especially given that \"Bad Reviews\" are extremely rare,
                  as seen below:"),
                img(src = 'fig24.png', width = 250, height = 200, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
            width = 10)
      ),
      
      tabItem(tabName = "main12",
              box(
                h2("Sentiment, Rating, and Check-ins 3", style = "font-weight: bold"),
                br(),
                p("We finally took a look at elite users. Yelp elite users, akin to Piazza super
                  users for this class, are particular Yelp members who post reviews often, check-in
                  often and answer questions frequently. We wanted to see if maybe elite users tend to
                  disporportionally post either good or bad reviews, compared to the average user. The
                  picture below shows one such attempt, plotting teh average review sentiment for reviews
                  posted by elite users vs. non-elite users", 
                  align = "justify"),
                img(src = 'fig25.png', width = 350, height = 300, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
                p("We can see there is no discernable difference in the average review sentiment
                  of elite users when compared to non-elite users. 
                  Our next task was to figure out, given that the elite reviews generally have the same
                  sentiment as non-elite reviews, whether or not elite user reviews would have a subsequent effect
                  on restaurant ratings. Specifically, we wanted to figure out whether a good review by an
                  elite user would result in an increase in sentiment of subsequent reviews by non-elite users.
                  In order to do so, we decided to create a case study, as shown on the next slide.", 
                  align = "justify"),
            width = 10)
      ),
      
      tabItem(tabName = "main13",
              box(
                h2("Case Study: Pai Northern Thai Kitchen", style = "font-weight: bold"),
                br(),
                p("In order to investigate a poential relationship between elite reviews and
                  subsequent review sentiment more closely, we decided to look more closely at 
                  business with the most reviews in the Toronto restaurant dataset (Pai Northern
                  Thai Kitchen in Toronto's Entertainment District). We then plotted the progession
                  of the restaurant's sentiment over the time horizon provided in the dataset, and
                  highlighted and elite review, in order to see whether or not there was an effect.
                  This can be seen in the graph to the right below.", 
                  align = "justify"),
                fixedRow(
                  column(5, align = "center",
                         img(src = 'fig26.png', width = 400, height = 300, 
                             style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;")
                  ),
                  column(5, offset = 1, align = "center",
                         img(src = 'fig27.png', width = 400, height = 300,
                             style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;")
                  )
                ),
                p("We noticed that the data was too clustered, with too many elite reviews in a
                  short time period, in order to get a good sense of a potential relationship. We
                  solved this issue, by plotting the same sentiment, but this time only over the last 6-months, 
                  instead of the full 3.5 years. The resulting graph is depicted the graph above to the right. We
                  can make a couple observations here:"),
                tags$ul(tags$li("The sentiment of elite reviews tends to hover in the 0.1 to 0.4 area (note that
                                it is positive the vast majority of the time) "),
                        tags$li("We can see that a surprisingly large amount of elite reviews happen to have a
                                sentiment that is near (or equal to) either the best or the worst
                                average review sentiment of that given day"),
                        tags$li("We can further note that there are a non-trivial set of instances in which sentiment
                                rises after a poor elite review and drops after a good elite review, such as the large
                                drop around November 2017"),
                        tags$li("Further data and analysis would be required in order to identify potential causes of
                                such strange patterns")),
                width = 10)
      ),
      
      tabItem(tabName = "revs1",
              box(
                h2("Executive Summary: Cuisine Diversity", style = "font-weight: bold"),
                br(),
                p("The Yelp open dataset that we chose to work with provides information on 
                  about 170,000 business across 11 metropolitan areas. We narrowed down our 
                  analysis to the city with the highest diversity. To find what city was the 
                  most diverse, we used some statistical approaches and visualised the 
                  distribution of the restaurants by cuisines in the cities.\n
                  We saw that Toronto was the most diverse out of all other cities.", 
                  align = "justify"),
                img(src = 'fig28.png', width = 470, height = 450, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
            width = 10)
      ),
      
      tabItem(tabName = "revs2",
              box(
                h2("Executive Summary: Geographical Distribution in Toronto", style = "font-weight: bold"),
                br(),
                p("Based on this finding, we decided to narrow down our focus to Toronto. 
                  Delving into Toronto, we analysed the geographical distribution of restaurants
                  around the city and saw that most of the restaurants were centered around the
                  Downtown/Entertainment District area. In all other parts of the city, we
                  noticed that the restaurants were more or less uniformly distributed.", 
                  align = "justify"),
                img(src = 'fig29.png', width = 550, height = 400, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
                width = 10)
      ),
      
      tabItem(tabName = "revs3",
              box(
                h2("Executive Summary: Best Cuisines", style = "font-weight: bold"),
                br(),
                p("Our next point of focus was analysing the popularity of the restaurants 
                  around Toronto through their reviews and ratings. We obtained a sentiment
                  score (between -1 and 1) for each review that measured how positive or 
                  negative the review was.",
                  align = "justify"),
                p("We analyzed the distributions of the sentiment scores of the restaurants
                  under each category (cuisine). Through the following boxplots, we can see
                  that there wasn't much of a difference in the distribution of sentiment 
                  scores across all cuisines - so the average sentiment towards all cuisines 
                  was more or less the same.",
                  align = "justify"),
                img(src = 'fig30.png', width = 325, height = 350, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
            width = 10)
      ),
      
      tabItem(tabName = "revs4",
              box(
                h2("Executive Summary: Ratings and Sentiment", style = "font-weight: bold"),
                br(),
                p("Next, we wanted to check if there was any relationship between the overall 
                  sentiment towards restaurants and their star ratings.\n
                  In the following bar chart, we can clearly see a relationship between the 
                  two - as the star rating increases, the average sentiment score also
                  increases.",
                  align = "justify"),
                img(src = 'fig31.png', width = 350, height = 300, 
                    style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;"),
            width = 10)
      ),
      
      tabItem(tabName = "revs5",
              box(
                h2("Executive Summary: Reviews Analysis", style = "font-weight: bold"),
                br(),
                p("Finally, we saw the distribution of words in the \"good\" and the \"bad\" 
                  reviews. We made the following word clouds, which clearly show that words 
                  like \"great\", \"excellent\" and \"delicious\" were very common in the 
                  \"good\" reviews, whereas words like \"worst\", \"bad\" and \"terrible\" 
                  were very common in the \"bad\" reviews.",
                  align = "justify"),
                fixedRow(
                  column(5, align = "center",
                         h5("Wordcloud for \"Good Reviews\"", style = "font-weight: bold", align = "center"),
                         img(src = 'fig22.png', width = 400, height = 300, 
                             style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;")
                  ),
                  column(5, offset = 1, align = "center",
                         h5("Wordcloud for \"Bad Reviews\"", style = "font-weight: bold", align = "center"),
                         img(src = 'fig23.png', width = 400, height = 300,
                             style="display: block; margin-left: auto; margin-right: auto; margin-top: auto; margin-bottom: auto;")
                  )
                ),
                width = 10)
      ),
      
      
      tabItem(tabName = "geo_1",
          h3("We invite you to further explore Toronto's restaurant scene"),
          box(
            selectInput("area", label = h4("Select an Area"), 
                        choices =  geo, selected = "Downtown"),
                
            selectInput("cuisine1", label = h4("Select a Cuisine"), 
                        choices = categories_1, selected = "Chinese"),
            width = 3
            ),
            mainPanel(
            plotlyOutput("TorontoMap", width = 800, height = 350),
            parcoordsOutput("pcp", width = 800, height = 300)
            ),
            fluidRow(
            )
      ),
      
      tabItem(tabName = "geo_2",
              h3("We invite you to further explore Toronto's restaurant scene"),
              box(
                textInput("address", "Enter Address / Location", "Address"),
                actionButton("do", " Click Here"),
                br(),
                br(),
                p(tags$em("Note: The above query uses a Google API, which has request timeouts if used
                  too frequently")),
                br(),
                p(tags$strong("Instructions: ")),
                p("Please enter an address or a location in the field above. For example, you could 
                  put in:"),
                tags$ul(tags$li("e.g. address: \"279 Yonge St, Toronto\""),
                        tags$li("e.g. location: \"Toronto City Hall\"")), style = "font-size:13px; text-align: left",
                p("Once the restaurants show up, click on one to see when it is busiest"),
                width = 3
              ),
              mainPanel(
                plotlyOutput("TorontoFind", width = 800, height = 350),
                plotOutput("plotClickOutput", width = 800, height = 300)
              ),
              fluidRow(
              )
      ),
      
      tabItem(tabName = "finder",
              h3("We invite you to further explore Toronto's restaurant scene"),
              box(
                selectInput("cuisine2", label = h4("Select a Cuisine"), 
                            choices = categories_2, selected = "Chinese"),
                br(),
                p(tags$em("Note: The graph on the right is produced by taking the top 5 and bottom 5
                        cuisines with regards to the average rating. However, since the
                        boxplot is ordered by the median rating, it is possible for a selected cuisine
                        to move into the top 5 or the bottom 5.")),
                width = 3
              ),

              mainPanel(
                plotlyOutput("boxplot", width = 800, height = 650)
              ),
              fluidRow(
              )
      ),
      
      tabItem(tabName = "conclusion",
              box(
                h2("Conclusion", style = "font-weight: bold"),
                p("The Yelp dataset had both strengths and limitations. Its limitations included the following:", 
                  align = "justify"),
                tags$ul(tags$li("Working with relational databases with tables that have a 
                                1-to-many relationship is very difficult. We experienced that
                                when dealing with the business \"category\" field, since businesses
                                were often assigned more than one category and was hard to 
                                include this useful information in one dataset without creating
                                duplicates. Furthermore, the categories ranged from very 
                                generic e.g. \"Food\" to very specific e.g. \"cantonese\". We 
                                feel like there would be a lot of additional opportunities 
                                for analysis if the categories had a hierarchical or more 
                                defined structure."),
                        tags$li("We initially wanted to include the check-in table in our 
                                analysis. This table is supposed to show the number of customers
                                that are \"checking-in\" to a particular business at a given time
                                using the app. We thought this information would be useful to 
                                analyze the popularity of certain restaurants over time, 
                                especially in relationship to its rating and sentiment score.
                                Although, we soon realized the ???check-ins??? were pre-aggregated 
                                by hour and day of the week and had no information about the day
                                of the year, so they were not useful for our time trend analysis 
                                of sentiment/ratings."),
                        tags$li("The dataset proved to have some limitations in terms 
                                of completeness. The most obvious example was the 
                                \"neighborhood\" field, which as we found out was often 
                                missing. Another thing to consider is that this dataset 
                                will only include businesses that are registered with Yelp;
                                all restaurants may not necessarily be registered with Yelp. 
                                However, the restaurants category is probably the most 
                                complete business category on Yelp, given that the app is 
                                most popularly used to look up restaurants.")),
                p("Despite some of the problems with the Yelp data, it had some definite advantages
                  that allowed us to answer some interesting questions:", align = "justify"),
                
                tags$ul(tags$li("The data was great for viewing the geographical distribution 
                                of restaurants as the longitude and latitude information for 
                                each business was complete. Though the Yelp dataset may not 
                                allow for visualizing the distribution of all restaurants in 
                                Toronto, since not all restaurants are registered with Yelp, 
                                it is useful for visualizing the geographical locations of 
                                restaurants that are registered with Yelp."),
                        tags$li("The review and rating data for each restaurant allowed us to 
                                obtain a measure of its quality and popularity, which opened up 
                                the door to some interesting exploratory analyses.")),
                p("Answering the questions that motivated the analysis of Yelp data inspired 
                  some new lines of inquiry, which we would have liked to pursue given 
                  more time. Some ideas include", align = "justify"),
                tags$ul(tags$li("Looking at Michelin guide ratings of restaurants and common 
                                features of reviews of those restaurants,"),
                        tags$li("Looking at the correlation between restaurant health grades,
                                ratings, review sentiment, and location, and"),
                        tags$li("Asking whether people are more likely to take pictures of a 
                                highly rated restaurant by using picture data from Yelp 
                                (a separate dataset).")),
            width = 10)
      )
    )
  )
)
