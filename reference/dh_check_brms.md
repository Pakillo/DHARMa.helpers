# Check Bayesian models fitted with brms

Check Bayesian models fitted with brms

## Usage

``` r
dh_check_brms(
  model,
  resp = NULL,
  integer = FALSE,
  plot = TRUE,
  nsamples = 1000,
  ntrys = 5,
  ...
)
```

## Arguments

- model:

  A fitted model
  [`brms::brmsfit-class()`](https://paulbuerkner.com/brms/reference/brmsfit-class.html).
  Categorical and ordinal models not supported by now.

- resp:

  Optional name of response variable (for multivariate models).

- integer:

  Logical (TRUE/FALSE), indicating if response is an integer, as in
  Poisson and binomial models

- plot:

  Logical. Plot residual checks? Default is TRUE.

- nsamples:

  Integer. Number of samples to draw from the posterior.

- ntrys:

  Integer. Number of trys to use for truncated distributions. See
  [`brms::posterior_predict()`](https://paulbuerkner.com/brms/reference/posterior_predict.brmsfit.html).

- ...:

  Further arguments for
  [`DHARMa::plotResiduals()`](https://rdrr.io/pkg/DHARMa/man/plotResiduals.html)

## Value

An object of type `DHARMa`. See
[`DHARMa::createDHARMa()`](https://rdrr.io/pkg/DHARMa/man/createDHARMa.html)
for more details.

## See also

<https://frodriguezsanchez.net/post/using-dharma-to-check-bayesian-models-fitted-with-brms/>

## Examples

``` r
if (FALSE) { # interactive()

#' # Example models taken from brms::brm()

# Poisson regression for the number of seizures in epileptic patients
fit1 <- brm(count ~ zAge + zBase * Trt + (1|patient),
           data = epilepsy, family = poisson())
simres <- dh_check_brms(fit1, integer = TRUE)
plot(simres, form = epilepsy$zAge)
testDispersion(simres)


# Probit regression using the binomial family
ntrials <- sample(1:10, 100, TRUE)
success <- rbinom(100, size = ntrials, prob = 0.4)
x <- rnorm(100)
data4 <- data.frame(ntrials, success, x)
fit4 <- brm(success | trials(ntrials) ~ x, data = data4,
            family = binomial("probit"))
summary(fit4)
simres <- dh_check_brms(fit4, integer = TRUE)
plot(simres, form = data4$x)


# Multivariate (multiresponse) model
data("BTdata", package = "MCMCglmm")
bf_tarsus <- bf(tarsus ~ sex + (1|p|fosternest) + (1|q|dam))
bf_back <- bf(back ~ hatchdate + (1|p|fosternest) + (1|q|dam))
fit <- brm(bf_tarsus + bf_back + set_rescor(TRUE),
            data = BTdata, chains = 2, cores = 2)
dh_check_brms(fit, resp = "tarsus")
brms::pp_check(fit, resp = "tarsus")
dh_check_brms(fit, resp = "back")
brms::pp_check(fit, resp = "back")
}
```
