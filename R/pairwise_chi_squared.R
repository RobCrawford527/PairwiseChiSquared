
################################################################################
################################################################################

### pairwise chi-squared function ###
#
# performs pairwise chi-squared tests between samples (i.e. columns)
# comparisons can be provided as a list of sample pairs, ...
# ... or all comparisons can be performed (default)
#
# alpha level must be set, default is 0.05
#
# adjustment method can be set to ...
# ... "Bonferroni" (default, most conservative), ...
# ... "BH" (less conservative, better for large numbers of comparisons), ...
# ... or "none" (not recommended)
#
pairwise_chi_squared <- function(data,
                                 comparisons = "all",
                                 alpha = 0.05,
                                 adjust = c("Bonferroni", "BH", "none")){

  ### parameters checked
  # set to Bonferroni if no value specified
  # check adjust has one of the three allowed values
  if (adjust == c("Bonferroni", "BH", "none")){
    adjust <- adjust[1]
  }
  if (!adjust %in% c("none","BH","Bonferroni")){
    stop("'adjust' must be one of 'none', 'BH' or 'Bonferroni'")
  }
  # create comparison list if comparisons = 'all'
  # all samples referred to in comparisons must be present in data
  if (all(comparisons == "all")){
    samples <- colnames(data)
    comparisons <- list()
    n <- 1
    for (j in 1:length(samples)){
      for (k in 1:length(samples)){
        if (j < k){
          comp <- c(samples[j], samples[k])
          comparisons[[n]] <- comp
          n <- n + 1
        }}}
  } else if (all(unique(unlist(comparisons)) %in% colnames(data))==FALSE){
    stop("one or more samples from 'comparisons' not present in data")
  }

  ### output data frame created
  # empty data frame created with appropriate columns
  output <- data.frame(comparison = NA,
                       sample1 = NA,
                       sample2 = NA,
                       chi_sq = NA,
                       df = NA,
                       p_value = NA)[0,]

  ### chi-squared tests performed for pairwise comparisons
  # comparisons selected one by one
  # only relevant columns retained
  # chi-squared test performed
  # appropriate values written into output data frame
  for (i in comparisons){
    data_i <- data[,i]
    chi_i <- stats::chisq.test(data_i)
    output_i <- data.frame(comparison = paste(i[1],"vs",i[2],sep="_"),
                           sample1 = i[1],
                           sample2 = i[2],
                           chi_sq = chi_i[["statistic"]],
                           df = chi_i[["parameter"]],
                           p_value = chi_i[["p.value"]])
    rownames(output_i) <- NULL
    output <- rbind.data.frame(output, output_i)
  }

  ### p-values corrected
  # p-values ranked (smallest to largest)
  output <- output[order(output[,"p_value"], decreasing = FALSE),]
  output <- dplyr::mutate(output, rank = 1:length(comparisons))
  # critical value determined for each comparison
  # significance determined by comparing p-values to respective critical values
  # values differ depending on adjustment method
  if (adjust == "Bonferroni"){
    output <- dplyr::mutate(output, critical_val = alpha / length(comparisons))
  } else if (adjust == "BH"){
    output <- dplyr::mutate(output, critical_val = rank / max(rank) * alpha)
  } else if (adjust == "none"){
    output <- dplyr::mutate(output, critical_val = alpha)
  }
  # p-values compared to critical values
  # TRUE = statistically significant at chosen alpha level
  # comparisons ranked higher (i.e. with smaller p-values) ...
  # ... than the lowest-ranked significant comparison are  ...
  # ... all deemed to be TRUE (note this is only relevant  ...
  # ... for BH correction, but it is also true for the others)
  output <- dplyr::mutate(output, significant = dplyr::case_when(is.na(p_value) ~ NA,
                                                                 p_value >= critical_val ~ FALSE,
                                                                 p_value < critical_val ~ TRUE))
  output <- dplyr::mutate(output, significant = dplyr::case_when(is.na(significant) ~ NA,
                                                                 rank > max(output[output[,"significant"]==TRUE,"rank"], na.rm = TRUE) ~ FALSE,
                                                                 TRUE ~ TRUE))

  ### output data frame returned
  output
}



################################################################################
################################################################################
