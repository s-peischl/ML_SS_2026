library(shiny)

ui <- fluidPage(
  titlePanel("Metrics and Threshold Demo (Placeholder)"),
  p("TODO: Add threshold slider and live precision/recall/F1 updates.")
)

server <- function(input, output, session) {}

shinyApp(ui, server)
