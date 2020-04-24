#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# new change
library(shiny)
library(shinydashboard)
library(shinylogs)
library(ggplot2)
library(RSQLite)
library(mc2d)
library(markdown)

ui <- dashboardPage(
    dashboardHeader(title = "Global Cases", titleWidth = 450),
    dashboardSidebar(),
    dashboardBody()
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   
}

# Run the application 
shinyApp(ui = ui, server = server)
