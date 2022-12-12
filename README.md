
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PairwiseChiSquared

<!-- badges: start -->
<!-- badges: end -->

The goal of **PairwiseChiSquared** is to facilitate the analysis of
categorical data across multiple samples using the chi-squared test. It
first enables you to perform an overall chi-squared test to determine if
*any* differences are present, then to perform a set of pairwise
chi-squared tests to determine *exactly which* differences are present.

## Installation

You can install the development version of PairwiseChiSquared from
[GitHub](https://github.com/) with:

Note: if it is not already installed, remove the comment sign (#) at the
start of the first line to install `devtools`.

``` r
# install.packages("devtools", dependencies = TRUE)
devtools::install_github("RobCrawford527/PairwiseChiSquared", dependencies = TRUE)
```

The `dependencies = TRUE` argument ensures that other packages that are
required for proteomicshelpers to work correctly are installed too.

## Data Preparation

To use the chi-squared test your data must be categorical - i.e. they
are counts of values in a number of non-overlapping, mutually exclusive
categories. For example, this might be numbers of granules per cell from
microscopy images, binned into counts of 0, 1-2, 3-4 and 5+ granules per
cell. The selection of bin boundaries is important: the general rule is
that *≥80% of your categories should have expected values ≥5*. If this
is not the case and many categories have low or zero values, consider
changing the boundaries to combine categories.

To use the PairwiseChiSquared functions, your data must be in the format
of a table, with your **samples as columns** and your **bins as rows**.
The value in each cell should be the **count** of measurements in each
bin for the appropriate sample. It is fine if the total numbers of
measurements for the samples differ: if this is the case you should
*leave the counts as is*, do not convert them to percentages.

You can prepare the table in e.g. Excel, export it as a `.txt` file and
then import to R. Make sure the bins are set as the *row names* rather
than a separate column. Once imported, the data frame should look
similar to the example below:

``` r
example_data <- data.frame(Sample1 = c(20,20,40),
                           Sample2 = c(10,12,58),
                           Sample3 = c(18,26,32),
                           Sample4 = c(16,24,30),
                           row.names = c("A", "B", "C"))
example_data
#>   Sample1 Sample2 Sample3 Sample4
#> A      20      10      18      16
#> B      20      12      26      24
#> C      40      58      32      30
```

## Chi-Squared Test

Use the `chi_squared()` function to test whether there are *any*
differences in the distribution of counts across the bins between your
samples. It is a modified version of the built-in `chisq.test()`
function that reports the result of the test in a comparable way to
`pairwise_chi_squared()`.

`chi-squared()` has only two parameters: `data` is the data frame
containing the data you wish to test, and `alpha` is the desired
significance level (0.05 by default)t.

``` r
# perform overall chi-squared test
overall_result <- PairwiseChiSquared::chi_squared(data = example_data,
                                                  alpha = 0.05)
print(overall_result[,c("chi_sq",
                        "p_value",
                        "critical_val",
                        "significant")])
#>     chi_sq     p_value critical_val significant
#> 1 20.05487 0.002707801         0.05        TRUE
```

If - and only if - the result of this test is significant should you
progress to perform pairwise chi-squared tests. Otherwise you should
stop, as there are no statistically significant differences between your
samples.

## Pairwise Chi-Squared Test

Having found that the distribution of counts differs significantly
between your samples, you can determine *exactly which samples differ*
using `pairwise_chi_squared()`. Again this function is a wrapper for
`chisq.test()`, which selects pairs of samples for testing in turn and
reports the results in a table that matches the one from
`chi_squared()`. Once all of the tests have been performed, the results
can be corrected for multiple testing using either the Bonferroni or BH
method.

`pairwise_chi_squared()` takes the same two parameters as
`chi_squared()`: `data` and `alpha`. It takes an additional two
parameters: `comparisons`, which specifies which pairwise tests to
perform, and `adjust`, which specifies how to perform multiple testing
correction.

By default, `comparisons` is set to “all”, meaning that all of the
pairwise comparisons will be evaluated.

``` r
# perform pairwise chi-squared tests for all comparisons
# Bonferroni method used for multiple testing correction
pairwise_result <- PairwiseChiSquared::pairwise_chi_squared(data = example_data,
                                                            comparisons = "all",
                                                            alpha = 0.05,
                                                            adjust = "Bonferroni")
print(pairwise_result[,c("chi_sq",
                         "p_value",
                         "critical_val",
                         "significant")])
#>        chi_sq      p_value critical_val significant
#> 4 14.86192719 0.0005926162  0.008333333        TRUE
#> 5 13.68787463 0.0010658984  0.008333333        TRUE
#> 1  8.63945578 0.0133035031  0.008333333       FALSE
#> 2  1.67529809 0.4327266505  0.008333333       FALSE
#> 3  1.57699443 0.4545273382  0.008333333       FALSE
#> 6  0.01561422 0.9922232884  0.008333333       FALSE
```

You may prefer to specify a subset of tests to perform. For example, if
you have an unstressed sample and multiple stress conditions, you may
want to compare each stress against the unstressed. To specify
comparisons, each should be in the format `c("Sample1", "Sample2")`.
Multiple comparisons can be joined together by using `list()`.

``` r
# define comparisons to perform 
comparisons_of_interest <- list(c("Sample1", "Sample2"),
                                c("Sample1", "Sample3"),
                                c("Sample1", "Sample4"))

# use comparisons list for pairwise chi-squared tests
pairwise_result <- PairwiseChiSquared::pairwise_chi_squared(data = example_data,
                                                            comparisons = comparisons_of_interest,
                                                            alpha = 0.05,
                                                            adjust = "Bonferroni")
print(pairwise_result[,c("chi_sq",
                         "p_value",
                         "critical_val",
                         "significant")])
#>     chi_sq   p_value critical_val significant
#> 1 8.639456 0.0133035   0.01666667        TRUE
#> 2 1.675298 0.4327267   0.01666667       FALSE
#> 3 1.576994 0.4545273   0.01666667       FALSE
```

The multiple testing correction method is set to “Bonferroni” by
default, but can alternatively be changed to “BH” or to “none” (which is
not recommended!). Multiple testing correction changes the critical
value against which the p-values are compared; in this case the p-values
themselves *are not adjusted* but the value they are compared with is
changed. If the p-value for a test is *smaller* than its respective
p-value, the result is considered *significant*. The Bonferroni method
divides the alpha value by the number of tests performed to define the
critical value for all of the tests. The BH method ranks the p-values
from smallest to largest and uses this to calculate the critical value
for each test. The critical value is defined as:
`alpha * (rank / total number of tests)`. The test with the highest
p-value that is considered significant is then identified, and a final
correction is made to ensure that all the tests with smaller p-values
are also considered significant (even if some of these p-values are
*larger* than their respective critical values).

``` r
# use BH correction for pairwise tests
pairwise_result <- PairwiseChiSquared::pairwise_chi_squared(data = example_data,
                                                            comparisons = "all",
                                                            alpha = 0.05,
                                                            adjust = "BH")
print(pairwise_result[,c("chi_sq", 
                         "p_value",
                         "critical_val",
                         "significant")])
#>        chi_sq      p_value critical_val significant
#> 4 14.86192719 0.0005926162  0.008333333        TRUE
#> 5 13.68787463 0.0010658984  0.016666667        TRUE
#> 1  8.63945578 0.0133035031  0.025000000        TRUE
#> 2  1.67529809 0.4327266505  0.033333333       FALSE
#> 3  1.57699443 0.4545273382  0.041666667       FALSE
#> 6  0.01561422 0.9922232884  0.050000000       FALSE
```
