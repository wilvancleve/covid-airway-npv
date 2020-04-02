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
    dashboardHeader(title = "COVID-19 NPV"),
    dashboardSidebar(sidebarMenu(
        menuItem("Simplified", tabName = "simple"),
        menuItem("Full Uncertainty", tabName = "complex"),
        menuItem("Explanation", tabName = "explanation")
    )),
    dashboardBody(
        tabItems(
            # First tab content
            tabItem(tabName = "simple",
                    fluidRow(
                        box(
                            title = "Inputs",
                            selectInput("prev",
                                        label="Prevalence of Disease in Asymptomatic Individuals:",
                                        choices = c("0.1 %" = 0.1,
                                                    "0.5 %" = 0.5,
                                                    "1%" = 1, 
                                                    "5%" = 5, 
                                                    "10%"=10,
                                                    "25%"=25,
                                                    "50%"=50),
                                        selected=0.005),
                            numericInput("sens", "Sensitivity of Test (%)", 60, min = 10, max = 99),
                            numericInput("spec", "Specificity of Test (%)", 99, min = 50, max = 99)
                        ),
                        box(align = "center",
                            h3("Negative Predictive Value"),
                            htmlOutput("npv"))
                    )
            ),
            
            # Second tab content
            tabItem(tabName = "complex",
                    fluidRow(
                        column(width = 4,
                               box(
                                   title = "Sensitivity Estimate", width = NULL, status = "primary",
                                   sliderInput("sens_shape1", "Beta Shape 1", value=15, min = 1, max = 20),
                                   sliderInput("sens_shape2", "Beta Shape 2", value=5, min = 1, max = 10),
                                   plotOutput("sens_plot", height="180"),
                                   htmlOutput("sens_dist")
                               )
                        ),
                        
                        column(width = 4,
                               box(
                                  title = "Specificity Estimate", width = NULL, status = "primary",
                                  sliderInput("spec_shape1", "Beta Shape 1", value=25, min = 1, max = 30),
                                  sliderInput("spec_shape2", "Beta Shape 2", value=0.5, min = 0, max = 5),
                                  plotOutput("spec_plot", height="180"),
                                  htmlOutput("spec_dist")
                               )
                        ),
                        
                        column(width = 4,
                               box(
                                  title = "Prevalence Estimate", width = NULL, status = "primary",
                                  sliderInput("prev_shape1", "Beta Shape 1", value=0.5, min = 1, max = 5),
                                  sliderInput("prev_shape2", "Beta Shape 2", value=100, min = 50, max = 150),
                                  plotOutput("prev_plot", height="180"),
                                  htmlOutput("prev_dist")
                               )
                        )
                    ),
                    fluidRow( 
                        box(align = "center",
                                   h4(strong("Negative Predictive Value")),
                                   htmlOutput("npv_uncertainty")
                        ),
                               box(align = "center",
                                   plotOutput("npv_uncertainty_plot", height=200)
                               )
                        )
                       
            ),
            tabItem(tabName = "explanation",
                    h4("NPV"),
                    withMathJax(helpText("$$NPV = \\frac{Specificity * (100 - Prevalence))}{(((100 - Sensitivity) * Prevalence) + ((Specificity) * (100 - Prevalence)))}$$")),
                    h4("SUMMARY"), 
                    print("Based on the performance of UW’s RT-PCR test and current prevalence estimates of COVID 19 in the Seattle Metro area, \
   this 'app' explains why it is reasonable to use droplet (rather than airborne) precautions when intubating a patient \
   with a recent negative COVID-19 test."),
                    h4("COVID-19 LAB TEST"), 
                    p("First, the analytic sensitivity and specificity of the UW COVID RT-PCR test when a sample has virus (>499 RNA copies/ml) is excellent—> \
   99% sensitivity and specificity according to package insert. \
   These performance characteristics are obtained when an adequate sample is taken."),
                    p("One clinical report from JAMA has found that \
   the 'clinical sensitivity' which accounts for when a poor sample might be obtained—of nasal swabs to be 63%. \
   (source: Detection of SARS-CoV-2 in Different Types of Clinical Specimens, https://jamanetwork.com/journals/jama/fullarticle/2762997)"),
                    p("Given UW's strict nasal sampling protocol, and the lab’s lack of discordance between initial and follow up test results to date \
   the clinical sensitivity of samples taken at UW Medicine is almost certainly much higher. \
   Nevertheless, the default of this calculator is to use the “worst case scenario” 'clinical sensitivity’ observed in the JAMA paper."),
                    h4("COVID IN SEATTLE - USED TO GENERATE NEGATIVE PREDICTIVE VALUE (NPV)"), 
                    p(" To have high confidence in the COVID test result, it is necessary to understand the negative predictive value: \
   i.e., probability that the disease is not present when the test is negative. \
   NPV is separate from the intrinsic test performance and requires knowledge of the prevalence of COVID-19 in our community."),
                    p("This enables us to answer how probable it is that our patient who tested COVID negative is truly free of disease. \
   You can estimate what the community prevalence is based on local hospitalization rates for COVID and prior knowledge \
   about how frequently hospitalization occurred in places (e.g. Wuhan) in  which COVID was widespread and testing was as well."),
                    p(strong("Our rough estimate of current population prevalence in Washington state is 0.6% (UI: 0.41% - 0.82%) but this estimate is for all individuals, the majority of whom are symptomatic.")),
                    p("We do not know with certainly the Seattle Metro prevalence of COVID-19; \
   The process is currently underway through the Greater Seattle Coronavirus Assessment Network SCAN study."),
                    h4("CONCLUSION"), 
                    print("In the Seattle area, based on current estimates of prevalence, \
   the chance of a false negative is < 0.5%, making use of standard (i.e., not airborne) \
   precautions reasonable when doing an aerosol generating procedure on a recently tested COVID (-) patient.")
                    
            )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
    
   output$npv <- renderText({
      npv <- sort(100*round((input$spec * (100 - as.numeric(input$prev)))/(((100 - input$sens) * as.numeric(input$prev)) + ((input$spec) * (100 - as.numeric(input$prev)))),3))
      num <- 100 - npv
      mult <- 1 / num
      denom = round(100 * mult,1)
      HTML(paste0("<h3>",paste(npv,  collapse=" - "),"%<br>or<br><strong>1 in ", denom, " with SARS-CoV2"),"</strong></h3>")
   })
      
   output$sens_plot <- renderPlot({ hist(rbeta(n = 2000, input$sens_shape1, input$sens_shape2), main = "", xlab="")  }) 
   output$sens_dist <- renderText({ 
      q  = 100*round(quantile(rbeta(n = 2000, input$sens_shape1, input$sens_shape2), c(0.5,0.25,0.75)),3)
      HTML(paste0("<strong>Median: </strong>",q[1], "%<br><strong>IQR: </strong>",q[2], ' - ',q[3]))
   }) 
   
   output$spec_plot <- renderPlot({ hist(rbeta(n = 2000, input$spec_shape1, input$spec_shape2), main = "", xlab="")  }) 
   output$spec_dist <- renderText({ 
      q  = 100*round(quantile(rbeta(n = 2000, input$spec_shape1, input$spec_shape2), c(0.5,0.25,0.75)),3)
      HTML(paste0("<strong>Median: </strong>",q[1], "%<br><strong>IQR: </strong>",q[2], ' - ',q[3]))
   })
   
   output$prev_plot <- renderPlot({ hist(rbeta(n = 2000, input$prev_shape1, input$prev_shape2), main = "", xlab="")  }) 
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
       m <- round(quantile(npv_samples, 0.5), 1)
       quantiles <- round(quantile(npv_samples, c(0.05,0.5,0.95)),1)
       
       num <- 100 - m
       mult <- 1 / num
       denom = round(100 * mult,1)
       
       
       str1 = paste0("<h4>", m, " [90% CI : ", quantiles[1], " - ", quantiles[3], "]</h4>")
       str2 = paste0("<h3><strong>1 in ", denom," with SARS-CoV2</strong></h3>")
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
       qplot(npv_samples, geom="density", ylab="", xlab="")
   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)
