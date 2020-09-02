
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggfail

<!-- badges: start -->

<!-- badges: end -->

It’s common to forget a “+” in a ggplot call, this is an attempt to fail
explicitly in those cases.

This is not very robust, might stop working if the code of ggplot2
changes.

## Installation

Install with :

``` r
remotes::install_github("moodymudskipper/ggfail")
```

## Example

Run `ggfail::trace_funs()` after attaching *{ggplot2}*, or copy the
following to your .Rpofile, it will run `ggfail::trace_funs()` anytime
you attach *{ggplot2}*:

``` r
setHook(packageEvent("ggplot2", "attach"),
        function(...) ggfail::trace_funs())
```

Then this will work as expected :

``` r
library(ggplot2)
#> Error in loadNamespace(name) : there is no package called 'ggfail'
plt <- function() {
  ggplot(cars, aes(speed, dist)) +
    geom_line()
}
plt()
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

But this will fail explicitly (because we miss a “+”)

``` r
plt <- function() {
  ggplot(cars, aes(speed, dist))
    geom_line()
}
plt()
#> geom_line: na.rm = FALSE, orientation = NA
#> stat_identity: na.rm = FALSE
#> position_identity
```

It works by making some ggplot functions fail if they’re not called by
`+`, or a selection of other allowed functions. all functions from
*{ggplot2}* prefixed in some ways (“geom\_”, “facet\_” etc), with
exceptions (“coord\_munch” etc) are traced.

you can untrace with `ggfail::untrace_funs()` but setting
`options(ggfail = FALSE)` will work just as well, without untracing.
