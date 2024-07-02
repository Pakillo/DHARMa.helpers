#' Check Bayesian models fitted with brms
#'
#' @param model A fitted model [brms::brmsfit-class()].
#' Categorical and ordinal models not supported by now.
#' @param resp Optional name of response variable (for multivariate models).
#' @param integer Logical (TRUE/FALSE), indicating if response is an integer,
#' as in Poisson and binomial models
#' @param plot Logical. Plot residual checks? Default is TRUE.
#' @param nsamples Integer. Number of samples to draw from the posterior.
#' @param ntrys Integer. Number of trys to use for truncated distributions. See [brms::posterior_predict()].
#' @param ... Further arguments for [DHARMa::plotResiduals()]
#'
#' @return An object of type `DHARMa`. See [DHARMa::createDHARMa()] for more details.
#' @export
#' @import DHARMa
#'
#' @seealso <https://frodriguezsanchez.net/post/using-dharma-to-check-bayesian-models-fitted-with-brms/>
#'
#' @examplesIf interactive()
#'
#' #' # Example models taken from brms::brm()
#'
#' # Poisson regression for the number of seizures in epileptic patients
#' fit1 <- brm(count ~ zAge + zBase * Trt + (1|patient),
#'            data = epilepsy, family = poisson())
#' simres <- dh_check_brms(fit1, integer = TRUE)
#' plot(simres, form = epilepsy$zAge)
#' testDispersion(simres)
#'
#'
#' # Probit regression using the binomial family
#' ntrials <- sample(1:10, 100, TRUE)
#' success <- rbinom(100, size = ntrials, prob = 0.4)
#' x <- rnorm(100)
#' data4 <- data.frame(ntrials, success, x)
#' fit4 <- brm(success | trials(ntrials) ~ x, data = data4,
#'             family = binomial("probit"))
#' summary(fit4)
#' simres <- dh_check_brms(fit4, integer = TRUE)
#' plot(simres, form = data4$x)
#'
#'
#' # Multivariate (multiresponse) model
#' data("BTdata", package = "MCMCglmm")
#' bf_tarsus <- bf(tarsus ~ sex + (1|p|fosternest) + (1|q|dam))
#' bf_back <- bf(back ~ hatchdate + (1|p|fosternest) + (1|q|dam))
#' fit <- brm(bf_tarsus + bf_back + set_rescor(TRUE),
#'             data = BTdata, chains = 2, cores = 2)
#' dh_check_brms(fit, resp = "tarsus")
#' brms::pp_check(fit, resp = "tarsus")
#' dh_check_brms(fit, resp = "back")
#' brms::pp_check(fit, resp = "back")
#'

dh_check_brms <- function(model,             # brms model
                          resp = NULL,       # response variable (for multivariate models)
                          integer = FALSE,   # integer response? (TRUE/FALSE)
                          plot = TRUE,       # make plot?
                          nsamples = 1000,   # posterior samples in posterior_predict
                          ntrys = 5,         # number of trys in truncated distributions. See posterior_predict
                          ...                # further arguments for DHARMa::plotResiduals
) {

  mdata <- brms::standata(model)

  if (!is.null(resp)) {
    respo <- paste0("Y_", resp)
  } else {
    respo <- "Y"
  }

  if (!respo %in% names(mdata)) {
    stop("Cannot extract the required information from this brms model")
  }


  dharma.obj <- DHARMa::createDHARMa(
    simulatedResponse = t(brms::posterior_predict(model,
                                                  resp = resp,
                                                  ndraws = nsamples,
                                                  ntrys = ntrys)),
    observedResponse = mdata[[respo]],
    fittedPredictedResponse = apply(
      t(brms::posterior_epred(model,
                              resp = resp,
                              ndraws = nsamples,
                              re.form = NA)),
      1,
      mean),
    integerResponse = integer)

  if (isTRUE(plot)) {
    plot(dharma.obj, ...)
  }

  invisible(dharma.obj)

}


