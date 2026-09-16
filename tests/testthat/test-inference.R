test_that("simulation retains events and separates intensity from disparity", {
  s <- sl_simulate(side = 3, missingness = "mnar", seed = 9)
  correlation <- cor(s$truth$ratio, s$truth$annual_intensity)
  expect_equal(correlation, 0, tolerance = 1e-10)
  expect_equal(sum(s$counts$n), sum(s$complete_counts$n))
  expect_gt(sum(s$counts$n[s$counts$ethnicity == "Unknown"]), 0)
  expect_s3_class(sl_contract(s$counts), "sl_contract")
  complete <- sl_rate_ratio(sl_rates(s$complete_counts, s$population))
  bounds <- sl_missing_ethnicity_bounds(s$counts, s$population)
  b <- bounds[bounds$scenario == "all_to_reference", ]
  ratio <- complete$ratio[match(b$geography_code, complete$geography_code)]
  expect_true(all(b$lower_bound <= ratio & b$upper_bound >= ratio))
  for (mechanism in c("mcar", "mar", "none")) {
    x <- sl_simulate(
      side = 3, missingness = mechanism,
      surface = "discontinuous"
    )
    expect_equal(sum(x$counts$n), sum(x$complete_counts$n))
  }
  small <- sl_simulate(side = 3, surface = "small")
  expect_equal(unique(small$population$population[
    small$population$ethnicity == "Black"
  ]), 50)
  expect_error(sl_simulate(side = 1), "Invalid")
})

test_that("count regression matches GLM with spatial diagnostics", {
  s <- sl_simulate(side = 3, seed = 8)
  rates <- sl_rates(s$counts, s$population)
  fit <- sl_count_model(rates, n ~ ethnicity, boundaries = s$boundaries)
  d <- as.data.frame(rates[rates$ethnicity != "Unknown", ])
  direct <- stats::glm(n ~ ethnicity + offset(log(exposure)),
    data = d,
    family = stats::poisson()
  )
  expect_equal(fit$estimate, unname(stats::coef(direct)))
  expect_true(is.finite(attr(fit, "diagnostics")$moran$statistic))
  expect_s3_class(attr(fit, "model"), "glm")
  nb <- sl_count_model(rates, n ~ ethnicity, family = "negbin")
  expect_s3_class(attr(nb, "model"), "negbin")
  expect_s3_class(sl_contract(nb), "sl_contract")
  expect_error(sl_count_model(rates, population ~ ethnicity), "response")
  expect_error(sl_count_model(rates, n ~ offset(log(population))), "exposure")
  expect_error(sl_count_model(rates, n ~ ethnicity, random = "bad"), "formula")
  rates$n[1] <- -1
  expect_error(sl_count_model(rates, n ~ ethnicity), "nonnegative")
})

test_that("mixed count models use genuine group random effects", {
  skip_if_not_installed("lme4")
  s <- sl_simulate(side = 4, rate = 0.1)
  r <- sl_rates(s$counts, s$population)
  fit <- sl_count_model(r, n ~ ethnicity, random = ~ (1 | geography_code))
  expect_s4_class(attr(fit, "model"), "glmerMod")
  expect_true(all(is.finite(fit$exp_estimate)))
})

test_that("multivariate CAR recovers independent disparity and exposes MCMC", {
  s <- sl_simulate(side = 3, rate = 0.08)
  attr(s$counts, "contract")$assignment_quality <- tibble::tibble(
    type = "synthetic", boundary_sensitive_share = 0.5
  )
  warnings <- character()
  fit <- withCallingHandlers(
    {
      sl_spatial_disparity(s$counts, s$population, s$boundaries,
        burnin = 50, n.sample = 200, thin = 1, seed = 43
      )
    },
    warning = function(w) {
      warnings <<- c(warnings, class(w)[1])
      invokeRestart("muffleWarning")
    }
  )
  expect_setequal(warnings, c(
    "searchlight_warning_geography",
    "searchlight_warning_convergence"
  ))
  expect_gt(cor(fit$ratio, s$truth$ratio), 0.9)
  covered <- fit$credible_low_95 <= s$truth$ratio &
    fit$credible_high_95 >= s$truth$ratio
  coverage <- mean(covered)
  expect_gte(coverage, 2 / 3)
  expect_s3_class(fit, "sl_spatial")
  expect_s3_class(sl_spatial_map(fit), "sf")
  expect_s3_class(plot(fit), "ggplot")
  expect_equal(dim(attr(fit, "posterior_draws")), c(300L, 9L))
  expect_true(all(fit$probability_above_1 >= fit$probability_above_k))
  expect_true(all(is.finite(fit$rhat)))
  model <- attr(fit, "model")
  # Independently reconstruct draws from posterior fitted means and exposure;
  # this detects category/area vectorisation mistakes in phi extraction.
  means <- do.call(rbind, model$samples$fitted)
  ref <- seq(1, 18, 2)
  expected <- (means[, ref + 1] / 1000) / (means[, ref] / 5000)
  expect_equal(unname(attr(fit, "posterior_draws")), unname(expected),
    tolerance = 1e-8
  )
  ranked <- sl_ranking_stability(fit, "posterior", n = 100)
  expect_equal(unname(rowSums(attr(ranked, "rank_probabilities"))), rep(1, 9))
  model <- function(...) {
    suppressWarnings(sl_spatial_disparity(
      s$counts, s$population,
      s$boundaries, ...
    ))
  }
  expect_error(model(backend = "inla"), "deferred")
  expect_error(model(chains = 1), "MCMC")
  expect_error(model(adjacency = matrix(0, 9, 9)), "named")
  expect_error(sl_spatial_map(s$counts), "sl_spatial")
})

test_that("full spatial recovery remains satisfactory on a larger lattice", {
  skip_on_cran()
  s <- sl_simulate(side = 5, rate = 0.06, seed = 32)
  fit <- suppressWarnings(sl_spatial_disparity(s$counts, s$population,
    s$boundaries,
    seed = 34
  ))
  expect_gt(cor(fit$ratio, s$truth$ratio), 0.85)
  covered <- fit$credible_low_95 <= s$truth$ratio &
    fit$credible_high_95 >= s$truth$ratio
  expect_gte(mean(covered), 0.8)
  expect_true(all(attr(fit, "diagnostics")$converged))
})

test_that("outcomes are separate with Wilson limits and explicit missingness", {
  x <- sl_sample()[rep(1, 100), ]
  x$ethnicity_5 <- rep(c("White", "Black"), each = 50)
  x$force_id <- "force"
  x$pfa <- "pfa"
  x$object_group <- "object"
  x$any_action <- rep(c(rep(TRUE, 20), rep(FALSE, 30)), 2)
  x$arrest <- rep(c(rep(TRUE, 10), rep(FALSE, 40)), 2)
  x$outcome_linked_to_object <- NA
  x$ethnicity_5[100] <- "Unknown"
  result <- sl_hit_rates(x)
  white <- result[result$ethnicity_5 == "White", ]
  expect_equal(white$hit_rate[white$outcome == "any_action"], 0.4)
  expect_equal(white$hit_rate[white$outcome == "arrest"], 0.2)
  linked <- white$hit_rate[white$outcome == "outcome_linked_to_object"]
  expect_true(is.na(linked))
  expected <- as.numeric(stats::prop.test(20, 50, correct = FALSE)$conf.int[1])
  expect_equal(white$conf_low[white$outcome == "any_action"], expected)
  expect_true("Unknown" %in% result$ethnicity_5)
  expect_equal(nrow(attr(result, "coefficients")), 3L)
  expect_equal(attr(result, "exclusions")$unknown_ethnicity, rep(1, 3))
  x$arrest <- 2
  expect_error(sl_hit_rates(x), "binary")
  expect_error(sl_hit_rates(x, outcome = "joint"), "Unknown")
  actual <- sl_hit_rates(sl_sample(), by = "object_group")
  expect_s3_class(sl_contract(actual), "sl_contract")
})
