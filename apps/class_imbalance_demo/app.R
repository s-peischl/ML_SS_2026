library(shiny)

ui <- fluidPage(
  titlePanel("Class Imbalance Demo (Placeholder)"),
  p("TODO: Add class prevalence and threshold controls with confusion matrix.")
)

server <- function(input, output, session) {}

shinyApp(ui, server)
