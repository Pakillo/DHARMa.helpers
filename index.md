# DHARMa.helpers

<https://pakillo.github.io/DHARMa.helpers>

DHARMa.helpers is an R package that facilitates checking fitted
statistical models via the
[DHARMa](https://cran.r-project.org/web/packages/DHARMa/vignettes/DHARMa.html)
package. By now, only Bayesian models fitted with
[brms](https://paul-buerkner.github.io/brms/) are implemented. See [this
blogpost](https://frodriguezsanchez.net/post/using-dharma-to-check-bayesian-models-fitted-with-brms/)
for a detailed explanation of the approach.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("Pakillo/DHARMa.helpers")
```

## Example

``` r
library(brms)
library(DHARMa.helpers)
```

### Poisson regression

Fit model:

``` r
# Example model taken brms::brm()
# Poisson regression for the number of seizures in epileptic patients
fit1 <- brm(count ~ zAge + zBase * Trt + (1|patient),
            data = epilepsy, family = poisson(), refresh = 0)
#> Compiling Stan program...
#> Start sampling
```

Check with DHARMa:

``` r
simres <- dh_check_brms(fit1, integer = TRUE)
```

![](reference/figures/README-unnamed-chunk-4-1.png)

Note that we use `integer = TRUE` in this case as we are modelling a
discrete response (counts).

Now check residuals against a predictor (zAge):

``` r
plot(simres, form = epilepsy$zAge)
```

![](reference/figures/README-unnamed-chunk-5-1.png)

Test overdispersion:

``` r
DHARMa::testDispersion(simres)
```

![](reference/figures/README-unnamed-chunk-6-1.png)

``` R
#> 
#>  DHARMa nonparametric dispersion test via sd of residuals fitted vs.
#>  simulated
#> 
#> data:  simulationOutput
#> dispersion = 1.1747, p-value = 0.194
#> alternative hypothesis: two.sided
```

See
<https://pakillo.github.io/DHARMa.helpers/reference/dh_check_brms.html>
for more examples.
