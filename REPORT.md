# REPORT — Adaptive N-delta quadratures through M20

Task ID: adaptive-quadrature-m20-sheet
Status: completed

No KAN, rollout, local PDE residual, or Izar job was used. The converged cold
sheet was projected with the established CIC plus Gaussian `sigma=1` operator
to produce M0..M20 at `a=1.08,1.2,1.5,2,3,5,10,20`.

Quadratures `Nmax=3,4,5,6,8` were tested. For each N, only M0..M(2N-1) enter
the reconstruction; M(2N)..M20 are strictly held out. Singular maximum-rank
inversions fall back locally to a lower rank, which is the fixed-architecture
limit with zero component weights.

The last dynamic equation, for M(2N-1), was evaluated in integral-space,
weak-time form after replacing only its closing flux M(2N). A separate dense
32,768-sheet trajectory with 256 intermediate snapshots was used; a 128-snapshot
pass provided a temporal convergence check.

## Held-out moments at each endpoint

| horizon | Nmax | first held-out | its error | worst error through M20 | weak closure defect / terms |
|---:|---:|---:|---:|---:|---:|
| 5 | 3 | M6 | 24.51% | 83.35% | 2.71% |
| 5 | 4 | M8 | 5.37% | 41.48% | 0.09% |
| 5 | 5 | M10 | 0.21% | 2.00% | 0.0006% |
| 5 | 6 | M12 | 0.002% | 0.02% | 0.08% |
| 10 | 5 | M10 | 2.14% | 22.68% | 0.0007% |
| 10 | 6 | M12 | 0.19% | 2.06% | 0.08% |
| 20 | 5 | M10 | 4.25% | 43.98% | 0.0007% |
| 20 | 6 | M12 | 0.79% | 9.65% | 0.08% |
| 20 | 8 | M16 | 0.65% | 8.04% | catastrophic |

## Weak comparison through a=20

| Nmax | last equation | oracle / term RSS | closed / term RSS | added closure defect / term RSS |
|---:|---:|---:|---:|---:|
| 3 | M5 | 5.93% | 5.55% | 2.88% |
| 4 | M7 | 0.80% | 0.77% | 0.10% |
| 5 | M9 | 2.29% | 2.29% | 0.0007% |
| 6 | M11 | 3.60% | 3.60% | 0.08% |
| 8 | M15 | 4.60% | 5.57e6% | 5.57e6% |

For N=6 the added weak defect decreased from 0.389% with 128 snapshots to
0.0768% with 256; N=5 stayed near 0.0007%. N=8 remains unstable: near the cold
limit, a nearly zero weight paired with an extreme velocity fits lower moments
but explodes M16. More nodes are therefore not monotonically safer without a
realizability/conditioning regularizer.

## Decision

Two criteria must not be confused:

- For the PINN hierarchy, only the first closing flux M(2N) and its weak effect
  are required. With a 5% flux threshold and 1% weak-defect threshold, the
  smallest candidate is `Nmax=5` through `a=5`, `10`, and `20`.
- To reproduce the whole velocity distribution through M20, use `Nmax=5` to
  `a=5`, `Nmax=6` to `a=10`, and none of the tested reconstructions at `a=20`.

Thus a physics-only non-rollout PINN intended through `a<=5` should evolve
M0..M9 and close M10 with an adaptive five-node representation. Keep hard ICs,
periodic boundaries, log-rho/asinh transforms, and integral weak equations only.
Do not start with N=8. For the current `a<=1.08` model, tri-delta M0..M5 remains
the smaller justified system.

Detailed artifacts:
`run/local_diag/adaptive_quadrature_m20_sheet_sigma1/REPORT.md` and
`scripts/diagnose_adaptive_quadrature_m20_sheet.py` in the main project.
