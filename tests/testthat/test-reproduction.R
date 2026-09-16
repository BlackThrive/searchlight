test_that("force ratios reproduce an independent recent-year fixture", {
  input <- function(name) {
    utils::read.csv(system.file("validation", name,
      package = "searchlight"
    ))
  }
  counts <- tibble::as_tibble(input("reproduction-counts.csv"))
  contract <- sl_new_contract()
  contract$source <- "Independent Python archive-count validation fixture"
  contract$analysis <- list(
    geography = "pfa", classification = "5",
    scheme = "self-defined", strata = c("force_id", "geography_code")
  )
  counts <- sl_carry(counts, contract, "sl_counts")
  population <- sl_exposure(input("reproduction-population.csv"), "pfa",
    source = "Independent TS021 and LAD22-PFA22 aggregation"
  )
  expect_warning(rates <- sl_rates(counts, population),
    class = "searchlight_warning_coverage"
  )
  actual <- sl_rate_ratio(rates)
  expected <- input("reproduction-expected.csv")
  actual <- actual[match(expected$geography_code, actual$geography_code), ]
  expect_equal(nrow(actual), 43L)
  expect_identical(is.na(actual$ratio), is.na(expected$ratio))
  expect_equal(actual$ratio, expected$ratio, tolerance = 1e-12)
  expect_equal(actual$n_reference, expected$n_reference)
  expect_equal(actual$n_comparison, expected$n_comparison)
  expect_equal(sum(tolower(expected$complete_year) == "true"), 28L)
  expect_true(all(is.na(actual$unknown_events[expected$months_submitted == 0])))
})
