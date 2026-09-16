fixture_polygons <- function() {
  square <- matrix(c(
    430000, 430000, 431000, 430000, 431000, 431000,
    430000, 431000, 430000, 430000
  ), ncol = 2, byrow = TRUE)
  sf::st_sf(
    geography_code = "E01000001", geography_name = "test",
    geometry = sf::st_sfc(sf::st_polygon(list(square)), crs = 27700)
  )
}

test_that("ten-metre boundary distance is measured in projected coordinates", {
  b <- fixture_polygons()
  point <- sf::st_sfc(sf::st_point(c(430010, 430500)), crs = 27700)
  ll <- sf::st_coordinates(sf::st_transform(point, 4326))
  x <- sl_sample()[1:2, ]
  x$longitude <- c(ll[1, 1], NA)
  x$latitude <- c(ll[1, 2], NA)
  result <- sl_assign_geography(x, list(lsoa21 = b))
  expect_equal(result$lsoa21, c("E01000001", NA))
  expect_equal(result$lsoa21_boundary_distance_m[1], 10, tolerance = 0.02)
  expect_true(result$lsoa21_boundary_sensitive[1])
  expect_equal(nrow(result), nrow(x))
  quality <- sl_contract(result)$assignment_quality
  expect_equal(quality$missing_coordinate_share[quality$type == "lsoa21"], 0.5)
  metadata <- sl_contract(result)$geography$lsoa21
  expect_equal(metadata$assignment_crs, "EPSG:27700")
  repeated <- sl_assign_geography(x[c(1, 1, 1, 2, 2), ], list(lsoa21 = b))
  expect_equal(nrow(repeated), 5L)
  expect_equal(
    repeated$lsoa21,
    c(rep("E01000001", 3), NA, NA)
  )
  expect_equal(repeated$lsoa21_boundary_distance_m[1:3], rep(10, 3),
    tolerance = 0.02
  )
  repeated_quality <- sl_contract(repeated)$assignment_quality
  expect_equal(repeated_quality$missing_coordinate_share[
    repeated_quality$type == "lsoa21"
  ], 0.4)
  expect_error(sl_assign_geography(x, b), "metadata")
  attr(b, "geography_metadata") <- list(type = "lsoa21")
  expect_equal(sl_assign_geography(x, b)$lsoa21, result$lsoa21)
  expect_error(sl_assign_geography(x, list(lsoa21 = b), "ward"))
  expect_error(sl_assign_geography(x, list(lsoa21 = b), threshold = -1))
  duplicate <- rbind(b, b)
  expect_error(sl_assign_geography(x, list(lsoa21 = duplicate)))
  x$latitude <- NA_real_
  expect_true(all(is.na(sl_assign_geography(x, list(lsoa21 = b))$lsoa21)))
  expect_equal(nrow(sl_assign_geography(x[FALSE, ], list(lsoa21 = b))), 0)
  overlap <- rbind(b, b)
  overlap$geography_code[2] <- "E01000002"
  x$latitude[1] <- ll[1, 2]
  result <- sl_assign_geography(x, list(lsoa21 = overlap))
  expect_true(result$lsoa21_ambiguous[1])
})

test_that("exposure validates unknowns, strata and measurement metadata", {
  x <- tibble::tibble(
    geography_code = "a", ethnicity = c("White", "Unknown"),
    population = c(100, NA)
  )
  p <- sl_exposure(x, "example")
  expect_s3_class(p, "sl_exposure")
  expect_equal(sl_contract(p)$population$classification, "5")
  expect_equal(sl_contract(p)$population$source, "user_supplied")
  expect_error(sl_exposure(dplyr::bind_rows(x, x), "example"), "Duplicate")
  x$population[2] <- 0
  expect_error(sl_exposure(x, "example"), "Unknown")
  x$ethnicity[2] <- "made up"
  expect_error(sl_exposure(x, "example"), "labels")
  expect_error(sl_population("area 1"))
  expect_null(sl_population_crosstab("E23000010"))
  b <- fixture_polygons()
  attr(b, "geography_metadata") <- list(type = "lad", vintage = "2026-05")
  expect_error(sl_population(b), "Census 2021")
})
