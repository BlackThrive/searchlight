test_that("rates and Poisson event ratios have hand-calculated answers", {
  counts <- fixture_counts()
  rates <- sl_rates(counts, fixture_population())
  expect_equal(rates$exposure[1:2], c(1000, 200) / 12)
  expect_equal(rates$rate[1:2], c(240, 600))
  expect_equal(rates$period_rate[1:2], c(20, 50))
  expect_true(is.na(rates$rate[3]))
  ratio <- sl_rate_ratio(rates)
  expect_equal(ratio$ratio, 2.5)
  expect_equal(unname(exp(stats::coef(ratio$model[[1]])[2])), 2.5)
  exact <- stats::poisson.test(c(10, 20), T = c(200, 1000))$conf.int
  expect_equal(c(ratio$conf_low, ratio$conf_high), as.numeric(exact))
  expect_true(is.na(ratio$dispersion))
  expect_s3_class(sl_contract(ratio), "sl_contract")
  counts$n <- c(2000, 1000, 0)
  expect_equal(sl_rate_ratio(sl_rates(counts, fixture_population()))$ratio, 2.5)
  counts$n <- c(20, 0, 0)
  ratio <- sl_rate_ratio(sl_rates(counts, fixture_population()))
  expect_equal(ratio$ratio, 0)
  expect_equal(ratio$conf_low, 0)
  expect_gt(ratio$conf_high, 0)
  counts$n <- c(0, 10, 0)
  expect_equal(sl_rate_ratio(sl_rates(counts, fixture_population()))$ratio, Inf)
  counts$n <- 0
  expect_false(sl_rate_ratio(sl_rates(counts, fixture_population()))$estimable)
  expect_error(sl_rate_ratio(rates, reference = "Unknown"))
  expect_error(sl_rate_ratio(rates, conf_level = 1))
  expect_error(sl_rates(counts, fixture_population(), per = 0))
  counts$n[1] <- -1
  expect_error(sl_rates(counts, fixture_population()), "valid")
  counts$n[1] <- 1.5
  expect_error(sl_rates(counts, fixture_population()), "valid")
  counts$n[1] <- 1
  counts$status[1] <- "missing"
  expect_error(sl_rates(counts, fixture_population()), "contradict")
})

test_that("time exposure excludes absent months and retains warnings", {
  x <- fixture_counts()
  absent <- x
  absent$n <- NA_real_
  absent$month <- "2026-02"
  absent$status <- "missing"
  absent$months_submitted <- 0
  x <- sl_carry(dplyr::bind_rows(x, absent), x)
  expect_warning(r <- sl_rates(x, fixture_population()),
    class = "searchlight_warning_coverage"
  )
  expect_equal(sum(r$exposure[r$ethnicity == "White"]), 1000 / 12)
  expect_equal(sl_rate_ratio(r)$ratio, 2.5)
  expect_warning(unavailable <- sl_rates(absent, fixture_population()),
    class = "searchlight_warning_coverage"
  )
  unavailable <- sl_rate_ratio(unavailable)
  expect_true(is.na(unavailable$n_reference))
  expect_true(is.na(unavailable$n_comparison))
  expect_true(is.na(unavailable$unknown_events))
  expect_false(unavailable$estimable)
  x$status[1:3] <- "partial_suspected"
  expect_warning(sl_rates(x[1:3, ], fixture_population()), "partial")
  bad <- fixture_population()
  attr(bad, "contract")$population$geography <- "pfa"
  expect_error(sl_rates(fixture_counts(), bad), "incompatible")
  bad <- fixture_population()
  bad$geography_code <- "not in records"
  expect_warning(sl_rates(fixture_counts(), bad), "no compatible")
  expect_warning(
    sl_rates(fixture_counts(), fixture_population(p = c(0, 200, NA))),
    "zero Census"
  )
})

test_that("counts fill units and retain contracts after dplyr grouping", {
  x <- sl_sample()[1:3, ]
  x$month <- "2026-01"
  x$msoa21 <- "a"
  ct <- sl_contract(x)
  ct$coverage <- tibble::tibble(
    force_id = "west-yorkshire",
    month = c("2026-01", "2026-02"), status = c("submitted", "missing"),
    n_records = c(3L, NA_integer_)
  )
  x <- sl_carry(x, ct)
  units <- tibble::tibble(force_id = "west-yorkshire", msoa21 = c("a", "b"))
  grouped <- dplyr::group_by(x, .data$msoa21)
  c <- sl_counts(grouped, c("msoa21", "ethnicity_5"), units = units)
  expect_equal(nrow(c), 24L)
  expect_equal(sum(c$n, na.rm = TRUE), 3)
  expect_true(all(is.na(c$n[c$month == "2026-02"])))
  expect_true(all(c$n[c$month == "2026-01" & c$msoa21 == "b"] == 0))
  expect_true("Unknown" %in% c$ethnicity)
  expect_s3_class(sl_contract(c), "sl_contract")
  expect_error(sl_counts(x, "msoa21"), "ethnicity")
  expect_error(sl_counts(x, "ethnicity_5"), "geography")
  detailed <- sl_counts(x, c("msoa21", "ethnicity_19"))
  expect_equal(sum(detailed$n, na.rm = TRUE), 3)
  officer <- sl_counts(x, c("msoa21", "ethnicity_officer"))
  expect_error(sl_rates(officer, fixture_population()), "incompatible")
  all <- sl_counts(sl_sample())
  expect_true(any(all$status == "missing"))
  demographic <- sl_counts(x, c("msoa21", "ethnicity_5", "age_band", "sex"))
  ages <- c("under 25", "25-34", "35+", "Unknown")
  expect_setequal(demographic$age_band, ages)
})

test_that("overdispersed families use replicated event-exposure cells", {
  monthly <- lapply(1:8, function(i) {
    fixture_counts(n = c(
      c(5, 30, 4, 70, 8, 50, 10, 60)[i],
      c(2, 20, 1, 40, 3, 30, 8, 10)[i], 0
    ), month = sprintf("2026-%02d", i))
  })
  counts <- sl_carry(dplyr::bind_rows(monthly), monthly[[1]])
  rates <- sl_rates(counts, fixture_population())
  quasi <- sl_rate_ratio(rates, method = "quasipoisson")
  expect_gt(quasi$dispersion, 1)
  expect_true(is.finite(quasi$conf_low))
  nb <- sl_rate_ratio(rates, method = "negbin")
  expect_true(is.finite(nb$ratio))
  expect_s3_class(nb$model[[1]], "negbin")
  single <- sl_rates(fixture_counts(), fixture_population())
  expect_error(sl_rate_ratio(single, method = "quasipoisson"), "replicated")
})
