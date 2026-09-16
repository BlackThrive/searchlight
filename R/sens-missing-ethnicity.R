#' Bound disparity under allocations of Unknown ethnicity
#'
#' Extreme allocations send every Unknown event to one of the two groups.
#' Proportional allocation uses all known groups, not only the comparison pair.
#' force_object_mar uses known-group shares within force and object, pooled over
#' areas and months; it refuses strata with no known ethnicity. These are
#' assumptions, not confidence intervals.
#' Force/object allocation also assumes pooled known composition applies to each
#' recipient area/month; MAR alone does not establish that transportability.
#' The tipping share solves the equation where the ratio equals one, with all
#' remaining Unknown sent to the reference.
#' A tipping value outside zero to one means no feasible tipping allocation.
#' @param counts Contract-bearing event counts.
#' @param population Marginal ethnic-group exposure table.
#' @param reference,comparison Groups to compare.
#' @param scenarios Allocation assumptions to report.
#' @return An sl_sensitivity tibble with scenario ratios, extreme bounds,
#'   tipping allocation and separately labelled baseline sampling intervals.
#' @family sensitivity
#' @seealso [sl_rates()], [sl_denominator_scenarios()]
#' @export
#' @examples
#' c <- readRDS(system.file("extdata", "example-counts.rds",
#'   package = "searchlight"
#' ))
#' p <- readRDS(system.file("extdata", "sample-population.rds",
#'   package = "searchlight"
#' ))$msoa21
#' head(sl_missing_ethnicity_bounds(c, p))
sl_missing_ethnicity_bounds <- function(counts, population,
                                        reference = "White",
                                        comparison = "Black",
                                        scenarios = c(
                                          "all_to_reference",
                                          "all_to_comparison", "proportional",
                                          "force_object_mar"
                                        )) {
  sl_validate_pair(reference, comparison)
  choices <- c(
    "all_to_reference", "all_to_comparison", "proportional",
    "force_object_mar"
  )
  if (!length(scenarios) || any(!scenarios %in% choices)) {
    sl_abort("Unknown missing-ethnicity allocation scenario.")
  }
  if (any(c("age_band", "sex") %in% names(population))) {
    sl_abort("Bounds require marginal ethnicity exposures.")
  }
  contract <- sl_contract(counts)
  collapsed <- sl_collapse_counts(counts)
  rates <- sl_rates(collapsed, population)
  baseline <- sl_rate_ratio(rates, reference, comparison)
  data <- tibble::as_tibble(counts)
  data <- data[!is.na(data$n), ]
  mar_available <- "object_group" %in% names(data)
  if ("force_object_mar" %in% scenarios && !mar_available) {
    cli::cli_inform("MAR unavailable: retain object_group in counts.")
  }
  if ("force_object_mar" %in% scenarios && mar_available) {
    known <- data[data$ethnicity != "Unknown", ]
    shares <- dplyr::summarise(
      dplyr::group_by(
        known, .data$force_id,
        .data$object_group
      ),
      known = sum(.data$n),
      reference_total = sum(.data$n[.data$ethnicity == reference]),
      comparison_total = sum(.data$n[.data$ethnicity == comparison]),
      .groups = "drop"
    )
    shares$reference_share <- shares$reference_total / shares$known
    shares$comparison_share <- shares$comparison_total / shares$known
    data <- dplyr::left_join(data, shares, by = c("force_id", "object_group"))
    bad <- data$ethnicity == "Unknown" & data$n > 0 &
      (!is.finite(data$known) | data$known == 0)
    if (any(bad)) {
      sl_abort("MAR allocation has a stratum without known ethnicity.")
    }
  }
  rows <- lapply(seq_len(nrow(baseline)), function(i) {
    b <- baseline[i, ]
    same_area <- if (is.na(b$geography_code)) {
      is.na(data$geography_code)
    } else {
      !is.na(data$geography_code) & data$geography_code == b$geography_code
    }
    ix <- data$force_id == b$force_id & same_area
    d <- data[which(ix), ]
    seen <- nrow(d) > 0L
    unknown <- if (seen) sum(d$n[d$ethnicity == "Unknown"]) else NA_real_
    known <- if (seen) sum(d$n[d$ethnicity != "Unknown"]) else NA_real_
    nr <- b$n_reference
    nc <- b$n_comparison
    er <- b$exposure_reference
    ec <- b$exposure_comparison
    ratio <- function(r, c) {
      if (anyNA(c(r, c)) || er <= 0 || ec <= 0 || r + c == 0) {
        NA_real_
      } else {
        (c / ec) / (r / er)
      }
    }
    lower <- ratio(nr + unknown, nc)
    upper <- ratio(nr, nc + unknown)
    tipping <- if (is.finite(unknown) && unknown > 0 && er > 0 && ec > 0) {
      (ec * (nr + unknown) - er * nc) / (unknown * (er + ec))
    } else {
      NA_real_
    }
    dplyr::bind_rows(lapply(unique(scenarios), function(scenario) {
      shares <- switch(scenario,
        all_to_reference = c(1, 0),
        all_to_comparison = c(0, 1),
        proportional = if (is.finite(known) && known > 0) {
          c(nr, nc) / known
        } else {
          c(NA_real_, NA_real_)
        },
        force_object_mar = {
          if (!mar_available) {
            c(NA_real_, NA_real_)
          } else {
            u <- d[d$ethnicity == "Unknown" & d$n > 0, ]
            if (is.finite(unknown) && unknown > 0) {
              c(
                sum(u$n * u$reference_share),
                sum(u$n * u$comparison_share)
              ) / unknown
            } else {
              c(0, 0)
            }
          }
        }
      )
      allocated <- unknown * shares
      if (isTRUE(unknown == 0)) allocated <- c(0, 0)
      tibble::tibble(
        force_id = b$force_id, geography_code = b$geography_code,
        scenario = scenario,
        ratio = ratio(nr + allocated[1], nc + allocated[2]),
        unknown = unknown, allocated_reference = allocated[1],
        allocated_comparison = allocated[2], lower_bound = lower,
        upper_bound = upper, tipping_allocation = tipping,
        available = seen && (scenario != "force_object_mar" || mar_available),
        tipping_feasible = is.finite(tipping) && tipping >= 0 && tipping <= 1,
        observed_ratio = b$ratio, conf_low = b$conf_low, conf_high = b$conf_high
      )
    }))
  })
  result <- sl_sensitivity(
    dplyr::bind_rows(rows), contract,
    "baseline exact Poisson intervals conditional on recorded ethnicity",
    "lower_bound and upper_bound allocate all Unknown between the two groups"
  )
  attr(result, "sampling") <- baseline
  result
}

#' @noRd
sl_collapse_counts <- function(counts, strata = character()) {
  contract <- sl_contract(counts)
  keys <- c(
    "force_id", "month", "geography_code", "ethnicity", "status",
    "months_submitted", strata
  )
  result <- dplyr::summarise(
    dplyr::group_by(
      tibble::as_tibble(counts),
      dplyr::across(dplyr::all_of(keys))
    ),
    n = if (all(is.na(.data$n))) NA_real_ else sum(.data$n, na.rm = TRUE),
    .groups = "drop"
  )
  contract$analysis$strata <- c("force_id", "geography_code")
  sl_carry(result, contract, "sl_counts")
}

#' @noRd
sl_sensitivity <- function(data, contract, sampling, assumptions) {
  attr(data, "sampling_description") <- sampling
  attr(data, "assumption_description") <- assumptions
  sl_carry(data, contract, "sl_sensitivity")
}

#' @export
print.sl_sensitivity <- function(x, ...) {
  sampling <- attr(x, "sampling")
  if (is.null(sampling)) sampling <- x
  limits <- if (all(c("rank_low", "rank_high") %in% names(x))) {
    c("rank_low", "rank_high")
  } else {
    c("conf_low", "conf_high")
  }
  interval <- sl_interval_text( # nolint: object_usage_linter.
    sampling, limits
  )
  range <- sl_interval_text( # nolint: object_usage_linter.
    x, c("lower_bound", "upper_bound")
  )
  cli::cli_text("sampling uncertainty: {interval}")
  cli::cli_text("  {attr(x, 'sampling_description')}")
  cli::cli_text("assumption range: {range}")
  cli::cli_text("  {attr(x, 'assumption_description')}")
  NextMethod("print")
}

#' @noRd
sl_interval_text <- function(x, limits) {
  if (!all(limits %in% names(x))) {
    return("not evaluated")
  }
  keys <- intersect(c("geography_code", "ethnicity"), names(x))
  rows <- unique(as.data.frame(x)[c(keys, limits)])
  if (!nrow(rows)) {
    return("no estimable rows")
  }
  shown <- utils::head(rows, 3)
  label <- if (length(keys)) {
    do.call(paste, c(shown[keys], sep = "/"))
  } else {
    as.character(seq_len(nrow(shown)))
  }
  values <- sprintf(
    "%s [%.3g, %.3g]", label, shown[[limits[1]]],
    shown[[limits[2]]]
  )
  if (nrow(rows) > 3) values <- c(values, "... see table for remaining areas")
  paste(values, collapse = "; ")
}
