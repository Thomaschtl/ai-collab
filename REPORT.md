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

## 2026-10-21 — Direct ZA-fit and masked Marquardt controls

Jobs 3226370–3226373 completed with empty stderr, but none produced the requested long trajectory: `za_fit`, `za_fit_TF`, and `1m2` accepted one step then rejected step 2; `1m2_T` rejected step 1. The final writer masks `stopped_no_acceptable_step` as `complete_without_success_criterion`.

- `za_fit`: ZA objective `.0094895 -> .00292547` (-69.2%) in one step, but weak loss `.0118533 -> .101933` and peak `55.233631 -> 55.147109` versus target `55.555556`.
- `za_fit_TF`: ZA objective `.0094895 -> .00263921` (-72.2%), weak loss `.0118533 -> .0862982`, peak `55.160146`. The uniform field MSE can improve while worsening the one-cell core, so this single step is not a representability test.
- `1m2`: frozen weak ratio `.876`, but refreshed loss `.0118533 -> .0142456`, peak `55.230739`; step 2 CG residuals are `2.90–4.09` and all predicted decreases are negative.
- `1m2_T`: no accepted step; CG residuals `1.02–2.55`.

The live diagonal still spans extreme ranges (`1m2`: `2.0e-21` to `1.49e14`; ZA-fit: `5.5e-12` to `3.44e10`). The implementation adds `mu*D` in raw coordinates but neither transforms by `D^-1/2` nor preconditions CG, and stops after 30 iterations. Thus dead-column masking alone does not make the solve usable.

Post-processing the saved `1m2` M1 residuals shows the one accepted step worsens centered core boxes most: RMS ratios final/initial are `2.88` for width 4 and `1.74` for width 8; the shortest temporal window (`wt=2`) reaches `4.91` and `3.08`. Widths 32/64 improve slightly. This directly localizes the flattening tradeoff to short-time centered-core constraints versus broader windows.

Artifacts: `run/local_diag/cumulative_local_q2_representation_lm/{3226370/step_za_fit,3226371/step_za_fit_TF,3226372/step_1m2,3226373/step_1m2_T}/` on Izar. No follow-up job was launched.

## 2026-10-22 — Jacobi-scaled CG (`za_p`, `1p`, `1p_null`, `1p_T`)

Jobs 3226443–3226446 completed normally with empty stderr.

- `za_p` accepted 40/40 steps, but only steps 35–40 have `CG_converged=true`; steps 1–34 have relative residuals `.00164–.273`. The ZA objective nevertheless decreased from `.0094895` to `2.7369e-5` (factor 347), and the final forward state has peak `55.63297` versus `55.55556`, global rho RMS `.003388`, core rho RMS `.04767`, endpoint-core max error `.34424`. Weak loss is `.02742` versus `.01185` initially.
- Because representability is an existence question, that final state rules out a hard decoder ceiling near peak `55.2`; it does not prove exact representation of the full ZA core/trajectory. The optimization path is not a clean GN trajectory because its first 34 solves were unconverged, and the six converged final steps occur only at mu `1.02–65.5`, with little remaining progress.
- `1p` accepted no step; all four solves are unconverged (relative residual `.221–1.77`). No physics conclusion.
- `1p_null` accepted no LM step, and its three constrained solves are grossly unconverged (relative residual `5.97–11.9`). The newly reported cheap peak-restoration cost (`~1e-4`, below base loss `.01185`) is invalid until the constrained solve converges.
- `1p_T` accepted 20 steps, but only steps 2–6 converge; later residuals reach `.410`. Across the five converged high-damping steps, the peak stays essentially fixed/slightly lower (`55.23359 -> 55.23315`). The final loss `.00596` and peak `55.23070` mix converged and unconverged steps and are not a clean T-only result.

Interpretation: Jacobi scaling helps only once damping becomes large; it does not yet solve the low-damping weak or nullspace systems. The decoder can produce a near-ZA peak, so the remaining issue is not a simple representational ceiling, but the weak-objective/tangent question remains unresolved by `1p` and `1p_null`.

Artifacts: `run/local_diag/cumulative_local_q2_representation_lm/{3226443/step_za_p,3226444/step_1p,3226445/step_1p_null,3226446/step_1p_T}/` on Izar. No follow-up job was launched.

## 2026-10-22 — Explicit dense Jacobian/SVD

Jobs 3227348 (`1d` theta0), 3227349 (`1d` ZA warm start), and 3227350 (`1d_T`) completed normally with empty stderr and valid SVD artifacts, but all rejected every first-step proposal.

- Dense construction is internally consistent: gradient dense/adjoint relative errors are `7.5e-9`, `1.3e-8`, `8.3e-8`; build times `295 s`, `331 s`, `155 s`.
- Theta0 TSF: J has 7,560 active rows and 13,005 selected columns; 5,639 singular values are below `1e-12*smax`. Column norms span `1.64e-19–1.19e7`. Exact normalization yields raw step norms `1.24e16–2.96e16`; all four proposals increase both frozen and refreshed loss.
- ZA warm start: 12,864 selected columns, norms `1.53e-18–7.33e6`, raw steps `6.43e14–3.23e15`; no accepted proposal. Even line-search epsilon `1e-3` increases frozen loss.
- T only: 5,896 selected columns, norms `3.73e-10–1.46e6`, raw steps `2.93e7–7.61e7`; no accepted proposal.

The exact tangent audit at theta0 reports nullspace fraction `7.75e-8` for the scaled peak gradient, but minimum residual cost per unit peak `9.62e-8` and quadratic cost for the missing peak `4.80e-16`. Thus the peak is not in the exact algebraic nullspace under the chosen cutoff, but lies along extremely small singular directions. This is a local tangent statement only: realizing it requires enormous raw parameter motion and immediately leaves the linear regime.

Interpretation: explicit J/SVD removes solver ambiguity and exposes the actual obstruction. Unthresholded exact column normalization is unusable for near-zero columns; a finite trust region or relative column-norm cutoff is required. No follow-up job was launched.

Artifacts: `run/local_diag/cumulative_local_q2_representation_lm/{3227348/step_1d,3227349/step_1d,3227350/step_1d_T}/` on Izar.

## 2026-10-22 — Dense SVD with More floor and raw trust region

Jobs 3227830 (`1d` theta0), 3227831 (`1d` ZA warm start), and 3227832 (`1d_T`) completed normally with empty stderr. All rejected every first-step proposal; the trust-region attempts stopped at raw norms `.0235`, `.0576`, and `.107`, still outside the nonlinear regime.

The corrected factorisation uses only More-effective columns: 5,715/13,054 at theta0, 6,081/12,898 at ZA-like, and 5,623/5,896 for T. Dense/adjoint gradient errors remain `7.5e-9–8.3e-8`.

Exact spectral audit from theta0:
- `s > 1e-2 smax`: residual fraction `.658`, peak change `-.0131`, raw step `.540`.
- `s > 1e-4`: residual fraction `.101`, peak `-1.553`, raw step `6.27`.
- `s > 1e-6`: residual fraction `.0263`, peak `-1.603`, raw step `32.8`.
- Peak change becomes positive only at `s > 1e-8`: `+16.0`, but raw step `4.81e3` (`+15.8`, `1.90e4` at `1e-10`).

From the ZA-like state the same pattern holds: peak changes `-.186`, `-.467`, `-.504` through the `1e-2–1e-6` bands, then `+9.04` only at `1e-8` with raw step `6.78e3`.

The exact algebraic nullspace fraction of the scaled peak gradient is negligible (`~2e-29`). The theoretical near-zero peak-restoration cost is carried by extremely small nonzero singular directions, not a true nullspace, and requires unusably large raw parameter changes.

Conclusion: on every finitely usable/well-conditioned tangent band, weak Gauss-Newton prefers a lower peak, including near ZA. Raising the peak exists only in numerically and nonlinearly inaccessible near-singular directions. This resolves the optimizer ambiguity: the effective discretized weak objective drives flattening; no follow-up job was launched.

Artifacts: `run/local_diag/cumulative_local_q2_representation_lm/{3227830/step_1d,3227831/step_1d,3227832/step_1d_T}/` on Izar.

## 2026-10-22 — Core-weight scan and window continuation launched

After local `py_compile`/`bash -n` checks and checksum-verified synchronization, two independent Izar jobs were submitted:

- `3228133`: core-stratum weight spectral scan (`w = 1,10,100,1000`), GPU Volta, 40 GB, 2 h.
- `3228134`: dense-LM continuation with the default `CONT_WEIGHT=1`, stages `1,2,4,6,10`, GPU Volta, 40 GB, 8 h.

Both jobs entered `RUNNING` immediately on separate nodes (`i07`, `i17`); stderr was empty at launch. If `3228133` selects a different weight, rerun only the continuation with `--export=ALL,CONT_WEIGHT=<w>`.

## 2026-10-22 — Early status of core-weight scan and continuation

- `3228133` is healthy and running with empty stderr. It completed `w=1` and entered `w=10`; the `w=1` spectrum reproduces the prior result (peak increase only at `s/smax <= 1e-8`, requiring raw norm about `4.8e3`).
- `3228134` completed normally but stopped scientifically at continuation stage 0 (`a=0.9802`): zero accepted LM steps, initial/final loss `0.0274375`.
- The unchanged theta0 endpoint peak is already `50.50231` versus ZA `50.50505`, but the curvature criterion is undefined because no step was accepted.
- All four candidates predicted a decrease of about `0.0268–0.0274`, yet refreshed loss rose to `0.0804–0.1131` and frozen loss exploded to `2.76e4–1.01e5`; rejection was therefore correct. The current continuation cannot enter even the shortest window with `CONT_WEIGHT=1`.

## 2026-10-22 — Core-weight scan 3228133 complete

Job `3228133` completed normally in `1:10:54`; all four summaries are present. The only stderr line is the harmless final self-`grep` warning.

No tested weight meets the predeclared criterion of positive peak motion at `s/smax >= 1e-4`. Peak changes at `1e-4` are `-1.55, -3.61, -4.20, -4.16` for weights `1,10,100,1000`; at `1e-6` they remain `-1.60, -3.17, -2.81, -3.18`.

Positive peak motion still appears only at `1e-8`. Raising the weight reduces the corresponding raw norm from `4815` (`w=1`) to `874` (`w=1000`), but this remains far outside the local nonlinear regime. Core-row reweighting improves the near-singular scale quantitatively without moving the desired direction into a usable spectral band. Do not rerun continuation with any scanned weight.

## 2026-10-22 — Reduced denominator-floor scan launched

Submitted the single requested job `3228164`: baseline `(weight=1, floor=0)` plus denominator floors `0.01, 0.1, 1`, with `row_structure` diagnostics. It is running on `i05`, GPU Volta, 40 GB, 2 h; stderr was empty at launch. No continuation or other job was submitted.

## 2026-10-23 — Reduced denominator-floor scan 3228164 complete

Job `3228164` completed normally in `1:12:23`; all four summaries exist. The only stderr line is the harmless final self-`grep` warning.

At spectral floor `1e-4`, peak changes for denominator floors `0, .01, .1, 1` are `-1.553, -1.576, -2.014, +0.707`; the floor-1 residual fraction is `.06785` with raw step norm `4.00`. Thus floor `1` meets the predeclared criterion and moves a peak-raising direction into a usable band. Floor `.1` only gives a negligible positive sign at `1e-2` (`+.0093`) and remains negative at `1e-4`.

The baseline stiff singular energy is not centered on the core: `76.3%` lies in offsets up to 32 cells, `23.7%` up to 8 cells, and only `.0375%` in the exact core bin. Its denominator-weighted mean is `log10 D=-5.65`, confirming that tiny-denominator shoulder/decentered rows dominate the stiff spectrum. The floor changes the sign without core reweighting, supporting the quasi-null-row normalization diagnosis rather than the claim that centered core rows intrinsically prefer flattening.

Caveat: at floor `1`, adding the `1e-6` band makes peak change negative again (`-.709`, raw norm `52.4`), so the next LM must verify that damping keeps the effective step near the favorable `1e-4` band. No follow-up job was launched.

## 2026-10-23 — Floor-1 LM and continuation submitted

After syntax checks and checksum-verified sync of the three requested Python files, submitted exactly two jobs:

- `3229086`: `REPR_STEP=1d_floor`, 15-step dense LM on `[.98,.982]`, denominator floor `1`, initial damping from spectral band `1e-4`, 4 h limit.
- `3229087`: continuation with `CONT_FLOOR=1`, `CONT_BAND=1e-4`, 8 h limit.

Both request one Volta GPU, 8 CPUs and 40 GB. At submission they were pending (`Resources` and `Priority` respectively), with no stderr yet.

## 2026-10-23 — Continuation 3229087 stopped at stage 0

Job `3229087` completed normally (`0:12:25`, exit `0`, empty stderr) but stopped scientifically at `[.98,.9802]`: zero accepted steps, initial/final loss `.0231382`, theta0 peak `50.50231` versus ZA `50.50505`.

The favorable full-window floor-1 spectrum does not transfer unchanged to this one-step window. Here the hard `1e-4` spectral truncation predicts peak change `-.0425` (raw norm `94.6`), while the smoothly damped LM direction predicts `-.0336` (raw norm `61.9`). Thus it already points weakly toward further flattening.

All four full LM attempts were too large (raw norms `61.9,32.2,15.2,8.00`) and increased refreshed loss to `.0346–.0727`; frozen loss diverged. However, the diagnostic line search at amplitude `.001` (raw move `.0619`) *did* reduce frozen loss by `.01721` and refreshed loss by `.01275`. The stop therefore reflects an insufficiently small trust-region/line-search acceptance path, not absence of any descent, but that tiny descent still follows a slightly peak-lowering direction. The independent full-window control `3229086` remains running.

## 2026-10-23 — Floor-1 T+F control submitted

Added `REPR_STEP=1d_floor_TF`, identical to `1d_floor` except that the subcell block S is frozen and only `density_model` (T) plus `local_flux_coefficients` (F) are trainable. Submitted job `3229102` with a 4 h limit. It requests one Volta GPU, 8 CPUs and 40 GB and was pending for resources at submission; no other job was launched.

## 2026-10-23 — Full-window floor-1 LM 3229086 complete

Job `3229086` completed normally in `19:56` with empty stderr, but stopped at step 1 with zero accepted steps. The floor-1 spectral audit is reproduced: hard `1e-4` band peak change `+.707` (raw norm `4.00`), and the smoothly damped initial LM direction predicts `+.0776` (raw norm `2.86`).

The nonlinear check rejects that tangent direction immediately. All four attempts increase refreshed loss (`.0442–.1806` versus `.01063`) and explode frozen loss. Unlike continuation 3229087, even line-search amplitude `.001` (raw move only `.00286`) increases frozen loss by `.00982` and refreshed loss by `.00270`. Thus the favorable peak motion exists in the Jacobian/SVD model but is not exploitable at the smallest sampled finite amplitude; the local linear regime is extraordinarily small or the residual/Jacobian path has a remaining finite-difference inconsistency. The T+F control `3229102` is the next discriminator.

## 2026-10-23 — Absolute-More-floor reruns submitted

The updated dense LM uses `cumulative_tsf_lm_raw_coordinate_max=1e-2`, reports per-block/max-coordinate moves and column norms, performs centered JVP-vs-FD checks at `h=1e-6,1e-7`, extends line search to `1e-4`, and includes fallback line-search acceptance.

Submitted `3229114` (`1d_floor`, T+S+F) and `3229115` (`1d_floor_TF`, S frozen), both 4 h. They were pending for resources/priority at submission. The already-running old-code T+F job `3229102` was not interrupted and remains a historical control.

## 2026-10-23 — Old-code T+F control 3229102 complete

Job `3229102` completed normally in `16:34`, empty stderr, but accepted zero steps. Removing S nearly removes the favorable floor-1 motion at the selected `1e-4` band: hard-band peak change is only `+.00682` (versus `+.707` for T+S+F), and the smoothly damped LM predicts only `+9.5e-5` (versus `+.0776`). At `1e-6`, T+F instead predicts `+.647`, showing that removing S reorganizes where the peak-carrying direction lies in the spectrum.

The nonlinear mismatch remains without S and is worse at the sampled micro-step: line-search amplitude `.001` increases frozen loss by `.01793` and refreshed loss by `.00317`. Therefore S is not the sole source of the immediate nonlinear breakdown, although it carried most of the favorable motion at the originally selected `1e-4` band. Updated absolute-floor jobs `3229114/3229115` remain the decisive comparison.

## 2026-10-23 — Absolute-floor jobs 3229114/3229115 complete

Both jobs completed normally with empty stderr and accepted all 15 steps. T+S+F loss fell `.010632 -> .003481`; T+F fell `.010632 -> .003500`. The fallback line search made the first acceptance at amplitude `.003`; later full proposals had healthy frozen ratios (`~1.3–2.1`).

The scientific target did not improve. Peak moved `55.23363 -> 55.23024` (T+S+F, curvature `.4172 -> .4111`) and `55.23363 -> 55.23146` (T+F, curvature `.4172 -> .4133`). S is largely irrelevant to the achieved loss reduction and only modestly worsens flattening.

The absolute floor rescales 1,239 T+S+F and 1,029 T+F columns. It changes the spectral metric itself: at `1e-4`, peak change becomes `-.0155` (T+S+F, raw norm `.0132`) and `-.00204` (T+F, `.0120`), so the former `+.707` favorable direction is no longer selected.

Most importantly, the directional JVP-vs-centered-FD control fails: relative errors are `2.90/2.87` for T+S+F and `3.94/3.94` for T+F at `h=1e-6/1e-7`, not `~1e-6`. The errors are stable as h shrinks, so spline/branch non-smoothness or a diagnostic/residual inconsistency remains. The weak-column second-curvature hypothesis is therefore insufficient: the absolute floor repairs step acceptance but does not validate the Jacobian or recover the peak.

## 2026-10-23 — JVP/FD bisection launched

Submitted the single requested job `3229259` (`REPR_STEP=fd_bisect`) after syntax checks and checksum-verified synchronization. It uses one LM step, a two-iteration CG direction, no dense Jacobian, and writes global plus per-block T/S/F JVP-vs-centered-FD comparisons for `(rho,u)` fields and the frozen residual. It started immediately on `i25` with one Volta GPU, 40 GB and a 1:30 h limit; stderr was empty at launch.

## 2026-10-23 — JVP/FD bisection 3229259 complete but under-scaled

Job `3229259` completed normally in `4:53`, empty stderr. Along its full direction, residual JVP/FD error is `.0386` at `h=1e-6` and worsens to `.127` at `1e-7`, not the prior `~3`. Per block at `h=1e-6`: T fields `.680`, residual `.744`; F fields `7.16e-5`, residual `.0103`; S reports `1.0` because its FD is exactly zero.

At face value this points to the T/density-KAN decoder, while F is consistent and S is unresolved. The KAN's hard B-spline interval indicator is the only obvious nonsmooth operation on the T path; the positive asinh/mass map is shared with F and is disfavored as culprit.

However, the diagnostic direction is numerically unsuitable: total norm is only `4.84e-9` (T `4.37e-10`, S `6.87e-14`, F `4.82e-9`). Multiplication by `h=1e-6` produces parameter perturbations around `1e-15`; S is below representability and T is near roundoff. The worsening global error as h shrinks and the near-perfect line-scan agreement over amplitudes `1e-4..1` confirm cancellation rather than reproducing the earlier finite-step mismatch. Therefore the block ranking suggests T but does not yet prove the KAN operation; the FD direction must be normalized before a definitive localization.

## 2026-10-23 — Normalized JVP/FD bisection relaunched

Submitted the single requested job `3229297` (`REPR_STEP=fd_bisect`) after checksum-verified synchronization of `scripts/train_decoupled_spatial_cvar_multiscale.py`. Every tested direction is now normalized before finite differences; the diagnostic uses `h=1e-5,1e-6`, adds deterministic random directions for T/S/F beside the CG direction, and reports rho, u and frozen-residual consistency separately. The job started immediately on `i27` with a 1:30 h limit. No other job was submitted.

## 2026-10-23 — Normalized bisection 3229297 localizes the mismatch to T

Job `3229297` completed normally in `5:10` (exit `0`, about 3.6 GB RAM). S is autodiff/FD-consistent: random-S relative errors at `h=1e-5` are `7.2e-9` for rho, `2.7e-8` for u and `4.8e-7` for the frozen residual. F shows the expected centered-FD truncation law: random-F errors fall by approximately 100x from `h=1e-5` to `1e-6` (`rho 2.4e-7 -> 2.4e-9`, `u 2.0e-5 -> 2.0e-7`, residual `1.6e-5 -> 1.6e-7`).

T fails before the residual operator. For random T, rho/u/residual errors are respectively `5.0%/5.2%/3.4%` at `h=1e-5` and worsen to `40.7%/54.2%/19.5%` at `h=1e-6`; the CG-T direction shows the same roughly `1/h` worsening (`rho .43% -> 3.91%`, `u .53% -> 4.42%`). Because rho and u are both already wrong for T while S/F and their shared downstream mass/residual paths pass, the mismatch is localized to the density-model T decoder, strongly favoring the KAN/spline evaluation rather than the weak operator or only the nested time JVP. The worsening with smaller h is not smooth O(h^2) truncation; it is consistent with a nonsmooth/numerically unresolved T spline path.

## 2026-10-23 — Gradient-direction FD bisection submitted

Submitted the single requested job `3229345` (`REPR_STEP=fd_bisect`) after checksum-verified synchronization. In addition to CG and random directions, it tests the gradient restricted to each T/S/F block at `h=1e-4,1e-5,1e-6`, and reports the differentiated signal against a double-precision rounding-floor estimate for rho, u and the frozen residual. It started immediately on `i17`; no other job was submitted.

## 2026-10-23 — 3229345 identifies mixed-precision quantization in T

Job `3229345` completed normally in `5:47` (exit `0`, about 3.6 GB). Gradient-T is not inert: its JVP norms are `3.08e4` for rho and `9.51e6` for u. Nevertheless its errors grow approximately as `1/h`: rho `.043% -> .356% -> 3.80%` and u `.162% -> .647% -> 5.00%` for `h=1e-4,1e-5,1e-6`. The random and CG T directions reproduce the same law. The differentiated signal remains `1e11–1e17` times above the recorded double-precision floor, so this is neither smooth `h^2` truncation nor a quasi-inert block under that floor estimate.

The checkpoint resolves the apparent contradiction. Most large KAN T arrays (`density_model_param_1/2/3`, `5/6/7`, `9/10/11`, `13/14/15`) are `float32`; only small bias-like arrays are `float64`. S and F are explicitly `float64`. Flattened LM coordinates are promoted to float64, but unravelling casts T leaves back to float32: infinitesimal JVPs are compared with quantized finite parameter moves. S passes to rounding accuracy, and F shows clean `h^2` convergence (typically 100x per decade). Thus this run does not yet prove a spline-derivative bug; it first proves a mixed-precision coordinate mismatch specific to T. The next correction should make all density-KAN trainable leaves float64 (or explicitly solve in native float32 coordinates with ULP-aware steps), then repeat this same check before interpreting LM geometry.

## 2026-10-23 — Float64 validation and LM submitted

After promoting every floating model/reference leaf to float64, submitted `3229374` (`fd_bisect`) then `3229376` (`1d_floor`, 4 h) in the requested order. The validation log reports all 34 floating leaves as float64, zero stderr, and unchanged theta0 decoding to about `1e-14`. At handoff `3229374` was running on `i40` and `3229376` was pending; no wait/monitor loop remains active.

## 2026-10-24 — Float64 validation passes; LM still selects the flat attractor

Both jobs completed cleanly: `3229374` in `5:41` and `3229376` in `1:12:08`, with empty stderr. Float64 fixes the T derivative audit. On gradient-T, relative errors decrease by about 100x per decade from `h=1e-4` to `1e-6`: rho `1.01e-4 -> 1.01e-6 -> 1.04e-8`, u `1.58e-3 -> 1.58e-5 -> 1.59e-7`, frozen residual `6.35e-3 -> 6.35e-5 -> 6.35e-7`. The prior mixed-precision inconsistency is closed.

The 15-step dense LM accepted all 15 steps and reduced weak loss `0.01063185 -> 0.00348622` (67.2%), but peak moved down `55.23363 -> 55.22983`; curvature `(peak-55)/.56` fell `.4172 -> .4104`, far from the `>.9` target and reference peak `55.55556`. Four-cell core mass moved slightly toward the lower ZA target (`~.0733149 -> .0733120`, target `.0732827`) without sharpening the central peak. This essentially reproduces the former float32 attractor (`3229114`: loss `.003481`, peak `55.23024`), so precision was a diagnostic/solver defect, not the scientific flattening cause.

The first exact band-`1e-4` LM direction itself predicts peak change `-.00633`. Its linear model is now valid at small amplitude (directional JVP/FD `8.95e-4` at `1e-5`, `1.13e-5` at `1e-6`); line search decreases true loss for amplitudes through `.003`, then nonlinear breakdown begins by `.01`. Spectrally, usable bands do not contain a robust rising direction: peak changes are `+.00124` at `1e-2`, `-.0155` at `1e-4`, and `-.730` at `1e-6`. Large positive motion appears only in extremely weak bands (`+2.59` at `1e-8`, raw step `16.2`; exact `+20.35`, raw step `667`), outside the local nonlinear regime. Therefore the well-resolved local weak descent from theta0 genuinely prefers flattening; the old apparent ambiguity from float32 is removed.

## 2026-10-24 — Warm-start ZA and second-order hard-IC runs submitted

Resolved the unique `za_p` warm start to job `3226443` (`endpoint_peak=55.63297`), checkpoint `run/local_diag/cumulative_local_q2_representation_lm/3226443/step_za_p/cold_m1_lm/checkpoint_final.npz`. Submitted in parallel `3230464` (`1d_floor` from that checkpoint) and `3230465` (`1d_floor_c2` from theta0), each with a 4 h limit. Both code files were syntax-checked and checksum-identical on Izar. At submission both were pending (`Resources`/`Priority`). The c2 step includes the final exact audit/post-processing and logs the hard-IC equation-vs-ZA curvature plus initial peak before LM.

## 2026-10-24 — Early status of ZA warm start and c2

Both jobs are running. `3230464` has accepted 2 steps: weak loss `0.01658 -> 0.00607` while peak remains near ZA (`55.63297 -> 55.63258`, reference `55.55556`) and core-4 mass stays `0.0733015` versus reference `0.0732827`. This is the first early evidence that weak loss can fall substantially from a ZA-like state without immediate peak collapse. Its stderr contains 10 XLA autotuner `Red zone modified` messages from startup on `i10`; no exception occurred and checkpoints continue to be written, but final results need that caveat.

`3230465` confirms a material missing hard-IC curvature. Before LM, c2 raises the theta0 peak `55.23363 -> 55.29004`, increasing recovered curvature `.4172 -> .5179` and closing 17.5% of the former missing peak gap. More strikingly, initial weak loss is only `4.776e-4` versus `1.063e-2` without c2 (95.5% lower), and core-4 mass after two tiny accepted steps is `0.07328626`, within `3.5e-6` of ZA. After two steps loss is `4.676e-4` and peak is unchanged. Both runs remain in progress; final audit/post-processing is not yet available.

## 2026-10-24 — Six-step status: a lower-loss ZA-like basin exists

Both runs remain active with 6/6 accepted steps. Warm-start `3230464` has reduced loss `0.01658 -> 0.002864` (82.7%) while peak increased slightly `55.63297 -> 55.63473` rather than collapsing; this loss is already below the theta0 flat-attractor result `0.003486` at peak `55.22983`. Therefore the same physics-only objective admits a sharper, lower-loss local basin, and the theta0 failure is at least a basin/reachability problem rather than proof that the global weak objective prefers the flat state. Core-4 mass drifts slightly away from ZA (`0.07330356` vs `0.07328273`), so the final profile still requires inspection. The initial 10 XLA red-zone autotuning warnings have not recurred.

c2 `3230465` has reduced its already-low loss `4.776e-4 -> 3.833e-4` (19.7%) while peak is stable/slightly rising (`55.290040 -> 55.290090`) and core-4 mass inches toward ZA (`0.07328624` vs `0.07328273`). Its accepted damping remains high (`125.3` at step 6), so progress is conservative. Final audits are not yet available.

## 2026-10-24 — c2 block and resolution controls submitted

Submitted `3230494` (`1d_floor_c2_TF`, 4 h, T+F only on the 2048 grid) and `3230495` (`1d_floor_c2_r2`, 8 h, T+F on 4096 cells) in parallel with the active c2 job. The refined run keeps F and legacy boxes at fixed physical sizes and adds 1/2-fine-cell core boxes. Both scripts passed compilation and are checksum-identical on Izar; both variants log initial/per-step core-mass curvature recovery and include final exact audits. At handoff `3230494` was running on `i56`, while `3230495` was pending for resources.

## 2026-10-24 — Warm-start 3230464 failed technically after six valid steps

`3230464` ended `FAILED` after `44:26`, not normally. At the construction of the step-7 dense Jacobian on node `i10`, XLA/cuBLAS autotuning reported repeated red-zone modifications and finally `No valid config found`; this is a GPU kernel/autotuning failure, not LM rejection or scientific divergence. Six accepted checkpoints remain, with recovery at `checkpoint_step_006.npz`; no final checkpoint or final audit was produced.

Across those six accepted steps, loss fell `0.0165798 -> 0.00286428` (82.7%), every frozen trust ratio was healthy (`0.83, 1.04, 1.35, 1.51, 1.49, 1.46`), and damping fell `2.21 -> .06897`. Peak was preserved but not improved toward ZA: `55.63297 -> 55.63473` versus `55.55556` (relative peak error `.139% -> .143%`). Core-4 mass drifted slightly away (`.0733014 -> .0733036`, ZA `.0732827`). Despite being incomplete, step 6 already has lower loss than the flat theta0 attractor (`.003486` at peak `55.2298`), establishing a distinct sharp low-loss basin; it does not establish its converged endpoint. A continuation would need to resume step 6 on a different node / safer cuBLAS autotuning configuration.

## 2026-10-24 — c2 3230465 complete: mass curvature solved, point peak remains

`3230465` completed all 20/20 accepted steps in `1:41:46`, exit 0 and empty stderr. Hard c2 starts at peak `55.290040`, initial weak loss `4.77612e-4`, and core-mass curvature recovery `1.0564` (reconstructed from the identical c2-TF validation fields; this metric was added after 3230465 had started). Final loss is `2.36478e-5` (95.0% below its already-low c2 start, 99.78% below the no-c2 theta0 loss), while peak only moves to `55.290553` versus ZA `55.555556` (0.477% low; recovered point-peak curvature `.5188`). Core-4 mass ends `.073285752` versus ZA `.073282728`, corresponding to curvature recovery `1.0483`: the core mass dynamics are essentially complete/slightly overshot.

The final exact audit confirms a local low-loss plateau for the point peak. The accepted LM direction predicts only `-9.8e-6` peak change. At spectral floors `1e-2/1e-4/1e-6`, peak changes are `~0/+0.00135/-0.00169`; order-unity positive motion appears only at `1e-8` (`+1.05`, raw step `.503`), outside the safe local band. Thus c2 repairs almost all weak residual and core-mass curvature but not the pointwise/subcell profile. Combined with incomplete warm-start 3230464, the two runs show distinct facts: a sharp physics-only basin exists, yet the coarse c2 basin can satisfy the weak mass dynamics nearly exactly while retaining a 0.48% point-peak deficit. The T+F and r2 controls are the correct discriminators for S versus spatial resolution.

## 2026-10-24 — In-progress c2 controls: S is inactive; resolution matters

Both controls are healthy with empty stderr. Coarse T+F `3230494` is at 19/20 accepted steps: loss `4.776e-4 -> 2.408e-5`, peak `55.290040 -> 55.289995`, core mass `.073286262 -> .073285998`, and core-mass curvature recovery `1.0564 -> 1.0522`. This is already indistinguishable from full T+S+F c2 (`2.365e-5`, peak `55.290553`, recovery `1.0483`) at scientific scale, strongly indicating S contributes nothing material in this regime.

Refined T+F `3230495` is at 12/20 accepted steps: the 4096 grid raises the initial peak to `55.412939` from coarse `55.290040`, immediately closing 46.3% of the remaining point-peak gap. Loss falls `7.833e-4 -> 1.623e-5`, peak stays near `55.4125` (ZA `55.5556`, 0.257% low), and mass-curvature recovery moves `1.0796 -> 1.0683`. Thus spatial resolution is a major part of the residual point-peak error, but x2 alone has not eliminated it. Neither final audit is available yet.

## 2026-10-24 — Residual-by-box post-processing and final c2-TF

Synchronized and ran `scripts/analyze_residual_by_box.py` on `3229376`, `3230465`, `3230494`, and in-progress `3230495`; each wrote `residual_by_box.json` in its run directory. The first three include before/final; r2 currently includes before only. Final c2 residual energy is concentrated at the core half-cell boxes: for T+S+F, final shares are core `.6583`, `subcell_w05 .5983`, Q1 `.6861`; T+F is essentially identical (core `.6621`, `subcell_w05 .6038`, Q1 `.6886`). Their final residual sums are `1.60237` and `1.59756` respectively. The r2 before dump has sum `64.1961`, with shares `<=32dx .8168`, core `.0133`, Q0 `.8955`; final is pending.

`3230494` completed normally in `1:24:43`, 20/20 steps, empty stderr. Loss `4.77612e-4 -> 2.29916e-5`, peak `55.290040 -> 55.290100`, core mass `.073286262 -> .073286023`, curvature recovery `1.05639 -> 1.05258`. This matches full c2 within `6.6e-7` loss and `4.5e-4` peak. Its final audit has no usable local peak recovery: band `1e-4` gives `+0.00136`; order-one motion appears only at `1e-10` with raw step `21.9`.

## 2026-10-24 — r2 complete: remaining floor is fine-core spatial

`3230495` completed 20/20 steps in `1:58:58`, exit 0. Loss `7.833e-4 -> 2.718e-6`; peak `55.412939 -> 55.412390` versus ZA `55.555556` (0.2577% low); core-mass curvature recovery `1.0796 -> 1.0604`. Relative to coarse T+F, x2 resolution lowers final loss by 8.46x and nearly halves point-peak error (`.4778% -> .2577%`), while LM itself leaves the peak essentially unchanged.

The updated residual-by-box final sum is `.36051`. Remaining shares are core `.7524`, `subcell_w05 .7216`, Q1 `.7654`, P0 `.9831`; the top three individual rows are all Q1/P0/M1 half-cell core boxes. Half-cell strata are the only ones that worsen (`final/initial 1.13–1.16`), while the widest w128 strata go to zero. This is the predicted fine-core spatial-discretization signature: S is immaterial, c2 solves temporal core-mass dynamics, and the residual floor/point peak are controlled by the smallest spatial scale. x2 materially improves but does not fully converge the point peak.

## 2026-10-24 — Half-cell restoration and r4 controls submitted

After local and Izar compilation checks, synchronized the main trainer and representation wrapper and submitted the three user-approved independent controls: `3230576` (`1d_floor_c2_TF_hc`, T+F with restored odd-Q1 half-cell rows, 3 h), `3230577` (`1d_floor_c2_hc`, T+S+F with the same rows, 3 h), and `3230578` (`1d_floor_c2_r4`, T+F on the x4 grid with the historical mask, 10 h). All request one normal Volta GPU, 8 CPUs, and 40 GB. At handoff all are pending (`Resources`, `Priority`, `Priority`); no monitoring loop remains active.

`3230578` subsequently failed after `4:49` with GPU `RESOURCE_EXHAUSTED` while allocating `13.29 GiB` in the initial residual adjoint, after its preflight had passed and before any LM step. It therefore contains no scientific r4 result. The 40 GB Slurm request is host RAM, not GPU VRAM. At the same check, `3230576` and `3230577` had both passed preflight and entered their LM branches normally on `i51`.

With explicit user approval, resubmitted only the identical r4 configuration as `3230596` on `gpu-xl`, retaining one Volta GPU, 8 CPUs, 40 GB host RAM, and a 10 h limit. At handoff it is pending for resources with `ixl01` selected by the scheduler; no monitoring loop remains active.

At user request, cancelled pending `gpu-xl` job `3230596`. The r4 OOM occurred in a redundant global residual VJP: dense LM subsequently constructs J explicitly and had previously verified `J.T @ r` against that adjoint to `2.3e-13`. The dense path now skips the global VJP/stochastic-adjoint prepass, determines dead/weak columns from exact dense column norms, and obtains the gradient directly as `J.T @ r`; matrix-free CG is unchanged. The modified trainer compiles locally and on Izar with matching SHA-256. Resubmitted identical r4 science configuration as `3230602` on normal `gpu` (10 h, 40 GB host RAM); it started immediately on `i35`. No monitoring loop remains active.

Scoped the dense-adjoint bypass to an explicit option enabled only for r4, preserving the faster sequential live-column prepass and dense-gradient consistency check for coarse jobs. Submitted formulation control `3230617` (`1d_floor_half`, one step, warm-start from exact za_p checkpoint `3226443`, 40 min) and, after its 353 half-domain geometries plus metadata/trajectory initialized with empty stderr, submitted equivalence run `3230618` (`1d_floor_c2_TF_half`, 20 steps, 3 h). Both started immediately. At the same handoff, r4 `3230602` had run 17.5 minutes on a normal GPU, well beyond the former 4:49 adjoint OOM point.

## 2026-10-25 — Restored-row controls complete; half-domain interim status

`3230576` (T+F hc) and `3230577` (T+S+F hc) completed 20/20 accepted steps. From identical loss `.00060465` and peak `55.29004`, T+F ends at loss `.00015303`, peak `55.29069`, core mass `.073286394` (curvature recovery `1.0585`); T+S+F ends at `.00014053`, peak `55.29939`, core mass `.073286020` (recovery `1.0525`). Target peak/core mass are `55.55556`/`.073282728`. S therefore gives only a modest 8.2% loss gain and `+0.0087` peak. Final residual energy remains dominated by half-cell Q1/P0 rows: `59.98%` for T+F and `56.14%` with S (total sums `1.5819` and `1.5049`). Restoring the missing equation exposes but does not remove the coarse fine-core floor.

`3230602` r4 passed the former global-adjoint OOM but failed at 26:08 in the step-1 peak audit: with the dense J/SVD resident, differentiating the endpoint peak needed another 200 MiB of GPU memory. No LM step/dump exists. `3230617` warm-start formulation control timed out at 40 min before its initial residual dump, so the requested same-state unilateral-vs-centred check remains unavailable. `3230618` half-domain is healthy at 12/20 accepted steps: loss `.08577 -> .002261` (not comparable to hc), peak `55.29004 -> 55.34644`, but core-mass curvature recovery overshoots `1.0564 -> 1.2066`; it is still running with empty stderr. Its initial residual is dominated by unilateral half-tiles (`w1.5`, `w2.5`, `w4.5`), but the missing warm-start control prevents declaring formulation equivalence.

Detailed hc ratios clarify the role of S. In `3230576` T+F, final/initial `w0.5` ratios for wt `1/2/4/5/8/10` are `.988/.984/.991/.981/.989/.953`: restored rows barely move. Core mass moves away from reference by `+1.32e-7` (`.073286262 -> .073286394`, reference `.073282728`; recovery `1.05639 -> 1.05850`). With S in `3230577`, ratios are `.859/.879/.901/.895/.870/.806`, a real 10–19% reduction, and core mass moves toward reference by `-2.42e-7` (`.073286262 -> .073286020`; recovery `1.05639 -> 1.05253`). Thus S acts on the restored rows, but only weakly in absolute field terms.

At 16/20 accepted steps, `3230618` has monotone true refreshed loss `.004571 -> .001182` and peak `55.30128 -> 55.43428`, while core-mass curvature recovery drifts from initial `1.05639` through `1.27567` (step 5), briefly back to `1.19328` (step 11), then to `1.86608` at step 16. This confirms mass drift while the half-domain objective decreases. No final residual dump exists yet, so the predicted decrease of `w0.25` cannot yet be tested; its initial shares are only `.04/.04/.03/.02/.01/0%` for wt `1/2/4/5/8/10` (absolute energies `.789/.789/.592/.395/.197/0` within total `1973.63`).

`3230618` timed out at 3 h after 19/20 accepted steps; the JSON remains `running` because Slurm killed it, and there is no final residual dump or final checkpoint. `checkpoint_step_019.npz` is valid. At step 19, true refreshed loss is `.00086125`, peak `55.47041` versus `55.55556` (0.1533% low), but core mass is `.073352853` versus `.073282728` and curvature recovery is `2.11896`. Thus the half-domain objective nearly recovers the point peak by over-injecting core mass (~`7.01e-5` excess, about 20x the initial excess). Testing whether `w0.25` itself fell requires a no-update residual evaluation from checkpoint 19 because forced timeout prevented `normalized_residual_final.npy`.

## 2026-10-25 — Long-window and r4 no-audit jobs submitted

Verified that `1d_floor_c2_TF_long` uses T+F, c2, the full `[.98,.99]` window, historical half-cell mask, and the dense no-field-adjoint path; `REPR_NO_AUDIT=1` disables both peak audits, while accepted-step checkpoints/trajectory writes remain active. Compiled and checksum-verified the main trainer, representation wrapper, and continuation script locally and on Izar. Submitted `3230773` (long window, 15 LM steps, 16 h) and `3230774` (r4, 10 LM steps, 12 h) in parallel on normal Volta GPUs with 8 CPUs/40 GB each. At handoff both are pending (`Resources` and `Priority`); no monitoring loop remains active.

`3230774` r4 completed 10/10 accepted steps in 2:17. Grid x4 starts at peak `55.48900` (0.1198% below `55.55556`), improving the spatial sequence coarse/r2/r4 from 0.478% to 0.258% to 0.120%. LM lowers loss `.0008071 -> .0003067` but leaves peak fixed/slightly lower (`55.48888`). Core-mass curvature moves only `1.08415 -> 1.08151`; core mass moves slightly toward reference (`.073288002 -> .073287836`, target `.073282728`). Thus resolution, not LM, recovers the point peak; the remaining short-window mass correction is small and locally stiff. Residual sum falls `75.69 -> 23.46`; w1/w2 strata fall mostly to 7–63% of initial, while historical masked w0.5 rows are mixed and not interpretable where initial energy is zero.

`3230773` long-window failed before step 1 after 32:40. Preflight passed and the initial residual dump exists, but the dense Jacobian SVD (`gesvd`) could not allocate an additional 4.44 GiB workspace. There is no checkpoint and the initial core-mass curvature was not flushed to trajectory. Skipping the field adjoint and audits solved the earlier memory sites, but full-window dense SVD itself does not fit a normal Volta GPU; this run produced no basin-test answer.

## 2026-10-25 — Long-window CPU SVD resubmitted

Validated and synchronized the new exact host-SVD path in the main trainer plus the representation and continuation wrappers. With `cumulative_tsf_lm_dense_svd_device="cpu"`, the dense Jacobian is copied to host, factorized by NumPy/LAPACK, and only `s`, `Vt`, and `U^T r` are returned to the GPU; this avoids the 4.44 GiB cuSOLVER workspace that killed `3230773`. The operation is mathematically equivalent up to normal floating-point/library differences, not bitwise identical. The actual long-window problem is larger than the initial estimate: `3230773` found 18,558 total columns and 10,887 effective columns after the More floor, so the CPU factorization may take materially longer than 1–2 minutes, but the dense matrix and thin U remain comfortably within the 40 GB host allocation.

Submitted replacement job `3231398` on normal `gpu`, 8 CPUs, 40 GB, 16 h, with `REPR_STEP=1d_floor_c2_TF_long`, `REPR_NO_AUDIT=1`, and OpenMP/OpenBLAS/MKL explicitly capped at 8 threads. It is pending only for scheduler priority; the request itself is valid.

Post-processed the surviving theta0 dump from failed job `3230773`. Initial normalized residual sum of squares is `269.304`. No unique temporal window is anomalous: aggregate shares are approximately wt1 `.099`, wt2 `.200`, wt4 `.200`, wt5 `.100`, wt8 `.200`, wt10 `.201`, mostly tracking each family's row count. The error is instead dominated by spatial Q0 (`.692`; Q1 `.194`, Q2 `.113`) and asymmetric/wide boxes (asym w64 `.232`, w32 `.131`); offset shares are core `.172`, <=8dx `.492`, <=32dx `.336`. Thus the long-window initial error is spatially broad rather than isolated to one temporal subwindow. `residual_by_box.json` was written in the `3230773` run directory.

At the first live check, `3231398` was healthy and running on `i24` after roughly 32 minutes. Preflight passed, including the current finite-difference check (`5.40e-9` relative error at the smallest step and Richardson ratios `3.986–3.996`), stderr was empty, and the sequential decoder agreed with the direct fields to near machine precision. The initial field/residual dumps and `dense_column_norms_step_001.npz` had been written, showing that the step-1 dense Jacobian construction completed; the process was then entering the host-SVD phase. Host RSS was about 9.8 GB out of 40 GB. No LM step had yet completed, so `trajectory.json` still had status `initializing` and no scientific trajectory point.

`3231398` then completed and accepted step 1. The CPU SVD itself took `170.43 s`; maximum observed host RSS was about 13.0 GB, confirming that the exact host path is viable. True refreshed weak loss fell `1.07752e-3 -> 8.57911e-4` (20.4%). The accepted frozen trust ratio was `1.114` (refreshed ratio `.382`) after two larger proposals were rejected; effective damping rose from the initial band value `1.64e-5` to `.0672`. Long-window core-mass curvature moved toward its target one, `1.34259 -> 1.29291`, and core mass moved `.08777910 -> .08771178` toward ZA `.08731486`. The point peak, however, moved slightly away from ZA, `83.01978 -> 82.95397` versus target `100`. One step is insufficient to decide the basin, but the intended mass-curvature signal is currently improving while the pointwise peak is not. The job remains healthy/running with empty stderr.

`3231398` accepted step 2 before failing technically during construction of the step-3 dense Jacobian. Step 2 reduced true loss `8.57911e-4 -> 6.12836e-4`, moved core-mass curvature `1.29291 -> 1.28477` and core mass `.08771178 -> .08770074` toward their targets, while point density again moved slightly down `82.95397 -> 82.94496` versus ZA `100`. Its accepted frozen ratio was `.967`. The subsequent failure was a GPU allocation of 6.49 GiB inside `jvp_columns`, not the CPU SVD; Slurm ended `FAILED` after 59:11 with about 17.5 GB host RSS. Checkpoints through step 2 remain valid, but no `fields_final.npz` was produced.

Computed the new physical-cell observable directly from available field dumps, integrating rho over `[0,1/2048]` with each run's Gauss-8 fine-cell quadrature. For `3231398` theta0 at `a=.99`, model cell mean is `62.59872519`, ZA quadrature `62.37672421`, exact Lagrangian `62.37673704`: cell error `+0.355904%`, versus point error `-16.9802%` (`83.01978/100`). The coarse Gauss-8 reference differs from exact by `-2.06e-7` relative. For r4 `3230774` at `a=.982`, initial cell mean is `46.79740894` and final `46.79730200`, versus ZA `46.79491345` (quadrature and exact agree to `6.1e-16` relative): errors `+5.333e-5` and `+5.104e-5`, while point errors are `-1.19795e-3` and `-1.20014e-3`. No compatible `fields_final.npz` exists for the completed x1/x2 runs, so their physical-cell means cannot be recovered from existing dumps alone. The newly instrumented trainer was compiled locally/remotely and synchronized (SHA-256 `17a856e8...ff0cf5`); no new job was launched.

## 2026-10-25 — Higher-than-quadratic core-mass remainder r3 and long-run restart

Recovered `r3=(M_endpoint-M_T2)/(M_ZA-M_T2)` from existing preflight/trajectory files only. Long `3231398` gives theta0/step1/step2 `-.825551, -.560834, -.517418`, matching the predicted values and moving toward target `+1`. Short-window sequences (theta0 then accepted steps) are: x1 full `3230465`, `-1.070558 -> -0.771779`; x1 TF `3230494`, `-1.070558 -> -0.930710`; x2 TF `3230495`, `-1.926841 -> -1.221932`; x1 TF restored rows `3230576`, `-1.070558 -> -1.147972`; x1 full restored rows `3230577`, `-1.070558 -> -0.928847`; half-domain `3230618`, `-1.070558 -> -40.088179`; x4 TF `3230774`, `-2.095363 -> -1.998419`. Thus none of the short runs reaches the ZA higher-order remainder even where the ordinary loss appeared nearly solved. `3230465` predates the validation keys, so its identical theta0/`M_T2` constants were taken from same-grid/same-c2 `3230494`; its per-step endpoint masses are its own.

With the instrumented trainer synchronized, resubmitted the unchanged long-window run as `3231460` (normal GPU, 8 CPU, 40 GB, 16 h, CPU SVD, audits disabled). It started immediately on `i07` and entered preflight with empty stderr. No separate job was launched for the r3 calculation.

The unchanged resubmission was a mistake: CPU SVD fixes the earlier cuSOLVER workspace failure, but it does not fix `3231398`'s later 6.49 GiB OOM during GPU Jacobian construction at step 3. At explicit user request, cancelled `3231460` after 22:20; Slurm confirms `CANCELLED by 227296`. It no longer consumes resources. Any next long-window attempt must first reduce/release Jacobian-path GPU memory and should resume from `3231398/checkpoint_step_002.npz` rather than restarting theta0.

Verified that the local trainer now contains the missing memory fixes while Izar initially did not: explicit release of the prior step's dense matrices (`grep` count 1), removal of redundant GPU Jacobian copies in the CPU-SVD path, direct `core_mass_third_order_recovered` logging, and wrapper support for `REPR_JAC_CHUNK`. Compiled and synchronized the trainer and representation wrapper; local/remote SHA-256 match (`529b7db9...04ba5`, `18817e66...89a7`). Submitted efficient continuation `3231482` from `3231398/.../checkpoint_step_002.npz`, requesting 13 remaining LM steps, 12 h, 8 CPU/40 GB, normal GPU, CPU SVD, and no audits. It started immediately on `i07`. Default Jacobian chunking was retained because the two explicit releases should recover roughly 9 GB; the environment override remains available if needed.

At 18.5 minutes, `3231482` remained healthy with empty stderr while building its first dense Jacobian from the resumed checkpoint. GPU process memory was about 12.68 GB and host RSS 3.56 GB. This first iteration does not yet validate the cross-step release fix; the decisive point is construction of the second Jacobian in this new process. The initial field dump exactly reflects old step 2 (`rho(0)=82.944961`). Its new physical-cell mean is `62.54231377` versus ZA `62.37672421`, relative error `+0.265467%`, improved from theta0's `+0.355904%`. Trajectory initial metrics had not yet been flushed because dense initialization was still in progress.

`3231482` accepted its first resumed step with healthy frozen ratio `1.039`: true loss `6.12836e-4 -> 3.51443e-4`, core-mass curvature `1.28477 -> 1.27998`, r3 `-.51742 -> -.49190`, and physical-cell density error `+.26547% -> +.25877%`. Point rho again moved slightly down (`82.94496 -> 82.93942`, ZA 100). During construction of the second Jacobian in this process—the actual cross-step memory test—GPU memory remained flat at about 12.69/32 GB instead of accumulating the prior matrices; host current/max RSS was about 8.1/14.4 GB and GPU utilization 100%, with empty stderr. This is strong live evidence that the explicit release fix is working, although the second Jacobian had not yet completed at this check.

The second resumed Jacobian completed and step 2 was accepted, validating the cross-step release in practice; the job then began its third Jacobian with GPU memory still flat near 12.69/32 GB, 100% utilization, empty stderr, and host max RSS 18.7 GB. Physics diagnostics continue in the intended direction: r3 `-.49190 -> -.42100`, mass curvature `1.27998 -> 1.26667`, and physical-cell density error `+.25877% -> +.24194%`; point rho decreases `82.93942 -> 82.92550`. However, acceptance-metric divergence appeared: frozen loss decreased `3.51443e-4 -> 2.99338e-4` with ratio `.817`, while the refreshed reported weak loss increased to `3.65242e-4` (`+1.38e-5`, refreshed ratio `-.216`). Cumulatively refreshed loss remains well below the resumed start (`6.12836e-4`), but per-step monotonicity of the actual refreshed objective is not guaranteed by frozen acceptance and must be monitored.

At 4:05 elapsed, `3231482` had completed 9/13 accepted resumed steps with empty stderr, decisively validating the memory fix across repeated Jacobian/SVD cycles. Refreshed loss recovered from the step-2 bump and fell monotonically thereafter to `2.10630e-4` (65.6% below resumed start, 80.5% below original theta0). r3 advanced `-.51742 -> -.11564` toward target `+1`; mass curvature `1.28477 -> 1.20937`; physical-cell error `+.26547% -> +.23989%`. Point rho remains essentially flat/slightly lower (`82.94496 -> 82.92380`, ZA 100). Damping halved on each accepted step to `1.313e-4`; frozen ratios were mostly above one, but step 9 fell to `.278`, just above the acceptance region and worth monitoring. Four scheduled steps remain.

Prepared the proposed start-at-.95 continuation path but did not submit it before validating lagged Jacobian reuse. Izar initially lacked all reuse flags; compiled and synchronized exactly the four updated files (main trainer, representation wrapper, continuation wrapper, continuation Slurm), with matching local/remote SHA-256 and markers for `REPR_JAC_REUSE`, `CONT_JAC_REUSE`, and the disabled curvature-stop override. Submitted only validation job `3231545`: short x1 c2 T+F, `REPR_JAC_REUSE=2`, no audits, 3 h. It started immediately on `i34`; the ongoing non-reuse long job `3231482` continues independently on `i07`. The .95 continuation remains intentionally unsubmitted until reuse validation is read; on failure it will use the non-reuse 14 h form instead.

Both jobs completed normally. Long non-reuse continuation `3231482` finished 13/13 resumed steps in 5:30 (15 total including `3231398`'s first two): final refreshed loss `1.90245e-4`, r3 `+.04976`, mass curvature `1.17833`, physical-cell density error `+.24027%`, and point rho `82.92411` versus ZA 100. Relative to original theta0, loss fell 82.3% and r3 moved `-.82555 -> +.04976`, but neither mass correction nor cell density reached target and point rho remained flat/slightly lower.

Jacobian-reuse validation `3231545` completed 20/20 steps in 34:27. Against non-reuse x1 TF `3230494` (1:24:43), its endpoint is scientifically close: loss `2.74317e-5` versus `2.29916e-5`, peak `55.28990` versus `55.29010`, r3 `-.91379` versus `-.93071`, and mass curvature `1.05212` versus `1.05258`; new cell-density error is `9.78e-6`. One age-2 reused step (10) raised refreshed loss `2.7899e-4 -> 3.8852e-4` with frozen ratio `.060`, but the next rebuilt-J step corrected it and convergence resumed. Reuse=2 is therefore accepted for the continuation with refreshed-loss monitoring. Submitted the authorized .95 chain as `3231546`: stages ending `.955/.96/.97/.98/.99`, steps `5/10/20/30/40`, dt `.001`, reuse 2, curvature stop disabled, 8 h. It started immediately on `i23`.

CPU-only residual post-processing of completed long run `3231482` shows a clear fine-core floor, not wide-box coupling. Final residual sum of squares is `24.6923` versus `82.5835` at the resumed start. By offset, `71.52%` is core and only `4.42%` lies in the outer `<=32dx` group; by nearest edge, `87.63%` is core. Box types are dominated by `subcell_w05` (`35.06%`) plus centered w1/w2 (`17.42% + 17.41%`), while all w64 types total below 1%. Modes are Q1 `73.42%` and P0 `98.90%`. The w0.5 strata retain `87.6–95.1%` of their initial energy, whereas w64 strata fall to only `1.0–2.8%`. Therefore the remaining .98-start residual is a core/spatial-resolution floor; if the .95 chain ends with the same pattern, x2 is the justified next step.

The last-four-step trend prevents calling this a reached floor: Q1 loss still fell `5.44428e-4 -> 5.16564e-4` (5.12%), essentially the same relative rate as total loss (4.89%), monotonically by `2.26%, 1.67%, 1.27%`. Q0 fell 17.5% but oscillated; Q2 rose 3.5%. Final/initial w1 ratios by wt1/2/4/5/8/10 are `.714/.212/.513/.301/.305/.270`; w2 `.721/.242/.521/.362/.310/.278`. Thus the residual is fine-core dominated but still moving: likely unresolved representation plus slow local conditioning, not a demonstrated hard floor.

The first .95-chain job `3231546` unexpectedly completed only stage 0 (`a_stop=.955`) in 7:56. Stage 0 itself was excellent: loss `7.609e-5 -> 8.618e-9`, r3 `.5781 -> 1.3080`, mass curvature `.9742 -> 1.0188`, cell-density error `-.04175% -> +.02377%`, peak error `.0552%`. Root cause of the premature chain was Slurm syntax: commas in `--export=...,CONT_STAGE_STEPS=5,10,20,30,40` are variable separators, so only value `5` reached the job. Resubmitted only stages 1–4 as `3231549`, explicitly exporting the intact list and `CONT_ROOT` pointing to `3231546`; it started stage 1 (`a_stop=.96`) on `i34`, warm-starting from the saved stage-0 checkpoint. No stage was recomputed.

At 18 minutes, continuation `3231549` completed stage 1 (`a_stop=.96`) successfully in one accepted LM step and began stage 2 (`a_stop=.97`) from its checkpoint, with empty stderr. At .96, loss fell `2.25125e-4 -> 4.14763e-7`, r3 `.5140 -> 1.2030`, mass curvature `.9425 -> 1.0240`, point peak `24.95235/25` (0.1906% low), and physical-cell error moved from `-.3780%` to `+.19135%`. Thus mass dynamics are already solved/overshot slightly at .96, while the cell-average error grows with window length; .97 and .98 remain the decisive resolution-versus-model checks.

CPU whole-domain cell-profile analysis rules out global mass renormalization as the main cause of the .955/.96 cell error. Both model and ZA integrate to one. At .96 the two central cells have `+0.19135%` error (`+4.57e-5` mass), but the next pairs are `-.0835%` and `-.1493%`; summed over `|x|<8dx`, signed mass error is only `2.9e-8` (`2.4e-7` relative). The far `>=32dx` region contains 75.9% of ZA mass yet has only `-4.37e-6` relative signed error, not a common positive scale. A best global multiplicative fit gives factor `1.000074`, correlation of delta-rho with ZA only `.082`, and leaves `99.76%` of the RMS delta. At .955 the same fit is also ineffective (factor `1.000033`, correlation `.041`, `99.94%` RMS left). Therefore the observed central-cell excess with a lower point peak is a localized, sign-changing shape redistribution, consistent with a weakly constrained temporal/local direction rather than normalization alone. Stage .97 is running and will test its growth.

## 2026-10-26 — Continuation corrigée, étapes 1–4 relancées

`3231549` utilisait encore l'arrêt anticipé à `loss < 1e-6`; il aurait donc limité chaque fenêtre à un seul pas et rendu la comparaison trompeuse. Il a été annulé après `56:05`. Ses sorties ont été conservées sous `stage_1_n10_one_step_3231549` et `stage_2_n20_partial_3231549`; `stage_0_n5` de `3231546` reste inchangé.

Le trainer, le wrapper de continuation et le Slurm corrigés ont été compilés puis synchronisés sur Izar avec empreintes identiques. Le parser accepte `5:10:20:30:40` et la continuation fixe maintenant `cumulative_tsf_lm_early_stop_loss=None`, donc chaque étape exécute ses dix pas prévus. Le remplacement `3231556` a été soumis pour les étapes `1 2 3 4`, racine `run/local_diag/cumulative_local_q2_continuation/3231546`, réutilisation du Jacobien 2 et limite 8 h. Il est `RUNNING` sur `i33`; le log confirme le démarrage de `cumulative_local_q2_continuation_stage_1` et un nouveau dossier `stage_1_n10` a été créé.

`3231556` a terminé normalement en `4:05:39`, sans stderr, avec 10/10 pas acceptés à chacune des étapes 1–4. À `a=.96/.97/.98/.99`, les losses finales sont respectivement `3.80e-8`, `1.86e-6`, `8.84e-6`, `8.62e-4`; r3 vaut `1.190/1.151/1.021/.731`; la courbure de masse `1.022/1.032/1.006/.919`; et l'erreur de densité moyenne de cellule centrale `+.185%/+.251%/-2.54%/-15.30%`. Les pics finaux/référence sont `24.951/25`, `32.608/33.333`, `43.901/50`, `54.924/100`. L'étape `.99` ne plafonne pas encore : sur ses trois derniers pas, loss `1.183e-3 -> 1.038e-3 -> 8.622e-4` et r3 `.694 -> .712 -> .731`. La continuation résout donc bien masse et dynamique jusqu'à `.98`, mais dix pas restent insuffisants à `.99`; aucune relance n'a été soumise.

Synchronisé uniquement le wrapper de continuation ajoutant `CONT_GRID` (`canonical_grid_refinement`; SHA-256 local/Izar `1d662a9e...52a41e0`), après compilation locale et distante. Soumis la chaîne indépendante grille x2 `3231956`: départ `.95`, fenêtres `5:10:20:30:40`, reuse 2, arrêt de courbure désactivé, limite 12 h, sans `CONT_ROOT` donc sans warm-start inter-grille. Elle est actuellement `PENDING (Resources)`. Aucun contrôle x1 optionnel supplémentaire n'a été soumis.

Premier contrôle vivant de `3231956`: job sain sur `i28`, 56 min écoulées, stderr vide. L'étape x2 `.955` a terminé 10/10 pas: loss `7.05e-5 -> 2.94e-8`, r3 `1.1503`, courbure de masse `1.0092`, erreur de densité de cellule `+0.01468%`, pic `22.22116/22.22222`. L'étape `.96` est à 8/10 pas: loss `4.25e-7`, r3 `1.1305`, courbure `1.0154`, erreur cellule `-0.01517%`, pic `24.95858/25`. Contre x1 final à `.96` (`+0.1846%`), la cellule x2 est déjà environ 12 fois plus précise en valeur absolue; résultat prometteur mais étape non encore finale.

À `2:20` écoulées, `3231956` reste sain sur `i28`, stderr vide. `.96` a fini à loss `1.29e-7`, cellule `-.01411%`, pic `24.95896/25`. `.97` a fini 10/10 à loss `6.08e-7`, r3 `1.0272`, courbure `1.00587`, cellule `-.03621%`, pic `32.99168/33.33333`; contre x1 (`+.2508%`, `32.60839`), l'erreur cellule est ~6.9 fois plus petite et l'erreur du pic ~2.1 fois plus petite. L'étape `.98` vient d'entrer en initialisation; aucune mesure scientifique n'est encore disponible pour elle.

## 2026-10-26 — Fermeture sur intégrales exactes par cellule

Implémenté et exécuté localement `scripts/diagnose_cell_integral_tridelta_closure.py` sur `a=1.002..2`, grilles 2048/4096, sans réseau ni Izar. Les intégrateurs de feuille Python/C++ utilisent maintenant Gauss-7; un défaut de modulo périodique C++ aux cellules de bord a été corrigé. Contrôles: Python/C++ M0..M10 `1.28e-13`, intégration directe 2048 vs agrégation conservative 4096 `6.84e-15`, masse `1-3e-15`; convergence N/pas à `a=1.01/1.05` reste très sous les erreurs de fermeture.

Verdict: tri-delta M6 n'est pas uniformément sous 1% lorsque la zone trois-flots est sous-cellule. Dans trois-flots+caustiques, le maximum pour `a<=1.03` est `1.907%`; aux grilles 2048/4096, M6 vaut `.572/1.042%` à `1.002`, `1.579/1.793%` à `1.005`, `1.823/1.453%` à `1.01`, `1.907/.603%` à `1.02`, puis `.628/.318%` à `1.03`. L'écart relatif entre grilles reste >10% jusqu'à `a=2` (erreur de cellule continuant à converger), mais l'écart absolu tombe durablement sous 0.1 point à partir de `a=1.08`. N=5 donne M10 <`.084%` jusqu'à `1.05`, mais sa réalisabilité tombe à `90–94%` des cellules actives dès `1.05`; l'excellente erreur est donc conditionnelle. Artefacts: `run/local_diag/cell_integral_tridelta_closure/` (`REPORT.md` 75 lignes, CSV, audit, PNG).

Nouveau contrôle vivant de la chaîne x2 `3231956`: saine sur `i28`, `3:52` écoulées, stderr vide. Étapes `.955/.96/.97` terminées; `.98` est à 9/10 pas. À ce point loss `2.319e-5`, r3 `.7800`, courbure `.9384`, erreur cellule `-5.934%`, pic `43.4125/50`. La trajectoire `.98` continue nettement à progresser depuis l'initialisation (cellule `-10.660%`, r3 `.4311`): sur les pas 7–9, loss `3.156e-5 -> 2.620e-5 -> 2.319e-5`, cellule `-6.082 -> -6.013 -> -5.934%`. Elle est cependant moins convergée que x1 final (loss `8.84e-6`, r3 `1.021`, cellule `-2.54%`), donc le chiffre courant ne permet pas encore de trancher grille contre normalisation; un même nombre de pas n'est pas un même niveau de convergence sur le problème x2 deux fois plus grand.

## 2026-10-26 — Partie B, coût faible de la fermeture aux faces

Implémenté et exécuté localement, sans réseau, `scripts/diagnose_cell_integral_tridelta_weak_partb.py`: feuille dense `.98..1.1`, 65,536 caractéristiques, 16,384 pas, 512 snapshots, grilles 2048/4096. Les boîtes Q0 sont les boîtes entières non triviales du demi-domaine `[0,w dx]`; la version littéralement symétrique annule M5/M9 par parité. À chaque face, les moments exacts des deux cellules adjacentes sont moyennés avant reconstruction. Le CSV contient 40,820 fenêtres et marque les traversées de caustique.

Verdict décisif pour N=3: sur `1<=a<=1.05`, boîtes 1–4 cellules et fenêtres 1/2/4/8, le défaut ajouté dans M5 par le flux M6 tri-delta vaut `10.37–86.17%` des termes en RMS, selon grille/largeur/fenêtre; il n'est donc pas sous 1%. À 2048, largeur 4, l'oracle est à `.50–.52%` alors que la fermeture est à `10.40–10.50%`: le défaut vient bien du flux fermé, pas du plancher oracle. Exclure les fenêtres où une caustique traverse une face ne change pas les maxima. Le faible `~2%` statique de M6 est fortement amplifié par la reconstruction du flux aux faces; une tri-delta nue est écartée pour cette équation faible du cœur. Une fermeture à largeurs (ou un autre flux face-consistent) doit être validée avant le modèle.

N=5 est nettement meilleur mais pas uniformément sous 1%: défaut RMS `0.764–2.555%`, avec maxima individuels `2.04–27.59%`; seul le cas 2048/largeur 4 est sous 1% en agrégat. Artefacts complets: `run/local_diag/cell_integral_tridelta_closure/partB/REPORT.md`, `weak_box_rows.csv`, `weak_box_summary.csv`, `audit.json`. Durée CPU `~2.3 min`; aucun job Izar lancé.

## 2026-10-26 — Décomposition `.98 x2` et prolongation 30 pas

Post-traitement CPU des dumps de `3231956/stage_3_n30`, sans lire les résultats scientifiques de l'étape `.99` encore en cours. Sur les dix pas `.98 x2`, le résidu carré indicatif M1 tombe `543.961 -> 2.01979`. Les strates raffinées `w=.5,1,2` tombent ensemble `121.847 -> .65461` (`-99.46%`), et le reste `422.114 -> 1.36518` (`-99.68%`). Détail: w.5 `23.499 -> .1192`, w1 `49.392 -> .2733`, w2 `48.956 -> .2622`; chaque strate fine finit à `.3–.9%` de son énergie initiale. Leur part relative augmente `22.4 -> 32.4%`, mais le reste porte encore `67.6%`: les fines convergent un peu plus lentement, elles ne plafonnent pas et ne dominent pas.

La vraie loss baisse sur chacun des dix pas, `.0163031 -> 1.78744e-5`, avec encore `-22.9%` au dernier pas (`2.31947e-5 -> 1.78744e-5`). Verdict: convergence, pas plancher de grille démontré. Conformément à la branche prévue, soumis uniquement `3232112`: même `.98 x2`, mêmes boîtes, 30 pas LM, reuse 2, warm-start identique depuis le checkpoint final `.97` de `3231956`; checksum source/copie identique `51fb62cf...`. Job sain et running sur `i31`, 8 CPU/40 GB/Volta, limite 8 h. Le `.99` original reste intact.

## 2026-10-26 — Attribution face/cellule et représentabilité du pli

Implémenté et exécuté localement `scripts/diagnose_fold_normal_form_weak.py` sur le même oracle dense `.98..1.1`, grilles 2048/4096, sans réseau ni Izar. Le contrôle d'attribution est décisif: la tri-delta appliquée aux moments ponctuels exacts M0..M5 reproduit M6 à `~1e-14%` pré-shell et `~1e-12%` post-shell. Remplacer seulement M6 de face par la moyenne exacte des deux cellules produit déjà, sans traversée, `17.5–19.3%` pré-shell et `54.2–55.6%` post-shell à 2048/w1. La tri-delta de moments cellulaires donne `14.8–16.1%` puis `82.3–83.0%`. Le gros défaut de la partie B vient donc bien de la reconstruction moyenne-de-cellule vers face, pas de la fermeture ponctuelle.

Testé aussi le pli local `X=c1 q+c3 q^3+c5 q^5`, K=1/2/3, ajusté sur les caractéristiques dont X tombe dans les huit cellules centrales. Une spline d'Hermite utilise conjointement les fits X et u et impose `u=∂aX`; les intégrales de boîte sont faites en q et les flux sont ponctuels. K3 ajuste X à `1.01%/0.726%` RMS et u à `.450%/.256%` sur 2048/4096, mais ne satisfait pas le seuil weak de 1%: pire erreur vectorielle des quatre termes sur M0..M5, largeurs 1–4, fenêtres 1–8, `25.6%` à 2048 et `38.4%` à 4096; même sans traversée, `21.6%/26.5%`. Les traversées montent à `74.8%/171%`. La métrique est la norme des quatre écarts de termes, donc sans compensation; tous les CSV sont finis, sans NaN/Inf. Conclusion: le pli est la bonne variable géométrique, mais cette paramétrisation/fitting local K≤3 n'est pas encore une fermeture weak <1%; il faut rendre l'ajustement temporel et spatial global/contraint (ou enrichir la forme) avant de l'intégrer au modèle.

Artefacts: `run/local_diag/cell_integral_tridelta_closure/fold_normal_form/REPORT.md`, `attribution_{rows,summary}.csv`, `fold_weak_{rows,summary}.csv`, `fit_summary.csv`, `audit.json`. Durée finale ciblée: 5.2 min depuis le cache dense.

## 2026-10-26 — Représentabilité du potentiel de pli sans dérivées spatiales

Implémenté et exécuté localement `scripts/diagnose_fold_potential_representability.py`, sans réseau ni Izar, sur la feuille exacte `a=.98..1.05`, grilles 2048/4096. Le diagnostic retire un pli cubique ou quintique du potentiel cumulatif exact, puis projette `Delta Phi` et la correction de vitesse de chaque branche avec au plus un degré de liberté par 1/2/4 cellules. Les masses sont évaluées par différences de potentiel et le contrôle sous-cellulaire utilise des intervalles décalés de `dx/2`; aucune dérivée spatiale numérique de `Phi` n'entre dans le test.

Le pli cubique avec reste à une cellule passe. Sur `a=1.01..1.05`, erreurs RMS 2048/4096: `Delta Phi .0175/.0163%`, masse décalée `.468/.535%`, correction de vitesse directe `.0810/.0552%`. Le pire snapshot vaut `1.16%` sur la masse et `.132%` sur la vitesse. Les 6192 cas ont zéro mismatch du nombre de branches, zéro incrément fin négatif, zéro masse de cellule négative et aucun NaN/Inf. Le quintique n'améliore pas le résultat. `dX/da` cubique reste <`.3%` RMS, mais atteint `1.85%` juste au croisement; une correction de vitesse de branche lisse reste donc nécessaire et devra être contrainte par la cohérence avec `j=-Phi_a` dans le modèle.

Verdict: l'échec weak du pli polynomial seul n'était pas un manque irréparable de représentation. `Phi_pli + Delta Phi` et des corrections de vitesse à l'échelle d'une cellule représentent l'oracle avec une précision sub-percent sans fabriquer de structure KAN sous-cellulaire. Cela autorise un prototype de décodeur, mais ne valide encore ni l'optimisation physics-only, ni la positivité par construction hors oracle, ni les colonnes jacobiennes de `c1,c3` au passage de caustique. Artefacts: `run/local_diag/cell_integral_tridelta_closure/fold_potential_representability/` (`REPORT.md`, trois CSV/JSON d'audit). Durée CPU 2.3 min.

## 2026-10-26 — Table weak du pli corrigé: arrêt avant prototype

Implémenté et exécuté localement `scripts/diagnose_corrected_fold_weak_terms.py`, sans réseau ni Izar, sur la feuille exacte `.98..1.05`, grilles 2048/4096, M0..M5, boîtes 1/2/4 cellules et fenêtres 1/2/4/8, traversées incluses. La représentation est exactement celle du diagnostic précédent: pli cubique calé sur la caustique, `Delta Phi` et corrections de vitesse projetés à une valeur par cellule. Pour rendre explicite le choix post-shell encore ouvert, le reste cumulatif est réparti entre branches au prorata des densités du pli.

Le prérequis de 1% échoue nettement. Pour le flux M6 dans l'équation M5, toutes les configurations valent `13.3–31.7%` à 2048 et `15.2–42.7%` à 4096. Normalisée par le RSS des quatre termes, l'erreur reste `8.74–22.1%` et `10.4–29.7%`: ce n'est pas un petit dénominateur. Mismatch de branches, incréments de masse négatifs, densités de branche négatives et NaN/Inf sont tous nuls. Le défaut est donc robuste sur boîtes et fenêtres malgré la bonne représentabilité statique de `Phi` et `u`.

Conformément au protocole demandé, le prototype `train_fold_potential_prototype.py` n'a pas été écrit. Il faut d'abord corriger la répartition du reste entre branches ou introduire des potentiels/courants de branche face-consistent; ajouter des paramètres au prototype pré-shell ne résout pas ce test post-shell. Artefacts: `run/local_diag/cell_integral_tridelta_closure/corrected_fold_weak_terms/REPORT.md`, CSV par ligne/synthèse, diagnostics snapshot et audit. Durée CPU 2.44 min.

## 2026-10-27 — Correction du verdict, prototype potentiel et trois branches lisses

Le verdict précédent sur `diagnose_corrected_fold_weak_terms.py` est retiré. Il mélangeait trois artefacts: fits indépendants par snapshot (indice de gigue temporelle `1.4–1.9`, bruit blanc), normalisation par un flux net compensé au lieu de celle du trainer, et flux ponctuel différent de `u_k^n j_k`, `j_k=-partial_a Phi_k`. Il ne testait donc ni le prototype pré-shell ni la formulation post-shell de la note.

Implémenté et exécuté localement `scripts/train_fold_potential_prototype.py`, sans modifier le trainer ni utiliser Izar. Préflight A sur ZA exact: 7020 lignes M0/M1, résidu max `1.17e-6` en quadrature de base et `3.44e-11` en quadrature doublée; statut passé. Préflight B: 102 paramètres, erreur relative RMS `Phi=1.88e-7`, `u=2.99e-6`; cellule centrale `-0.00200%`, masse quatre cellules `+0.00127%`, r3 `.99564`. Le LM dense physics-only depuis theta zéro accepte 20/20 pas; tous les critères de la note sont déjà simultanément satisfaits au pas 1 (loss `2.39e-8`, cellule `+0.0198%`, masse4 `+0.00353%`, r3 `.9871`). Au pas 20: loss `1.30e-10`, cellule `-0.00814%`, masse4 `-0.01013%`, r3 `1.04536`; le très léger dépassement final du seuil masse4 ne retire pas le succès atteint aux pas 1–13. Artefacts: `run/local_diag/fold_potential_prototype/REPORT.md` et fichiers associés.

Implémenté et exécuté localement `scripts/diagnose_smooth_branch_potential_weak.py`: trois primitives orientées de branche, pli analytique portant naissance/échange, exactement un degré de liberté de reste par cellule et par branche, splines cubiques temporelles, `j_k=-partial_a Phi_k` dans le support, boîtes centrées Q0/Q1/Q2 et normalisation du trainer. Sur les valeurs de face, le seuil 1% est passé traversées incluses: RMS M2/M4/M6 `.791/.487/.257%` à 2048 et `.288/.118/.0448%` à 4096. La table weak ne passe toutefois pas entièrement le seuil terme par terme: les pires flux valent `3.00%` (2048, M0/Q2) et `3.84%` (4096, M0/Q2); le flux M1/Q1 vaut `2.62/1.27%`. Boundary/time-test M1/Q1 valent `1.90/1.97%` à 2048 et `.855/.936%` à 4096. Expansion et gravité restent <`.016%`. Conclusion: la forme face-consistent est validée pour M2/M4/M6, mais un reste strictement limité à un degré de liberté par cellule ne garantit pas <1% sur chaque terme weak. Artefacts: `run/local_diag/cell_integral_tridelta_closure/smooth_branch_potential_weak/`.

Lecture seule de `3231956` finalisée dans `run/local_diag/cumulative_local_q2_continuation/3231956/BILAN_READONLY.md`. À `.955/.96/.97`, erreur cellule `+.0147/-.0141/-.0362%`; à `.98`, loss `1.787e-5`, cellule `-5.912%`, masse4 `-1.132%`, r3 `.77885`, encore lentement mobile mais r3 en plateau. À `.99`, loss baisse `2.899e-4 -> 2.495e-4` sur les trois derniers pas tandis que cellule `-17.60 -> -18.47%` et r3 `.4827 -> .4159` empirent. La descente weak à `.99` ne peut donc pas être expliquée par un simple manque de pas. Aucun job Izar n'a été soumis pour ces trois tâches; seuls les petits artefacts de `3231956` ont été lus.

## 2026-10-27 — Contrôle à pentes libres et porte post-shell

Le contrôle pré-shell a été refait localement avec une IC dure uniquement en valeur à `a=.98`; aucune dérivée temporelle ZA n'entre dans le LM physics-only, qui repart de corrections nulles. Préflight exact passé (`max=3.45e-11`). Après 20/20 pas acceptés, loss `9.66e-3 -> 5.12e-3`, mais cellule centrale `-14.34%`, masse4 `-10.14%`, r3 `.0322`. Erreurs finales rho/j par zones 0–8, 8–20, 20–32, >32 dx: `9.26/48.7%`, `2.42/60.0%`, `12.5/62.3%`, `11.1/348%`. La descente continue, donc ce n'est pas une preuve d'impossibilité, mais le test à 20 pas échoue nettement et montre que le succès précédent dépendait des pentes exactes imposées. Artefacts: `run/local_diag/fold_potential_prototype_free_slopes/`.

La table post-shell a aussi été refaite avec les polyfits degré 3 déjà calculés, fenêtre `[1.001,1.05]`, rapport sans colonne de quadrature et verdict uniquement sur `w>=2`. Elle échoue: pire face `1.65%` (M6/w4/4096), pires M2/M4/M6 `1.04/1.46/1.64%` à 2048 et `1.19/1.30/1.65%` à 4096; pire terme weak `21.9%` (flux M0/Q2/w2/4096). Le prototype post-shell §8 n'a donc pas été lancé: le garde-fou mono-courant à pentes libres ne l'autorise pas, et tester trois Phi_k/Q2 dedans-dehors maintenant confondrait défaut pré-shell et répartition multistream. Rapport consolidé: `run/local_diag/fold_potential_sequence_20261027/REPORT.md`.

## 2026-10-27 — Contrôle de Moré corrigé : les lignes ne déterminent pas le pli

Le contrôle pré-shell à pentes libres a été corrigé localement : suppression du plafond brut, région de confiance dans les coordonnées mises à l'échelle, `d` figé à l'IC et retiré des paramètres, base apprise annulée hors `|x|<=32dx`, amortissement adaptatif `.3/3`, 40 pas et arrêt sur progrès de trois pas. Le préflight exact passe (`3.445e-11`); le vecteur tombe de 102 à 96 paramètres.

Le LM est sain et concluant : 40/40 pas acceptés, 32 ratios sur 40 supérieurs à `.75` (médiane `.874`), loss `1.0283e-2 -> 9.4026e-9`. Pourtant la cellule centrale finit à `57.0890/62.3767` (`-8.477%`), la masse des quatre cellules à `+2.505%`, et `r3=.3514`. Le fit ZA diagnostique séparé atteint au contraire `+1.67e-4` sur la cellule, `+1.62e-5` sur masse4 et `r3=.9958`, donc la représentation peut porter les observables mais l'objectif weak sélectionne une autre solution.

Les résidus finaux sont minuscules (RMS M0/M1 `1.45e-4/1.29e-4`) et répartis : M1 `center_w16 Q1/P0` porte 37.5% de M1; M0 est dominé par `tile_±16_w4 Q1/P0` (18.35% chacun) et `tile_±8_w4 Q2/P0` (16.01% chacun). Il n'y a pas une unique strate du cœur qui plafonne. Conclusion : les lignes M0/M1 discrètes ne déterminent pas le pli depuis une IC fixée seulement en valeur; ce n'est plus un problème de solveur ou de conditionnement.

La table post-shell polynomiale `smooth_branch_potential_weak_polyfit_a1001` et son 21.9% sont retirés : un polynôme global de degré 3 ne respecte pas la naissance d'une branche à un nœud. La première table spline reste la référence; aucune autre table statique n'a été lancée. Le prototype post-shell reste fermé puisque le contrôle pré-shell corrigé échoue physiquement. Artefacts : `run/local_diag/fold_potential_prototype_free_slopes_more/` et rapport consolidé `run/local_diag/fold_potential_sequence_20261027/REPORT.md`.
