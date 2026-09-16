fixture_counts <- function(n = c(20, 10, 40), area = "a", month = "2026-01") {
  data <- tibble::tibble(
    force_id = "west-yorkshire", month = month,
    geography_code = area, ethnicity = c("White", "Black", "Unknown"), n = n,
    months_submitted = 1L, status = "submitted"
  )
  ct <- sl_new_contract()
  ct$source <- "synthetic known-answer fixture"
  ct$analysis <- list(
    geography = "msoa21", classification = "5",
    scheme = "self-defined", strata = c("force_id", "geography_code")
  )
  ct$coverage <- unique(data[c("force_id", "month", "status")])
  sl_carry(data, ct, "sl_counts")
}

fixture_population <- function(area = "a", p = c(1000, 200, NA)) {
  sl_exposure(tibble::tibble(
    geography_code = area,
    ethnicity = c("White", "Black", "Unknown"), population = p
  ), "msoa21")
}
