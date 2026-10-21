# REPORT — Global-T51 diagnostics

Task ID: audit-global-t51-legendre-calibration
Status: corrected w05 baseline and calibrated audit completed; no training was launched.

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

## Legendre calibration (3111391, valid after w05 correction)

The audit now uses the trainer quadratures, face fluxes, drag and gravity
conventions, and computes an independent post-IBP denominator for every Pk.
It writes 405 strata each for ZA, B2-7k and C500:
`run/local_diag/legendre_trainer_calibrated.json` on Izar.

- For C500, P1 has median \(|r|=1.26e-2\) for n=0 and 1.46e-1 for n=2;
  P2 has medians 1.07e-1 (n=0) and 2.16e-1 (n=2).
- These P1/P2 values exceed the matched ZA values by over 10x in 42–45 of
  the 45 non-negligible n=0/n=2 strata; B2 shows the same pattern.
- The w05 box was corrected from an effective \(\Delta x\) quadrature to two
  Gauss half-intervals covering exactly \([-.25,+.25]\Delta x\), with total
  weight \(.5\Delta x\). Faces and volume already used this geometry.
- The ZA P0 maxima at w05 are now \(4.20\times10^{-7}\) (n=0), zero to
  numerical precision (n=1), and \(3.53\times10^{-6}\) (n=2). The previous
  0.289/0.972/0.567 anomaly is eliminated.

## W=.5dx P0 regression (3111394, valid)

All 285 frozen T51 half-cell boxes were compared term-by-term on ZA.
The legacy independent GL8 rule, the former trainer rule, the corrected
trainer rule, and an independently evaluated P0-Legendre rule were used.

- The former trainer support was \([-0.465,+0.215]\Delta x\) with total
  quadrature weight \(\Delta x\), while its faces/volume declared
  \([-.25,+.25]\Delta x\) and \(.5\Delta x\).
- Its maximum discrepancy from the legacy rule is 2.086e-3 in \(T_{\Delta M}\),
  producing 0.306 in normalized r. Flux, drag, gravity and volume agree.
- Corrected trainer vs legacy differs by at most 9.80e-9 in \(T_{\Delta M}\)
  (3.11e-6 in r), as expected from GL4-split versus GL8 quadrature.
- Corrected trainer vs P0-Legendre is exactly equal (zero to stored precision)
  for every reported term \(T_{\Delta M},T_{flux},T_{drag},T_{grav},R,D,r,V\).

The regression is therefore understood and fixed; w05 was not silently
removed. Artifact: `run/local_diag/w05_operator_regression.json`.

Conclusion: the corrected baseline passes. P1/P2 retain strong calibrated
excess over ZA, so the Legendre validation gate is now satisfied. A training
submission still requires explicit user confirmation.

## Non-results

- 3111378/3111379 failed before output (audit implementation shape bugs);
  3111380 exposed the w05 geometry defect; 3111391 is the valid replacement.
- Adam A/B/C replay 3111288 OOMed; no gradient cosine, one-step matrix, or
  optimizer-state conclusion exists.

## 2026-10-20 — Short cold-M1 representation sequence

Jobs 3225444/46/47/48 completed normally; stderr was empty and MaxRSS was 3.43 GB.
All used normalized-dt2, cold rank-1, M1 only, spatial mean, and 20 requested LM steps.

| step | loss initial -> final | peak; curvature | ratios >.75/20 | mu/sigma2 | sigma2 | accepted step norm | accepted/attempted |
|---|---|---|---:|---|---:|---|---:|
| 1b square+xi | .0118533 -> .0117723 | 55.233118; .4163 | 1 | .004–1.72e7 | 2.54e14 | 4.38e-18–1.90e-8 | 17/18 |
| 2 abs+xi | .0118533 -> .0117752 | 55.233094; .4162 | 2 | .004–1.37e8 | 2.53e14 | 5.90e-19–1.92e-8 | 19/20 |
| 3 abs+tanh4 | .0118533 -> .0118531 | 55.233631; .4172 | 3 | .016–3.44e7 | 2.15e17 | 1.63e-20–2.47e-11 | 17/18 |
| 3r +rhoIC | .0118533 -> .0118533 | 55.233631; .4172 | 0 | .016–262 | 4.00e19 | 7.56e-17–8.53e-13 | 6/7 |

- Every preflight passed: FD max-relative error 3.44e-9; Richardson ratios 3.945/4.004/3.909.
- Each run stopped on its first fully rejected LM step; missing steps count as failures in the /20 ratio criterion.
- Controls: 3225038 curvature .421, 9/20, mu/sigma2 .06–2; 3225412 .417, 2/20, .06–4, sigma2 8.3e14.
- No step reached curvature >.9. Mean lowers loss by 0.68% without improving the peak; abs adds no benefit.
- The tanh carriers increase stiffness by 3–5 orders and make usable steps microscopic; rhoIC scaling is worst.

Artifacts: `run/local_diag/cumulative_local_q2_representation_lm/{3225444,3225446,3225447,3225448}/` on Izar.
Conclusion: stop this representation sequence; do not launch a follow-up job from these variants.

## 2026-10-21 — Frozen-IRLS acceptance and first-direction scans

Jobs 3225544 (`1f`) and 3225545 (`3rf`) completed normally; all 20 steps were accepted.
Both preflights passed (FD 3.44e-9; Richardson 3.945/4.004/3.909).

| step | scan eps | frozen/predicted | refreshed/predicted |
|---|---:|---:|---:|
| 1f | .001 / .01 / 1 | .987 / .989 / 1.491 | .280 / .280 / -.662 |
| 3rf | .001 / .01 / 1 | .108 / .108 / .060 | .033 / .033 / -.090 |

| step | refreshed loss | peak; curvature | frozen ratios >.75 | refreshed >.75 | mu/sigma2 | sigma2 | step norm |
|---|---|---|---:|---:|---|---:|---|
| 1f | .0118533 -> .0060531 | 55.215337; .3845 | 18/20 | 1/20 | 3.81e-9–1e-3 | 2.54e14 | 5.46e-8–3.66e-7 |
| 3rf | .0118533 -> .0118533 | 55.233631; .4172 | 0/20 | 0/20 | .001–16.384 | 4.00e19 | 1.54e-15–1.08e-11 |

- `1f` confirms the trust-ratio pathology: the frozen quadratic has the right local slope, while denominator/weight refresh changes the measured decrease.
- Frozen IRLS restores healthy ratios and damping for `1f`, but stronger weak-loss reduction flattens the peak further; no curvature recovery occurs.
- `3rf` fails the directional consistency test even for eps=1e-3; its representation/Jacobian path has a second defect and its LM result is not interpretable as a representation test.

Artifacts: `run/local_diag/cumulative_local_q2_representation_lm/{3225544/step_1f,3225545/step_3rf}/` on Izar.
No follow-up job was launched.

## 2026-10-21 — Peak-nullspace and determinacy controls

Jobs 3225573–3225576 completed normally; all stderr files are empty.

| step | parameters / active residuals | loss | peak; curvature | frozen ratios >.75 | mu/sigma2 |
|---|---:|---|---|---:|---|
| 1f_null | 31,870 / 7,560 | .0118533 -> .0122652 (1 step) | 55.232512; .4152 | 1/1 | .001 |
| 1f_h9 | 31,870 / 69,336 | .0149469 -> .00862344 (-42.3%) | 55.216137; .3860 | 9/20 | 3.91e-6–.001 |
| 1f_TF | 18,558 / 7,560 | .0118533 -> .00607508 (-48.7%) | 55.214775; .3835 | 16/20 | 3.05e-8–.001 |
| 1f_T | 18,090 / 7,560 | .0118533 -> .0118539 | 55.233631; .4172 | 0/20 | .001–65.536 |

The nullspace audit starts at loss .0118533, residual norm .15397, missing peak .321925. At mu/sigma2 = 1e-3, 1e-6, 1e-9, the reported quadratic costs for restoring the peak are 1.0865, .1974, .1944, all much larger than the base loss; linear changes are .0429, .0248, .0246. The two smaller-mu CG solves did not converge (relative residuals 5.82 and 4.99), so those are not reliable optima; the 1e-3 solve is only approximate (8.2e-3).

The first LM direction lowers the peak by .001119 and normalized steepest descent also points toward lower peak. Thus there is no evidence that peak restoration lies in a cheap weak-residual nullspace; the measured loss locally opposes it.

Adding M2–M9 makes active residuals exceed parameters but does not recover curvature. Removing S changes almost nothing: T+F reproduces full T+S+F descent and flattening. T alone is numerically ineffective. The local-flux block F, not S, is the decisive route used by this LM.

Artifacts: `run/local_diag/cumulative_local_q2_representation_lm/{3225573/step_1f_null,3225574/step_1f_h9,3225575/step_1f_TF,3225576/step_1f_T}/` on Izar. No follow-up job was launched.

## 2026-10-21 — Marquardt diagonal damping

Jobs 3225579 (`1m`), 3225580 (`1m_null`), and 3225581 (`1m_T`) completed normally with empty stderr.

- `1m` (20/20 accepted): loss `.0118533 -> .00554544` (-53.2%), peak `55.233631 -> 55.214531`, curvature `.3831` versus target peak `55.555556` (target curvature `.9921`). Frozen ratios were >.75 for 18/20; refreshed ratios for 2/20. The line scan has frozen/predicted `.984` at eps `1e-3`, but refreshed/predicted `.278`.
- `1m_T` stopped after rejecting all four first-step attempts. Every CG solve was unconverged (relative residuals `3.44, 3.37, 2.81, 1.37`), so this does not test whether T can descend under a valid Marquardt solve.
- `1m_null` again reports a small-mu quadratic peak-restoration cost `.1957`, or `16.5x` the base loss `.0118533`, but all three constrained CG solves were unconverged (relative residuals `2.40, 8.02, 8.90`). The number is not a certified constrained minimum.
- The 32-probe diagonal estimate is very noisy/sparse: in `1m`, `80.9–81.7%` of 31,870 entries are at the floor and the reported median is zero; in `1m_T`, `68.2%` are at the floor. Thus the run did not establish a well-resolved metric in which every column is comparably damped.

Interpretation: the usable full-block Marquardt direction still reduces weak loss while flattening the peak, but these runs do not establish that ZA is outside the decoder tangent. The T-only and nullspace claims remain blocked by failed linear solves and an inadequately resolved diagonal estimate.

Artifacts: `run/local_diag/cumulative_local_q2_representation_lm/{3225579/step_1m,3225580/step_1m_null,3225581/step_1m_T}/` on Izar. No follow-up job was launched.
