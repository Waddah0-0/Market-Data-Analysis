library(shiny)
library(ggplot2)
library(plotly)
library(arules)
library(arulesViz)
library(shinythemes)
library(DT)
library(readxl)
library(dplyr)

# UI
ui <- fluidPage( #creates a responsive layout for shiny web app
  theme = shinytheme("cyborg"), # to put the Cyborg theme (shiny themes used)
  titlePanel("Market Data Analysis"), #to put the title for the app
  
  sidebarLayout( #to define the layout of the page with sidebar and main panel
    sidebarPanel( #sidebar layout containing input controls for the user
      h4("Step 1: Upload Your Data"), #to head the step 1 with a name
      fileInput("dataset_file", "Choose a CSV file to upload:"), # allows the user to choose a csv file from the device
      
      h4("Step 2: Customize Analysis"), # to head step 2 with a name
      numericInput("num_clusters", "Choose Number of Clusters (2 to 4):", min = 2, max = 4, value = 3), # to select number of clusters from 2 to 4 and put the default value with 3
      numericInput("min_support", "Set Minimum Support (0 to 1):", value = 0.001, min = 0.001, max = 1), # to select number of support from 0.001 to 1 and put the default value with 0.001
      numericInput("min_confidence", "Set Minimum Confidence (0 to 1):", value = 0.001, min = 0.001, max = 1), #to select number of confidence from 0.001 to 1 and put the default value with 0.001
      
      actionButton("load_data", "Load and Analyze Data") #user clicks to load and analyze the data
    ),
    
    mainPanel( # to display the results in main panel after the data analysis
      tabsetPanel( #to display multiple tabs for different outputs
        tabPanel("Data", #to put a panel named data
                 h4("Dataset Summary"), # title for data set summary
                 verbatimTextOutput("summary")), #output of data set summary (shiny package used)
        
        tabPanel("Visualization",  #to put a panel named data
                 h4("Spending by Payment Type"), #title
                 plotOutput("cash_credit_plot"), # interactive plot for total spending by payment type (plotly used)
                 h4("Spending by Age Group"), #title
                 plotOutput("age_spending_plot"), #interactive plot for spending by age group (plotly used)
                 h4("Spending by City"), #title
                 plotOutput("city_spending_plot"), #interactive plot forspending by city (plotly used)
                 h4("Total Spending Distribution"), #title
                 plotOutput("spending_distribution_plot")), #interactive plot for total spending by distribution (plotly used)
        
        tabPanel("Clustering", # to put a panel named clustering
                 h4("Clustering Results"), # title
                 tableOutput("cluster_table")), #table displaying the clustering results (shiny used)
        
        tabPanel("Association Rules", #to put a panel named association rules
                 h4("Association Rules"), # title
                 DT::dataTableOutput("rules_table")) #data table output for association rules (DT used)
      )
    )
  )
)

# Define server logic for a Shiny app
server <- function(input, output, session) {
  dataset <- reactiveVal() #to create a reactive value to store the dataset
  
  observeEvent(input$load_data, { #to observe the event when the user clicks the "load_data" button
    req(input$dataset_file) #to ensure that the user has uploaded a file
    data_path <- input$dataset_file$datapath #to get the file path of the uploaded dataset
    data <- read.csv(data_path) #to read the CSV file into a data frame
    
    # Validate dataset structure of the uploaded dataset
    required_columns <- c("total", "paymentType", "age", "city", "customer") # Define the required column names
    validate(need(all(required_columns %in% colnames(data)), # Check if all required columns are present in the dataset
                  paste("Dataset must include the following columns:", paste(required_columns, collapse = ", ")))) # Error message if columns are missing
    
    #data cleaning: remove duplicates, NAs, and handle outliers
    duplicated(data) #represents dublicated data 
    sum(duplicated(data)) #clalculate the sum of dublicated data
    data=unique(data) #delete dublicated data
    data # represent data after deleting dublicated data 
    sum(duplicated(data))
    is.na(data) #represnts N/A fileds
    sum(is.na(data)) #calculate the sum of N/A fileds ( didnt find N/A feilds)
    boxplot(data[,2:4]) #represents data outliers
    outlier=boxplot(data$count)$out #store "Count" outlier variable (outlier)
    outlier #represent outlier (count)
    data[which(data$count %in% outlier),] #check (count) outlier
    data<-data[-which(data$count %in% outlier),]#delete outlier
    
    
    dataset(data) #save cleaned data
    
    #data summary output
    output$summary <- renderPrint({
      summary(data)
    })
    
    #visualizations 1/total spending by payment type
    output$cash_credit_plot <- renderPlot({
      total_by_payment <- aggregate(total ~ paymentType, data = data, FUN = sum)
      barplot(
        total_by_payment$total,                   
        names.arg = total_by_payment$paymentType,  
        xlab = "Payment Type", 
        ylab = "Total Payment", 
        col = "darkred", 
        main = "Spending by Payment Type" )
    })
    
    # visualizations 2/total spending by age
    output$age_spending_plot <- renderPlot({
      total_by_age <- aggregate(total ~ age, data = data, FUN = sum)
      barplot(
        total_by_age$total,                       
        names.arg = total_by_age$age,         
        xlab = "Age", 
        ylab = "Total Payment",
        col = "blue", 
        main = "Spending by Age Group")
    })
    
    # visualizations 3/total spending by city
    output$city_spending_plot <- renderPlot({
      city_summary <- aggregate(total ~ city, data = data, sum)
      city_summary <- city_summary[order(-city_summary$total), ]
      
      barplot(city_summary$total, 
              names.arg = city_summary$city, 
              xlab = "City", 
              ylab = "Total Payment", 
              col = "pink", 
              main = "Spending by City")
    })
    
    # visualizations 4/spending distribution
    output$spending_distribution_plot <- renderPlot({
      
      hist(data$total, 
           breaks = seq(min(data$total), max(data$total), by = 100), 
           col = "lightblue", 
           main = "Distribution of Total Spending", 
           xlab = "Total Spending", 
           ylab = "Count")
    })
    
    #perform K-means clustering based on 'age' and 'total' columns
    output$cluster_table <- renderTable({
      req(input$num_clusters)
      
      # Prepare data for clustering
      data_cluster <- data %>%
        select(customer, age, total) %>%
        group_by(customer) %>%
        summarize(total_spent = sum(total), age = mean(age), .groups = "drop")
      
      
      # Scale the 'age' and 'total_spent' columns for clustering
      scaled_data <- scale(data_cluster[, c("age", "total_spent")])
      
      # Perform K-means clustering
      set.seed(80)  # For reproducibility
      kmeans_result <- kmeans(scaled_data, centers = input$num_clusters, nstart = 20)
      
      # Add cluster labels to the dataset
      data_cluster$Cluster <- kmeans_result$cluster
      
      # Return the clustering results
      data_cluster
    })
    # Association Rules: Find frequent itemsets and rules based on customer transactions
    output$rules_table <- DT::renderDataTable({
      # Ensure the user has provided both minimum support and confidence values
      req(input$min_support, input$min_confidence)
      # Check that the dataset contains a column named 'items'
      # This column is where all the transaction data is stored 
      
      # Convert the 'items' column into a list of transactions
      # Each row in the 'items' column represents one transaction 
      # Use strsplit to break the string into individual items using commas as separators
      items_list <- strsplit(as.character(dataset()$items), ",\\s*") # Split items by comma
      transactions <- as(items_list, "transactions")
      # Check if there are any transactions to work with
      # This avoids errors if the dataset is empty or incorrectly formatted
      
      # Generate association rules
      # Apply the Apriori algorithm to generate association rules
      # The algorithm uses the user-defined support and confidence thresholds
      rules <- apriori(transactions, parameter = list(supp = input$min_support, conf = input$min_confidence), minlen=2)
      
      # Check if rules were generated
      # If no rules are found, let the user know 
      if (length(rules) == 0) {
        return(data.frame(Message = "No rules found with the given parameters."))
      }
      
      # Convert rules to a data frame for display
      rules_df <- as(rules, "data.frame")
      
      # Optionally filter rules with lift > 1.2 for better insights
      rules_df <- rules_df[rules_df$lift > 1.2, ]
      
      rules_df
    })
  })
  
}
shinyApp(ui = ui, server = server)