server <- function(input, output) {
  # Load necessary libraries
  library(dplyr)
  library(lubridate)
  library(ggplot2)
  library(readr)
  library(plotly)
  
  # Load the dataset
  
  nypd_shootings <- read_csv("nypd-shootings (1).csv")
  
  nypd_shootings$OCCUR_DATE <- mdy(nypd_shootings$OCCUR_DATE)
  
  # Trend Analysis Plot
  output$trendPlot <- renderPlotly({
    req(input$yearRange)  # Ensure input$yearRange is not NULL
    
    trend_data <- nypd_shootings %>%
      filter(year(OCCUR_DATE) >= input$yearRange[1] & year(OCCUR_DATE) <= input$yearRange[2]) %>%
      group_by(Month = month(OCCUR_DATE, label = TRUE, abbr = TRUE)) %>%
      summarise(n = n())  # Aggregate data
    
    p <- ggplot(trend_data, aes(x = Month, y = n, group = 1)) +  # Add 'group = 1' to ensure line connects points
      geom_line() +
      labs(title = "Monthly Trend of Shooting Incidents", x = "Month", y = "Number of Incidents") +
      theme_minimal()  # Optional: Use a minimal theme for a cleaner look
    
    ggplotly(p)
  })
  
  
  
  # Heatmap
  output$heatmapPlot <- renderPlotly({
    heatmap_data <- nypd_shootings %>%
      count(Year = year(OCCUR_DATE), Month = month(OCCUR_DATE, label = TRUE, abbr = TRUE))
    
    p <- ggplot(heatmap_data, aes(x = Month, y = Year, fill = n)) +
      geom_tile() +
      geom_text(aes(label = n), vjust = 1.5, color = "black") +
      scale_fill_gradient(low = "white", high = "lightblue") +
      labs(title = "Heatmap of Shooting Incidents", x = "Month", y = "Year") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = "text")
  })
  
  
  # Polar Coordinate Map
  output$polarPlot <- renderPlot({
    # Ensure OCCUR_TIME is in the correct format
    polar_data <- nypd_shootings %>%
      filter(!is.na(OCCUR_TIME)) %>%
      mutate(Hour = hour(hms(OCCUR_TIME))) %>%
      count(Hour) %>%
      filter(!is.na(Hour))  # Filter out NA values in Hour
    
    # Ensure there's data to plot
    if (nrow(polar_data) == 0) {
      return()
    }
    
    # Create the polar plot using ggplot
    p <- ggplot(polar_data, aes(x = factor(Hour), y = n)) +
      geom_bar(stat = "identity", width = 1, fill = "blue", alpha = 0.7) +
      coord_polar(start = 0) +
      scale_x_discrete(limits = as.character(0:23), labels = paste0(0:23, "h")) +
      labs(title = "Shooting Incidents by Hour of Day", x = "Hour of Day", y = "Number of Incidents") +
      theme_minimal()
    
    p
  })

  
  
  # Downloadable Reports
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("NYPD-Shootings-Data-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      data_to_download <- nypd_shootings %>%
        filter(OCCUR_DATE >= input$downloadDateRange[1] & OCCUR_DATE <= input$downloadDateRange[2]) %>%
        filter(if (input$downloadPrecinctSelect != "All") PRECINCT %in% input$downloadPrecinctSelect else TRUE)
      
      write.csv(data_to_download, file, row.names = FALSE)
    }
  )
}


