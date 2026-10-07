---
name: nwchem-systems-control
description: Closed-loop systems controller for the p-Orbital Interactive Learning Guide quantum pipeline (EPAM Ketcher, NWChem DFT/SCF, DPLOT cubes, 3Dmol.js) using Supabase as the job/cache/storage control plane. Use when submitting or monitoring quantum jobs, generating .nw decks or .cube files, caching orbitals by SMILES, rendering isosurfaces, or changing Ketcher/NWChem/DPLOT/Supabase control-plane schema.
---

# NWChem systems control

The agent is the **closed-loop controller** over the quantum learning pipeline, not a one-shot code generator.

Canonical doctrine (source of truth): [Skills/Architectural Strategy for NWChem.md](../../../Skills/Architectural%20Strategy%20for%20NWChem.md)

## Control loop

Follow this order for every quantum job:

1. **Sense** — read Ketcher export (MOL V3000 / SMILES) and query `public.smiles_cube_cache` via Supabase MCP.
2. **Decide** — cache hit → return Storage path; miss → enqueue compute. Refuse empty or invalid sketches.
3. **Actuate** — middleware `tools/` → NWChem DFT/SCF → DPLOT inside sandbox limits. Do not invent ad-hoc job files when MCP can record state.
4. **Record** — write `public.quantum_jobs` status, cube path, SMILES key; emit Realtime updates.
5. **Audit** — after schema or tooling changes, run `get_advisors` and `list_migrations`.

## Layer map

| Layer | Duty | Supabase lever |
|-------|------|----------------|
| Ketcher MOL V3000 / SMILES | Validate before submit | `quantum_jobs.status = validated` |
| Middleware `tools/` | 2D→3D; defaults 6-31G*, B3LYP, 50³ grid, HOMO | Persist `.nw` + job id |
| NWChem SCF/DFT | Sandbox timeout/memory; no secrets in decks/logs | `running` / `failed` / `converged` |
| DPLOT `.cube` | Enforce ≤2MB grid | Upload to `orbital-cubes`; upsert `smiles_cube_cache` |
| 3Dmol.js | Dual-phase isosurfaces ±c | Read cache + signed URL |
| Security | No key paste; RLS on | Advisors; never grant `anon` EXECUTE on SECURITY DEFINER |

## Compute defaults

- Basis: `6-31g*`
- DFT: `xc b3lyp`, `iterations 100`
- DPLOT: `LimitXYZ` 50³ (`-5.0 5.0 50` each axis), `spin total`, `gaussian`
- Cube artifacts: private bucket `orbital-cubes`, `file_size_limit` 2097152
- Leave bucket `Integrations Readme files` untouched

## Supabase first

Use Supabase MCP (`execute_sql`, `apply_migration`, `list_migrations`, `get_advisors`) for job, cache, and storage metadata. Do not create side-channel JSON/SQLite job stores.

Worker writes use `service_role`. Clients read via RLS (`authenticated` own jobs; cache SELECT for `authenticated`). Uploads go through the service path; clients use signed URLs.
