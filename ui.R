library(shiny)
library(shinythemes)
library(ggplot2)
library(DT)
library(plotly)
library(lubridate)
library(readr)

nypd_shootings <- read_csv("nypd-shootings (1).csv")

# Define UI
ui <- navbarPage(
  title = "NYPD Shooting Incidents Analysis",
  theme = shinytheme("spacelab"), # Using shinythemes for additional styling
  tabPanel("Main", 
           h2("Introduction"),
           p("Dataset: nypd-shootings.csv (Shootings in New York from 2006-2021)"),
           p("Dataset derived from (https://data.cityofnewyork.us/Social-Services/NYPD/fjn5-bxwg). Downloaded dataset then trimmed it to only include shooting incidents."),
           p("My project aims to analyze the NYPD shooting crime dataset to explore how crime intensity has evolved over the years in New York. This is a valuable endeavor, as understanding crime trends can inform policy-making and community safety initiatives."),
           h4("Importance of the Question"),
           p("Understanding the trend of shooting incidents over time is crucial for informing public safety strategies, law enforcement resource allocation, and community engagement initiatives. It also prompts further investigation into the underlying causes of these trends.")),
  tabPanel("Trend Analysis",
           sidebarLayout(
             sidebarPanel(
               sliderInput("yearRange", 
                           "Select Year Range:",
                           min = 2006, 
                           max = 2021, 
                           value = c(2006, 2021),
                           step = 1)
             ),
             mainPanel(
               plotlyOutput("trendPlot"),
               h4("Trend Analysis Overview"),
               p("• Peak in 2006 with over 2000 incidents."),
               p("• Steady decline until 2017 with the lowest count of 970."),
               p("• Resurgence in incidents in 2020 and 2021."),
               p("• General trend indicates fluctuating patterns with recent increase.")
             )
           )),
  tabPanel("Heatmap Analysis",
           mainPanel(
             plotlyOutput("heatmapPlot"),
             h4("Heatmap Analysis Overview"),
             p("• Seasonal trends with higher counts in summer months."),
             p("• Year-over-year comparison shows fluctuating incident distribution."),
             p("• Recent years display a notable increase across several months.")
           )),
  tabPanel("Polar Time Plot",
           mainPanel(
             plotOutput("polarPlot"),
             h4("Polar Plot Analysis Overview"),
             p("• Higher number of incidents at night, peaking around 11 PM to 1 AM."),
             p("• Fewest incidents occur in the early morning hours."),
             p("• Incremental increase from morning to evening, with rapid rise post 6 PM.")  
           )),
  tabPanel("Download Data",
           sidebarLayout(
             sidebarPanel(
               dateRangeInput("downloadDateRange", 
                              "Select Date Range:",
                              min = "2006-01-01", 
                              max = "2021-12-31"),
               selectInput("downloadPrecinctSelect", 
                           "Select NYPD Precinct:",
                           choices = c("All", sort(unique(nypd_shootings$PRECINCT))),
                           selected = "All", 
                           multiple = TRUE)
             ),
             mainPanel(
               downloadButton("downloadData", "Download Data")
             ))
  )
)
