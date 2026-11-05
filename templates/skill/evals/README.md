# Test cases

One folder per case, named for what it tests (`catches-gamed-fix`, `handles-empty-input`).
Rename `example-case/`, write a realistic prompt, then replace the placeholder grader with
objective statements, one per file (`01-states-total.md`, `02-flags-bad-row.md`).

For input files, add a `files/` folder, a `place-files.sh` that copies them into the working
directory, `context: { scaffold_script: place-files.sh }` in `case.yaml`, and a final
`Input files: ...` line in the prompt. See `skills/core/verify-before-done/evals/` for a full example.

Run the cases with and without the skill using the `skill-creator` skill (see AGENTS.md).
Delete this README when you copy the template.
