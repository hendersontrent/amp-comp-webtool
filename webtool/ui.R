
# Define UI for web application

shinyUI(navbarPage(theme = "corp-styles.css", 
                   title = div(img(src = "waveform.png", height = '30px', hspace = '30'),
                               ""),
                   position = c("static-top"), windowTitle = "Guitar VST Comparison Tool",
                   id = "page_tab",
                   
                   #------------------ Pairwise correlations -----------------
                   
                   tabPanel(navtab0,
                            tags$head(
                              tags$link(rel = "stylesheet", type = "text/css", href = "corp-styles.css")
                            ),
                            
                            sidebarLayout(
                              sidebarPanel(
                                h1("Pairwise correlation matrix control"),
                                p("This page visualises pairwise correlations between the VST heads based on their feature vectors rather than the raw time-domain space (which in the case of a 20Hz-20kHz sine sweep is very large).."),
                                radioButtons("pw_corrs_cluster", "What clustering method would you like to use to organise the matrix?",
                                             choices = clusters, selected = clusters[1], inline = FALSE),
                                radioButtons("pw_corrs_cor", "What correlation method would you like to use?",
                                             choices = cors, selected = cors[1], inline = TRUE),
                                pickerInput("pw_corrs_amps", "What VSTs do you want to include in the analysis?", choices = amplifiers, 
                                            selected = amplifiers, options = list(`actions-box` = TRUE), multiple = TRUE),
                              ),
                              
                              mainPanel(
                                shinycssloaders::withSpinner(plotlyOutput("pw_corrs", height = "850px"))
                              )
                            )
                            
                   ),
                   
                   #------------------ Low dimensional projection -----------------
                   
                   tabPanel(navtab1,
                            
                            sidebarLayout(
                              sidebarPanel(
                                h1("Low dimensional projection control"),
                                p("This page presents a graphical summary of how different VST heads are related to each other based on their time-series feature values, but in a two-dimensional space (instead of the 542-dimensional space of all calculated features). This makes visualisation as a scatterplot in terms of the two most important dimensions a useful tool for obtaining an understanding about the VSTs."),
                                radioButtons("low_dim_norm", "What rescaling/normalisation method would you like to use?",
                                             choices = rescalers, selected = rescalers[1], inline = FALSE),
                                radioButtons("low_dim_unit", "Would you like to rescale to the unit interval after applying the above method?",
                                             choices = boolean, selected = boolean[1], inline = TRUE),
                                radioButtons("low_dim_method", "What dimensionality reduction method would you like to use?",
                                             choices = dim_reds, selected = dim_reds[2], inline = FALSE),
                                pickerInput("low_dim_amps", "What VSTs do you want to include in the analysis?", choices = amplifiers, 
                                            selected = amplifiers, options = list(`actions-box` = TRUE), multiple = TRUE),
                                
                                conditionalPanel(
                                  condition = "input.low_dim_method == 'tSNE'",
                                  sliderInput("low_dim_perplexity", "Perplexity hyperparameter",
                                              min = 2, max = 23, value = 10),
                                )
                              ),
                              
                              mainPanel(
                                shinycssloaders::withSpinner(plotlyOutput("low_dim_plot", height = "850px"))
                              )
                            )
                   ),
                   
                   #------------------ Data matrix -----------------
                   
                   tabPanel(navtab2,
                            
                            sidebarLayout(
                              sidebarPanel(
                                h1("Data matrix visualisation control"),
                                p("This page visualises the time series x feature matrix calculated for the set of VST heads. This visualisation is useful as it can pull out empirical structure from data to assist in the ability to derive inferences regarding how the amplitude waveforms for each VST head might be similar or not."),
                                radioButtons("data_matrix_norm", "What rescaling/normalisation method would you like to use?",
                                             choices = rescalers, selected = rescalers[3], inline = FALSE),
                                radioButtons("data_matrix_unit", "Would you like to rescale to the unit interval after applying the above method?",
                                             choices = boolean, selected = boolean[2], inline = TRUE),
                                radioButtons("data_matrix_cluster", "What clustering method would you like to use to organise the matrix?",
                                             choices = clusters, selected = clusters[1], inline = FALSE),
                                pickerInput("data_matrix_amps", "What VSTs do you want to include in the analysis?", choices = amplifiers, 
                                            selected = amplifiers, options = list(`actions-box` = TRUE), multiple = TRUE),
                              ),
                              
                              mainPanel(
                                shinycssloaders::withSpinner(plotlyOutput("data_matrix", height = "850px"))
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