
################################################################################
################################################################################

### chi-squared function ###
#
# determines whether there are any differences between the samples
#
# input should be a data frame with SAMPLES as columns and BINS as rows
# alpha level must be set, default is 0.05
#
# returns a data frame with one row showing the outcome of the chi-squared test
#
chi_squared <- function(data,
                        alpha = 0.05){

  ### chi-squared test performed
  # chi-squared test performed
  # output data frame created
  # appropriate values written into output data frame
  chi <- stats::chisq.test(data)
  output <- data.frame(comparison = "overall",
                       sample1 = NA,
                       sample2 = NA,
                       chi_sq = chi[["statistic"]],
                       df = chi[["parameter"]],
                       p_value = chi[["p.value"]],
                       rank = NA,
                       critical_val = alpha)
  rownames(output) <- NULL

  ### outcome of test determined
  # significance determined by comparing p-value to critical value
  output <- dplyr::mutate(output, significant = dplyr::case_when(p_value >= critical_val ~ FALSE,
                                                                 TRUE ~ TRUE))

  ### output data frame returned
  output
}



################################################################################
################################################################################
