# Run explicitly after the local release check. This is not a CRAN submission.
rhub_result <- tryCatch(
  {
    rhub::rhub_check(
      gh_url = "https://github.com/black-thrive-global/searchlight",
      platforms = c("linux", "windows", "macos"),
      branch = "feat/m5-reporting-release"
    )
    list(status = "dispatched; result not yet verified")
  },
  error = function(e) list(status = "blocked", reason = conditionMessage(e))
)
jsonlite::write_json(list(
  attempted = as.character(Sys.time()), rhub = rhub_result,
  ci_matrix = "Pending: specified GitHub repository is unavailable",
  pkgdown_deployment = "Pending: specified GitHub repository is unavailable"
), "inst/validation/M5-external-checks.json", pretty = TRUE, auto_unbox = TRUE)
