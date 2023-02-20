#' Chi-squared test
#'
#' @param data A data frame with samples as columns and bins as rows.
#' @param alpha Significance level (default 0.05).
#'
#' @return A data frame with one row, containing the output of the Chi-squared test.
#' @export
#'
#' @examples
#' example_data <- data.frame(Sample1 = c(10,20,30),
#'                            Sample2 = c(10,12,38),
#'                            Sample3 = c(10,22,28))
#' chi_squared(data = example_data, alpha = 0.05)
#'
chi_squared <- function(data,
                        alpha = 0.05){

  # chi-squared test performed
  # output data frame created
  # appropriate values written into output data frame
  chi <- stats::chisq.test(data)
  output <- data.frame(comparison = "overall",
                       sample1 = NA,
                       sample2 = NA,
                       chi_sq = chi[["statistic"]],
                       df = chi[["parameter"]],
                       pval = chi[["p.value"]],
                       adj_pval = chi[["p.value"]])
  rownames(output) <- NULL

  # significance determined by comparing p-value to critical value
  output <- dplyr::mutate(output, significant = dplyr::case_when(adj_pval >= alpha ~ FALSE,
                                                                 TRUE ~ TRUE))

  # output data frame returned
  output
}
