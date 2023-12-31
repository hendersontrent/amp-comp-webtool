#------------ Data matrix and pairwise correlation matrix plots from {theft} - https://github.com/hendersontrent/theft ------------

#' Produce a plot for a feature_calculations object
#' 
#' @importFrom rlang .data
#' @import dplyr
#' @import ggplot2
#' @import tibble
#' @importFrom tidyr pivot_wider pivot_longer drop_na
#' @importFrom reshape2 melt
#' @importFrom stats hclust dist cor
#' @param x the \code{feature_calculations} object containing the raw feature matrix produced by \code{calculate_features}
#' @param type \code{character} specifying the type of plot to draw. Defaults to \code{"quality"}
#' @param norm_method \code{character} specifying a rescaling/normalising method to apply if \code{type = "matrix"} or if \code{type = "cor"}. Can be one of \code{"z-score"}, \code{"Sigmoid"}, \code{"RobustSigmoid"}, or \code{"MinMax"}. Defaults to \code{"z-score"}
#' @param unit_int \code{Boolean} whether to rescale into unit interval \code{[0,1]} after applying normalisation method. Defaults to \code{FALSE}
#' @param clust_method \code{character} specifying the hierarchical clustering method to use if \code{type = "matrix"} or if \code{type = "cor"}. Defaults to \code{"average"}
#' @param cor_method \code{character} specifying the correlation method to use if \code{type = "cor"}. Defaults to \code{"pearson"}
#' @param feature_names \code{character} vector denoting the name of the features to plot if \code{type = "violin"}. Defaults to \code{NULL}
#' @param ... Arguments to be passed to \code{ggplot2::geom_bar} if \code{type = "quality"}, \code{ggplot2::geom_raster} if \code{type = "matrix"}, \code{ggplot2::geom_raster} if \code{type = "cor"}, or \code{ggplot2::geom_point} if \code{type = "violin"}
#' @return object of class \code{ggplotly} that contains the graphic
#' @author Trent Henderson
#' 

plot.feature_calculations <- function(x, type = c("quality", "matrix", "cor", "violin"), 
                                      norm_method = c("zScore", "Sigmoid", "RobustSigmoid", "MinMax"),
                                      unit_int = FALSE,
                                      clust_method = c("average", "ward.D", "ward.D2", "single", "complete", "mcquitty", "median", "centroid"),
                                      cor_method = c("pearson", "spearman"), feature_names = NULL, ...){
  
  stopifnot(inherits(x, "feature_calculations") == TRUE)
  type <- match.arg(type)
  norm_method <- match.arg(norm_method)
  clust_method <- match.arg(clust_method)
  cor_method <- match.arg(cor_method)
  
  if(type == "quality"){
    
    #--------------- Calculate proportions ------------
    
    tmp <- x[[1]] %>%
      dplyr::mutate(quality = dplyr::case_when(
        is.na(.data$values)                               ~ "NaN",
        is.nan(.data$values)                              ~ "NaN",
        is.infinite(.data$values)                         ~ "-Inf or Inf",
        is.numeric(.data$values) & !is.na(.data$values) &
          !is.na(.data$values) & !is.nan(.data$values)    ~ "Good")) %>%
      dplyr::group_by(.data$names, .data$quality) %>%
      dplyr::summarise(counter = dplyr::n()) %>%
      dplyr::group_by(.data$names) %>%
      dplyr::mutate(props = .data$counter / sum(.data$counter)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(quality = factor(.data$quality, levels = c("-Inf or Inf", "NaN", "Good")))
    
    # Calculate order of 'good' quality feature vectors to visually steer plot
    
    ordering <- tmp %>%
      dplyr::filter(.data$quality == "Good") %>%
      dplyr::mutate(ranker = dplyr::dense_rank(.data$props)) %>%
      dplyr::select(c(.data$names, .data$ranker))
    
    # Join back in
    
    tmp <- tmp %>%
      dplyr::left_join(ordering, by = c("names" = "names"))
    
    #--------------- Draw plot ------------------------
    
    # Define a nice colour palette consistent with RColorBrewer in other functions
    
    my_palette <- c("-Inf or Inf" = "#7570B3",
                    "NaN" = "#D95F02",
                    "Good" = "#1B9E77")
    
    # Plot
    
    p <- tmp %>%
      ggplot2::ggplot(ggplot2::aes(x = stats::reorder(.data$names, -.data$ranker), y = .data$props)) +
      ggplot2::geom_bar(stat = "identity", ggplot2::aes(fill = .data$quality), ...) +
      ggplot2::labs(x = "Feature",
                    y = "Proportion of Outputs",
                    fill = "Data Type") +
      ggplot2::scale_y_continuous(limits = c(0,1),
                                  breaks = seq(from = 0, to = 1, by = 0.1)) +
      ggplot2::scale_fill_manual(values = my_palette) +
      ggplot2::theme_bw() +
      ggplot2::theme(panel.grid = ggplot2::element_blank(),
                     legend.position = "bottom")
    
    if(length(unique(tmp$names)) > 22){
      p <- p + 
        ggplot2::theme(axis.text.x = ggplot2::element_blank())
    } else{
      p <- p + 
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
    }
  } else if(type == "matrix"){
    
    #------------- Apply normalisation -------------
    
    data_id <- x[[1]] %>%
      dplyr::select(c(.data$id, .data$names, .data$values, .data$feature_set)) %>%
      tidyr::drop_na() %>%
      dplyr::mutate(names = paste0(.data$feature_set, "_", .data$names)) %>% # Catches errors when using all features across sets (i.e., there's duplicates)
      dplyr::select(-c(.data$feature_set)) %>%
      dplyr::group_by(.data$names) %>%
      dplyr::mutate(values = normalise(.data$values, norm_method = norm_method, unit_int = unit_int)) %>%
      dplyr::ungroup()
    
    #------------- Hierarchical clustering ----------
    
    dat <- data_id %>%
      tidyr::pivot_wider(id_cols = "id", names_from = "names", values_from = "values") %>%
      tibble::column_to_rownames(var = "id")
    
    # Remove any columns with >50% NAs to prevent masses of rows getting dropped due to poor features
    
    dat_filtered <- dat[, which(colMeans(!is.na(dat)) > 0.5)]
    
    # Drop any remaining rows with NAs
    
    dat_filtered <- dat_filtered %>%
      tidyr::drop_na()
    
    row.order <- stats::hclust(stats::dist(dat_filtered, method = "euclidean"), method = clust_method)$order # Hierarchical cluster on rows
    col.order <- stats::hclust(stats::dist(t(dat_filtered), method = "euclidean"), method = clust_method)$order # Hierarchical cluster on columns
    dat_new <- dat_filtered[row.order, col.order] # Re-order matrix by cluster outputs
    
    cluster_out <- reshape2::melt(as.matrix(dat_new)) %>% # Turn into dataframe
      dplyr::rename(id = .data$Var1,
                    names = .data$Var2)
    
    #------------- Draw graphic ---------------------
    
    # Define a nice colour palette consistent with RColorBrewer in other functions
    
    mypalette <- c("#B2182B", "#D6604D", "#F4A582", "#FDDBC7", "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC")
    
    p <- cluster_out %>%
      ggplot2::ggplot(ggplot2::aes(x = .data$names, y = .data$id, fill = .data$value,
                                   text = paste('<b>VST head:</b>', id,
                                                '<br><b>Feature:</b>', names,
                                                '<br><b>Value:</b>', round(value, digits = 2))))  +
      ggplot2::geom_raster(...) +
      ggplot2::scale_fill_stepsn(n.breaks = 6, colours = rev(mypalette),
                                 show.limits = TRUE) +
      ggplot2::labs(x = "Feature",
                    y = "VST head",
                    fill = "Scaled value") +
      ggplot2::theme_bw() + 
      ggplot2::theme(axis.text.x = ggplot2::element_blank(),
                     legend.position = "bottom",
                     panel.background = ggplot2::element_rect(fill = 'transparent'),
                     plot.background = ggplot2::element_rect(fill = 'transparent', color = NA),
                     panel.grid.minor = ggplot2::element_blank(),
                     legend.background = ggplot2::element_rect(fill = 'transparent'),
                     legend.box.background = ggplot2::element_rect(fill = 'transparent'))
    
  } else if(type == "cor") {
    
    #------------- Clean up structure --------------
    
    data_id <- x[[1]] %>%
      dplyr::select(c(.data$id, .data$names, .data$values)) %>%
      tidyr::drop_na() %>% 
      tidyr::pivot_wider(id_cols = "names", names_from = "id", values_from = "values") %>%
      dplyr::select(-c(.data$names)) %>%
      dplyr::select_if(~sum(!is.na(.)) > 0) %>%
      dplyr::select(where(~dplyr::n_distinct(.) > 1)) # Delete features that are all NaNs and features with constant values
    
    #--------- Correlation ----------
    
    # Calculate correlations and take absolute
    
    result <- abs(stats::cor(data_id, method = cor_method))
    
    #--------- Clustering -----------
    
    # Wrangle into tidy format
    
    melted <- reshape2::melt(result)
    
    # Perform clustering
    
    row.order <- stats::hclust(stats::dist(result, method = "euclidean"), method = clust_method)$order # Hierarchical cluster on rows
    col.order <- stats::hclust(stats::dist(t(result), method = "euclidean"), method = clust_method)$order # Hierarchical cluster on columns
    dat_new <- result[row.order, col.order] # Re-order matrix by cluster outputs
    cluster_out <- reshape2::melt(as.matrix(dat_new)) # Turn into dataframe
    
    #--------- Graphic --------------
    
    # Define a nice colour palette consistent with RColorBrewer in other functions
    
    mypalette <- c("#B2182B", "#D6604D", "#F4A582", "#FDDBC7", "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC")
    
    p <- cluster_out %>%
      ggplot2::ggplot(ggplot2::aes(x = .data$Var1, y = .data$Var2,
                                   text = paste('<b>VST 1:</b>', Var1,
                                                '<br><b>VST 2:</b>', Var2,
                                                '<br><b>Correlation:</b>', round(value, digits = 2)))) +
      ggplot2::geom_raster(ggplot2::aes(fill = .data$value), ...) +
      ggplot2::labs(x = "VST head",
                    y = "VST head",
                    fill = "Absolute correlation coefficient") +
      ggplot2::scale_fill_stepsn(n.breaks = 6, colours = rev(mypalette),
                                 show.limits = TRUE) +
      ggplot2::theme_bw() +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90),
                     legend.position = "bottom",
                     panel.background = ggplot2::element_rect(fill = 'transparent'),
                     plot.background = ggplot2::element_rect(fill = 'transparent', color = NA),
                     panel.grid.minor = ggplot2::element_blank(),
                     legend.background = ggplot2::element_rect(fill = 'transparent'),
                     legend.box.background = ggplot2::element_rect(fill = 'transparent'))
    
  } else{
    
    if(is.null(feature_names)){
      stop("feature_names argument must not be NULL if drawing a violin plot. Please enter a vector of valid feature names.")
    } else{
      p <- x[[1]] %>%
        dplyr::filter(names %in% feature_names) %>%
        dplyr::mutate(names = paste0(feature_set, "_", .data$names))
      
      if("group" %in% colnames(p)){
        p <- p %>%
          ggplot2::ggplot(ggplot2::aes(x = .data$group, y = .data$values, colour = .data$group))
      } else{
        p <- p %>%
          dplyr::mutate(group = "Data") %>%
          ggplot2::ggplot(ggplot2::aes(x = .data$group, y = .data$values))
      }
      
      p <- p + 
        ggplot2::geom_violin() +
        ggplot2::geom_point(position = ggplot2::position_jitter(w = 0.05), ...) +
        ggplot2::labs(x = "Class",
                      y = "Feature value") +
        ggplot2::scale_colour_brewer(palette = "Dark2") +
        ggplot2::theme_bw() +
        ggplot2::theme(legend.position = "none",
                       axis.text.x = ggplot2::element_text(angle = 90)) +
        ggplot2::facet_wrap(~ names, scales = "free_y")
    }
  }
  
  # Convert to interactive graphic
  
  p <- plotly::ggplotly(p, tooltip = c("text")) %>%
    config(displayModeBar = FALSE) %>%
    layout(legend = list(orientation = "h", x = 0.4, y = -0.2))
  
  return(p)
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#------------ Dimension reduction plots from {theft} - https://github.com/hendersontrent/theft ------------

#' Produce a plot for a low_dimension object
#' 
#' @importFrom rlang .data
#' @import dplyr
#' @import ggplot2
#' @import tibble
#' @importFrom tidyr drop_na
#' @importFrom broom augment tidy
#' @param x \code{low_dimension} object containing the dimensionality reduction projection calculated by \code{reduce_dimensions}
#' @param show_covariance \code{Boolean} of whether covariance ellipses should be shown on the plot. Defaults to \code{TRUE}
#' @param ... Arguments to be passed to methods
#' @return object of class \code{ggplotly} that contains the graphic
#' @author Trent Henderson
#' 

plot.low_dimension <- function(x, show_covariance = TRUE, ...){
  
  stopifnot(inherits(x, "low_dimension") == TRUE)
  
  if(inherits(x[[3]], "prcomp") == TRUE){
    
    # Retrieve eigenvalues and tidy up variance explained for plotting
    
    eigens <- x[[3]] %>%
      broom::tidy(matrix = "eigenvalues") %>%
      dplyr::filter(.data$PC %in% c(1, 2)) %>% # Filter to just the 2 going in the plot
      dplyr::select(c(.data$PC, .data$percent)) %>%
      dplyr::mutate(percent = round(.data$percent * 100), digits = 1)
    
    eigen_pc1 <- eigens %>%
      dplyr::filter(.data$PC == 1)
    
    eigen_pc2 <- eigens %>%
      dplyr::filter(.data$PC == 2)
    
    eigen_pc1 <- paste0(eigen_pc1$percent,"%")
    eigen_pc2 <- paste0(eigen_pc2$percent,"%")
    
    fits <- x[[3]] %>%
      broom::augment(x[[2]]) %>%
      dplyr::rename(id = 1) %>%
      dplyr::mutate(id = as.factor(.data$id)) %>%
      dplyr::rename(.fitted1 = .data$.fittedPC1,
                    .fitted2 = .data$.fittedPC2)
    
    data_id <- as.data.frame(lapply(x[[1]], unlist)) # Catch weird cases where it's a list...
    
    groups <- data_id %>%
      dplyr::rename(group_id = .data$plugin) %>%
      dplyr::group_by(.data$id, .data$group_id) %>%
      dplyr::summarise(counter = dplyr::n()) %>%
      dplyr::ungroup() %>%
      dplyr::select(-c(.data$counter)) %>%
      dplyr::mutate(id = as.factor(.data$id))
    
    fits <- fits %>%
      dplyr::inner_join(groups, by = c("id" = "id"))
    
    # Draw plot
    
    p <- fits %>%
      dplyr::mutate(group_id = as.factor(.data$group_id)) %>%
      ggplot2::ggplot(ggplot2::aes(x = .data$.fitted1, y = .data$.fitted2,
                                   text = paste('<b>VST head:</b>', id,
                                                '<br><b>Plugin:</b>', group_id))) +
      ggplot2::geom_point(size = 2, ggplot2::aes(colour = .data$group_id)) +
      ggplot2::labs(x = paste0("PC 1"," (", eigen_pc1, ")"),
                    y = paste0("PC 2"," (", eigen_pc2, ")"),
                    colour = NULL) +
      ggplot2::theme_bw() +
      ggplot2::theme(legend.position = "none",
                     panel.background = ggplot2::element_rect(fill = 'transparent'),
                     plot.background = ggplot2::element_rect(fill = 'transparent', color = NA),
                     panel.grid.minor = ggplot2::element_blank(),
                     legend.background = ggplot2::element_rect(fill = 'transparent'),
                     legend.box.background = ggplot2::element_rect(fill = 'transparent'))
    
  } else{
    
    # Retrieve 2-dimensional embedding and add in unique IDs
    
    id_ref <- x[[2]] %>%
      tibble::rownames_to_column(var = "id") %>%
      dplyr::select(c(.data$id))
    
    fits <- data.frame(.fitted1 = x[[3]]$.fitted1,
                       .fitted2 = x[[3]]$.fitted2) %>%
      dplyr::mutate(id = id_ref$id)
    
    fits <- fits %>%
      dplyr::mutate(id = as.factor(.data$id))
    
    data_id <- as.data.frame(lapply(x[[1]], unlist)) # Catch weird cases where it's a list...
    
    groups <- data_id %>%
      dplyr::rename(group_id = .data$plugin) %>%
      dplyr::group_by(.data$id, .data$group_id) %>%
      dplyr::summarise(counter = dplyr::n()) %>%
      dplyr::ungroup() %>%
      dplyr::select(-c(.data$counter)) %>%
      dplyr::mutate(id = as.factor(.data$id))
    
    fits <- fits %>%
      dplyr::inner_join(groups, by = c("id" = "id"))
    
    p <- fits %>%
      dplyr::mutate(group_id = as.factor(.data$group_id)) %>%
      ggplot2::ggplot(ggplot2::aes(x = .data$.fitted1, y = .data$.fitted2,
                                   text = paste('<b>VST head:</b>', id,
                                                '<br><b>Plugin:</b>', group_id))) +
      ggplot2::geom_point(size = 2, ggplot2::aes(colour = .data$group_id)) +
      ggplot2::labs(x = "Dimension 1",
                    y = "Dimension 2",
                    colour = NULL) +
      ggplot2::theme_bw() +
      ggplot2::theme(legend.position = "none",
                     panel.background = ggplot2::element_rect(fill = 'transparent'),
                     plot.background = ggplot2::element_rect(fill = 'transparent', color = NA),
                     panel.grid.minor = ggplot2::element_blank(),
                     legend.background = ggplot2::element_rect(fill = 'transparent'),
                     legend.box.background = ggplot2::element_rect(fill = 'transparent'))
  }
  
  p <- plotly::ggplotly(p, tooltip = c("text")) %>%
    config(displayModeBar = FALSE)
  
  return(p)
}
