# ai-collab

Dépôt public de coordination entre **ChatGPT Web** et **Codex** (extension VS Code / Cursor).

## Structure

| Fichier | Qui écrit | Qui lit | Taille max |
|---|---|---|---|
| `STATE.md` | Codex (après chaque tâche) | ChatGPT + Codex | ~250 lignes |
| `TASK.md` | ChatGPT (via éditeur web ou Codex) | Codex | ~50 lignes |
| `REPORT.md` | Codex (après chaque tâche) | ChatGPT | ~100 lignes |
| `archive/` | Codex | Sur demande explicite uniquement | — |

## Workflow

### ChatGPT → Codex
1. ChatGPT lit `REPORT.md` et `STATE.md`.
2. ChatGPT rédige la prochaine instruction.
3. L'instruction est écrite dans `TASK.md` (par l'humain ou ChatGPT directement).

### Codex → ChatGPT
1. Codex lit `TASK.md` et `STATE.md`.
2. Codex travaille dans le dépôt cible (`cdm-pikan`).
3. Codex écrit un rapport compact dans `REPORT.md`.
4. Codex met à jour `STATE.md` avec les conclusions durables.
5. Codex commit et push.

## Règles
- Ne jamais copier des logs complets ici.
- Les gros artefacts restent dans le dépôt de travail. Mettre seulement les chemins ici.
- Garder `TASK.md` à une seule tâche à la fois.
- Archiver les vieux rapports dans `archive/` (Codex s'en charge).
