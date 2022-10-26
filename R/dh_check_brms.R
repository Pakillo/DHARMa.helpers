#' Check Bayesian models fitted with brms
#'
#' @param model A fitted model [brms::brmsfit-class()].
#' @param integer Logical (TRUE/FALSE), indicating if response is an integer, as in Poisson and binomial models
#' @param plot Logical. Plot residual checks? Default is TRUE.
#' @param nsamples Integer. Number of samples to draw from the posterior.
#' @param ntrys Integer. Number of trys to use for truncated distributions. See [brms::posterior_predict()].
#' @param ... Further arguments for [DHARMa::plotResiduals()]
#'
#' @return An object of type `DHARMa`. See [DHARMa::createDHARMa()] for more details.
#' @export
#' @import DHARMa
#'
#' @seealso https://frodriguezsanchez.net/post/using-dharma-to-check-bayesian-models-fitted-with-brms/
#'
#' @examples
#' \dontrun{
#' # Example models taken from brms::brm()
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
#' }
dh_check_brms <- function(model,             # brms model
                       integer = FALSE,   # integer response? (TRUE/FALSE)
                       plot = TRUE,       # make plot?
                       nsamples = 1000,   # posterior samples in posterior_predict
                       ntrys = 5,         # number of trys in truncated distributions. See posterior_predict
                       ...                # further arguments for DHARMa::plotResiduals
) {

  mdata <- brms::standata(model)
  if (!"Y" %in% names(mdata))
    stop("Cannot extract the required information from this brms model")

  dharma.obj <- DHARMa::createDHARMa(
    simulatedResponse = t(brms::posterior_predict(model, ndraws = nsamples, ntrys = ntrys)),
    observedResponse = mdata$Y,
    fittedPredictedResponse = apply(
      t(brms::posterior_epred(model, ndraws = nsamples, re.form = NA)),
      1,
      mean),
    integerResponse = integer)

  if (isTRUE(plot)) {
    plot(dharma.obj, ...)
  }

  invisible(dharma.obj)

}


