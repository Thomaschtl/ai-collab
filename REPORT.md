# REPORT — Decisive SGD resumes from healthy Run B

Task ID: inspect-decisive-sgd-resumes
Status: completed

Inspected Izar jobs 3099912, 3099913, and 3099914 with targeted Slurm,
log-header, `metrics.json`, and checkpoint-path checks. No new Izar job was
submitted.

## Resume verification

- **3099912**: `COMPLETED` (exit `0:0`, 1m34s). It rebuilt the 12,000-step
  supervised h=1024 Run B. Its metrics reproduce the healthy solution: peak
  86.205 at a=1.02 (target 88.084), rho/j/S RMSE 6.02/6.92/8.40%.
- The exact saved state exists (12.7 MB):
  `/scratch/izar/chetaill/CDM/cdm-pikan/run/postshell_sigma1_Bweighted_state_rebuild_h1024/train_state.pkl`.
- **3099913** and **3099914** both completed (exit `0:0`) and their logs
  explicitly restore that exact path; their arguments have
  `skip_base_training=True`, SGD, frozen Q key
  `phys_sindy_kappajump_thr0.003`, data loss active, and weak-P2 weight 1e-3.
- Their first phase metric is peak 86.205 and rho/j/S = 6.02/6.92/8.40%, not
  the old peak-77.9 / about-12% surrogate. The test is therefore decisive.

`weak P2` below is the raw weak-P2 phase loss; all error columns are percent.

| job (LR) | phase step | weak P2 | R_P2/R_true | dK2 | P3 jump | peak | rho / j / S |
|---|---:|---:|---:|---:|---:|---:|---:|
| 3099913 (1e-6) | 1 | 2.548 | 46.31 | 843.4 | 15.68 | 86.205 | 6.02 / 6.92 / 8.40 |
|  | 250 | 2.351 | 45.46 | 824.9 | 15.17 | 86.204 | 5.99 / 6.74 / 8.07 |
|  | 500 | 2.201 | 44.83 | 811.0 | 14.77 | 86.202 | 5.98 / 6.60 / 7.81 |
| 3099914 (3e-6) | 1 | 2.548 | 46.30 | 843.2 | 15.68 | 86.205 | 6.02 / 6.92 / 8.39 |
|  | 100 | 2.293 | 45.18 | 818.9 | 15.01 | 86.203 | 5.99 / 6.68 / 8.00 |
|  | 200 | 2.110 | 44.39 | 801.7 | 14.50 | 86.201 | 5.97 / 6.52 / 7.71 |

K2 RMSE also improves: 8.27% -> 6.99% (1e-6, 500 steps) and 6.57%
(3e-6, 200 steps). No NaN, Inf, or divergence occurred in either phase.

Checkpoint paths:

- 3099913: `.../postshell_sigma1_Bweighted_SGDweak_w1em3_lr1em6_500_fromB/phase_checkpoints/C2_stress_only_step00050.pkl` through `...step00500.pkl`; final state at `.../phase_diagnostics/C2_stress_only_state.pkl`.
- 3099914: `.../postshell_sigma1_Bweighted_SGDweak_w1em3_lr3em6_200_fromB/phase_checkpoints/C2_stress_only_step00050.pkl` through `...step00200.pkl`; final state at `.../phase_diagnostics/C2_stress_only_state.pkl`.

## Interpretation

- **Does weak P2 decrease from healthy Run B?** Yes. Its raw loss falls 13.6%
  at 1e-6 and 17.2% at 3e-6; R_P2/R_true falls 3.2% and 4.1%, respectively.
- **Are fields preserved?** Yes. The peak stays 86.20 throughout; rho, j, S,
  K2, and P3-jump errors all improve slightly. In particular, j is stable
  (6.92% -> 6.60% or 6.52%), with no evidence of the Adam-like drift.
- **Which LR is safer?** `1e-6`: it is demonstrated stable for 500 steps.
  `3e-6` is promising and faster per step, but is only validated for 200;
  it is not yet justified for a long continuation.
- **Is the gain enough?** It is a useful, stable PDE reduction, but still
  small relative to dK2 about 800% and R_P2/R_true about 45. It justifies a
  staged 1500-step test, not an uninspected 3000-step extension.

## One recommended next job (pending user confirmation)

Start again from the exact healthy 3099912 `train_state.pkl`; SGD without
momentum, LR `1e-6`, weak-P2 weight `1e-3`, weak windows `4,8`, active data
loss and frozen Q/SINDy closure; run **1500 phase steps** with metrics and
checkpoints every 50 steps, in a new output directory. Do not use 3e-6 or
extend to 3000 before that result is inspected.
