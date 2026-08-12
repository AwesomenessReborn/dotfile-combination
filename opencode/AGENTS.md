# Personal Working Style

- Be direct and practical.
- For non-trivial tasks, inspect the relevant files before proposing changes.
- Prefer the smallest correct change over broad refactors.
- State the plan briefly before editing.
- After changes, run the narrowest useful verification first.
- Call out risks, tradeoffs, and uncertainty explicitly.
- Do not make unrelated cleanup changes unless asked.
- Prefer repo-specific instructions over global defaults when they conflict.

# Shell / Environment Constraints

- Agent shells may be non-interactive and may not source `.zshrc`.
- Do not assume `python`, `conda activate`, `node`, `npm`, or `npx` are available in PATH.

## Python
- Prefer the repo's own environment if one is defined.
- If no project-specific environment exists, use:
  `/Users/hareee234/miniconda3/envs/torch-default/bin/python`
  or
  `/Users/hareee234/miniconda3/bin/conda run -n torch-default python`
- Do not rely on bare `python` or `conda activate`.

## Node
- Prefer the repo's declared Node version (`.nvmrc`, `.node-version`, tool config) if present.
- If no project-specific version is declared, use the fnm-installed binaries directly.
- Do not rely on bare `node`, `npm`, or `npx`.

# Data / Code Separation

- When working in `~/Dev` projects that separate code and data:
  - keep code local and under git
  - keep large datasets / recordings in Google Drive streamed storage
  - never store important data in `.tmp` under the Google Drive mount
  - **never commit data files to git** — all data lives in Drive, code lives in the repo
  - use a config module (e.g. `config.py`) that reads data paths from a `.env` file
  - provide a `.env.example` template so teammates can set their own local paths
  - personal/local paths must never appear in committed files
- The `backups/dev/` folder appears in the streamed Google Drive mount at
  `My Drive/backups/dev/` but takes negligible local disk — files are
  metadata-only until opened. This is expected and not a duplication issue.
- `st-work` has two distinct roles: `My Drive/st-work/` is the data archive
  (CSVs, recordings, shareable via Drive links), while
  `/Dev/projects/st-work/` is the code home (repos on GitHub, backed up via
  rclone). Same folder names appear in both but contain different content —
  this is by design.
