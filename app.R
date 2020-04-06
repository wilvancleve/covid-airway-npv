#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(ggplot2)

ui <- dashboardPage(
    dashboardHeader(title = "SARS-CoV-2 Airway Managenent NPV Calculator", titleWidth = 450),
    dashboardSidebar(sidebarMenu(
        menuItem("Simplified", tabName = "simple"),
        menuItem("Full Uncertainty", tabName = "complex"),
        menuItem("Explanation", tabName = "explanation")
    )),
    dashboardBody(
       withMathJax(),
       tabItems(
            # First tab content
            tabItem(tabName = "simple",
                    fluidRow(
                        box(
                            selectInput("prev",
                                        label="Prevalence of Disease in Asymptomatic Individuals:",
                                        choices = c("0.1 %" = 0.1,
                                                    "0.5 %" = 0.5,
                                                    "1%" = 1, 
                                                    "5%" = 5, 
                                                    "10%"=10,
                                                    "25%"=25,
                                                    "50%"=50),
                                        selected=1),
                            numericInput("sens", "Sensitivity of Test (%)", 65, min = 10, max = 99),
                            numericInput("spec", "Specificity of Test (%)", 99, min = 50, max = 99)
                        ),
                        box(
                              align = "center",
                              htmlOutput("npv"))
                    )
            ),
            
            # Second tab content
            tabItem(tabName = "complex",
                    fluidRow(
                        column(width = 4,
                               box(
                                   title = "Sensitivity Estimate", width = NULL, status = "primary",
                                   sliderInput("sens_shape1", label = '\\( \\alpha \\)', value=9, min = 1, max = 20),
                                   sliderInput("sens_shape2", label = '\\( \\beta \\)', value=5, min = 1, max = 10),
                                   plotOutput("sens_plot", height="180"),
                                   htmlOutput("sens_dist")
                               )
                        ),
                        
                        column(width = 4,
                               box(
                                  title = "Specificity Estimate", width = NULL, status = "primary",
                                  sliderInput("spec_shape1", label = '\\( \\alpha \\)', value=25, min = 1, max = 30),
                                  sliderInput("spec_shape2", label = '\\( \\beta \\)', value=0.5, min = 0, max = 5),
                                  plotOutput("spec_plot", height="180"),
                                  htmlOutput("spec_dist")
                               )
                        ),
                        
                        column(width = 4,
                               box(
                                  title = "Prevalence Estimate", width = NULL, status = "primary",
                                  sliderInput("prev_shape1", label = '\\( \\alpha \\)', value=1, min = 0.1, max = 5),
                                  sliderInput("prev_shape2", label = '\\( \\beta \\)', value=75, min = 50, max = 150),
                                  plotOutput("prev_plot", height="180"),
                                  htmlOutput("prev_dist")
                               )
                        )
                    ),
                    fluidRow( 
                        box(align = "center",
                            height=225,
                                   h4(strong("Negative Predictive Value")),
                                   htmlOutput("npv_uncertainty")
                        ),
                               box(align = "center",
                                   height=225,
                                   plotOutput("npv_uncertainty_plot", height=200)
                               )
                        )
                       
            ),
            tabItem(tabName = "explanation",
                    fluidRow(
                       column(width = 12,
                              h3("Formula for Negative Predictive Value (NPV%)"),
                              withMathJax("$$NPV\\% = \\frac{\\% \\; Spec * (100 - \\% \\; Prev)}{((100 - \\% \\; Sens) * \\% \\; Prev) + (\\% \\; Spec * (100 - \\% \\; Prev))}$$"),
                              includeMarkdown("explanation.md")
                       ),
               )
            )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
    
   output$npv <- renderText({
      npv <- 100*((input$spec * (100 - as.numeric(input$prev)))/(((100 - input$sens) * as.numeric(input$prev)) + ((input$spec) * (100 - as.numeric(input$prev)))))
      num <- 100 - npv
      mult <- 1 / num
      denom = round(100 * mult,0)
      output_prob <- ifelse(!is.finite(denom), "None", paste0("1 in ",denom))
      HTML(paste0("<h4><strong>Negative Predictive Value</strong></h4><h4>",round(npv,2),"%</h4><br>",
               "<h4><strong>Post-Test Probability of SARS-CoV2</strong></h4><h4> ", output_prob, "</h4>"))
   })
      
   output$sens_plot <- renderPlot({ par(mar = c(2, 1, 1, 1)); hist(rbeta(n = 2000, input$sens_shape1, input$sens_shape2), main = "", xlab="", yaxt='n')  }) 
   output$sens_dist <- renderText({ 
      q  = 100*round(quantile(rbeta(n = 2000, input$sens_shape1, input$sens_shape2), c(0.5,0.25,0.75)),3)
      HTML(paste0("<strong>Median: </strong>",q[1], "%<br><strong>IQR: </strong>",q[2], ' - ',q[3]))
   }) 
   
   output$spec_plot <- renderPlot({ par(mar = c(2, 1, 1, 1)); hist(rbeta(n = 2000, input$spec_shape1, input$spec_shape2), main = "", xlab="", yaxt='n')  }) 
   output$spec_dist <- renderText({ 
      q  = 100*round(quantile(rbeta(n = 2000, input$spec_shape1, input$spec_shape2), c(0.5,0.25,0.75)),3)
      HTML(paste0("<strong>Median: </strong>",q[1], "%<br><strong>IQR: </strong>",q[2], ' - ',q[3]))
   })
   
   output$prev_plot <- renderPlot({ par(mar = c(2, 1, 1, 1)); hist(rbeta(n = 2000, input$prev_shape1, input$prev_shape2), main = "", xlab="", yaxt='n')  }) 
   output$prev_dist <- renderText({ 
      q  = 100*round(quantile(rbeta(n = 2000, input$prev_shape1, input$prev_shape2), c(0.5,0.25,0.75)),3)
      HTML(paste0("<strong>Median: </strong>",q[1], "%<br><strong>IQR: </strong>",q[2], ' - ',q[3]))
   })
   
   output$npv_uncertainty <- renderText({
       
       sens <- rbeta(n = 2000, input$sens_shape1, input$sens_shape2)
       spec <- rbeta(n = 2000, input$spec_shape1, input$spec_shape2)
       prev <- rbeta(n = 2000, input$prev_shape1, input$prev_shape2)
       sens_sampl <- 100*sample(sens, 10000, replace=TRUE)
       spec_sampl <- 100*sample(spec, 10000, replace=TRUE)
       prev_sampl <- 100*sample(prev, 10000, replace=TRUE)
       npv_samples <- 100 * (spec_sampl * (100 - prev_sampl))/(((100 - sens_sampl) * prev_sampl) + ((spec_sampl) * (100 - prev_sampl)))
       m <- quantile(npv_samples, 0.5)
       quantiles <- quantile(npv_samples, c(0.05,0.5,0.95))
       
       num <- 100 - m
       mult <- 1 / num
       denom = round(100 * mult,0)
       print(quantiles)
       uncert.1 <- round(100 * (1/(100-quantiles[1])),0)
       uncert.2 <- round(100 * (1/(100-quantiles[3])),0)
       
       output_prob <- ifelse(!is.finite(denom), "None", paste0("1 in ",denom))
       
       str1 = paste0("<h4>", round(m,2), " [90% CI : ", round(quantiles[1],2), " - ", round(quantiles[3],2), "]</h4>")
       str2 = paste0("<h4><strong>Post-Test Probability of SARS-CoV-2</strong></h4><h4>1 in ", denom," [90% CI: ", uncert.1, " - ", uncert.2, "]</h4>")
       HTML(paste(str1, str2, sep = ''))
   })
 
   output$npv_uncertainty_plot <- renderPlot({
       
       sens <- rbeta(n = 2000, input$sens_shape1, input$sens_shape2)
       spec <- rbeta(n = 2000, input$spec_shape1, input$spec_shape2)
       prev <- rbeta(n = 2000, input$prev_shape1, input$prev_shape2)
       sens_sampl <- 100*sample(sens, 10000, replace=TRUE)
       spec_sampl <- 100*sample(spec, 10000, replace=TRUE)
       prev_sampl <- 100*sample(prev, 10000, replace=TRUE)
       npv_samples <- 100*(spec_sampl * (100 - prev_sampl))/(((100 - sens_sampl) * prev_sampl) + ((spec_sampl) * (100 - prev_sampl)))
       par(mar = c(2, 1, 1, 1))
       hist(npv_samples, main = "", xlab="", yaxt='n')
   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)
