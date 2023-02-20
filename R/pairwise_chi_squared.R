#' Pairwise Chi-squared test
#'
#' @param data A data frame with samples as columns and bins as rows.
#' @param comparisons A list containing the comparisons to perform, in the format c("Sample1", "Sample2"). Default is "all", which performs all pairwise comparisons.
#' @param alpha Significance level (default 0.05).
#' @param method Method to use for multiple testing correction, from p.adjust.methods. Default is "bonferroni".
#'
#' @return A data frame with one row per comparison, containing the output of the Chi-squared test.
#' @export
#'
#' @examples
#' example_data <- data.frame(Sample1 = c(10,20,30),
#'                            Sample2 = c(10,12,38),
#'                            Sample3 = c(10,22,28))
#' pairwise_chi_squared(data = example_data,
#'                      comparisons = list(c("Sample1", "Sample2"),
#'                                         c("Sample1", "Sample3")),
#'                      alpha = 0.05,
#'                      method = "Bonferroni")
#'
pairwise_chi_squared <- function(data,
                                 comparisons = "all",
                                 alpha = 0.05,
                                 method = "bonferroni"){

  ### parameters checked
  # check adjust has one of the three allowed values
  if (length(method) > 1){
    method <- method[1]
  }
  if (!method %in% p.adjust.methods)){
    stop("'method' must be one of 'p.adjust.methods'")
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
  output <- data.frame()

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
                           pval = chi_i[["p.value"]])
    rownames(output_i) <- NULL
    output <- rbind.data.frame(output, output_i)
  }

  ### p-values corrected
  output <- dplyr::mutate(output,
                          adj_pval = stats::p.adjust(output$pval,
                                                     method = method))
  # p-values compared to critical values
  # TRUE = statistically significant at chosen alpha level
  output <- dplyr::mutate(output, significant = dplyr::case_when(is.na(adj_pval) ~ NA,
                                                                 adj_pval >= alpha ~ FALSE,
                                                                 adj_pval < alpha ~ TRUE))

  ### output data frame returned
  output
}
