# REPORT — Late-time tri-delta test on the continuous phase sheet

Task ID: late-time-tridelta-sheet
Status: completed

No KAN, rollout, local PDE residual, or Izar job was used. Cold Zel'dovich
phase sheets were evolved locally at:

`a = 1.08, 1.2, 1.5, 2, 3, 5, 10, 20`.

The main calculation uses 65,536 characteristics, 16,384 time steps, a 2,048
point Eulerian grid, and the established CIC plus periodic Gaussian `sigma=1`.
The adaptive sheet projection limits every quadrature subsegment to 0.0625
cell. Tri-delta is reconstructed from M0..M5; M6, M7, and M8 are held out.

## Global result

| a | max resolved streams | M6 | M7 | M8 |
|---:|---:|---:|---:|---:|
| 1.08 | 3 | 0.83% | 0.25% | 1.69% |
| 1.2 | 3 | 0.13% | 0.06% | 0.27% |
| 1.5 | 3 | 0.03% | 0.01% | 0.06% |
| 2 | 3 | 0.03% | 0.02% | 0.05% |
| 3 | 5 | 12.74% | 2.30% | 23.38% |
| 5 | 11 | 24.51% | 9.70% | 45.98% |
| 10 | 19 | 31.46% | 19.72% | 59.16% |
| 20 | 65 | 36.89% | 27.95% | 67.38% |

The transition is controlled by stream complexity rather than scale factor:
tri-delta is excellent while at most three streams are present and fails
abruptly when five streams appear at `a=3`.

At `a=20`, conditioned errors are:

| region | M6 | M7 | M8 |
|---|---:|---:|---:|
| multistream bulk | 35.02% | 27.21% | 65.01% |
| caustics | 41.28% | 35.92% | 72.81% |
| exterior monostream | <0.001% | <0.001% | <0.001% |

By exact local stream count at `a=20`, M6 errors are 0.003%, 4.67%, 30.09%,
38.32%, and 41.83% for 1, 3, 5, 7, and 9 streams respectively. This confirms
that the global late-time failure comes from the multistream hierarchy, not
from the well-resolved exterior.

## Convergence at a=20

The main 65,536/16,384 result was compared with a joint reference using
131,072 characteristics and 32,768 time steps:

- rho difference: 0.011%; S: 0.002%; Q: 0.009%;
- M6 and M8 differences: 0.001%;
- tri-delta on the joint reference: M6 36.89%, M7 27.95%, M8 67.38%;
- projection order/subdivision error: at most `7.2e-7` over M0..M8.

Stream-count maps differ in only 0.146% of cells. The single central pixel is
not stream-count converged: it resolves 65 streams in the main calculation and
87 in the finest reference as nested folds become visible. The stable 1--15
stream groups already establish the closure failure, so this does not affect
the conclusion.

## Decision

For the current PINN horizon `a=0.98..1.08`, keep tri-delta: only three streams
occur and M6 remains below 1% at the endpoint. Proceed with the planned
non-rollout weak hierarchy M0..M5 closed by tri-delta M6.

Do not treat tri-delta as a universal late-time closure. For `a>=3`, a model
must increase its effective node count or evolve additional moments. A fixed
four-delta is not sufficient through `a=20`, where stable 5--15 stream regions
already exist and the central sheet contains still more nested folds.

Detailed artifacts:
`run/local_diag/late_time_tridelta_sheet_sigma1/REPORT.md` and
`scripts/diagnose_late_time_tridelta_sheet.py` in the main project.
