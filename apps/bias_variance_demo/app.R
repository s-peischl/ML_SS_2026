library(shiny)

ui <- fluidPage(
  titlePanel("Bias-Variance Demo (Placeholder)"),
  p("TODO: Add interactive complexity control and train/validation curves.")
)

server <- function(input, output, session) {}

shinyApp(ui, server)
