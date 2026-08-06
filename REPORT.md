# REPORT — Correction weak M1–M9 et impact pré-shell

Task ID: correct-weak-hierarchy-before-pinn  
Status: completed locally — aucun entraînement ni job Izar lancé.

## Correction appliquée

Depuis les conventions C++ `u=dx/da=a^(-3/2)v` et
`dv/da=(3/2)a^(-1/2)g`, les coefficients corrects avec le préfacteur
`(3/2)a²` sont :

`expansion = 9n/4 - 3`, `gravity = -9n/4`.

Ils remplacent `n-3` et `-n` dans :

- `scripts/diagnose_adaptive_quadrature_m20_sheet.py` ;
- `scripts/diagnose_moment_hierarchy_m0_m9.py` via le helper partagé ;
- `scripts/train_postshell_weak_hierarchy_kan.py` ;
- `scripts/diagnose_tridelta_weak_m5_oracle.py` ;
- le résidu momentum intégral/local actif de `scripts/train_dm1d_euler_integral.py` ;
- le diagnostic exact pré-shell.

Le sanity KAN corrigé (2 pas, cinq nœuds, faible grille) reste fini, avec
poids positifs et nœuds bornés.

## Audit oracle corrigé M0–M9

Held-out `a>1.04`, fenêtre 4 :

| équation | résidu/RSS |
|---|---:|
| M0 | 0.257 % |
| M1 | 0.644 % |
| M2 | **0.057 %** |
| M3 | 0.269 % |
| M4 | 0.046 % |
| M5 | 0.237 % |
| M6 | 0.033 % |
| M7 | 0.222 % |
| M8 | 0.023 % |
| M9 | 0.214 % |

Le scan résolution/filtre/cadence donne maintenant M2 sous 0,2 % partout,
contre 6,5 % avant correction. Les nouvelles échelles sont dans
`equation_scales.json`.

## Le plafond pré-shell 48,8/50

Le test Zel’dovich exact montre que, avant shell crossing, `force ≈ a Pi`.
Les deux normalisations annulent donc presque pareil les termes source sur la
solution exacte. La correction est indispensable pour la cohérence générale,
mais elle n’explique probablement pas seule le plafond 48,8/50. Elle peut
toutefois modifier le paysage de gradient autour d’une solution imparfaite.

Le plafond pré-shell doit donc aussi être attribué à la résolution/localisation
du pic et à l’optimisation KAN, après un nouveau contrôle avec la correction.

## Artefacts

- `run/local_diag/moment_hierarchy_m0_m9_a098_108/REPORT.md`
- `run/local_diag/moment_hierarchy_m0_m9_a098_108/equation_scales.json`
- `run/local_diag/m2_m3_convergence_a098_108/REPORT.md`
- `run/local_diag/preshell_momentum_coefficients/REPORT.md`
- `scripts/diagnose_preshell_momentum_coefficients.py`
