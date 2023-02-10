library(shiny)
library(pheatmap)

# Define UI for application that draws a heatmap
ui <- fluidPage(
  titlePanel(
    title = h1(
      "MetaboHeatMap"
    ),
    windowTitle = "MetaboHeatMap by Karat Sidhu"
  ),
  # Add CSS stylesheet
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  tabsetPanel(
    tabPanel(
      h2("Instructions and Info"),
      h3("Instructions"),
      p("1. Go to the 'Data Input' tab."),
      p("2. Prepare and upload a CSV file."),
      p(
        "3. Choose appropriate settings for the heatmap (row method,
palette,
etc)."
      ),
      p("4. Set cutree rows and cutree columns sliders as desired (0 to 5)."),
      p("5. Press 'Get Heatmap' button."),
      p(
        "6. View the heatmap in the 'Heatmap' tab. To download the heatmap,
right click on the image and select 'Save Image As...' and save as a PNG file."
      ),
      p("7. Optional : View the data in the 'Data' tab."),
      tabPanel(
        h4("Data Input"),
        sidebarPanel(
          fileInput(
            "file",
            "Choose CSV File",
            accept = c(
              "text/csv",
              "text/comma-separated-values,text/plain",
              ".csv"
            )
          ),
          tags$hr(),
          checkboxInput(
            "header",
            "My Data Contains a Header",
            TRUE
          ),
          selectInput(
            "cluster_rows",
            "Cluster Rows",
            c(
              Yes = "TRUE",
              No = "FALSE"
            )
          ),
          selectInput(
            "row_method",
            "If Clustering Rows, Choose Clustering Method",
            c(
              correlation = "correlation",
              euclidean = "euclidean",
              maximum = "maximum",
              manhattan = "manhattan",
              canberra = "canberra",
              binary = "binary"
            )
          ),
          selectInput(
            "cluster_cols",
            "Cluster Columns",
            c(
              Yes = "TRUE",
              No = "FALSE"
            )
          ),
          selectInput(
            "col_method",
            "If Clustering Columns, Choose Clustering Method",
            c(
              correlation = "correlation",
              euclidean = "euclidean",
              maximum = "maximum",
              manhattan = "manhattan",
              canberra = "canberra",
              binary = "binary"
            )
          ),
          selectInput(
            "display_numbers",
            "Display Numbers inside Cells",
            c(
              Yes = "TRUE",
              No = "FALSE"
            )
          ),
          selectInput(
            "palette_start",
            "Palette Start",
            c(
              red = "red",
              green = "green",
              blue = "blue",
              yellow = "yellow",
              purple = "purple"
            )
          ),
          selectInput(
            "palette_end",
            "Palette End",
            c(
              red = "red",
              green = "green",
              blue = "blue",
              yellow = "yellow",
              purple = "purple"
            )
          ),
          selectInput(
            "palette_mid",
            "Palette Middle (optional)",
            c(
              None = "white",
              red = "red",
              green = "green",
              blue = "blue",
              yellow = "yellow",
              purple = "purple"
            )
          ),
          sliderInput(
            "cutree_rows",
            "Cutree Rows",
            min = 0,
            max = 10,
            value = 0,
            step = 1
          ),
          sliderInput(
            "cutree_cols",
            "Cutree Columns",
            min = 0,
            max = 10,
            value = 0,
            step = 1
          ),
          actionButton(
            "get_heatmap",
            "Generate Heatmap"
          )
        )
      )
    ),
    tabPanel(
      h2("Heatmap"),
      fluidRow(column(
        12,
        plotOutput("themap",
          width = "1000px",
          height = "1500px"
        ),
        downloadButton(outputId = "download", label = "Download Heatmap")
      ))
    ),
    tabPanel(
      h2("Data"),
      fluidRow(column(
        12,
        tableOutput("tbl")
      ))
    )
  )
)

server <- function(input, output, session) {
  df <- reactive({
    inFile <- input$file
    if (is.null(inFile)) {
      return(NULL)
    }
    tbl <- read.csv(inFile$datapath, header = input$header)
    return(tbl)
  })



  # Generate the table output

  output$tbl <- renderTable({
    df()
  })


  # Create a reactive expression to generate the heatmap data

  data <- eventReactive(input$get_heatmap, {
    mat <- as.matrix(df()[-1])
    row.names(mat) <- df()$compound
    mat[is.na(mat)] <- 0
    mat
  })


  # Code to generate the heatmap from the options selected
  output$themap <- renderPlot({
    pheatmap(
      data(),
      cluster_rows = as.logical(input$cluster_rows),
      cluster_cols = as.logical(input$cluster_cols),
      clustering_distance_rows = input$row_method,
      display_numbers = as.logical(input$display_numbers),
      number_color = "black",
      color = colorRampPalette(
        c(
          input$palette_start,
          input$palette_mid,
          input$palette_end
        )
      )(100),
      clustering_distance_cols = input$col_method,
      cutree_rows = ifelse(input$cutree_rows == 0, 1, input$cutree_rows + 1),
      cutree_cols = ifelse(input$cutree_cols == 0, 1, input$cutree_cols + 1),
      fontsize_row = 10,
      border_color = "black",
      border_width = 1
    )
  })


  # Download button code to save the heatmap as a PNG file
  output$download <- downloadHandler(
    filename = function() {
      paste0("meataboheatmap", Sys.Date(), ".png")
    },
    content = function(file) {
      # Save the plot as a PNG file
      png(file,
        width = 1500,
        height = 2000,
        units = "px"
      )

      # Generate the heatmap
      pheatmap(
        data(),
        cluster_rows = as.logical(input$cluster_rows),
        cluster_cols = as.logical(input$cluster_cols),
        clustering_distance_rows = input$row_method,
        display_numbers = as.logical(input$display_numbers),
        number_color = "black",
        color = colorRampPalette(
          c(
            input$palette_start,
            input$palette_mid,
            input$palette_end
          )
        )(100),
        clustering_distance_cols = input$col_method,
        cutree_rows = ifelse(input$cutree_rows == 0, 1, input$cutree_rows + 1),
        cutree_cols = ifelse(input$cutree_cols == 0, 1, input$cutree_cols + 1),
        fontsize_row = 10,
        border_color = "black",
        border_width = 1
      )

      # Close the PNG file
      dev.off()
    }
  )
}


# Run the application
shinyApp(ui, server)
