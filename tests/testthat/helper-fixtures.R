# Synthetic records exercise edge cases; these are not the real bundled sample.
fixture_rows <- function(n = 3L, month = "2026-06") {
  if (n == 0L) {
    return(fixture_rows(1L, month)[FALSE, ])
  }
  x <- data.frame(
    Type = rep("Person search", n),
    Date = paste0(month, "-12T12:30:00+00:00"),
    "Part of a policing operation" = "False",
    "Policing operation" = NA_character_,
    Latitude = "53.8", Longitude = "-1.5", Gender = "Male",
    "Age range" = "18-24",
    "Self-defined ethnicity" = rep(c("W1", "B2", "NS"), length.out = n),
    "Officer-defined ethnicity" = "White",
    Legislation = "Police and Criminal Evidence Act 1984 (section 1)",
    "Object of search" = "Controlled drugs",
    Outcome = rep(c("A no further action disposal", "Arrest", NA),
      length.out = n
    ),
    "Outcome linked to object of search" = rep(c(
      "False", "True",
      NA
    ), length.out = n),
    "Removal of more than just outer clothing" = "False",
    check.names = FALSE
  )
  x
}

fixture_zip <- function(dir, archive = "2026-06", n = 3L) {
  staging <- file.path(dir, paste0("staging-", archive))
  dir.create(file.path(staging, "2026-06"), recursive = TRUE)
  for (force in c("west-yorkshire", "dyfed-powys")) {
    filename <- file.path("2026-06", paste0(
      "2026-06-", force,
      "-stop-and-search.csv"
    ))
    readr::write_csv(fixture_rows(n), file.path(staging, filename))
  }
  writeLines("ignored crime data", file.path(
    staging, "2026-06",
    "street.csv"
  ))
  target <- file.path(dir, paste0(archive, ".zip"))
  zip::zipr(target, files = "2026-06", root = staging)
  target
}

fixture_records <- function(dir) {
  fixture_zip(dir)
  sl_archive_snapshot(dir)
  sl_read_records(dir)
}
