#' List available bulk archive snapshots
#'
#' Parses advertised month ranges and publisher MD5 checksums. The complete
#' rolling snapshot can contain several years. Results are cached only after
#' this function is called. Source failures return `NULL` with a message.
#' @param dir Cache directory.
#' @param refresh Refresh the cached index.
#' @param url Archive listing URL, normally the official source.
#' @return A tibble with archive name, snapshot month, coverage range,
#' URL and MD5,
#'   or `NULL` if unavailable.
#' @family ingest
#' @seealso [sl_archive_download()]
#' @export
#' @examples
#' index <- readRDS(system.file("extdata", "archive-index.rds",
#'   package = "searchlight"
#' ))
#' index[, c("archive_file", "month_start", "month_end")]
sl_archive_index <- function(dir = sl_cache_dir(), refresh = FALSE,
                             url = "https://data.police.uk/data/archive/") {
  cache <- file.path(dir, "archive-index.rds")
  if (!refresh && file.exists(cache)) {
    return(readRDS(cache))
  }
  response <- sl_get(url)
  if (is.null(response)) {
    return(NULL)
  }
  doc <- xml2::read_html(httr2::resp_body_string(response))
  nodes <- xml2::xml_find_all(doc, ".//div[@class='download']")
  rows <- lapply(nodes, function(node) {
    href <- xml2::xml_attr(xml2::xml_find_first(node, ".//a"), "href")
    if (is.na(href) || !grepl("[0-9]{4}-[0-9]{2}\\.zip$", href)) {
      return(NULL)
    }
    range <- trimws(xml2::xml_text(xml2::xml_find_first(
      node, ".//p[@class='contained-range']"
    )))
    parts <- regmatches(range, regexec(
      "([A-Za-z]{3}) ([0-9]{4}) to ([A-Za-z]{3}) ([0-9]{4})", range
    ))[[1]]
    if (length(parts) != 5L) {
      sl_abort(
        "Archive coverage format changed; cannot infer dates.", "source"
      )
    }
    months <- match(parts[c(2, 4)], month.abb)
    if (anyNA(months)) {
      sl_abort(
        "Unrecognised archive month labels.", "source"
      )
    }
    tibble::tibble(
      archive_file = basename(href),
      snapshot_month = sub("\\.zip$", "", basename(href)),
      month_start = sprintf("%s-%02d", parts[3], months[1]),
      month_end = sprintf("%s-%02d", parts[5], months[2]),
      url = xml2::url_absolute(href, url),
      md5 = trimws(xml2::xml_text(xml2::xml_find_first(
        node, ".//p[@class='md5sum']"
      )))
    )
  })
  result <- dplyr::bind_rows(rows)
  if (!nrow(result)) {
    sl_abort(
      "Archive listing has no usable entries.", "source"
    )
  }
  result$checksum_is_md5 <- grepl("^[a-f0-9]{32}$", result$md5)
  sl_prepare_cache(dir)
  saveRDS(result, cache)
  result
}

#' Download and verify the necessary archive snapshots
#'
#' Selects the newest available snapshots that cover the requested months.
#' Forces are recorded as extraction filters; the source only offers full
#' ZIPs.
#' Checks publisher MD5 before recording local SHA-256. Existing files
#' must match
#' both the publisher and any recorded SHA-256; corrupt files are never
#' replaced
#' silently. The manifest and ZIPs are written to `dir`.
#' @param months Character vector of YYYY-MM months.
#' @param forces Force identifiers, or `NULL` for all forces.
#' @param dir Cache directory.
#' @param index Optional previously retrieved archive index.
#' @return Manifest tibble, or `NULL` when a resource is unavailable.
#' @family ingest
#' @seealso [sl_archive_snapshot()], [sl_list_versions()]
#' @export
#' @examples
#' index <- readRDS(system.file("extdata", "archive-index.rds",
#'   package = "searchlight"
#' ))
#' index$archive_file[1]
sl_archive_download <- function(months, forces = NULL, dir = sl_cache_dir(),
                                index = NULL) {
  months <- sl_months(months)
  if (!is.null(forces)) {
    known <- jsonlite::fromJSON(system.file(
      "extdata", "forces.json",
      package = "searchlight"
    ))$id
    if (anyNA(forces) || !length(forces) || any(!forces %in% known)) {
      sl_abort("Unknown force identifier in forces.")
    }
  }
  if (is.null(index)) index <- sl_archive_index(dir)
  if (is.null(index)) {
    return(NULL)
  }
  sl_require_columns(index, c(
    "archive_file", "snapshot_month", "month_start", "month_end", "url", "md5"
  ))
  index <- index[order(index$snapshot_month, decreasing = TRUE), ]
  valid <- grepl("^[a-f0-9]{32}$", index$md5)
  if (any(!valid)) {
    cli::cli_inform(
      "Skipping archives without a valid published MD5 checksum."
    )
    index <- index[valid, ]
  }
  if (any(!grepl("^[0-9]{4}-[0-9]{2}\\.zip$", index$archive_file))) {
    sl_abort("Unsafe archive filename.")
  }
  needed <- integer()
  remaining <- months
  for (i in seq_len(nrow(index))) {
    covered <- remaining >= index$month_start[i] &
      remaining <= index$month_end[i]
    if (any(covered)) {
      needed <- c(needed, i)
      remaining <- remaining[!covered]
    }
  }
  if (length(remaining)) {
    sl_abort(paste("No archive covers", paste(remaining, collapse = ", ")))
  }
  dir <- sl_prepare_cache(dir)
  manifest_path <- file.path(dir, "archive-manifest.rds")
  old <- if (file.exists(manifest_path)) {
    readRDS(
      manifest_path
    )
  } else {
    tibble::tibble()
  }
  rows <- list()
  for (i in needed) {
    item <- index[i, ]
    target <- file.path(dir, item$archive_file)
    previous <- if (nrow(
      old
    )) {
      old[old$archive_file == item$archive_file, ]
    } else {
      old
    }
    if (!file.exists(target)) {
      cli::cli_inform("Downloading {item$archive_file}.")
      partial <- tempfile("archive-", tmpdir = dir, fileext = ".part")
      response <- sl_get(item$url, partial)
      if (is.null(response)) {
        unlink(partial)
        return(NULL)
      }
      if (!identical(sl_hash(partial, "md5"), item$md5)) {
        unlink(partial)
        sl_abort(
          "Downloaded archive failed its published MD5 check.", "integrity"
        )
      }
      if (!file.rename(partial, target)) {
        sl_abort(
          "Cannot save downloaded ZIP."
        )
      }
    }
    sha <- sl_hash(target)
    changed <- nrow(previous) && !identical(sha, previous$sha256[[1]])
    if (!identical(sl_hash(target, "md5"), item$md5) || changed) {
      sl_abort(
        "Existing archive failed integrity checks; retained for review.",
        "integrity"
      )
    }
    item$sha256 <- sha
    item$downloaded_at <- if (nrow(
      previous
    )) {
      previous$downloaded_at
    } else {
      Sys.time()
    }
    item$requested_months <- list(months)
    item$requested_forces <- list(forces)
    rows[[length(rows) + 1L]] <- item
    merged <- dplyr::bind_rows(rows)
    if (nrow(old)) {
      merged <- dplyr::bind_rows(
        old[!old$archive_file %in% merged$archive_file, ], merged
      )
    }
    saveRDS(merged, manifest_path)
  }
  dplyr::bind_rows(rows)
}

#' Extract immutable stop and search CSV snapshots
#'
#' Other archive contents are not extracted. Retains source ZIPs and raw
#' CSV bytes.
#' A manifest records archive and CSV SHA-256, row count and original
#' member path.
#' ZIP traversal paths are refused. Previously extracted CSVs are
#' hash-checked.
#' @param dir Cache containing archive ZIPs and optionally a download
#' manifest.
#' @param months Optional YYYY-MM filter; defaults to the download request.
#' @param forces Optional force filter; defaults to the download request.
#' @return A tibble of CSV versions. Writes snapshots and their manifest
#' in `dir`.
#' @family ingest
#' @seealso [sl_select_version()], [sl_read_records()]
#' @export
#' @examples
#' sl_list_versions(system.file("extdata", "sample", package = "searchlight"))
sl_archive_snapshot <- function(dir = sl_cache_dir(), months = NULL,
                                forces = NULL) {
  if (!is.null(months)) months <- sl_months(months)
  archives <- list.files(dir, "^[0-9]{4}-[0-9]{2}\\.zip$", full.names = TRUE)
  if (!length(archives)) sl_abort("No archive ZIPs found in dir.")
  sl_prepare_cache(dir)
  mp <- file.path(dir, "archive-manifest.rds")
  metadata <- if (file.exists(mp)) readRDS(mp) else tibble::tibble()
  manifest_path <- file.path(dir, "snapshot-manifest.rds")
  prior <- if (file.exists(manifest_path)) {
    readRDS(
      manifest_path
    )
  } else {
    tibble::tibble()
  }
  rows <- list()
  for (archive in archives) {
    aname <- basename(archive)
    sha <- sl_hash(archive)
    meta <- if (nrow(
      metadata
    )) {
      metadata[metadata$archive_file == aname, ]
    } else {
      metadata
    }
    if (nrow(meta) && !identical(sha, meta$sha256[[1]])) {
      sl_abort("Archive changed since acquisition.", "integrity")
    }
    members <- utils::unzip(archive, list = TRUE)$Name
    members <- members[grepl("-stop-and-search\\.csv$", members)]
    if (any(grepl("(^/|^[A-Za-z]:|\\\\|(^|/)\\.\\.(/|$))", members))) {
      sl_abort("Unsafe path in archive.", "integrity")
    }
    wanted_months <- months
    wanted_forces <- forces
    if (nrow(meta)) {
      if (is.null(wanted_months)) wanted_months <- meta$requested_months[[1]]
      if (is.null(wanted_forces)) wanted_forces <- meta$requested_forces[[1]]
    }
    for (member in members) {
      fields <- regmatches(basename(member), regexec(
        "^([0-9]{4}-[0-9]{2})-([a-z-]+)-stop-and-search\\.csv$",
        basename(member)
      ))[[1]]
      if (length(fields) != 3L) {
        sl_abort(
          "Unrecognised CSV filename.", "source"
        )
      }
      month <- fields[2]
      force <- fields[3]
      if (!is.null(wanted_months) && !month %in% wanted_months) next
      if (!is.null(wanted_forces) && !force %in% wanted_forces) next
      folder <- file.path("snapshots", sub("\\.zip$", "", aname))
      rel <- file.path(folder, member)
      target <- file.path(dir, rel)
      prev <- if (nrow(prior)) prior[prior$csv_path == rel, ] else prior
      if (file.exists(target)) {
        if (!nrow(prev) || !identical(
          sl_hash(target),
          prev$csv_sha256[[1]]
        )) {
          sl_abort(
            "Unverified or changed extracted CSV; not overwriting.",
            "integrity"
          )
        }
      } else {
        utils::unzip(archive, files = member, exdir = file.path(dir, folder))
      }
      raw <- readr::read_csv(target,
        col_types = readr::cols(.default = readr::col_character()),
        show_col_types = FALSE, progress = FALSE
      )
      rows[[length(rows) + 1L]] <- tibble::tibble(
        force_id = force, month = month, archive_file = aname,
        snapshot_month = sub("\\.zip$", "", aname),
        csv_path = rel, csv_sha256 = sl_hash(target),
        n_records = nrow(raw), archive_sha256 = sha,
        downloaded_at = if (nrow(
          meta
        )) {
          meta$downloaded_at
        } else {
          as.POSIXct(NA)
        },
        url = if (nrow(meta)) meta$url else NA_character_
      )
    }
  }
  result <- dplyr::bind_rows(rows)
  if (nrow(prior)) {
    result <- dplyr::bind_rows(
      prior[!prior$csv_path %in% result$csv_path, ], result
    )
  }
  saveRDS(result, manifest_path)
  result
}
