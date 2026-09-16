test_that("missing ethnicity bounds and tipping have analytical answers", {
  counts <- fixture_counts()
  pop <- fixture_population()
  b <- sl_missing_ethnicity_bounds(counts, pop)
  expect_s3_class(b, "sl_sensitivity")
  expect_equal(unique(b$lower_bound), 5 / 6)
  expect_equal(unique(b$upper_bound), 12.5)
  expect_equal(unique(b$tipping_allocation), 1 / 24)
  expect_true(all(b$tipping_feasible))
  expect_equal(b$ratio[b$scenario == "proportional"], 2.5)
  expect_false(b$available[b$scenario == "force_object_mar"])
  output <- capture.output(print(b), type = "message")
  expect_true(any(grepl("sampling uncertainty", output)))
  expect_true(any(grepl("assumption range", output)))
  expect_error(sl_missing_ethnicity_bounds(counts, pop, scenarios = "bad"))
  counts$n[3] <- 0
  b <- sl_missing_ethnicity_bounds(counts, pop, scenarios = "proportional")
  expect_equal(b$ratio, 2.5)
  expect_true(is.na(b$tipping_allocation))
  counts$n <- c(0, 0, 10)
  b <- sl_missing_ethnicity_bounds(counts, pop, scenarios = "proportional")
  expect_true(is.na(b$ratio))
})

test_that("wholly missing submissions have unavailable allocation counts", {
  counts <- fixture_counts(n = rep(NA_real_, 3))
  counts$status <- "missing"
  counts$months_submitted <- 0L
  attr(counts, "contract")$coverage$status <- "missing"
  expect_warning(
    bounds <- sl_missing_ethnicity_bounds(counts,
      fixture_population(),
      scenarios = c("all_to_reference", "proportional")
    ),
    class = "searchlight_warning_coverage"
  )
  expect_true(all(is.na(bounds$unknown)))
  expect_true(all(is.na(bounds$allocated_reference)))
  expect_true(all(is.na(bounds$ratio)))
  expect_false(any(bounds$available))
})

test_that("MAR pools force-object shares without repeating exposure", {
  a <- fixture_counts(c(18, 2, 0))
  a$object_group <- "Drugs"
  b <- fixture_counts(c(2, 8, 40))
  b$object_group <- "Weapons"
  counts <- sl_carry(dplyr::bind_rows(a, b), a)
  bounds <- sl_missing_ethnicity_bounds(counts, fixture_population())
  expect_equal(bounds$ratio[bounds$scenario == "force_object_mar"], 7.5)
  expect_equal(bounds$ratio[bounds$scenario == "proportional"], 2.5)
  b$n <- c(0, 0, 40)
  counts <- sl_carry(dplyr::bind_rows(a, b), a)
  expect_error(
    sl_missing_ethnicity_bounds(counts, fixture_population()),
    "without known ethnicity"
  )
})

test_that("denominator scenarios separate conditional intervals and ranges", {
  p <- fixture_population()
  q <- fixture_population(p = c(1000, 400, NA))
  s <- sl_denominator_scenarios(fixture_counts(), list(resident = p, user = q))
  expect_equal(s$ratio, c(2.5, 1.25))
  expect_equal(unique(s$lower_bound), 1.25)
  expect_equal(unique(s$upper_bound), 2.5)
  expect_true(all(s$conf_low < s$ratio & s$conf_high > s$ratio))
  expect_error(sl_denominator_scenarios(fixture_counts(), list(p)))
  q$geography_code <- "b"
  expect_error(
    sl_denominator_scenarios(fixture_counts(), list(a = p, b = q)),
    "incompatible"
  )
})

test_that("direct standardisation reproduces a worked two-age example", {
  pop <- sl_exposure(tibble::tibble(
    geography_code = "a",
    ethnicity = c("White", "White", "Black", "Black"),
    age_band = c("under 25", "35+", "under 25", "35+"), sex = "Female",
    population = c(100, 900, 900, 100)
  ), "msoa21")
  data <- tidyr::expand_grid(
    month = sprintf("2026-%02d", 1:12),
    cell = 1:4
  )
  data <- dplyr::bind_cols(data, as.data.frame(pop)[data$cell, ])
  data$population <- NULL
  data$n <- c(1, 9, 18, 1)[data$cell]
  data$force_id <- "west-yorkshire"
  data$status <- "submitted"
  data$months_submitted <- 1
  counts <- sl_carry(data, fixture_counts(), "sl_counts")
  result <- sl_standardise(counts, pop, "study_population")
  expect_equal(result$crude_rate[result$ethnicity == "White"], 120)
  expect_equal(result$crude_rate[result$ethnicity == "Black"], 228)
  expect_equal(result$standardised_rate[result$ethnicity == "White"], 120)
  expect_equal(result$standardised_rate[result$ethnicity == "Black"], 180)
  expect_equal(attr(result, "weights")$weight, c(0.5, 0.5))
  expect_true(all(result$complete_strata))
  expect_true(all(result$conf_low < result$standardised_rate))
  outside <- as.data.frame(pop)
  outside$geography_code <- "outside"
  outside$population <- c(10000, 1, 10000, 1)
  extended <- sl_exposure(dplyr::bind_rows(as.data.frame(pop), outside),
    geography = "msoa21", source = "Test exposure"
  )
  restricted <- sl_standardise(counts, extended, "study_population")
  expect_equal(attr(restricted, "weights")$weight, c(0.5, 0.5))
  counts$n <- 0
  result <- sl_standardise(counts, pop, "study_population")
  expect_true(all(result$conf_low == 0 & result$conf_high > 0))
  expect_false(any(sl_standardise(counts, pop)$complete_strata))
  pop$population[1] <- 0
  expect_false(sl_standardise(counts, pop, "study_population")$complete_strata[
    result$ethnicity == "White"
  ])
})

test_that("rank probabilities, posterior ordering and RNG restoration work", {
  x <- tibble::tibble(geography_code = c("a", "b"))
  x <- sl_carry(x, fixture_counts())
  attr(x, "posterior_draws") <- cbind(a = rep(5, 100), b = rep(1, 100))
  set.seed(17)
  state <- .Random.seed
  result <- sl_ranking_stability(x, "posterior", n = 100)
  expect_identical(.Random.seed, state)
  expect_equal(result$median_rank, c(1, 2))
  expect_equal(rowSums(attr(result, "rank_probabilities")), c(a = 1, b = 1))
  expect_true(attr(result, "pairwise")$stable)
  expect_error(sl_ranking_stability(x, n = 1))
  expect_error(sl_ranking_stability(x[1, ], "posterior"))
  a <- fixture_counts(c(100, 100, 0), "a")
  b <- fixture_counts(c(100, 1000, 0), "b")
  counts <- sl_carry(dplyr::bind_rows(a, b), a)
  pop <- sl_carry(dplyr::bind_rows(
    fixture_population("a"),
    fixture_population("b")
  ), fixture_population())
  ratios <- sl_rate_ratio(sl_rates(counts, pop))
  rank <- sl_ranking_stability(ratios, n = 100)
  expect_equal(rank$median_rank, c(2, 1))
  expect_true(attr(rank, "pairwise")$stable)
  expect_identical(.Random.seed, state)
  scenarios <- sl_denominator_scenarios(counts, list(a = pop, b = pop))
  varied <- sl_ranking_stability(scenarios, n = 100)
  expect_equal(nrow(varied), 4L)
  expect_length(attr(varied, "rank_probabilities"), 2L)
  ratios$n_reference[1] <- 0
  expect_error(sl_ranking_stability(ratios), "positive")
})
