# omop-report-template — CLAUDE Instructions (Local Wrapper)

Shared baseline (applies first):

- `../CLAUDE.md`

> **This file is itself a template.** When a report repo is created from this
> repo, rewrite the "Local Overrides" section below to describe *that*
> study's report. Keep the wrapper shape: point at `../CLAUDE.md` as the
> shared baseline first, then record local overrides only. Never restate the
> shared baseline here.

## Local Overrides

- **This repo is a GitHub template, not a study's report.** It has no real
  results, no `_report_config.yaml` field list, and no clinical narrative.
  Do not add real result artifacts, PHI, or study content to it — those
  belong in a repo created *from* it.
- **This repo renders a Word report from result artifacts. It must never
  gain a database dependency.** If a change here seems to need
  `DatabaseConnector`, `connection_details`, or any live CDM query, the
  query belongs in the sibling analysis-core repo's
  `R/extract_report_inputs.R` instead, writing a new CSV artifact this repo
  reads. This is the one rule that must never be broken — see
  [charon's "Multi-Repo Analysis Pipeline" section](https://github.com/Duke-Vascular-Informatics/charon#multi-repo-analysis-pipeline) for why.
- Consumes [`omopReportToolkit`](https://github.com/Duke-Vascular-Informatics/omop-report-toolkit)
  for generic figure styling and report helpers, pinned to a commit in
  `renv.lock` (never a branch). Bump it deliberately: `renv::install(...)`
  then hand-verify the `renv.lock` diff — do not run a blind
  `renv::snapshot()` afterward. It has been observed in this workspace to
  silently strip unrelated packages from a lockfile when run over an
  existing project; see that package's own README for the same warning.
- No `study_params.yaml` here — see `config.R`'s header. Report parameters
  come from `_report_config.yaml`, written by the analysis-core repo's
  extract step, not duplicated in this repo.
- Repo visibility (private/public) follows the sibling analysis-core repo's
  visibility, not a repo-specific decision.

### Pipeline

| Step | File | What it does |
|------|------|---------------|
| — | `GenerateReport.R` | Entry point. `Rscript GenerateReport.R` — resolves its data source automatically (see below). |

**Data source resolution** (first match wins), implemented in
`GenerateReport.R`:

1. `RESULTS_DIR` env var, if set — explicit always wins.
2. A `.zip` in `prcc_data/` (gitignored) — a Duke PRCC export archive,
   extracted to `prcc_data/.extracted/` and rendered from. **This is the
   normal way to render real Duke results.** Newest *run* (by filename
   timestamp, not file mtime) wins; re-extracts only when the archive
   changes.
3. Already-unzipped content in `prcc_data/`.
4. `ANALYSIS_CORE_OUTPUT_DIR` (set near the top of `GenerateReport.R`) — the
   synthetic dev-container run of the sibling analysis-core repo.

The chosen source is announced in a banner on startup, and a synthetic
render prints an explicit "do not circulate as a real result" warning at the
end. That banner is the point of the ordering: silently rendering synthetic
numbers and believing they are real is the expensive mistake here. Never
remove it.

`prcc_data/` is gitignored except its README — it holds real results, and
an archive is only aggregate because `duke-prcc-deploy`'s export step made
it so, which is not a property this repo can verify after the fact.

**Rendered output goes to `reports/`** (gitignored) when the source is an
extracted archive, and next to the results otherwise. It must NOT default
into `prcc_data/.extracted/`: that directory is a working copy this script
deletes and re-creates whenever the archive changes, so a report written
there is silently destroyed by the next render of a new export.
`REPORT_OUTPUT_DIR` overrides.

There is no Step 1/2/9 numbering here — that convention belongs to the
analysis-core repo's Strategus or `workflow/01–09` pipeline. This repo has
exactly one script.

### TODO [STUDY] markers

`GenerateReport.R` and `R/report_dispatch.R` ship with `TODO [STUDY]`
markers at every point that needs your study's specifics filled in
(`ANALYSIS_CORE_OUTPUT_DIR`, `SCORE_SUBDIRS`, `generate_report()`'s body).
Find them all with:

```bash
grep -rn "TODO \[STUDY\]" . --include="*.R"
```

### Version Control Routing

Independent repository; **not** a submodule, and not added to the workspace
root's index.

| Remote | URL | What to push |
|--------|-----|---------------|
| `origin` | (set when a study repo is created from this template) | Full repository |

```bash
BRANCH=$(gh api user --jq .login)
git push origin "$BRANCH"   # then open a PR into main
```

No Duke GitLab routing — a report repo has no PRCC deployment concerns. If
it ever needs one (e.g. rendering directly on PRCC rather than from an
export), that is bucket-4 (`duke-prcc-deploy`) scope, not something to add
here directly.
