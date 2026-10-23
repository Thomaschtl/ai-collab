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
