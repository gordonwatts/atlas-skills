# Rucio CLI Cheat Sheet (ATLAS)

## Auth and Environment

- Verify CLI: `rucio --version`
- Verify auth: `rucio whoami`
- If any command reports auth/X.509 failure, stop and ask the user to refresh credentials.

## Scopes and Dataset Discovery

- List scopes: `rucio list-scopes`
- List datasets by pattern:
  - `rucio list-dids <scope>:<pattern> --did-type dataset`
  - Example pattern for “data24”: `<scope>:data24*`
- List container contents: `rucio list-content <scope>:<container>`

## Container Management

- Create container: `rucio add-container <scope>:<container>`
- Attach datasets to container:
  - `rucio attach <scope>:<container> <scope>:<dataset1> <scope>:<dataset2> ...`
- Verify container contents: `rucio list-content <scope>:<container>`

## Files and Downloads

- List files in dataset: `rucio list-files <scope>:<dataset>`
- Download a file by DID: `rucio download <scope>:<file>`
- Download all files in a dataset: `rucio download <scope>:<dataset>`

## Help and Options

- Per-command help: `rucio <command> --help`
- Use help to check flags like `--rse`, `--dir`, `--impl`, or filtering options.
