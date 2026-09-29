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

test_that("tiny values do not expand every numeric cell in a report column", {
  values <- data.frame(value = c(0.123456, 1.23456e-100, 0, Inf, NA_real_))
  html <- xml2::read_html(sl_report_table(values, 10))
  cells <- xml2::xml_text(xml2::xml_find_all(html, ".//td"))
  expect_equal(cells, c("0.12346", "1.2346e-100", "0", "Inf", "NA"))
  expect_true(all(nchar(cells) <= 12L))
})

test_that("report summaries separate filtered records and source coverage", {
  records <- sl_sample()
  subset <- records[which(records$ethnicity_5 == "Unknown")[1:2], ]
  html <- xml2::read_html(sl_report_overview(subset, sl_coverage(subset)))
  values <- xml2::xml_text(xml2::xml_find_all(
    html, ".//dd[@class='metric-value']"
  ))
  expect_equal(values, c("2", "100.0%", "3 / 6"))
  expect_match(xml2::xml_text(html), "3 missing force-months", fixed = TRUE)
  empty <- sl_report_overview(records[FALSE, ], sl_coverage(records))
  expect_match(empty, "Not available", fixed = TRUE)
  expect_false(grepl("NaN|Inf%", empty))
})

test_that("report navigation and disclosures retain accessible audit content", {
  path <- file.path(withr::local_tempdir(), "report.html")
  suppressMessages(sl_report(sl_sample(), path))
  html <- xml2::read_html(path)
  anchors <- xml2::xml_attr(xml2::xml_find_all(
    html, ".//a[starts-with(@href, '#')]"
  ), "href")
  ids <- xml2::xml_attr(xml2::xml_find_all(html, ".//*[@id]"), "id")
  expect_true(all(substring(anchors, 2) %in% ids))
  expect_equal(length(ids), length(unique(ids)))
  expect_length(xml2::xml_find_all(html, ".//h1"), 1L)
  expect_length(xml2::xml_find_all(html, ".//main"), 1L)
  expect_true(length(xml2::xml_find_all(html, ".//details//table")) > 0L)
  sources <- xml2::xml_text(xml2::xml_find_first(html, ".//details//pre"))
  expect_match(sources, "sha256")
  tables <- xml2::xml_find_all(html, ".//table/..")
  expect_true(all(xml2::xml_attr(tables, "tabindex") == "0"))
  expect_true(all(nzchar(xml2::xml_attr(tables, "aria-label"))))
  headers <- xml2::xml_find_all(html, ".//th[@title='n_records']")
  expect_true(all(xml2::xml_text(headers) == "Recorded events"))
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
