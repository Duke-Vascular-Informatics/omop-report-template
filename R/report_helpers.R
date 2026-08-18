# =============================================================================
# R/report_helpers.R
#
# Study-specific report helpers only. Anything generic enough to be verified
# byte-identical across multiple report-repos belongs in omopReportToolkit
# instead — see that package's README ("What this is not") before adding a
# function here: if it has no study-specific branch (no clinical narrative,
# no score/cohort names, no per-study table shape), it likely belongs in the
# toolkit, not here.
#
# TODO [STUDY]: add your study's table/figure builders here (e.g. a cohort
# summary Table 1, a study-specific supplemental table). Call
# omopReportToolkit's exported helpers (.build_table1(), save_figure(),
# theme_manuscript(), .append_references_section(), etc.) rather than
# reimplementing them — see that package's README for the full list.
#
# This file is sourced by R/report_dispatch.R, which also loads
# omopReportToolkit for the generic functions above. Do not library() or
# source() a second time inside generate_report() — the dispatcher already
# did it once per render.
# =============================================================================

library(omopReportToolkit)
