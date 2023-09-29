
# Define UI for web application

shinyUI(navbarPage(theme = "corp-styles.css", 
                   title = div(img(src = "waveform.png", height = '30px', hspace = '30'),
                               ""),
                   position = c("static-top"), windowTitle = "Guitar VST Comparison Tool",
                   id = "page_tab",
                   
                   #------------------ Low dimensional projection -----------------
                   
                   tabPanel(navtab0,
                            tags$head(
                              tags$link(rel = "stylesheet", type = "text/css", href = "corp-styles.css")
                            ),
                            
                            sidebarLayout(
                              sidebarPanel(
                                h1("Low dimensional projection control"),
                                p("This page")
                              ),
                              
                              mainPanel(
                                shinycssloaders::withSpinner(plotlyOutput("low_dim_plot", height = "600px"))
                              )
                            )
                   ),
                   
                   #------------------ Data matrix -----------------
                   
                   tabPanel(navtab1,
                            
                            sidebarLayout(
                              sidebarPanel(
                                h1("Data matrix visualisation control"),
                                p("This page")
                              ),
                              
                              mainPanel(
                                shinycssloaders::withSpinner(plotlyOutput("data_matrix", height = "600px"))
                              )
                            )
                   ),
                   
                   #------------------ Pairwise correlations -----------------
                   
                   tabPanel(navtab2,
                            
                            sidebarLayout(
                              sidebarPanel(
                                h1("Pairwise correlation matrix control"),
                                p("This page")
                              ),
                              
                              mainPanel(
                                shinycssloaders::withSpinner(plotlyOutput("pw_corrs", height = "600px"))
                              )
                            )
                   ),
                   
                   #------------------ About page ----------------
                   
                   tabPanel(navtab3,
                            includeMarkdown("./md/about.Rmd")
                   ),
                   
                   #------------------ Footer ----------------
                   
                   fluidRow(style = "height: 50px;"),
                   fluidRow(style = "height: 50px; color: white; background-color: #003f5c; text-align: center;line-height: 50px;", HTML(footer)),
                   fluidRow(style = "height: 50px;")
  )
)