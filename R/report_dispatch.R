# =============================================================================
# R/report_dispatch.R
#
# Dispatcher stub for this report repo. GenerateReport.R sources this file and
# calls generate_report() once it has resolved a results directory and read
# _report_config.yaml. It exists as its own file — rather than inline in
# GenerateReport.R — purely so your real report logic has an obvious place to
# land without touching the generic entry point at all.
#
# TODO [STUDY]: replace the body of generate_report() with calls into your
# study's own report composition (tables, figures, narrative text). Use
# omopReportToolkit for any generic figure/table helper before writing a new
# one in R/report_helpers.R — see that package's README for what already
# exists. For a worked example of a completed dispatcher, read
# pad-amp-nhd-prog-report's R/report_extended.R (Duke-Vascular-Informatics
# org) alongside this stub.
# =============================================================================

library(officer)
library(flextable)
library(ggplot2)

# Greyscale figure styling + generic report helpers. Pinned to a commit in
# renv.lock, not a branch — see that package's README before bumping it.
library(omopReportToolkit)

source("R/report_helpers.R")

#' Render the manuscript Word report from extracted result artifacts.
#'
#' @param output_dir Directory to write the rendered .docx into.
#' @param model_dirs Named character vector of per-model result directories,
#'   one per `SCORE_SUBDIRS` entry set in `GenerateReport.R` (e.g.
#'   `c(my_score = "<results_dir>/my_score")`). Empty (`character(0)`) if the
#'   study has no per-model split.
#' @param report_inputs_dir Path to `report_inputs/` (aggregate CSVs +
#'   `_report_config.yaml`).
#' @param config Named list returned by `config.R`'s `get_report_config()`.
#' @return Path to the rendered `.docx` file.
generate_report <- function(output_dir, model_dirs, report_inputs_dir, config) {
  stop(
    "TODO [STUDY]: generate_report() is a template stub — implement your ",
    "study's report composition here. See this repo's README and ",
    "pad-amp-nhd-prog-report's R/report_extended.R (Duke-Vascular-Informatics ",
    "org) for a worked example."
  )
}
