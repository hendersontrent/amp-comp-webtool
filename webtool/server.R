# Define server function

shinyServer <- function(input, output, session) {
  
  #------------ Low dim plot -----------
  
  output$low_dim_plot <- renderPlotly({
    
    feat_mat2 <- feat_mat %>%
      filter(id %in% input$low_dim_amps)
    
    feat_mat2 <- structure(list(feat_mat2), class = "feature_calculations") # For consistency with {theft}
    
    # Perform dimensionality reduction
    
    if(input$low_dim_method == "tSNE"){
      dr <- reduce_dimensions(feat_mat2,
                              norm_method = input$low_dim_norm,
                              unit_int = input$low_dim_unit,
                              low_dim_method = input$low_dim_method,
                              perplexity = input$low_dim_perplexity,
                              seed = 123)
    } else{
      dr <- reduce_dimensions(feat_mat2,
                              norm_method = input$low_dim_norm,
                              unit_int = input$low_dim_unit,
                              low_dim_method = input$low_dim_method,
                              seed = 123)
    }
    
    # Draw plot
    
    p <- plot(dr)
    return(p)
  })
  
  #------------ Pairwise correlations -----------
  
  output$pw_corrs <- renderPlotly({
    
    feat_mat2 <- feat_mat %>%
      filter(id %in% input$pw_corrs_amps)
    
    feat_mat2 <- structure(list(feat_mat2), class = "feature_calculations") # For consistency with {theft}
    
    # Draw plot
    
    p <- plot(feat_mat2, 
              type = "cor",
              clust_method = input$pw_corrs_cluster,
              cor_method = input$pw_corrs_cor)
    
    return(p)
  })
  
  #------------ Data matrix -----------
  
  output$data_matrix <- renderPlotly({
    
    feat_mat2 <- feat_mat %>%
      filter(id %in% input$data_matrix_amps)
    
    feat_mat2 <- structure(list(feat_mat2), class = "feature_calculations") # For consistency with {theft}
    
    # Draw plot
    
    p <- plot(feat_mat2, 
              type = "matrix",
              norm_method = input$data_matrix_norm,
              unit_int = input$data_matrix_unit,
              clust_method = input$data_matrix_cluster)
    
    return(p)
  })
}