# Match httptest2's documented fixture convention (URL plus query digest).
fixture_http <- function(dir, url, body, json = FALSE) {
  parts <- strsplit(sub("^https?://", "", url), "?", fixed = TRUE)[[1]]
  name <- parts[1]
  if (length(parts) > 1L) {
    name <- paste0(name, "-", substr(digest::digest(parts[2]), 1, 6))
  }
  path <- file.path(dir, paste0(name, if (json) ".json" else ".txt"))
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(body, path, useBytes = TRUE)
  path
}

fixture_nomis_url <- function(cross = FALSE) {
  table <- if (cross) "NM_2132_1" else "NM_2041_1"
  query <- list(
    geography = "E02002330", c2021_eth_20 = "1...19",
    measures = 20100, recordlimit = 25000
  )
  if (cross) {
    query$c2021_age_6 <- "1...5"
    query$c_sex <- "1,2"
  }
  sl_query_url(paste0(
    "https://www.nomisweb.co.uk/api/v01/dataset/", table,
    ".data.csv"
  ), query)
}

test_that("NOMIS fixtures retain stable Census codes across table orderings", {
  mocks <- withr::local_tempdir()
  cache <- withr::local_tempdir()
  pop_path <- fixture_http(
    mocks, fixture_nomis_url(),
    readLines(test_path("fixtures", "nomis-ts021.csv"))
  )
  cross_path <- fixture_http(
    mocks, fixture_nomis_url(TRUE),
    readLines(test_path("fixtures", "nomis-rm032.csv"))
  )
  withr::local_envvar(NO_INTERNET_TEST = "")
  httptest2::with_mock_dir(mocks, {
    p <- sl_population("E02002330", dir = cache)
    expect_s3_class(p, "sl_exposure")
    expect_equal(nrow(p), 6L)
    expect_equal(p$population[p$ethnicity == "Unknown"], NA_real_)
    raw <- readr::read_csv(test_path("fixtures", "nomis-ts021.csv"),
      show_col_types = FALSE
    )
    white <- grepl("^White:", raw$C2021_ETH_20_NAME)
    expected <- sum(raw$OBS_VALUE[white])
    expect_equal(p$population[p$ethnicity == "White"], expected)
    expect_identical(sl_population("E02002330", dir = cache), p)
    detailed <- sl_population("E02002330", "19", cache)
    expect_equal(nrow(detailed), 20L)
    b <- sf::st_sf(geography_code = "E02002330", geometry = sf::st_sfc(
      sf::st_point(c(0, 0)),
      crs = 4326
    ))
    expect_equal(sl_population(b, dir = cache)$population, p$population)
    c <- sl_population_crosstab("E02002330", dir = cache)
    expect_equal(nrow(c), 36L)
    expect_setequal(c$age_band, c("under 25", "25-34", "35+"))
    expect_setequal(c$sex, c("Female", "Male"))
    raw <- readr::read_csv(test_path("fixtures", "nomis-rm032.csv"),
      show_col_types = FALSE
    )
    white <- grepl("^White:", raw$C2021_ETH_20_NAME)
    expect_equal(
      sum(c$population[c$ethnicity == "White"]),
      sum(raw$OBS_VALUE[white])
    )
    writeLines("<html>unavailable</html>", pop_path)
    expect_null(sl_population("E02002330", dir = withr::local_tempdir()))
    rows <- readLines(test_path("fixtures", "nomis-ts021.csv"))
    writeLines(rows[-length(rows)], pop_path)
    expect_null(sl_population("E02002330", dir = withr::local_tempdir()))
    writeLines(gsub(",822,", ",NA,", rows, fixed = TRUE), pop_path)
    # Explicit unmapped cell, not a fabricated denominator.
    raw <- read.csv(test_path("fixtures", "nomis-ts021.csv"))
    raw$C2021_ETH_20_CODE[1] <- "_999"
    readr::write_csv(raw, pop_path)
    expect_null(sl_population("E02002330", dir = withr::local_tempdir()))
    expect_true(file.exists(cross_path))
  })
})

test_that("ONS fixtures exercise metadata, caching and offline paths", {
  mocks <- withr::local_tempdir()
  cache <- withr::local_tempdir()
  layer <- sl_table("ons-layers.csv")[1, ]
  base <- sl_arc_base(layer$service)
  fixture_http(
    mocks, paste0(base, "?f=json"),
    '{"objectIdField":"FID"}', TRUE
  )
  query <- list(
    f = "geojson", where = "LSOA21CD IN ('E01000001')",
    outFields = "*", outSR = 4326, orderByFields = "FID",
    resultOffset = 0L, resultRecordCount = 500
  )
  url <- sl_query_url(paste0(base, "/query"), query)
  feature <- list(type = "Feature", properties = list(
    FID = 1L,
    LSOA21CD = "E01000001", LSOA21NM = "test"
  ), geometry = list(
    type = "Polygon", coordinates = list(list(
      c(-1, 53), c(-1, 54),
      c(0, 54), c(0, 53), c(-1, 53)
    ))
  ))
  payload <- list(type = "FeatureCollection", features = list(feature))
  body <- jsonlite::toJSON(payload, auto_unbox = TRUE)
  path <- fixture_http(mocks, url, body, TRUE)
  tables <- list(
    OA_LSOA_MSOA_EW_DEC_2021_LU_v3 = c("LSOA21CD", "MSOA21CD", "LAD22CD"),
    LAD25_CSP25_PFA25_EW_LU = c("LAD25CD", "PFA25CD", "PFA25NM"),
    WD26_LAD26_UK_LU = c("WD26CD", "LAD26CD"),
    LSOA21_BUA22_LAD22_RGN22_EW_LU_v2 = c("LSOA21CD", "LAD22CD", "RGN22CD")
  )
  for (service in names(tables)) {
    fields <- tables[[service]]
    where <- if (service == "WD26_LAD26_UK_LU") {
      "WD26CD LIKE 'E%' OR WD26CD LIKE 'W%'"
    } else {
      "1=1"
    }
    table_url <- sl_query_url(paste0(sl_arc_base(service), "/query"), list(
      f = "json", where = where, outFields = paste(fields, collapse = ","),
      returnGeometry = "false", returnDistinctValues = "true",
      orderByFields = paste(fields, collapse = ","),
      resultOffset = 0L, resultRecordCount = 1000
    ))
    attributes <- as.list(stats::setNames(
      rep("E01000001", length(fields)),
      fields
    ))
    data <- list(features = list(list(attributes = attributes)))
    body <- jsonlite::toJSON(data, auto_unbox = TRUE)
    fixture_http(mocks, table_url, body, TRUE)
  }
  withr::local_envvar(NO_INTERNET_TEST = "")
  httptest2::with_mock_dir(mocks, {
    b <- sl_boundaries("lsoa21", dir = cache, codes = "E01000001")
    expect_s3_class(b, "sf")
    expect_equal(attr(b, "geography_metadata")$vintage, "2021-12")
    expect_equal(nrow(attr(b, "lookups")$census_hierarchy), 1L)
    cached <- sl_boundaries("lsoa21", dir = cache, codes = "E01000001")
    expect_identical(cached, b)
    expect_equal(nrow(sl_lookups(cache)$census_hierarchy), 1L)
    expect_error(sl_boundaries("bad", dir = cache))
    expect_error(sl_boundaries("lsoa21", "1900-01", dir = cache))
    expect_error(sl_boundaries("lsoa21", codes = "not a code", dir = cache))
    writeLines('{"error":{"message":"unavailable"}}', path)
    expect_null(sl_boundaries("lsoa21",
      dir = withr::local_tempdir(),
      codes = "E01000001", lookups = FALSE
    ))
    writeLines('{"type":"FeatureCollection","features":[]}', path)
    expect_null(sl_boundaries("lsoa21",
      dir = withr::local_tempdir(),
      codes = "E01000001", lookups = FALSE
    ))
    payload$features <- list(feature, feature)
    writeLines(jsonlite::toJSON(payload, auto_unbox = TRUE), path)
    expect_error(sl_boundaries(
      "lsoa21",
      dir = withr::local_tempdir(),
      codes = "E01000001", lookups = FALSE
    ), class = "searchlight_error_source")
    feature$properties$LSOA21CD <- "E01000002"
    payload$features <- list(feature)
    writeLines(jsonlite::toJSON(payload, auto_unbox = TRUE), path)
    expect_warning(sl_boundaries(
      "lsoa21",
      dir = withr::local_tempdir(),
      codes = "E01000001", lookups = FALSE
    ), class = "searchlight_warning_geography")
  })
  withr::local_envvar(NO_INTERNET_TEST = "true")
  expect_null(sl_boundaries("lsoa21", dir = withr::local_tempdir()))
  expect_null(sl_population("E02002330", dir = withr::local_tempdir()))
  expect_null(sl_population_crosstab("E02002330", dir = withr::local_tempdir()))
  expect_null(sl_lookups(withr::local_tempdir()))
})
