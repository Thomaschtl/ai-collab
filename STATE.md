# Project State

## Goal
Train a Physics-Informed Neural Network (PINN) to reproduce cold dark matter (CDM)
N-body simulation dynamics from initial conditions, using Euler/Zel'dovich equations
as physics constraints. Training on EPFL Izar cluster; analysis locally.

## Validated
- MLP with integral-form Euler PDE constraint converges.
- Zel'dovich approximation used as analytic initial condition.
- Pre-shell-crossing regime successfully learned in several configurations.
- `codex-budget` project config applied: `gpt-5.6-terra`, reasoning `medium`,
  tool output limit 5000 tokens.

## Current problem
Diagnosing discrepancy between Zel'dovich approximation and N-body in the
pre-shell-crossing regime. See `scripts/diagnose_zeldovich_vs_nbody_preshell.py`.

## Important files (in Thomaschtl/cdm-pikan)
- `scripts/diagnose_zeldovich_vs_nbody_preshell.py` — active diagnostic script
- `scripts/diagnose_caustic_loss_landscape.py` — caustic loss analysis
- `scripts/euler_data.py` — data generation
- `configs/` — training configurations
- `run/` — local training runs (not pushed)
- `models/` — checkpoints (not pushed)

## Current decision
Focus on pre-shell-crossing diagnosis before tackling post-shell-crossing training.

## Last update
Date: 2026-07-30
Task ID: bridge-setup
