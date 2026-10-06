# export_data/ — secure-environment export drop-zone

Copy an approved export archive from your secure analytic environment into this directory and run
`Rscript GenerateReport.R` from the repo root. The report will render from it
instead of the synthetic development data, and will say so on startup.

```bash
cp ~/Downloads/<your_study>_strategusOutput_*.zip export_data/
Rscript GenerateReport.R
```

The archive is produced by your institution's site-deploy repo (bucket 4) and
must have cleared your institution's data-egress review before it leaves the
secure environment. This
repo does not check that and cannot — it only renders what it is given.

## What happens

- The newest `.zip` here (by run timestamp in the filename, not file mtime)
  is extracted to `export_data/.extracted/` and rendered from. Re-extraction
  happens only when the archive changes, so re-running is cheap.
- Already-unzipped content placed here directly works too.
- With this directory empty, the report falls back to the synthetic run at
  `ANALYSIS_CORE_OUTPUT_DIR` (set in `GenerateReport.R`) and prints a
  prominent warning that the output is **not** a real result.
- `RESULTS_DIR=<path>` overrides all of the above.

## Everything here is gitignored

Except this README. Do not commit exports, extracted contents, or rendered
documents built from them — this directory holds real results.
