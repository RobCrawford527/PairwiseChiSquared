
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
#> Downloading GitHub repo RobCrawford527/PairwiseChiSquared@HEAD
#> 
#>          checking for file 'C:\Users\mqbpqrc6\AppData\Local\Temp\RtmpQV5noF\remotes16c812e07aa8\RobCrawford527-PairwiseChiSquared-19186b3/DESCRIPTION' ...  ✔  checking for file 'C:\Users\mqbpqrc6\AppData\Local\Temp\RtmpQV5noF\remotes16c812e07aa8\RobCrawford527-PairwiseChiSquared-19186b3/DESCRIPTION' (372ms)
#>       ─  preparing 'PairwiseChiSquared':
#>    checking DESCRIPTION meta-information ...     checking DESCRIPTION meta-information ...   ✔  checking DESCRIPTION meta-information
#>       ─  checking for LF line-endings in source and make files and shell scripts
#>   ─  checking for empty or unneeded directories
#>       ─  building 'PairwiseChiSquared_0.0.0.9000.tar.gz'
#>      
#> 
#> Installing package into 'C:/Users/mqbpqrc6/AppData/Local/Temp/Rtmpm0KSWk/temp_libpath38941ac01d12'
#> (as 'lib' is unspecified)
```

The `dependencies = TRUE` argument ensures that other packages that are
required for proteomicshelpers to work correctly are installed too.

## Data preparation

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
example_data <- data.frame(Sample1 = c(10,20,30),
                           Sample2 = c(10,12,38),
                           Sample3 = c(10,22,28),
                           row.names = c("A", "B", "C"))
example_data
#>   Sample1 Sample2 Sample3
#> A      10      10      10
#> B      20      12      22
#> C      30      38      28
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
