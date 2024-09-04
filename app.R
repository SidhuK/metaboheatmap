library(shiny)
library(pheatmap)
library(RColorBrewer)
library(viridis)

# Define UI for application that draws a heatmap
ui <- fluidPage(
  titlePanel(
    title = div(h3(
      "MetaboHeatMap"
    ), h5("A R/Shiny based app for visualizing metabolomics data through heatmaps")),
    windowTitle = "MetaboHeatMap"
  ),
  # Add CSS stylesheet
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  sidebarPanel(
    h3("Data Input"),
    fileInput(
      "file",
      "Choose CSV File",
      accept = c(
        "text/csv",
        "text/comma-separated-values,text/plain",
        ".csv"
      )
    ),
    h3("Heatmap Settings"),
    tags$hr(),
    checkboxInput(
      "header",
      "My Data Contains a Header",
      TRUE
    ),
    h4("Clustering Settings"),
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
    h4("Cells and Colors"),
    selectInput(
      "display_numbers",
      "Display Numbers inside Cells",
      c(
        Yes = "TRUE",
        No = "FALSE"
      )
    ),
    h4("Slice Rows and Columns"),
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
    numericInput("filter_threshold", "Filter threshold (absolute value)", value = 0, min = 0),
    selectInput("normalization", "Data Normalization",
                choices = c("None" = "none", "Z-score" = "zscore", "Min-Max" = "minmax")),
    sliderInput("font_size", "Font Size", min = 6, max = 20, value = 10),
    selectInput("color_scheme", "Color Scheme",
                choices = c("Red-White-Blue" = "RdBu",
                            "Red-Yellow-Green" = "RdYlGn",
                            "Purple-Orange" = "PuOr",
                            "Viridis" = "viridis",
                            "Magma" = "magma")),
    selectInput("font_color", "Font Color",
                choices = c("Black" = "black", "White" = "white", "Red" = "red", "Blue" = "blue")),
    actionButton(
      "get_heatmap",
      "Generate Heatmap",
      class = "btn btn-primary btn-block"
    )
  ),
  mainPanel(
    tabsetPanel(
      tabPanel(
        h2("Instructions"),
        h2("Instructions"),
        h3("About"),
        p(
          "The MetaboHeatmap application provides an elegant solution for visualizing
           small to medium sized metabolomics output data by presenting a heatmap generated from a user-supplied CSV file.
            The input data must adhere to specific formatting requirements, with a header
            row and the first column reserved for compound names. The heatmap is generated
             using the highly customizable 'pheatmap' library in R, enabling the user to tinker with the
              output through the available sidebar options."
        ),
        p("Once generated, the heatmap can be easily saved to a PNG file by right-clicking on the image and selecting
      'Save Image As...' or by utilizing the convenient 'Download Heatmap' button within the 'Heatmap' tab.
      The user-supplied data can be viewed in its raw form in the 'Data' tab for added transparency."),
        p("The MetaboHeatmap app is hosted on both shinyapps.io and GitHub,
       providing access through a web-based platform or by downloading and
       running the app locally through RStudio/VSCode or IDE of your choice. The application can be accessed on
       shinyapps.io at https://karatsidhu.shinyapps.io/metaboheatmap/ and on
       GitHub at https://github.com/sidhuk/metaboheatmap/."),
        h3("Useful Links"),
        helpText(a("ShinyApps", href = "https://karat.shinyapps.io/metaboheatmap/", target = "_blank")),
        helpText(a("GitHub Repository", href = "https://github.com/sidhuk/metaboheatmap/", target = "_blank")),
        helpText(a("Sample Data", href = "https://github.com/SidhuK/metaboheatmap/blob/main/metabolites.csv", target = "_blank")),
        h3("Steps to Generate Heatmap"),
        p("1. Navigate to the 'Data Input' area on the left."),
        p("2. Prepare the csv file in acceptable format and click upload."),
        p(
          "3. Choose appropriate settings for the heatmap (clustering method, color
palette,
etc)."
        ),
        p("4. Set cutree rows and cutree columns sliders as desired."),
        p("5. Press 'Get Heatmap' button. Depending on the size of CSV file, this can take from a few seconds to a few minutes."),
        p(
          "6. View the heatmap in the 'Heatmap' tab. To download the heatmap,
right click on the image and select 'Save Image As...' and save as a PNG file. Alternatively, you can use the 'Download Heatmap' button in the 'Heatmap' tab on the bottom of the page."
        ),
        p("7. Optional : View the data in the 'Data' tab to ensure that the data was processed correctly."),
        p("You can make changes to the heatmap after it has been generated by changing the settings in the sidebar and pressing 'Get Heatmap' again, as long as the data is still uploaded.
      Keep in mind that the heatmap will be regenerated from scratch each time the 'Get Heatmap' button is pressed, so if you are making multiple changes to the heatmap,
       it will take the same amount of time to generate the new heatmap.")
      ),
      tabPanel(
        h2("Heatmap"),
        fluidRow(column(
          8,
          plotOutput("themap",
            width = "1000px",
            height = "1500px"
          ),
          downloadButton(outputId = "download", label = "Download Heatmap", class = "btn btn-primary btn-block")
        ))
      ),
      tabPanel(
        h2("Data Table"),
        fluidRow(column(
          8,
          tableOutput("tbl")
        ))
      )
    )
  ),
  tags$footer(HTML("<footer class='page-footer'> © 2023 Copyright:
                           <a href='https://github.com/SidhuK'> Karat Sidhu</a>
                           </footer>"))
)

server <- function(input, output, session) {
  df <- reactive({
    inFile <- input$file
    if (is.null(inFile)) return(NULL)
    tbl <- read.csv(inFile$datapath, header = input$header)
    
    # Data Filtering
    if (input$filter_threshold > 0) {
      tbl <- tbl[rowSums(abs(tbl[,-1]) >= input$filter_threshold) > 0, ]
    }
    
    # Data Normalization
    if (input$normalization != "none") {
      normalize <- function(x) {
        if (input$normalization == "zscore") {
          return((x - mean(x)) / sd(x))
        } else if (input$normalization == "minmax") {
          return((x - min(x)) / (max(x) - min(x)))
        }
      }
      tbl[,-1] <- apply(tbl[,-1], 2, normalize)
    }
    
    return(tbl)
  })

  output$tbl <- renderTable({ df() })

  data <- eventReactive(input$get_heatmap, {
    mat <- as.matrix(df()[-1])
    row.names(mat) <- df()$compound
    mat[is.na(mat)] <- 0
    mat
  })

  output$themap <- renderPlot({
    req(data())
    
    # Color scheme
    if (input$color_scheme %in% c("viridis", "magma")) {
      color_func <- get(input$color_scheme)
      colors <- color_func(100)
    } else {
      colors <- colorRampPalette(rev(brewer.pal(n = 7, name = input$color_scheme)))(100)
    }
    
    pheatmap(
      data(),
      cluster_rows = as.logical(input$cluster_rows),
      cluster_cols = as.logical(input$cluster_cols),
      clustering_distance_rows = input$row_method,
      clustering_distance_cols = input$col_method,
      cutree_rows = ifelse(input$cutree_rows == 0, 1, input$cutree_rows + 1),
      cutree_cols = ifelse(input$cutree_cols == 0, 1, input$cutree_cols + 1),
      display_numbers = as.logical(input$display_numbers),
      number_color = input$font_color,
      fontsize = input$font_size,
      fontsize_number = input$font_size,
      color = colors,
      border_color = "black",
      main = "Metabolomics Heatmap"
    )
  })

  output$download <- downloadHandler(
    filename = function() { paste0("metaboheatmap_", Sys.Date(), ".png") },
    content = function(file) {
      png(file, width = 1500, height = 2000, units = "px", res = 300)
      print(output$themap())
      dev.off()
    }
  )
}


# Run the application
shinyApp(ui, server)
