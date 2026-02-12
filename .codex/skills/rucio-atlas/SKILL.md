---
name: rucio-atlas
description: Rucio ATLAS dataset management via the `rucio` CLI. Use when a user asks to discover ATLAS scopes or datasets with search strings, create containers, attach datasets, or download files from datasets (including questions like “what MC is available for X derivation” or “what is the scope for data24”).
---

# Rucio Atlas

## Overview

Use this skill to run ATLAS Rucio CLI commands for listing scopes/datasets, creating containers, attaching datasets, and downloading files. Always stop and tell the user to fix authentication if any Rucio command fails due to missing/expired X.509 credentials.

The rucio data model has datasets and containers. Datasets contain files, and containers contain datasets. Both datasets and containers are identified by DIDs (Data Identifiers) with the format `<scope>:<name>`. The scope is a namespace that helps organize data, and the name is the unique identifier within that scope. For almost all uses, containers and datasets can be treated as the same.

## Quick Start

1. Confirm `rucio` CLI is available. If not, stop and ask the user to fix their environment. The `rucio ping` is an effective way to test everything is working.
2. Proceed with the requested task using the task sections below.

If authentication fails, do not retry. Tell the user to obtain/refresh their X.509 cert and re-run.

## Tasks

### Count Files in a Dataset or Container

Use this when a user asks “how many files are in <DID>”.

Steps:

1. Count files directly (works for DATASET or CONTAINER):
   - `rucio list-files --csv <scope>:<did> | wc -l`

### List Scopes or Datasets (Search)

Use this for prompts like “What is the rucio scope for data24?” or “What MC is available for the LLP1 derivation?”

Steps:

1. List scopes (`rucio list-scopes`) and filter client-side if the user gave a hint like `data24`.
2. Search datasets with `rucio list-dids <scope>:<pattern> --filter 'type=DATASET' --short` (pattern often ends with `*`).
   - Note: `--did-type` is not supported in this CLI; use `--filter 'type=DATASET'` instead.
3. If the user’s request is ambiguous (multiple scopes or derivations), show short options and ask which they want.

Performance tips (important when searches time out):

- Always include the scope prefix and use a tight pattern. Avoid unscoped searches.
- Prefer the "scope-prefixed pattern" for speed:
  - `rucio list-dids data24_13p6TeV:data24_13p6TeV*.DAOD_LLP1.*p7079* --filter 'type=DATASET' --short`
- Narrow by stream early (e.g. `physics_Main`) to reduce matches:
  - `rucio list-dids data24_13p6TeV:data24_13p6TeV*.physics_Main.deriv.DAOD_LLP1.*p7079* --filter 'type=DATASET' --short`
- To find the most recent run number, sort the output and take the tail:
  - `... | sort | tail -n 5`
- For large attach operations, write the DID list to a temp file and batch with `xargs`:
  - `rucio list-dids ... --short > /tmp/dids.txt`
  - `xargs -a /tmp/dids.txt -n 50 rucio attach user.<username>:<container>`

### Create Container

Use this for prompts like “Please create a container that has all the data24 runs with the LLP1 container.”

Steps:

1. Default to the user's scope unless explicitly requested otherwise.
   - Use `user.<username>` for containers, e.g. `user.gwatts:<container>`.
2. Create the container: `rucio add-container user.<username>:<container>`
3. Attach datasets: `rucio attach user.<username>:<container> <scope>:<dataset1> <scope>:<dataset2> ...`
4. Verify contents: `rucio list-content user.<username>:<container>`

If the user didn’t provide the exact dataset list, first search with `rucio list-dids` and confirm the set before attaching.

### Download a File

Use this for prompts like “Please download a file from the dataset XXX.”

Steps:

1. List files in the dataset: `rucio list-files <scope>:<dataset>`
2. Pick the file DID and download it with `rucio download <scope>:<file>`
3. If the user wants all files, download the dataset DID instead.

Use `rucio download --help` if you need RSE or destination options.

Notes:

- For long downloads, use a longer timeout (10 or 30 minutes):
  - `timeout 10m rucio download <scope>:<file>`
  - `timeout 30m rucio download <scope>:<file>`
- To run a download in the background with a log:
  - `nohup timeout 30m rucio download <scope>:<file> > /tmp/rucio_download_<tag>.log 2>&1 &`
  - Check progress: `tail -n 50 /tmp/rucio_download_<tag>.log`
- If the user asks whether the transfer started, check network activity (fallback when `ss` is unavailable):
  - `lsof -nP -iTCP | rg -i "xrootd|rucio|1094"`

## References

See `references/rucio-cli.md` for a concise CLI cheat sheet and common flags.
