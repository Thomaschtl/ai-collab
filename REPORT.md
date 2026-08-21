# REPORT — Global-T51 diagnostics

Task ID: audit-global-t51-legendre-calibration
Status: all submitted audit jobs are finished; no training was launched.

## D/E functional freeze (3111377, valid)

Along \(v=\theta_{100}-\theta_{50}\), raw KAN output changes, but the
velocity correction becomes numerically null at the odd-parity projection:

| stage, \(\lambda=4\) | \(\|\Delta\cdot\|\) |
|---|---:|
| raw KAN / even parity | 2.43e-3 |
| odd parity | 3.41e-14 |
| u after tanh / gate / final | 1e-14 to 5e-15 |
| rho before mass normalisation | 3.42e-3 |
| rho final | 1.42e-5 |

Thus the local functional freeze of \(u\) precedes tanh and the gate; density
motion is further reduced by mass renormalisation. This is evidence about the
actual Adam direction, not an optimizer-state replay.

## Fixed-window phase (3111301/3111308, valid for n=0)

For C500, \(\Delta a=0.001\), changing only the time-window phase gives
\(\max_\delta|R|/(\min_\delta|R|+\epsilon)=14.3\) at \(W=.5\Delta x\) and
51.1 at \(W=\Delta x\). The fixed P0 operator is phase-sensitive. No random
shift training has been started.

## Legendre calibration (3111380, completed)

The audit now uses the trainer quadratures, face fluxes, drag and gravity
conventions, and computes an independent post-IBP denominator for every Pk.
It writes 405 strata each for ZA, B2-7k and C500:
`run/local_diag/legendre_trainer_calibrated.json` on Izar.

- For C500, P1 has median \(|r|=1.26e-2\) for n=0 and 1.46e-1 for n=2;
  P2 has medians 1.07e-1 (n=0) and 2.16e-1 (n=2).
- These P1/P2 values exceed the matched ZA values by over 10x in 42–45 of
  the 45 non-negligible n=0/n=2 strata; B2 shows the same pattern.
- However, ZA itself has systematic P0 normalized residuals at
  \(W=.5\Delta x\) (up to 0.289 for n=0, 0.972 for n=1, 0.567 for n=2).
  This is not a numerical floor: it exposes an existing mismatch between the
  trainer's w05 quadrature support and its face/volume convention.

Conclusion: P1/P2 retain strong calibrated excess over ZA, but the present
audit cannot yet authorize a P0+P1+P2 training because the \(W=.5\Delta x\)
baseline operator is inconsistent. Diagnose/correct that baseline first,
then rerun the read-only calibration.

## Non-results

- 3111378/3111379 failed before output (audit implementation shape bugs);
  3111380 supersedes them.
- Adam A/B/C replay 3111288 OOMed; no gradient cosine, one-step matrix, or
  optimizer-state conclusion exists.
