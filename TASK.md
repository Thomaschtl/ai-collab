# TASK — Inspect decisive SGD resumes

Read:

- the project `AGENTS.md`;
- `STATE.md`.

Do not submit any Izar job without explicit user confirmation.

## Goal

Determine whether weak P2 improves temporal dynamics from the true healthy supervised Run B checkpoint, rather than from the previous degraded peak-about-77.9 surrogate.

## Inspect

Check Izar jobs:

- 3099912
- 3099913
- 3099914

Use targeted commands and `codex-budget capture`.

Do not read full logs or large artifacts.

Confirm first:

1. 3099912 completed successfully.
2. `train_state.pkl` exists at the expected location.
3. 3099913 and 3099914 actually resumed that exact state.
4. Their initial metrics reproduce the healthy Run B:
   - peak near 86.2 at `a=1.02`;
   - rho/j/S RMSE near 6–8%;
   - not peak about 77.9 / RMSE about 12%.

## Extract compact metrics

For 3099913 and 3099914, report initial, intermediate and final:

- weak P2 loss;
- `R_P2 / R_true`;
- dK2 or K2 temporal error;
- P3_jump error;
- peak at `a=1.02`;
- rho RMSE;
- j RMSE;
- S RMSE;
- NaN/divergence status;
- checkpoint paths.

## Interpret

Answer clearly:

- Does SGD reduce weak P2 from the healthy checkpoint?
- Does it preserve peak 86–88?
- Which LR is safer: `1e-6` or `3e-6`?
- Is `j` stable?
- Is the gain large enough to justify 1500–3000 steps?

Distinguish carefully between:

- failure to resume the correct checkpoint;
- stable but negligible PDE effect;
- useful PDE reduction with preserved fields;
- destructive update.

## Output

Update only `REPORT.md` with a compact report.

Do not modify `STATE.md` or `TASK.md`.

Do not launch follow-up jobs.

End with exactly one recommended next job configuration, pending user confirmation.
