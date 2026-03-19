# Global Preferences

## Storage Strategy (apply to any project with data/code separation)

**Code → Local + Git. Data → Google Drive (streamed).**

| Type | Where | How |
|---|---|---|
| Dev code / projects | `/Dev/projects/` (local) | Git push to GitHub always |
| Build artifacts | Excluded everywhere | .gitignore / .rclone-exclude |
| Research data, CSVs, recordings | `My Drive/...` (cloud only) | Google Drive desktop app, streamed on demand |

**Rules:**
- Never mix data files into `/Dev/` — they belong in Google Drive
- Never commit build artifacts (node_modules, .venv, __pycache__, dist, etc.)
- Data recording software should save directly to the Google Drive mount:
  `/Users/hareee234/Library/CloudStorage/GoogleDrive-hareee234@gmail.com/My Drive/...`
- Never save recordings/data to `.tmp/` inside the Google Drive mount — that is an internal staging area, not reliable storage
- Code should be pushed to GitHub regularly (git is version control, not just backup)

**Google Drive mount path on this Mac:**
```
/Users/hareee234/Library/CloudStorage/GoogleDrive-hareee234@gmail.com/My Drive/
```

**Why this works:**
- 512GB SSD — streaming data from Google Drive avoids filling local disk
- Large files (CSVs, recordings) stay in cloud, available on demand
- Code is small, fast to work with locally, and version-controlled via Git
- rclone backup of /Dev/projects is a secondary safety net (in case of uncommitted local work)

## Python / Conda Environment

- Miniconda3 at `/Users/hareee234/miniconda3` (Apple Silicon, osx-arm64)
- Default environment for all Python work: **`torch-default`** (Python 3.12.12, PyTorch 2.9.1, NumPy, Pandas, Matplotlib, Jupyter, Google Cloud SDKs, 150+ packages)
- Other envs: `base` (py3.13.9), `sample` (py3.11.14)
- **Claude Code subshells are non-interactive — `.zshrc` is NOT sourced.** `conda activate` and bare `python` will both fail.
- **ALWAYS use one of these patterns:**
  1. Direct path (preferred): `/Users/hareee234/miniconda3/envs/torch-default/bin/python script.py`
  2. conda run: `/Users/hareee234/miniconda3/bin/conda run -n torch-default python script.py`
- Install packages: `/Users/hareee234/miniconda3/bin/conda run -n torch-default pip install <pkg>`
- Never attempt bare `python`, `which python`, or `conda activate` in Bash tool calls

## Node.js / fnm Environment

- Node version manager: **fnm** (Fast Node Manager), installed via Homebrew at `/opt/homebrew/opt/fnm/bin/fnm`
- Default Node version: **v24.11.0** (npm 11.6.1)
- fnm only initializes in interactive shells via `.zshrc` — Claude Code subshells do NOT have `node`/`npm`/`npx` in PATH
- **ALWAYS use direct paths:**
  - `node` → `/Users/hareee234/.local/share/fnm/node-versions/v24.11.0/installation/bin/node`
  - `npm` → `/Users/hareee234/.local/share/fnm/node-versions/v24.11.0/installation/bin/npm`
  - `npx` → `/Users/hareee234/.local/share/fnm/node-versions/v24.11.0/installation/bin/npx`
- If a project uses a different Node version (via `.node-version` or `.nvmrc`), check `fnm list` and adjust the version segment in the path above
- Never attempt bare `node`, `npm`, or `npx` in Bash tool calls
