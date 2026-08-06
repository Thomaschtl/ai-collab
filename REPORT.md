# REPORT — Coefficients weak M2 et covariance gravitationnelle

Task ID: m2-coefficients-and-gravity-covariance  
Status: completed — aucun entraînement ni job Izar lancé.

## 1. Coefficients indépendants

L’intégrateur C++ définit `u=dx/da=a^(-3/2)v` et
`dv/da=(3/2)a^(-1/2)g`. Donc :

`u_a=(3/2)a^(-2)g-(3/2)a^(-1)u`.

La hiérarchie de moments est alors

`∂a M_n + ∂x M_(n+1) + (3n/(2a))M_n - (3n/(2a²))gM_(n-1)=0`.

Avec le préfacteur weak `(3/2)a²`, les coefficients source sont `9n/4`, et
après intégration temporelle : `expansion=9n/4-3`, `gravity=-9n/4`.

La forme actuelle utilise `expansion=n-3`, `gravity=-n`.

Held-out, fenêtre 4 :

| source | équation | actuelle | coefficients dérivés |
|---|---|---:|---:|
| N-body CIC | M2 | 6.550 % | 0.0725 % |
| feuille continue | M2 | 6.550 % | 0.0720 % |
| N-body CIC | M3 | 0.450 % | 0.286 % |
| feuille continue | M3 | 0.447 % | 0.285 % |

La feuille continue, projetée avec le même CIC+filtre, reproduit le N-body.
Le défaut 6,5 % est donc une erreur de normalisation de l’implémentation weak,
pas un effet de macroparticules.

## 2. Test de covariance gravitationnelle

Sur la feuille fine `N=65536`, j’ai calculé `g*u` avant projection, puis :

`tau_g1 = overline(g M1) - gbar M1bar`.

La covariance a une amplitude de 4,95 % du produit gravitationnel filtré,
soit 0,085 % en RMS absolu sur le held-out.

| gravité dans M2 | forme | résidu/RSS held-out, fenêtre 4 |
|---|---|---:|
| `gbar M1bar` | actuelle | 6.550 % |
| `overline(g M1)` | actuelle | 6.515 % |
| `gbar M1bar` | dérivée | 0.072 % |
| `overline(g M1)` | dérivée | 0.038 % |

La covariance ne réduit donc pas le verrou 6,5 % vers 0,5 %. Elle est une
correction secondaire, à inclure éventuellement après la correction principale
des coefficients.

## Décision

1. Corriger d’abord les coefficients weak `9n/4` dans M1–M9.
2. Régénérer les échelles de loss et refaire l’audit oracle M0–M9.
3. Garder `tau_g1` comme terme de coarse-graining optionnel seulement si la
   feuille continue montre un gain utile après cette correction.
4. Ne lancer aucun PINN avec l’ancienne hiérarchie.

## Artefacts

- `run/local_diag/m2_derivation_and_sheet_a098_108/REPORT.md`
- `run/local_diag/m2_gravity_covariance_a098_108/REPORT.md`
- `run/local_diag/m2_gravity_covariance_a098_108/gravity_covariance_residuals.csv`
- `run/local_diag/m2_gravity_covariance_a098_108/gravity_products.npz`
- `scripts/diagnose_m2_derivation_and_sheet.py`
- `scripts/diagnose_m2_gravity_covariance.py`
