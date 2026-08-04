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
