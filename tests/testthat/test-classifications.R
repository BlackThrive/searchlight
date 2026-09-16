test_that("published archive labels retain Black and mixed ethnicity", {
  labels <- c(
    paste0(
      "Black/African/Caribbean/Black British - ",
      "Any other Black/African/Caribbean background"
    ),
    "Black/African/Caribbean/Black British - African",
    "Black/African/Caribbean/Black British - Caribbean",
    "Mixed/Multiple ethnic groups - White and Black African",
    paste0(
      "Mixed/Multiple ethnic groups - ",
      "Any other Mixed/Multiple ethnic background"
    ),
    "Other ethnic group - Not stated"
  )
  mapped <- sl_map_ethnicity(labels)
  expect_equal(
    as.character(mapped$ethnicity_5),
    c("Black", "Black", "Black", "Mixed", "Mixed", "Unknown")
  )
  expect_equal(
    as.character(mapped$ethnicity_19),
    c(
      "Other Black", "African", "Caribbean", "White and Black African",
      "Other Mixed", "Unknown"
    )
  )
  sample <- sl_sample()
  source_black <- grepl(
    "^Black/African/Caribbean/Black British -",
    sample$self_defined_ethnicity_raw
  )
  expect_gt(sum(source_black), 0)
  expect_true(all(sample$ethnicity_5[source_black] == "Black"))
  expect_warning(unmapped <- sl_map_ethnicity("New source label"),
    class = "searchlight_warning_classification"
  )
  expect_equal(as.character(unmapped$ethnicity_5), "Unknown")
})

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
