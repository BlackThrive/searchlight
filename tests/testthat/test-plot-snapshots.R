test_that("coverage and spatial maps retain visual snapshots", {
  skip_on_cran()
  skip_if_not_installed("vdiffr")
  vdiffr::expect_doppelganger(
    "coverage with missing force",
    plot(sl_coverage(sl_sample()))
  )
  path <- system.file("extdata", "example-spatial.rds", package = "searchlight")
  vdiffr::expect_doppelganger(
    "crude and spatial disparity",
    plot(readRDS(path))
  )
})
