# omop-report-template

GitHub template repository for a **bucket-3b report repo** — one study's Word
manuscript report composition, rendered from result artifacts only, in a
[charon](https://github.com/Duke-Vascular-Informatics/charon)-based workspace.

Use this when you need a `<study>-report` repo: which tables, which figures,
and the clinical narrative for one study's manuscript, consuming
[`omop-report-toolkit`](https://github.com/Duke-Vascular-Informatics/omop-report-toolkit)
(bucket 3) for the generic figure/table helpers shared across studies.

**Renders from result artifacts only. No database connection, ever.** A repo
created from this template must remain runnable on a laptop with nothing but
a clone of it and a `results/` directory copied over — no VPN, no
credentials, no JDBC driver, no `DatabaseConnector`. See
[charon's "Multi-Repo Analysis Pipeline" section](https://github.com/Duke-Vascular-Informatics/charon#multi-repo-analysis-pipeline)
for why this is a separate repo from the analysis itself, and why that
separation is load-bearing rather than a style preference.

---

## Where this fits

| Bucket | Repo | Contents |
|---|---|---|
| 1 — synth | `<study>-synth` (from [`synthea-omop-template`](https://github.com/Duke-Vascular-Informatics/synthea-omop-template)) | Synthea module + ETL for one synthetic dataset |
| 2 — analysis-core | `<study>` (from [`strategus-study-template`](https://github.com/Duke-Vascular-Informatics/strategus-study-template)) | Cohorts, analysis spec, the extract layer. **No report content of any kind.** |
| 3 — report-toolkit | [`omop-report-toolkit`](https://github.com/Duke-Vascular-Informatics/omop-report-toolkit) | Generic figure/table helpers only. Nothing study-specific. |
| **3b — report-repo** | **`<study>-report`, from this template** | **One study's report composition — which tables, which figures, the narrative.** |
| 4 — site-deploy | `<your-site>-deploy` (your institution's own; no template) | Bundle builder and secure-environment specifics |

A repo built from this template pairs with exactly one bucket-2 analysis-core
repo (named `<study>-report` next to `<study>`) and consumes bucket 3 for
anything generic. It never holds cohort definitions, concept IDs, or a live
CDM connection — that content belongs in bucket 2.

## What this template ships

```
GenerateReport.R           entry point — resolves its data source automatically
config.R                   reads report_inputs/_report_config.yaml (no study_params.yaml here)
R/report_dispatch.R        TODO [STUDY] stub — your report composition goes here
R/report_helpers.R         TODO [STUDY] stub — your study-specific table/figure builders
export_data/README.md       Secure-environment export drop-zone (gitignored except this file)
CHECKLIST.md               new report-repo (Path A) / extraction from an existing repo (Path B)
CLAUDE.md                  local-wrapper AI instructions — rewrite after creating a repo from this
renv.lock                  pinned to omop-report-toolkit@<sha>, plus officer/flextable/ggplot2/yaml
```

## Quick start

```bash
# 1. Create your repo from this template, named <study>-report, and clone it
#    as a sibling of <study> (the analysis-core repo) in the workspace folder.
BRANCH=$(gh api user --jq .login)
git checkout -b "$BRANCH"

# 2. Create the project library FIRST — git does not track empty directories,
#    so a fresh clone has no renv/library/, and renv silently falls back to
#    the system library (restore() still exits 0 and reports success).
mkdir -p renv/library/linux-ubuntu-noble/R-4.5/aarch64-unknown-linux-gnu renv/staging
Rscript -e 'renv::restore()'
Rscript -e 'cat(.libPaths()[1], "\n")'   # must print renv/library/..., not the system library

# 3. Work through CHECKLIST.md — Path A for a new study, Path B to extract an
#    existing in-repo report.

# 4. Render against the synthetic dev-container run of your analysis-core repo:
Rscript GenerateReport.R
```

Find everything that needs a decision:

```bash
grep -rn "TODO \[STUDY\]" . --include="*.R"
```

## Reference implementation

Read a real one alongside the template — it differs from the template only
in having its `TODO [STUDY]` markers resolved:

| Repo | Read it for |
|---|---|
| [`pad-amp-nhd-prog-report`](https://github.com/Duke-Vascular-Informatics/pad-amp-nhd-prog-report) | The completed Path-B extraction: a real `R/report_dispatch.R`-equivalent (`R/report_extended.R`), a real `SCORE_SUBDIRS`-equivalent (three per-model result folders), and the provenance note recording a byte-for-byte verification against the pre-split report |

## Non-negotiables

- **Never add a database dependency.** If a change here seems to need
  `DatabaseConnector` or `connection_details`, that query belongs in the
  analysis-core repo's `R/extract_report_inputs.R` instead, writing a new
  CSV artifact this repo reads.
- **Nothing study-specific goes into `omop-report-toolkit`.** If a helper
  here has no study-specific branch (no clinical narrative, no score/cohort
  names), move it to the toolkit instead of leaving a near-duplicate here.
- **Pin `omop-report-toolkit` to a commit SHA, never a branch**, and
  hand-verify the `renv.lock` diff after installing — never a blind
  `renv::snapshot()`.
- **Push to your own branch**, then open a PR into `main`. Never push to
  `main`, never to another collaborator's branch.
- **No PHI on disk.** `export_data/`, `output/`, `results/`, `reports/`, and
  `*.docx` are all gitignored.
- **Announce the data source loudly.** A synthetic render must say so on
  every run — silently believing synthetic numbers are a real result is the
  expensive failure mode this template is built to prevent.

## Funding

Research reported in this publication was supported by the National Center For Advancing Translational Sciences of the National Institutes of Health under Award Number K12TR005435. The content is solely the responsibility of the authors and does not necessarily represent the official views of the National Institutes of Health.

---

## License

Copyright 2026 Duke University. All Rights Reserved. The software is hereby licensed under the GNU GPL License v2 (see [LICENSE](LICENSE)).
