# REPORT — Audit indépendant des coefficients weak M2

Task ID: m2-coefficients-vlasov-sheet  
Status: completed — aucun entraînement ni job Izar lancé.

## Dérivation indépendante

Les conventions de l’intégrateur C++ sont :

`u=dx/da=a^(-3/2)v`, `dv/da=(3/2)a^(-1/2)g`,
`g=(x-x_min)-M(x)`.

Donc :

`u_a=(3/2)a^(-2)g-(3/2)a^(-1)u`.

Pour `M_n=∫u^n f du`, Vlasov donne :

`∂a M_n + ∂x M_(n+1) + (3n/(2a))M_n - (3n/(2a²))g M_(n-1)=0`.

Avec le préfacteur du dépôt `(3/2)a²`, les coefficients locaux sont `9n/4`.
Après intégration temporelle de `(3/2)a² ∂a K_n`, les coefficients weak sont :

`expansion = (9n/4 - 3) ∫aK_n da`, `gravity = -(9n/4)∫G_n da`.

La hiérarchie actuelle utilise `expansion=(n-3)∫aK_n` et `gravity=-n∫G_n`.

| équation | actuelle | dérivée |
|---|---|---|
| M2 | -1 ; -2 | +1.5 ; -4.5 |
| M3 | 0 ; -3 | +3.75 ; -6.75 |

## Test N-body / feuille continue

Les deux jeux de moments sont projetés sur la même grille et avec le même CIC
plus filtre gaussien sigma=1. Les résidus sont intégrés en espace et weak en
temps, sans dérivée spatiale locale.

Held-out `a>1.04`, fenêtre 4 :

| source | équation | coefficients actuels | coefficients dérivés |
|---|---|---:|---:|
| N-body CIC | M1 | 1.145 % | 0.653 % |
| N-body CIC | M2 | **6.550 %** | **0.0725 %** |
| N-body CIC | M3 | 0.450 % | 0.286 % |
| feuille continue | M1 | 1.143 % | 0.651 % |
| feuille continue | M2 | **6.550 %** | **0.0720 %** |
| feuille continue | M3 | 0.447 % | 0.285 % |

Pour la feuille continue, le coefficient dérivé donne pour M2
`0.076/0.072/0.068/0.065 %` sur les fenêtres 1/4/8/16. Le N-body donne les
mêmes valeurs à l’écart de dépôt près.

## Décision

Le défaut M2 à 6,5 % n’est ni un artefact de macroparticules, ni un problème de
résolution de la feuille, ni un simple effet du filtre. Il vient de la
normalisation des termes source dans l’implémentation weak actuelle : les
coefficients `n` doivent être remplacés par `9n/4` lorsque le résidu conserve
le préfacteur `(3/2)a²`.

Le résultat est suffisamment net pour corriger la hiérarchie avant le PINN.
Il faut ensuite régénérer les échelles de loss et refaire l’audit M0–M9 avec ces
coefficients. Aucun entraînement ne doit être lancé avec l’ancienne forme.

## Artefacts

- `run/local_diag/m2_derivation_and_sheet_a098_108/REPORT.md`
- `run/local_diag/m2_derivation_and_sheet_a098_108/m2_m3_derivation.csv`
- `run/local_diag/m2_derivation_and_sheet_a098_108/derivation.json`
- `scripts/diagnose_m2_derivation_and_sheet.py`
