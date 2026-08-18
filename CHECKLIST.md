# Checklist

Two paths. **Path A** creates a new report repo alongside a study you're
building now. **Path B** extracts an existing, already-in-analysis-repo
report into its own bucket-3b repo from this template — the harder one, with
`pad-amp-nhd-prog` → `pad-amp-nhd-prog-report` as the precedent.

Read [docs/MIGRATION_PLAN_REPO_SPLIT.md](https://github.com/Duke-Vascular-Informatics/omop-dev-workspace/blob/main/docs/MIGRATION_PLAN_REPO_SPLIT.md)
(in `omop-dev-workspace`) before either — especially the "load-bearing
refactor: split extract from render" section.

---

## Path A — new report repo for a study in progress

- [ ] Repo created from this template, named `<study>-report`; cloned into
      the workspace folder as a sibling of `<study>` (the analysis-core
      repo) — **not** a submodule, **not** added to the workspace root's
      index
- [ ] Working on your own branch: `BRANCH=$(gh api user --jq .login)`
- [ ] `ANALYSIS_CORE_OUTPUT_DIR` in `GenerateReport.R` points at `<study>`'s
      `output/` folder
- [ ] `SCORE_SUBDIRS` set (or left `character(0)` if the study has no
      per-model split)
- [ ] `<study>`'s `R/extract_report_inputs.R` exists and writes
      `report_inputs/_report_config.yaml` **with no `connection_details`
      argument on the render side** — the extract/render split is the whole
      point; see the migration plan's "load-bearing refactor" section
- [ ] `generate_report()` in `R/report_dispatch.R` implemented; every
      `TODO [STUDY]` resolved (`grep -rn "TODO \[STUDY\]" . --include="*.R"`)
- [ ] `renv::install("Duke-Vascular-Informatics/omop-report-toolkit@<sha>")`
      run, pinned to a commit — never a branch — and the `renv.lock` diff
      hand-verified (not a blind `renv::snapshot()`; see that package's
      README)
- [ ] `prcc_data/README.md` reviewed — do not commit anything else in that
      directory
- [ ] `Rscript GenerateReport.R` produces a `.docx` from the synthetic
      dev-container run of `<study>` before anything real is rendered
- [ ] `CLAUDE.md` written as a **local wrapper** — first line points at
      `../CLAUDE.md` as the shared baseline, then local overrides only
- [ ] Registered in `../studies.yaml` (`pipeline_role: report-repo`,
      `report_repo_for: <study>`); `<study>`'s own entry updated with
      `report_repo: <study>-report` and `migration.report: extracted`
- [ ] Added to the layout table in the workspace root `CLAUDE.md`

## Path B — extracting an existing in-repo report

The conversion moves report code (tables, figures, narrative) OUT of the
analysis-core repo and into a repo built from this template — the analysis
repo keeps only the extract layer, and must end up with **no**
`ggplot2`/`officer`/`flextable` import for reporting purposes at all.

### B1. Split extract from render, still inside the analysis-core repo
- [ ] `R/extract_report_inputs.R` added: everything currently calling
      `fetch_*_from_omop()` writes CSVs into `output/report_inputs/`
- [ ] The existing report function's `connection_details` argument dropped
      entirely — the compiler-style guarantee that render cannot reach a
      database
- [ ] Verified: run extract once, then run render in a session with no
      database access at all, and diff the resulting `.docx` against the
      current one
- [ ] **Exit criterion:** report renders with no DB connection; output
      matches

### B2. Move the code
- [ ] `R/report_*.R` files moved from the analysis-core repo into this
      repo's `R/`, verbatim except for dead-code removal — do not "clean up"
      in the same move, or a real regression becomes indistinguishable from
      an intentional change
- [ ] Any function verified byte-identical to another study's copy moves to
      `omop-report-toolkit` instead of staying here — see that package's
      README ("What this is not")
- [ ] Everything else (the study-specific composition — which tables, which
      figures, the clinical narrative) stays in this repo's
      `R/report_dispatch.R` / `R/report_helpers.R`
- [ ] `config.R`'s header updated if this study's `_report_config.yaml`
      field list differs from the template's generic prose
- [ ] Team test: someone other than you clones this repo plus a results
      directory (from a sibling analysis-repo run, or a copied-out export)
      and produces the report with no VPN and no database
- [ ] **Exit criterion:** report renders byte-identical (barring the
      generation date) to the last report generated before the split

### B3. Retire the old location
- [ ] Report code deleted from the analysis-core repo — not left as dead
      files "just in case"
- [ ] Analysis-core repo's `renv.lock` no longer lists `ggplot2`, `officer`,
      `flextable`, or any other reporting-only dependency
- [ ] `studies.yaml` updated: analysis-core entry's `migration.report` set
      to `extracted`, `report_repo` set to this repo's name

### B4. Then Path A's registration steps.
