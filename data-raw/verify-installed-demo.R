# Install a built archive into a new library and exercise its public interface.
# Run from the repository root with an optional archive and output directory.
args <- commandArgs(trailingOnly = TRUE)
archive <- normalizePath(if (length(args)) {
  args[1]
} else {
  "searchlight_0.1.0.tar.gz"
}, winslash = "/", mustWork = TRUE)
output <- if (length(args) >= 2L) {
  args[2]
} else {
  "../searchlight-demo-2026-09-22"
}
dir.create(output, recursive = TRUE, showWarnings = FALSE)
output <- normalizePath(output, winslash = "/")
Sys.setenv(
  NO_INTERNET_TEST = "true", VROOM_THREADS = "2", OMP_NUM_THREADS = "2",
  OPENBLAS_NUM_THREADS = "2"
)
options(width = 110, tibble.width = 110)
library_dir <- tempfile("searchlight-installed-demo-")
dir.create(library_dir)
install_log <- file.path(output, "installation.log")
started <- Sys.time()
status <- system2(file.path(R.home("bin"), "R.exe"), c(
  "CMD", "INSTALL", paste0("--library=", shQuote(library_dir)), shQuote(archive)
), stdout = install_log, stderr = install_log)
stopifnot(status == 0L)
.libPaths(c(library_dir, .libPaths()))
library(searchlight, lib.loc = library_dir)
stopifnot(identical(
  normalizePath(find.package("searchlight")),
  normalizePath(file.path(library_dir, "searchlight"))
))
cat("Fresh installation loaded:", as.character(packageVersion("searchlight")), "\n")
data_file <- function(x) system.file("extdata", x, package = "searchlight")

# Reparse the packaged raw CSVs, then use the sample's original ONS assignments.
versions <- sl_select_version(sl_list_versions(data_file("sample")))
parsed <- sl_read_records(data_file("sample"), versions)
records <- sl_sample()
stopifnot(
  nrow(parsed) == nrow(records),
  identical(
    table(parsed$month, parsed$ethnicity_5),
    table(records$month, records$ethnicity_5)
  )
)
coverage <- sl_coverage(records)
stopifnot(all(is.na(coverage$n_records[coverage$status == "missing"])))
timestamps <- sl_timestamp_quality(records)
locations <- sl_location_quality(records)
population <- readRDS(data_file("sample-population.rds"))$msoa21
records <- sl_quality(records, population)
area <- names(sort(table(records$msoa21), decreasing = TRUE))[1:4]
units <- sl_contract(records)$units
units <- units[units$msoa21 %in% area, ]
subset <- records[records$msoa21 %in% area, ]
counts <- sl_counts(subset,
  by = c("msoa21", "ethnicity_5"),
  units = units, forces = "west-yorkshire"
)
stopifnot(sum(counts$n) == nrow(subset))
rates <- sl_rates(counts, population)
ratios <- sl_rate_ratio(rates)
stopifnot(nrow(ratios) == 4L)
object_counts <- sl_counts(subset,
  by = c("msoa21", "ethnicity_5", "object_group"),
  units = units, forces = "west-yorkshire"
)
bounds <- sl_missing_ethnicity_bounds(object_counts, population)
ranking <- sl_ranking_stability(ratios[ratios$n_comparison > 0, ], n = 200)
regression <- sl_count_model(rates, n ~ ethnicity)
outcomes <- sl_hit_rates(records)

# Geographic assignment is exercised on compact example polygons separately.
boundaries <- readRDS(data_file("sample-boundaries.rds"))
assigned <- sl_assign_geography(parsed[1:25, ], boundaries, types = "msoa21")
stopifnot(nrow(assigned) == 25L, "msoa21" %in% names(assigned))

# Exercise the documented time-quality guard without inventing an estimate.
date_only <- records[1:10, ]
day <- as.Date(date_only$date, tz = "Europe/London")
date_only$date <- as.POSIXct(paste(day, "00:00:00"), tz = "Europe/London")
date_only$date_raw <- format(date_only$date, "%Y-%m-%dT%H:%M:%S%z")
date_only <- sl_quality(date_only)
gated <- sl_veil_of_darkness(date_only)
stopifnot(
  nrow(gated) == 1L, is.na(gated$odds_ratio), gated$n == 0L,
  nrow(attr(gated, "excluded_force_months")) > 0L
)

ratio_table <- ratios[c(
  "geography_code", "n_reference", "n_comparison",
  "ratio", "conf_low", "conf_high", "unknown_events"
)]
tables <- list(
  coverage = coverage, timestamp_quality = timestamps,
  location_quality = locations, counts = counts, rates = rates,
  rate_ratios = ratio_table, missing_ethnicity = bounds,
  ranking = ranking, count_regression = regression, outcomes = outcomes
)
for (name in names(tables)) {
  value <- as.data.frame(tables[[name]])
  value <- value[!vapply(value, is.list, logical(1))]
  utils::write.csv(value, file.path(output, paste0(name, ".csv")), row.names = FALSE)
}
saveRDS(list(records = records, tables = tables), file.path(output, "analysis.rds"))

coverage_plot <- plot(coverage)
ggplot2::ggsave(file.path(output, "coverage.png"), coverage_plot,
  width = 9, height = 3.5, dpi = 160, bg = "white"
)

# A presentation chart made from the returned ratio table, not an automatic UI.
ratio_plot <- ggplot2::ggplot(ratio_table, ggplot2::aes(y = geography_code)) +
  ggplot2::geom_vline(xintercept = 1, colour = "#798C93", linetype = "dashed") +
  ggplot2::geom_segment(ggplot2::aes(
    x = conf_low, xend = conf_high,
    yend = geography_code
  ), linewidth = 1, colour = "#167D8D") +
  ggplot2::geom_point(ggplot2::aes(x = ratio), size = 3.5, colour = "#123F49") +
  ggplot2::scale_x_continuous(limits = c(0, NA), expand = ggplot2::expansion(mult = c(.015, .05))) +
  ggplot2::labs(
    title = "Black-to-White recorded stop-rate ratios",
    subtitle = "Four example MSOAs in West Yorkshire | May-July 2026",
    x = "Event-rate ratio and exact 95% Poisson sampling interval", y = "MSOA code",
    caption = paste("Resident Census exposure; three submitted months.",
      "These intervals do not cover missing-ethnicity assumptions.",
      sep = "\n"
    )
  ) +
  ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(
    plot.title = ggplot2::element_text(face = "bold"),
    plot.caption = ggplot2::element_text(hjust = 0), panel.grid.minor = ggplot2::element_blank()
  )
ggplot2::ggsave(file.path(output, "rate-ratios.png"), ratio_plot,
  width = 9, height = 4.6, dpi = 160, bg = "white"
)

report <- file.path(output, "searchlight-report.html")
sl_report(records, report,
  estimates = list(
    "Four-MSOA event-rate ratios" = ratios,
    "Missing-ethnicity allocation" = bounds,
    "Count regression" = regression,
    "Three separate outcomes" = outcomes
  ), title = "Stop and search: West Yorkshire sample",
  assumptions = "Resident Census 2021 exposure is held fixed over the submitted months.",
  limitations = c(
    "Rates, bounds and count regression cover the four sample MSOAs with most recorded events.",
    "Outcome summaries use all 4,657 bundled events; the analyses have different scopes.",
    "All three requested Dyfed-Powys submissions are missing.",
    "The sample is a demonstration, not a national estimate or proof of discrimination."
  ), overwrite = TRUE
)
html <- xml2::read_html(report)
stopifnot(
  length(xml2::xml_find_all(html, ".//table")) > 0L,
  !length(xml2::xml_find_all(html, ".//script|.//link|.//iframe|.//img")),
  grepl("Sampling uncertainty", xml2::xml_text(html), fixed = TRUE),
  grepl("Assumption range", xml2::xml_text(html), fixed = TRUE),
  !any(grepl(
    "[0-9]\\.[0-9]{20,}",
    xml2::xml_text(xml2::xml_find_all(html, ".//td"))
  ))
)
vignettes <- vignette(package = "searchlight")$results
stopifnot(nrow(vignettes) == 4L)
capture.output(citation("searchlight"), file = file.path(output, "citation.txt"))
capture.output(sessionInfo(), file = file.path(output, "session-info.txt"))
capture.output(
  {
    cat("SUBMISSION COVERAGE\n")
    print(coverage[c("force_id", "month", "n_records", "status")], n = Inf)
    cat("\nBLACK-TO-WHITE EVENT-RATE RATIOS\n")
    print(ratio_table, n = Inf)
    cat("\nMISSING-ETHNICITY SCENARIOS\n")
    print(bounds, n = Inf)
    cat("\nDATE-ONLY TIMESTAMP SAFEGUARD\n")
    print(gated)
  },
  file = file.path(output, "console-output.txt")
)
summary <- list(
  checked = as.character(Sys.time()), source_sha256 = digest::digest(file = archive, algo = "sha256"),
  package_version = as.character(packageVersion("searchlight")),
  installation = "Fresh temporary package library; existing dependency libraries reused",
  installed_package_path_verified = TRUE, offline_analysis = TRUE,
  records = nrow(records), parsed_raw_records = nrow(parsed),
  unknown_ethnicity = sum(records$ethnicity_5 == "Unknown"),
  submitted_force_months = sum(coverage$status != "missing"),
  missing_force_months = sum(coverage$status == "missing"),
  rate_analysis_areas = area, rate_analysis_records = nrow(subset),
  installed_vignettes = nrow(vignettes), date_only_guard_passed = TRUE,
  report_tables = length(xml2::xml_find_all(html, ".//table")),
  elapsed_seconds = as.numeric(difftime(Sys.time(), started, units = "secs")),
  passed = TRUE, output = output
)
jsonlite::write_json(summary, file.path(output, "verification.json"),
  pretty = TRUE, auto_unbox = TRUE
)
print(summary)
print(ratio_table, n = Inf)
