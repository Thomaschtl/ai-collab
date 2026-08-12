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

## Audit oracle décisif weak M0–M9 — 12 août 2026

L’audit a réutilisé l’opérateur partagé `fivedelta_ablation_core` et les
échelles physiques fixes des fenêtres 1/4/8/16. Aucun entraînement n’a été
utilisé pour produire ces résultats.

- Loss weak globale oracle : `5.4843e-6` (plancher numérique/coarse-graining).
- Checkpoint data-only 3106390, meilleur état : `5.2851e-3`, reproduit à
  `4e-8` près. La valeur rapportée à l’update 0 (`0.308943`) est conservée
  comme métadonnée du run, car le champ de cet update n’a pas été rapatrié.
- Le plancher M0 est dominé par la discrétisation : RMS normalisé moyen
  `0.00201` sur la grille complète, `0.0301` à résolution spatiale /2 et
  `0.999` à /4. La cadence temporelle /2 ne crée qu’une petite hausse
  (`0.00332`). Il faut donc conserver la grille fine pour l’audit de loss.
- La fermeture cinq-delta oracle (M0–M9 → M10) donne une erreur M10 de
  `2.94e-4` et n’ajoute qu’environ `2.1e-15` RMS au résidu M9 : M10 n’est pas
  le verrou principal de ce test.
- Sur la feuille continue filtrée identiquement, la covariance exacte
  `overline(g M1)` − `g_bar M1_bar` vaut `4.95%` RMS du produit de force
  (5.4% sur l’intervalle held-out). Dans l’équation M2, remplacer le produit
  factorisé par le produit filtré réduit le défaut relatif de ~`4.7%` à
  ~`0.14%` (fenêtre 1 post-shell), et jusqu’à `0.09%` pour fenêtre 16.
  C’est une correction physique/coarse-graining importante, pas un simple
  réglage d’optimiseur.
- Le spectre JVP calculé est explicitement un diagnostic en espace des
  moments (condition ~`2.87`), pas une preuve d’unicité du réseau. Les
  perturbations de paramètres et les distances entre plusieurs solutions
  restent non disponibles localement.

Artefacts détaillés :
`run/local_diag/decisive_weak_oracle_audit_3106390/` (tables par équation et
fenêtre, convergence M0, fermeture M9, spectre et rapport).

Le premier relancement demandé (`3106471`) a atteint l’initialisation mais a
échoué avant l’update 0 sur une erreur cuFFT d’allocation GPU. La même
configuration corrigée a été relancée avec allocation GPU non préallouée et
fraction mémoire limitée : job `3106473`; il ne faut pas l’interrompre.
