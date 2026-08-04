# REPORT — Continuous 1D phase sheet vs N-body ground truth

Task ID: continuous-sheet-vs-nbody
Status: completed

No Izar job and no KAN training were launched. The repository's cold 1D
rank-force solver was run locally with Zel'dovich ICs. The converged reference
uses 65,536 sheet characteristics and 4,096 time steps for each of the 101
snapshots at `a=0.98..1.08`.

## Method

- Evolve the connected cold phase sheet in Lagrangian order.
- Integrate each linear sheet element through the same nodal CIC kernel as the
  8,192-particle N-body data, then apply the same periodic Gaussian `sigma=1`.
- Reconstruct raw moments `M0..M8`, with `u=dx/da`.
- Compare fine-grained `x(q),u(q)`, caustics, stream counts, and phase curves.
- Compare coarse-grained fields, `K2`, flux jumps, weak/integral P2 and M3
  balances with windows `1,4,8,16`. No local PDE residual was introduced.
- Re-evaluate the tri-delta prediction of held-out `M6..M8` on both truths.

Numerical controls: spatial convergence `N=4096..65536`, temporal convergence
`512..4096` steps, and sheet quadrature order `16->32`. The latter changes no
moment by more than `1.2e-7` relative at `a=1.08`.

## Fine-grained result

- Before shell crossing, relative errors in `psi` and `u` are below `8e-8`.
- At `a=1.02..1.08`, `psi` error stays below `4.3e-7` and `u` below `7.3e-6`.
- Both resolutions locate the same two post-shell caustics; caustic-position
  disagreement is at most `3.3e-7` box units.
- Stream-count maps agree in every one of the 2,048 sampled cells and both have
  a maximum of three streams on this interval.

## Coarse-grained result, post-shell

| comparison | rho | j | S | Q | K2 | P3 jump | M6 | M8 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| continuous sheet vs particle CIC | 0.037% | 0.097% | 0.002% | 0.002% | <0.001% | 0.095% | 0.093% | 0.093% |
| converged sheet vs N=8192 sheet elements | <0.001% | 0.001% | <0.001% | 0.001% | <0.001% | 0.001% | 0.001% | 0.001% |

Almost all visible discrepancy comes from replacing point-particle CIC by the
continuous integration of the N=8192 elements, not from the dynamics or the
resolution of the sheet.

The weak-P2 RMS ratio sheet/N-body is `1.000` for every window. The residual
difference normalized by the small N-body residual is `0.93%, 0.27%, 0.17%,
0.13%` for windows `1,4,8,16`. The weak-M3 residual is closer to its numerical
floor (`4.4e-9` at window 1), so its relative difference reaches 38% at window
1 but falls to 6.3% at window 16; the actual M4-jump difference is only 0.093%.

## Tri-delta robustness

| ground truth | M6 held-out | M7 held-out | M8 held-out |
|---|---:|---:|---:|
| particle CIC N=8192 | 1.358% | 0.295% | 2.441% |
| continuous sheet N=65536 | 1.358% | 0.295% | 2.441% |

The differences between these closure scores are below `1.4e-7` absolute.
Therefore the tri-delta accuracy is not an artifact of macroparticle sampling
or CIC: it describes the same coarse-grained collisionless sheet recovered by
the converged continuous representation.

## Decision

The current N-body data are validated as ground truth for this coarse-grained
1D Vlasov-Poisson problem through `M8`. Keep the tri-delta as the minimal
candidate closure of `M6` for a PINN predicting `M0..M5` with integral/weak
equations and no rollout. A four-delta model is still not justified: its gain
on M8 requires fitting M6 and M7 plus two extra moment equations, while the
three-node closure has now passed the continuum-limit sampling/deposition test.

This uses the same exact-rank characteristic integrator at higher resolution;
it is not a code-to-code verification with a second independent Vlasov solver.

Detailed artifacts:
`run/local_diag/continuous_sheet_vs_nbody_sigma1_098_108/REPORT.md` and
`scripts/diagnose_continuous_sheet_vs_nbody.py` in the main project.
