test_that("legislation groups distinguish exact section numbers", {
  raw <- tibble::as_tibble(fixture_rows(6))
  names(raw) <- gsub("[^a-z0-9]+", "_", tolower(names(raw)))
  names(raw)[names(raw) == "self_defined_ethnicity"] <-
    "self_defined_ethnicity_raw"
  raw$legislation <- c(
    "Police and Criminal Evidence Act 1984 (section 1)",
    "Police and Criminal Evidence Act 1984 (section 18)",
    "Misuse of Drugs Act 1971 (section 23)",
    "Criminal Justice and Public Order Act 1994 (section 60)",
    "Firearms Act 1968 (section 47)",
    "Terrorism Act 2000 (section 43)"
  )
  result <- sl_classify_records(raw)
  expect_equal(result$legislation_group, c(
    "PACE s.1", "Other", "Misuse of Drugs Act s.23", "CJPOA s.60",
    "Firearms Act", "Terrorism Act"
  ))
})
