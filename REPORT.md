# REPORT — Convergence ciblée des résidus weak M2/M3

Task ID: m2-m3-convergence-audit  
Status: completed — aucun entraînement ni job Izar lancé.

## Méthode

Le diagnostic oracle réutilise exactement la forme intégrale weak du projet :
primitives spatiales, sauts de flux et intégration en temps. Aucun résidu PDE
local ni dérivée spatiale n'est introduit. Les snapshots N-body sont filtrés
par CIC + gaussien et les intervalles évalués sont held-out (`a>1.04`, deux
extrémités dans le bloc).

Variations : `n_grid=1024,2048,4096`, sigma gaussien `0.5,1,2` cellules,
101 snapshots (`a=0.98..1.08`) puis strides temporels `1,2,4`; fenêtres
complètes `1,2,4,8,16` et fenêtres à span approximativement égal après
sous-échantillonnage.

## Résultat canonique

`n_grid=2048`, sigma=1 cellule, fenêtre 4, held-out :

| équation | résidu RMS / RSS des termes | résidu RMS | RSS termes |
|---|---:|---:|---:|
| M2 | **6.538 %** | 7.904e-6 | 1.209e-4 |
| M3 | **0.461 %** | 2.121e-8 | 4.600e-6 |

## Robustesse

- M2 sur le scan résolution/filtre, fenêtre 4 : **6.519–6.590 %**.
- M3 sur le même scan : **0.386–0.801 %** (la variation est faible en valeur
  absolue et reste très inférieure à M2).
- À `2048, sigma=1`, fenêtres 1/4/8/16 : M2 = **6.566/6.538/6.503/6.448 %**;
  M3 = **0.492/0.461/0.452/0.440 %**.
- Sous-échantillonnage avec fenêtre physique approximativement conservée
  (stride 1/2/4, fenêtre de base 1) : M2 = **6.566/6.607/6.660 %**;
  M3 = **0.492/0.466/0.453 %**.
- Pour le span de base 4 (strides 1/2, fenêtres effectives 4/8) : M2 =
  **6.538/6.519 %**, M3 = **0.461/0.445 %**. Les fenêtres plus longues n'ont
  pas assez d'intervalles held-out au stride 4 pour une comparaison honnête.

## Conclusion

Le contraste M2/M3 est stable à quelques dixièmes de point malgré les quatre
variations demandées. Il ne s'agit donc pas d'un simple artefact de résolution,
de la largeur du filtre, du nombre de snapshots ou d'une fenêtre particulière.
Cela justifie de traiter M2 comme le verrou dominant de la hiérarchie coarse-
grainée/intégrale actuelle, tandis que M3 est proche de son plancher oracle.

Ce test **ne suffit pas** à appeler l'écart « nouvelle physique » : sigma est
paramétré en cellules (son échelle physique change avec `n_grid`) et l'audit
reste fondé sur le même N-body et le même opérateur de coarse-graining. Une
comparaison à filtre physique fixé et, idéalement, à une feuille continue reste
le contrôle final.

## Artefacts

- `run/local_diag/m2_m3_convergence_a098_108/REPORT.md`
- `run/local_diag/m2_m3_convergence_a098_108/m2_m3_convergence.csv`
- `run/local_diag/m2_m3_convergence_a098_108/config.json`
- `scripts/diagnose_m2_m3_convergence.py`
