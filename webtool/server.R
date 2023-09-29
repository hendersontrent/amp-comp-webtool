# Define server function

shinyServer <- function(input, output, session) {
  
  #------------ Low dim plot -----------
  
  output$low_dim_plot <- renderPlotly({
    
    #
    
  })
  
  #------------ Data matrix -----------
  
  output$data_matrix <- renderPlotly({
    
    #
    
  })
  
  #------------ Pairwise correlations -----------
  
  output$pw_corrs <- renderPlotly({
    
    #
    
  })
}