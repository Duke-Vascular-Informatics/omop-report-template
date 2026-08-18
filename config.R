# =============================================================================
# config.R
#
# This repo has no study_params.yaml of its own, and that is deliberate, not
# an oversight. The report code should read only the handful of config$
# fields it actually needs (verify by grepping every config$ access across
# R/*.R before adding a new one — do not assume a field exists). Those fields
# are written by your analysis-core repo's R/extract_report_inputs.R into
# <report_inputs_dir>/_report_config.yaml as part of the same extract step
# that writes every other CSV this repo reads.
#
# Duplicating those fields into a second study_params.yaml here would create
# exactly the drift risk this whole repo split is designed to avoid: someone
# changes a parameter in the analysis repo and the report's methods text
# silently keeps describing the old value. There is exactly one place these
# values can come from — the analysis run that actually produced the results
# this report describes.
#
# Nothing in _report_config.yaml should imply database access: no schema
# names, no cohort ids, no credentials. TODO [STUDY]: document your study's
# _report_config.yaml field list here (or link to where the analysis-core
# repo's extract_report_inputs.R documents it) once you know what the report
# actually reads.
# =============================================================================

#' Read the report-relevant config fields from an extract's output directory.
#'
#' @param report_inputs_dir Path to the `report_inputs/` directory produced by
#'   your analysis-core repo's extract_report_inputs(). Typically
#'   `<results_dir>/report_inputs`.
#' @return A named list matching the shape generate_report() expects.
get_report_config <- function(report_inputs_dir) {
  path <- file.path(report_inputs_dir, "_report_config.yaml")
  if (!file.exists(path)) {
    stop(
      "_report_config.yaml not found in ", report_inputs_dir, ".\n",
      "This file is written by your analysis-core repo's ",
      "extract_report_inputs() — run that (or the full analysis pipeline) ",
      "against the CDM before rendering, or point report_inputs_dir at a ",
      "results export that already has it."
    )
  }
  yaml::read_yaml(path)
}
