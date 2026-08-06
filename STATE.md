# CDM-PIKAN — STATE

Updated: 2026-08-05

## Workflow rules

- Read the project `AGENTS.md` before acting.
- Never submit Izar jobs without explicit user confirmation.
- Use targeted inspection only.
- Use `codex-budget capture` for verbose commands and `codex-budget pack` before large logs.
- Do not read large artifacts in full.
- Ignore the removed local MCP `ai_bridge`.
- ChatGPT maintains `STATE.md` and `TASK.md`; Codex writes `REPORT.md`.
- Keep this repository free of secrets, credentials, personal paths, raw logs, and large artifacts.

## Project

1D cosmological CDM collapse with Eulerian PINN/KAN.

Main code repository: `cdm-pikan`.
Cluster: Izar.

## Pre-shell baseline

Target: pressureless Zel’dovich solution up to `a=0.98`.

- Analytic density peak at `a=0.98`: about 50.
- Best pre-shell KAN peak: about 48.8.
- FWHM and enclosed masses were close to Zel’dovich.
- Main difficulty: temporal consistency of the inertial term `Pi_a`, not only the final density profile.
- Final pre-shell model should remain physics-only.

## Post-shell fields and equations

Current coarse-graining: N-body CIC plus Gaussian filtering at fixed `sigma=1`.

Fields:

- `rho`
- `j = rho*u`
- `P2 = j^2/rho + S`
- `P3 = rho*u^3 + 3*u*S + Q`

`S` is the effective multistream velocity-dispersion stress at the chosen coarse-graining scale.

Integral quantities:

- `M = integral rho dx`
- `R_cont = M_a + j - j_min`
- `K2 = integral P2 dx`
- `P3_jump = P3(x) - P3(x_min)`
- `Wg = integral j*g dx`

Pointwise-in-time second-moment residual:

`R_P2 = (3/2)*a^2*(K2_a + P3_jump) + 2*a*K2 - 2*Wg`

Preferred time-weak form:

`[(3/2)*a^2*K2]_(aL)^(aR) + integral_a[(3/2)*a^2*P3_jump - a*K2 - 2*Wg] da = 0`

This avoids directly penalizing the poorly learned pointwise derivative `K2_a`.

## Q closure

Current frozen closure: `phys_sindy_kappajump_thr0.003`.

- Trained a priori on true `sigma=1` fields.
- In a closed run:
  `rho_theta,j_theta,S_theta -> Q_closure -> P3_theta -> weak P2 residual`.
- True `Q_f` is oracle-only and must not enter the final closed system.
- Current evidence: the dominant error is the temporal trajectory of `K2`, not Q alone.
- Do not redesign Q before stabilizing `rho,j,S + weak P2`.

Later Q options:

- constrained/a-posteriori SINDy or rollout training;
- spatial CNN/nonlocal closure;
- extended `(rho,j,S,Q)` system with an M4 closure, only after diagnostics.

## Continuous-sheet ground-truth validation

The N-body CIC `sigma=1` moments were compared with a converged cold 1D phase
sheet evolved from the same Zel'dovich ICs (65,536 characteristics, 4,096 time
steps), then projected with the identical CIC plus Gaussian operator.

- Fine-grained phase curves, two caustics, and one/three-stream maps agree.
- Post-shell discrepancies: rho 0.037%, j 0.097%, S/Q 0.002%, M6/M8 0.093%.
- Weak-P2 RMS is unchanged; its sheet/N-body difference is 0.13--0.93% of the
  already small reference residual for windows 16--1.
- Tri-delta held-out errors are identical on both truths: M6 1.358%, M7 0.295%,
  M8 2.441%.

Conclusion: the N-body data are a valid coarse-grained 1D Vlasov-Poisson ground
truth through M8, and tri-delta accuracy is not a particle/CIC artifact. Keep
tri-delta as the minimal M6 closure candidate for a non-rollout PINN on M0..M5;
four deltas remain unjustified.

## Late-time limit of tri-delta

The continuous-sheet tri-delta test was extended to
`a=1.08,1.2,1.5,2,3,5,10,20`, with M6..M8 held out.

- Up to `a=2`, only three streams occur and M6 error is at most 0.83%.
- At `a=3`, five streams appear and M6 jumps to 12.74%.
- At `a=5,10,20`, M6 errors are 24.51%, 31.46%, and 36.89%.
- At `a=20`, caustic/multistream M6 errors are 41.28%/35.02%, while the
  monostream exterior remains exact to better than 0.001%.
- A joint N=131072, 32768-step reference reproduces the M6/M7/M8 closure errors
  to displayed precision; projection uncertainty is below `7.2e-7`.

Conclusion: tri-delta is justified for the current `a<=1.08` PINN, but it is
not universal once more than three streams are present. Late-time work requires
adaptive node count or more dynamic moments; a fixed four-delta is insufficient
through `a=20`.

## Tri-delta semi-oracle weak-M5 test

Using true M0..M5 and gravity, only M6 was replaced by the tri-delta
reconstruction before evaluating the integral-space, weak-time M5 equation.

- Held-out `a>1.04` M6 error: 0.123% globally, 1.358% in the dispersive mask.
- The M6 spatial jump has the same error; no jump amplification is observed.
- For windows 1/4/8/16, the added closure defect is 0.0446--0.0450% of the RSS
  size of the individual equation terms.
- The total tri-delta weak residual is 0.994--0.995 times the oracle residual;
  the weak loss is therefore unchanged rather than inflated.

Conclusion: the closure passes the relevant oracle test on `a<=1.08`. Proceed
to a controlled non-rollout PINN for M0..M5 closed by tri-delta M6, using the
integral/weak hierarchy and gradient-balanced weights. Monitor compensation
among the six predicted moments and respect the measured semi-oracle floor.

## Adaptive N-delta diagnostic through M20

The converged cold sheet was projected to M0..M20 at late times and fixed
architectures with local effective rank were tested for Nmax=3,4,5,6,8.

- For the first held-out closing flux and its last weak equation, Nmax=5 is the
  smallest candidate meeting 5% moment and 1% weak-defect tolerances through
  a=5, 10, and 20.
- At a=20, N=5 predicts M10 to 4.25%; substituting it in weak M9 adds only
  0.0007% of the individual-term RSS, leaving the 2.29% oracle floor unchanged.
- Strong distribution fidelity through M20 needs N=5 to a=5, N=6 to a=10,
  and is not achieved by any tested case at a=20.
- N=8 is numerically unsafe near the cold limit: a tiny weight at an extreme
  node explodes M16 and weak M15 despite good static endpoint errors.

Recommendation: retain tri-delta M0..M5 for the current a<=1.08 PINN. For a
future physics-only model through a<=5, evolve M0..M9 and close M10 with an
adaptive five-node representation. Hardcode ICs/periodicity, keep log-rho and
asinh transforms, and use only integral/weak moment equations; do not use a
fixed unregularized N=8 closure.

## Weak hierarchy audit and trainer

Held-out oracle weak residual floors for M0..M9 are respectively
0.303%, 1.241%, 6.566%, 0.492%, 2.230%, 0.278%, 0.693%, 0.248%, 0.231%, and
0.234% of term RSS. Float32-vs-float64 gaps are only 3.4e-5 at worst, so M2's
6.566% is a physical/coarse-graining floor rather than roundoff.

Direct five-node inversion of perturbed M0..M9 is not realizable: valid active
fractions are only 1.85% at 1e-5 perturbations and 1.41% at 1e-4, with complex
roots and extreme standardized nodes. The trainer therefore predicts rho,
five softmax weights, and five bounded velocities directly, then forms M0..M10
by quadrature. This preserves positivity and realizability by construction.

`scripts/train_postshell_weak_hierarchy_kan.py` passed a local two-step sanity
run, including weak loss and checkpoint writes. It uses hard Zel'dovich ICs,
periodic features, log-rho, tanh(asinh) bounded node offsets, and weak integral
equations M0..M9 only. The Slurm wrapper is
`run_postshell_weak_hierarchy_izar.slurm`; no job has been submitted.

## Healthy supervised Run B

Reference run:
`postshell_sigma1_Bweighted_pure_supervised_h1024`

Configuration:

- MLP hidden=1024
- Adam, 12000 steps
- lr=2e-4
- sigma=1
- data weights:
  - late=5
  - center=12
  - center_width=0.012
  - rho_peak=12
- frozen Q closure:
  `phys_sindy_kappajump_thr0.003`

At `a=1.02`:

- target peak: 88.08
- model peak: 86.21
- rho RMSE: about 6.5%
- j RMSE: about 6.2%
- S RMSE: about 7.6%
- `R_P2(pred)/R_P2(true)`: about 45.8

Term diagnostic at `a=1.02`:

- K2 error: 3.8%
- Drag2 error: 3.8%
- Wg2 error: 5.9%
- P3_jump error: 16.1%
- K2_a error: 628%
- R_P2: about 55 times the exact residual

Conclusion: good snapshots, bad temporal trajectory.

A larger MLP h=2048 slightly improved pointwise fields but worsened `dK2` and the P2 residual. Model size alone does not solve temporal dynamics.

## Optimization diagnostics

Direct `-grad(P2 weak)` is locally useful:

- lowers weak P2 loss;
- lowers P2 residual;
- barely changes data loss and fields for small steps;
- gradient cosine with data: about `-0.132`, only mild conflict.

Adam can transform this useful direction into a destructive update, especially on `j`.

Previous SGD jobs 3099898–3099899:

- improved P2 residual and dK2;
- kept fields stable;
- but started from a degraded retrained surrogate with peak about 77.9, not the healthy Run B state.

Therefore they show that SGD is promising, but they are not the decisive continuation test.

## Infrastructure fix

Modified in the main project:

- `scripts/train_postshell_moment_branch.py`
- `run_postshell_branch_izar.slurm`

Trainer now supports:

- `train_state.pkl` with model parameters and full Adam state;
- phase states;
- periodic phase checkpoints;
- field metrics every 50 steps;
- `--resume_state`
- `--skip_base_training`
- `--phase_optimizer sgd`
- `--phase_checkpoint_every`

## Current decisive jobs

Last known setup:

- 3099912: rebuild healthy Run B deterministically.
- 3099913: afterok 3099912, true resume with SGD.
- 3099914: afterok 3099912, higher-LR stability probe.

3099912 expected output:

`run/postshell_sigma1_Bweighted_state_rebuild_h1024/train_state.pkl`

3099913:

- resume exact `train_state.pkl`
- SGD, no momentum
- lr=1e-6
- `lambda_P2weak=1e-3`
- weak windows 4,8
- 500 steps
- data loss active
- frozen Q/SINDy closure
- diagnostics/checkpoints every 50 steps

3099914:

- same resume
- SGD, no momentum
- lr=3e-6
- 200-step stability probe
- same diagnostics every 50 steps

Do not infer live scheduler state from this file; check Izar.

## Decision criterion

Decisive question:

Can weak P2 decrease from the true healthy Run B checkpoint while preserving the supervised solution?

Success requires:

- clear decrease of weak P2 / P2 ratio;
- peak at `a=1.02` remains close to 86–88;
- rho/j/S RMSE remain stable;
- no strong drift of j.

If 3099913 is stable, propose a continuation to 1500–3000 steps.

Do not extend lr=3e-6 before inspecting 3099914.
2026-08-06 — M2/M3 convergence audit completed.

- Added `scripts/diagnose_m2_m3_convergence.py` and ran it locally, without Izar.
- Scanned n_grid=1024/2048/4096, Gaussian sigma=0.5/1/2 grid cells, snapshot strides 1/2/4, and weak windows 1/2/4/8/16 (matched spans where available).
- Held-out M2 remains 6.52–6.66%; M3 remains 0.39–0.80%. The canonical 2048/sigma1/window4 values are 6.538% and 0.461%.
- Interpretation: M2 is a stable dominant integral/coarse-grained bottleneck, not a single-resolution/window artifact. This is not yet proof of new physics because the same N-body/coarse-graining operator is used and sigma is specified in grid cells.
- Artifacts: `run/local_diag/m2_m3_convergence_a098_108/`.

2026-08-06 — Independent M2 coefficient and continuous-sheet control completed.

- From the C++ characteristics, `u=dx/da=a^(-3/2)v` and `dv/da=(3/2)a^(-1/2)g`, yielding source coefficients `9n/4` when the weak residual keeps prefactor `(3/2)a^2`.
- The current `n` coefficients give M2=6.55% held-out, while the derived coefficients give M2=0.0725% on N-body CIC and 0.0720% on the continuously evolved sheet with identical CIC+Gaussian projection.
- Therefore the 6.5% M2 floor is an implementation normalization error, not a particle-resolution effect. Correct the weak hierarchy and regenerate M0–M9 scales before any PINN training.
- Artifacts: `run/local_diag/m2_derivation_and_sheet_a098_108/`; diagnostic `scripts/diagnose_m2_derivation_and_sheet.py`.

2026-08-06 — Gravity covariance substitution completed.

- Projected fine-sheet `g*u` with the same CIC+Gaussian operator and compared it to `gbar*M1bar`.
- `tau_g1` is 4.95% of the filtered gravity product (0.085% absolute held-out RMS).
- Substitution changes current M2 only from 6.550% to 6.515%; with corrected coefficients it changes 0.072% to 0.038%. It is not the source of the old 6.5% floor.
- Artifacts: `run/local_diag/m2_gravity_covariance_a098_108/`; diagnostic `scripts/diagnose_m2_gravity_covariance.py`.

2026-08-06 — Corrected weak M1–M9 implementation and regenerated audit.

- Replaced `n-3,-n` by `9n/4-3,-9n/4` in the hierarchy helper, post-shell five-node PINN, tri-delta audit, and active integrated/local momentum paths of the Euler trainer.
- Regenerated `equation_scales.json` and reran M0–M9. Held-out window-4 M2 is now 0.057% (previously 6.55%); all equations are below 0.65% except M1 at 0.64%.
- Ran exact pre-shell Zel'dovich integrated M1 control. Both old and corrected forms are near the exact floor because force≈a Pi before shell crossing; the 48.8/50 KAN ceiling is therefore not explained by this coefficient error alone.
- Sanity KAN run with corrected hierarchy is finite and realizable.
- Artifacts: `run/local_diag/moment_hierarchy_m0_m9_a098_108/`, `run/local_diag/preshell_momentum_coefficients/`.
