# Use an explicitly acquired local Pandoc when it is not on the system PATH.
# This changes only this developer R process, never a user's persistent settings.
if (!rmarkdown::pandoc_available()) {
  binaries <- Sys.glob(".cache/pandoc/*/pandoc.exe")
  if (length(binaries)) {
    Sys.setenv(RSTUDIO_PANDOC = normalizePath(dirname(binaries[1]),
      winslash = "/"
    ))
    rmarkdown::find_pandoc(cache = FALSE)
  }
}
