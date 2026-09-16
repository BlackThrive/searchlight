test_that("bundled force list contains the default forces", {
  force_text <- readLines(system.file(
    "extdata", "forces.json",
    package = "searchlight"
  ))
  expect_true(any(grepl("west-yorkshire", force_text, fixed = TRUE)))
  expect_true(any(grepl("dyfed-powys", force_text, fixed = TRUE)))
})

test_that("Census mapping has 19 distinct groups and retained Unknown", {
  mapping <- read.csv(system.file(
    "extdata", "ethnicity.csv",
    package = "searchlight"
  ))
  expect_equal(nrow(mapping), 20L)
  expect_equal(anyDuplicated(mapping$police_code), 0L)
  expect_equal(sort(na.omit(mapping$census_code)), 1:19)
  expect_setequal(
    mapping$ethnicity_5,
    c("Asian", "Black", "Mixed", "White", "Other", "Unknown")
  )
  expect_equal(mapping$ethnicity_19[mapping$police_code == "W4"], "Roma")
  expect_equal(mapping$ethnicity_19[mapping$police_code == "O1"], "Arab")
})
