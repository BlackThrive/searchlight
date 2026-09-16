#' @noRd
sl_map_ethnicity <- function(raw) {
  table <- sl_table("ethnicity.csv")
  value <- trimws(tolower(raw))
  mapped <- table$ethnicity_19[match(toupper(value), table$police_code)]
  suffix <- sub("^.* - ", "", value)
  aliases <- list(
    Bangladeshi = "bangladeshi", Chinese = "chinese", Indian = "indian",
    Pakistani = "pakistani", `Other Asian` = "any other asian background",
    African = "african", Caribbean = "caribbean",
    `Other Black` = c(
      "any other black background",
      "any other black/african/caribbean background"
    ),
    `White and Asian` = "white and asian",
    `White and Black African` = "white and black african",
    `White and Black Caribbean` = "white and black caribbean",
    `Other Mixed` = c(
      "any other mixed/multiple ethnic background",
      "any other mixed background"
    ),
    British = c("english/welsh/scottish/northern irish/british", "british"),
    Irish = "irish", `Gypsy or Irish Traveller` = "gypsy or irish traveller",
    Roma = "roma", `Other White` = "any other white background",
    Arab = "arab", `Other ethnic group` = c(
      "any other ethnic group",
      "any other ethnic group - not stated"
    )
  )
  for (group in names(aliases)) {
    mapped[is.na(mapped) & suffix %in% aliases[[group]]] <- group
  }
  unknown <- is.na(raw) | value %in% c(
    "", "not stated", "unknown",
    "ns", "refused"
  ) |
    grepl("not stated|not defined|not known|refused", value)
  unmapped <- !unknown & is.na(mapped)
  if (any(unmapped)) {
    labels <- unique(raw[unmapped])
    sl_warn(paste0(
      "Unrecognised self-defined ethnicity labels retained as Unknown: ",
      paste(utils::head(labels, 5), collapse = "; "),
      ". Review the source classification."
    ), "classification")
  }
  mapped[unknown | is.na(mapped)] <- "Unknown"
  broad <- table$ethnicity_5[match(mapped, table$ethnicity_19)]
  tibble::tibble(
    ethnicity_5 = factor(broad, c(
      "Asian", "Black", "Mixed",
      "White", "Other", "Unknown"
    )),
    ethnicity_19 = factor(mapped, table$ethnicity_19)
  )
}

#' @noRd
sl_bool <- function(x) {
  value <- tolower(trimws(x))
  if (any(!is.na(value) & !value %in% c("true", "false", "", "1", "0"))) {
    sl_abort(
      "Unexpected boolean field value; schema requires review.", "schema"
    )
  }
  ifelse(is.na(value) | value == "", NA, value %in% c("true", "1"))
}

#' @noRd
sl_classify_records <- function(x) {
  ethnicity <- sl_map_ethnicity(x$self_defined_ethnicity_raw)
  x <- dplyr::bind_cols(x, ethnicity)
  officer <- x$officer_defined_ethnicity
  officer[is.na(officer) | !officer %in% c(
    "Asian", "Black",
    "Mixed", "White", "Other"
  )] <- "Unknown"
  x$ethnicity_officer <- factor(officer, c(
    "Asian", "Black",
    "Mixed", "White", "Other", "Unknown"
  ))
  x$is_strip_search <- sl_bool(x$removal_of_more_than_just_outer_clothing)
  x$outcome_linked_to_object <- sl_bool(x$outcome_linked_to_object_of_search)
  legislation <- tolower(x$legislation) # nolint: object_usage_linter.
  x$legislation_group <- dplyr::case_when(
    grepl("police and criminal evidence act.*\\(section 1\\)",
      legislation,
      fixed = FALSE
    ) ~ "PACE s.1",
    grepl(
      "misuse of drugs act.*\\(section 23\\)",
      legislation
    ) ~ "Misuse of Drugs Act s.23",
    grepl(
      "criminal justice and public order act.*\\(section 60\\)",
      legislation
    ) ~ "CJPOA s.60",
    grepl("firearms act", legislation) ~ "Firearms Act",
    grepl("terrorism act", legislation) ~ "Terrorism Act",
    TRUE ~ "Other"
  )
  object <- tolower(x$object_of_search) # nolint: object_usage_linter.
  x$object_group <- dplyr::case_when(
    grepl("drug", object) ~ "Drugs",
    grepl("weapon|firearm|blade", object) ~ "Weapons",
    grepl("stolen", object) ~ "Stolen goods",
    is.na(object) | object == "" ~ "Unknown",
    TRUE ~ "Other"
  )
  outcome <- tolower(trimws(x$outcome))
  unknown <- is.na(outcome) | outcome == ""
  nfa <- grepl(
    "no further action|nothing found",
    outcome
  ) | outcome == "false"
  x$any_action <- ifelse(unknown, NA, !nfa)
  x$arrest <- ifelse(unknown, NA, grepl("arrest", outcome))
  x$outcome_group <- ifelse(unknown, "Unknown",
    ifelse(nfa, "No further action", ifelse(x$arrest, "Arrest",
      "Other action"
    ))
  )
  x
}
