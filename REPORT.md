# REPORT — Audit Mean/L4/CVaR Global-T51

Task ID: audit-global-t51-objective-identity  
Status: instrumentation complete locally; no training or Izar job launched.

## Finding from existing checkpoints

The A/B/C files are byte-distinct and their parameters are not identical:

| step | pair | ||dtheta|| | max abs diff | cos(theta) |
|---:|:---:|---:|---:|---:|
| 50 | A-B | 2.046e-5 | 8.617e-7 | 0.990573 |
| 50 | A-C | 6.328e-5 | 1.710e-6 | 0.910198 |
| 50 | B-C | 6.371e-5 | 1.381e-6 | 0.909080 |
| 100 | A-C | 8.994e-7 | 7.703e-7 | 0.999987 |
| 500 | A-C | 8.235e-8 | 8.235e-8 | 0.999999917 |

Thus field equality cannot be attributed to equal checkpoint bytes. Differences
collapse strongly after step 50, but no gradient conclusion is valid yet.

## Correction and deterministic audit added

`train_ablation_global_t51_objectives.py` previously logged the loss/fields
before Adam while writing theta after Adam. This invalidated direct association
between a checkpoint and its recorded loss. It now re-evaluates each saved
checkpoint on the exact same frozen T51 boxes.

For every saved step, the trainer now writes
`models/audit_ablation_obj_<A|B|C>_step_<N>.json` with:

- all A/B/C gradient norms, pairwise cosines and norm ratios at the same theta;
- SHA256 of parameters and optimizer state;
- one common-state Adam update per objective, its 3x3 loss matrix, directional
  derivative, update cosines, and ||Delta rho||, ||Delta u||, ||Delta j||;
- distributions of R, D, and |R|/D by (n,W,Delta-a), including requested tail
  fractions and quantiles.

`scripts/audit_global_t51_checkpoint_parameters.py` prints SHA256, pairwise
parameter distances, cosine, and per-leaf max difference for pre-existing
checkpoints without JAX reconstruction.

## Verification

- Both modified/new Python files compile with `py_compile`.
- The NumPy checkpoint audit ran successfully on existing step 50/100/500 files.
- A one-step JAX smoke run was attempted in a temporary output directory; it
  reached trainer initialization but did not produce artifacts locally, so the
  full JAX diagnostic remains to be executed on the intended GPU environment.

## Next job (pending user confirmation)

Run the existing Global-T51 A/B/C ablation for 500 steps with the instrumented
trainer; inspect the JSON files at steps 1, 50, 100, and 500 before changing
any curriculum or objective.
