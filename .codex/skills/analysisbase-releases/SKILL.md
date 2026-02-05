---
name: analysisbase-releases
description: List the most recent analysisbase container tags from gitlab-registry.cern.ch/atlas/athena/analysisbase, installing crane into ./bin if needed.
---

# Analysisbase Releases

Use this skill when the user wants the most recent AnalysisBase container tags from the CERN GitLab OCI registry. It ensures `crane` is installed into `./bin` (downloading the latest stable release if missing) and then lists the newest tags.

## Quick start

Run the bundled script from the repo root for the default "last 10 tags" behavior (it will install crane if needed):

```bash
./.codex/skills/analysisbase-releases/scripts/list_analysisbase_recent.sh
```

## Workflow

1. Ensure `./bin` exists.
2. If `./bin/crane` is missing or not executable, download the latest stable `crane` release from GitHub and install it into `./bin`.
3. If the user asks for "recent tags" (or similar wording without extra constraints), run the bundled script to return the 10 most recent tags.
4. For anything other than the default "last 10" (date ranges, exact counts, filtering, metadata, etc.), use `crane` directly and filter/format the output with shell tools.

Crane GitHub repo: `https://github.com/google/go-containerregistry`

## Notes

* Override the crane version by setting `CRANE_VERSION` (e.g., `CRANE_VERSION=v0.20.7`).
* The script is POSIX-ish bash and expects `curl`, `tar`, and standard coreutils.
