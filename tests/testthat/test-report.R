test_that("offline reports retain coverage and separate uncertainty types", {
  records <- sl_sample()
  counts <- readRDS(system.file("extdata", "example-counts.rds",
    package = "searchlight"
  ))
  population <- readRDS(system.file("extdata", "sample-population.rds",
    package = "searchlight"
  ))$msoa21
  rates <- sl_rates(sl_collapse_counts(counts), population)
  estimates <- list(
    ratios = sl_rate_ratio(rates),
    missingness = sl_missing_ethnicity_bounds(counts, population),
    regression = sl_count_model(rates, n ~ ethnicity)
  )
  path <- file.path(withr::local_tempdir(), "report.html")
  withr::local_envvar(NO_INTERNET_TEST = "true")
  expect_message(result <- sl_report(
    records, path, estimates,
    title = paste0(
      "A <script>alert('x')</script> & ",
      "![image](https://example.invalid/pixel)"
    ),
    assumptions = paste0(
      "Census exposure remains fixed\n\n",
      "![image](https://example.invalid/pixel)"
    ),
    limitations = "Example subset of four areas", max_rows = 4
  ), "Report written")
  expect_s3_class(result, "tbl_df")
  expect_s3_class(sl_contract(result), "sl_contract")
  html <- paste(readLines(path), collapse = "\n")
  expect_match(html, "Sampling uncertainty", fixed = TRUE)
  expect_match(html, "Assumption range", fixed = TRUE)
  expect_match(html, "dyfed-powys", fixed = TRUE)
  expect_match(html, "missing", fixed = TRUE)
  expect_match(html, "2,280", fixed = TRUE)
  expect_match(html, "&lt;script&gt;", fixed = TRUE)
  expect_false(grepl("<script|<iframe|<link|<img", html))
  expect_match(html, "Showing 4 of", fixed = TRUE)
  expect_match(html, "dispersion", fixed = TRUE)
  expect_false(grepl("\\{\\{[a-z]+\\}\\}", html))
  expect_error(sl_report(records, path), "Report exists")
  expect_message(sl_report(records, path, overwrite = TRUE), "Report written")
  expect_match(paste(readLines(path), collapse = "\n"), "No estimates supplied")
})

test_that("reports reject invalid paths and mismatched provenance", {
  x <- sl_sample()
  path <- tempfile(fileext = ".html")
  expect_error(sl_report(x, file.path(tempfile(), "x.html")), "Invalid report")
  expect_error(sl_report(x, path, max_rows = 0), "Invalid report")
  expect_error(sl_report(x, path, estimates = list(x)), "uniquely named")
  expect_error(sl_report(x, path, estimates = list(bad = 1)), "must be tables")
  different <- x
  attr(different, "contract")$source <- "different source"
  expect_error(
    sl_report(x, path, list(different = different)),
    "source or classification"
  )
  expect_match(sl_report_table(data.frame(), 10), "No rows")
})
