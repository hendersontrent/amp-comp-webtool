
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
                                p("This page XXXX"),
                                radioButtons("low_dim_norm", "What rescaling/normalisation method would you like to use?",
                                             choices = rescalers, selected = rescalers[1], inline = FALSE),
                                radioButtons("low_dim_unit", "Would you like to rescale to the unit interval after applying the above method?",
                                             choices = boolean, selected = boolean[1], inline = TRUE),
                                radioButtons("low_dim_method", "What dimensionality reduction method would you like to use?",
                                             choices = dim_reds, selected = dim_reds[1], inline = FALSE),
                                pickerInput("low_dim_amps", "What VSTs do you want to include in the analysis?", choices = amplifiers, 
                                            selected = amplifiers, options = list(`actions-box` = TRUE), multiple = TRUE),
                                
                                conditionalPanel(
                                  condition = "input.low_dim_norm == 'tSNE'",
                                  sliderInput("low_dim_perplexity", "Perplexity hyperparameter",
                                              min = 2, max = 100, value = 10),
                                )
                              ),
                              
                              mainPanel(
                                shinycssloaders::withSpinner(plotlyOutput("low_dim_plot", height = "800px"))
                              )
                            )
                   ),
                   
                   #------------------ Data matrix -----------------
                   
                   tabPanel(navtab1,
                            
                            sidebarLayout(
                              sidebarPanel(
                                h1("Data matrix visualisation control"),
                                p("This page XXXX"),
                                radioButtons("data_matrix_norm", "What rescaling/normalisation method would you like to use?",
                                             choices = rescalers, selected = rescalers[1], inline = FALSE),
                                radioButtons("data_matrix_unit", "Would you like to rescale to the unit interval after applying the above method?",
                                             choices = boolean, selected = boolean[1], inline = TRUE),
                                radioButtons("data_matrix_cluster", "What clustering method would you like to use to organise the matrix?",
                                             choices = clusters, selected = clusters[1], inline = FALSE),
                                pickerInput("data_matrix_amps", "What VSTs do you want to include in the analysis?", choices = amplifiers, 
                                            selected = amplifiers, options = list(`actions-box` = TRUE), multiple = TRUE),
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
                                p("This page XXXX"),
                                radioButtons("pw_corrs_norm", "What rescaling/normalisation method would you like to use?",
                                             choices = rescalers, selected = rescalers[1], inline = FALSE),
                                radioButtons("pw_corrs_unit", "Would you like to rescale to the unit interval after applying the above method?",
                                             choices = boolean, selected = boolean[1], inline = TRUE),
                                radioButtons("pw_corrs_cluster", "What clustering method would you like to use to organise the matrix?",
                                             choices = clusters, selected = clusters[1], inline = FALSE),
                                radioButtons("pw_corrs_cor", "What correlation method would you like to use?",
                                             choices = cors, selected = cors[1], inline = TRUE),
                                pickerInput("pw_corrs_amps", "What VSTs do you want to include in the analysis?", choices = amplifiers, 
                                            selected = amplifiers, options = list(`actions-box` = TRUE), multiple = TRUE),
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
                   fluidRow(style = "height: 50px; color: white; background-color: #084C61; text-align: center;line-height: 50px;", HTML(footer)),
                   fluidRow(style = "height: 50px;")
  )
)