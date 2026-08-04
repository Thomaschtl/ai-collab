# REPORT — Semi-oracle tri-delta in the weak M5 equation

Task ID: tridelta-weak-m5-oracle
Status: completed

No KAN, training, rollout, local PDE residual, or Izar job was used. The test
keeps the oracle M0..M5 and gravity and changes only the closing flux:
`M6_true -> M6_tridelta(M0..M5)`.

The integral-in-space, weak-in-time M5 equation was evaluated on the 101
`sigma=1` snapshots over `a=0.98..1.08`, using windows 1/4/8/16. Fit and
held-out intervals are wholly contained in `a<=1.04` and `a>1.04`,
respectively.

## Audit

- Tri-delta reconstructs its input moments M0..M5 to `8.33e-14` relative error.
- Active quadrature validity is 99.9995%; condition-number p95 is 5.88.
- The generalized weak moment implementation reproduces the established weak
  M3 diagnostic to `2.37e-20` absolute error.

## M6 and its spatial jump

| block | M6 global | M6 jump global | M6 dispersive | M6 jump dispersive |
|---|---:|---:|---:|---:|
| fit | 0.085% | 0.085% | 1.419% | 1.419% |
| held-out | 0.123% | 0.123% | 1.358% | 1.358% |

The dispersive mask is `S > 1e-4 max_x(S)` per snapshot, matching the earlier
tri-delta metric. The weak integral itself uses the whole spatial grid. The
spatial jump does not amplify the closure error: its amplification factor is
1.000 in every block.

## Weak M5 on held-out a>1.04

| window | oracle RMS | tri RMS | tri/oracle | closure diff/oracle | oracle/terms | tri/terms | closure diff/terms |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 1.070e-10 | 1.064e-10 | 0.994 | 0.157 | 2.865e-3 | 2.849e-3 | 4.500e-4 |
| 4 | 4.036e-10 | 4.012e-10 | 0.994 | 0.167 | 2.702e-3 | 2.686e-3 | 4.501e-4 |
| 8 | 8.031e-10 | 7.985e-10 | 0.994 | 0.167 | 2.688e-3 | 2.673e-3 | 4.493e-4 |
| 16 | 1.601e-9 | 1.592e-9 | 0.995 | 0.167 | 2.680e-3 | 2.665e-3 | 4.462e-4 |

`closure diff/oracle` looks larger because the oracle residual is already the
small remainder of a strong cancellation. The decisive normalization is
`closure diff/terms`: replacing M6 adds only about 0.045% of the RSS size of
the individual equation terms. The normalized weak loss changes by a factor
0.988--0.989, i.e. it does not increase.

## Decision

The semi-oracle test passes. On `a<=1.08`, tri-delta is accurate enough to
close M6 in a controlled non-rollout PINN for M0..M5. There is no evidence that
the spatial jump or weak integration amplifies its held-out M6 error.

Next, start from a supervised M0..M5 checkpoint and activate the integral/weak
moment hierarchy with a gradient-balanced PDE weight. Do not force the loss
below the measured semi-oracle floor, and monitor each moment to detect any
compensation among M0..M5. This result does not extend tri-delta beyond the
previously established late-time limit near the transition to five streams.

Detailed artifacts:
`run/local_diag/tridelta_weak_m5_oracle_sigma1_098_108/REPORT.md` and
`scripts/diagnose_tridelta_weak_m5_oracle.py` in the main project.
