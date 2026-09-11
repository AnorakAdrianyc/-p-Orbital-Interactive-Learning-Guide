# p-Orbital Interactive Learning Guide

This folder contains an interactive HTML learning resource for p-orbitals, built from two partial source files.

## Files

- `Quantum Numbers & p-Orbitals1.html` — the first partial fragment containing the full HTML head, CSS, navigation, module 1 (Infographic Builder), and module 2 (Feynman Simulator).
- `Quantum Numvers and p-Orbitals2.html` — the second fragment containing module 3 (3D Viewer), module 4 (Orbital Filling Game), module 5 (Compare Matrix), module 6 (Flashcards), and the remaining navigation script.
- `Quantum Numbers & p-Orbitals Combined.html` — the merged full HTML page combining both fragments into a single working interactive experience.

## How to use

1. Open `Quantum Numbers & p-Orbitals Combined.html` in a web browser.
2. Use the navigation bar to switch between sections:
   - Infographic Builder
   - Feynman Simulator
   - 3D Viewer
   - Orbital Game
   - Compare Matrix
   - Flashcards
   - How to Use
3. Use the interactive controls to edit the infographic, analyze explanations, view the 3D model, generate game content, check matrix answers, and flip flashcards.

## Notes

- The combined file is the recommended version to use because it contains the complete page structure and merged content from both supporting fragments.
- The second fragment file contains a typo in the file name: `Quantum Numvers and p-Orbitals2.html`.

## Recommended workflow

- If you want to edit the page, modify `Quantum Numbers & p-Orbitals Combined.html` directly.
- Keep the original fragments as reference if you need to trace where each module came from.

## New implementations:
Here’s the fully updated HTML with all the improvements applied:

**File saved to:** 

### What’s included in this version

| Feature | Details |
|---------|---------|
| **CSS overlap fixed** | Infographic uses a clean 4-row grid (Header → Orientations \| Shape → Capacity → Footer) with no overlapping cells |
| **Responsive grid** | Stacks to single column ≤ 900 px |
| **Media query breakpoints** | 900 px / 768 px / 480 px |
| **Responsive typography** | Fluid `clamp()` scale (`--font-xs` → `--font-4xl`) |
| **Fluid spacing system** | Full `clamp()` spacing scale (`--space-3xs` → `--space-3xl`) + semantic aliases (`--space-card`, `--space-gap`, etc.) applied throughout |

## Orbital atlas (Si, TiO2, Eu3+ at 300 K)

The `matlab/` folder now also exports Beiser-level hybrid-orbital and electron-cloud panels. Python then composes those panels (plus the diamond-cubic and E–k SVGs in `src files for 9,11/`) into course sheets.

### Workflow

1. In MATLAB R2026a (your machine):

```matlab
cd matlab
make_orbital_atlas_svgs          % writes svg/matlab_export/*.svg + manifest.json
```

2. Commit `svg/matlab_export/` (this overwrites any Octave preview SVGs).

3. Compose the sheets (stdlib Python, no extra packages):

```bash
python tools/compose_orbital_atlas.py
```

Outputs in `svg/`:

| File | Contents |
|------|----------|
| `si_orbitals_300K.svg` | Silicon filling, P(r), sp3 cloud, tetrahedron, bands, plus the existing diamond-cubic and E–k figures |
| `tio2_orbitals_300K.svg` | TiO2 filling, 3d t2g/eg, TiO6 LFT vs d2sp3, O sp2, bond P(r), UV gap |
| `eu3_orbitals_300K.svg` | Eu3+ 4f6 → 7F0, 4f angular set, 4f vs 5s/5p shielding, CN 8/9, Boltzmann ladder |
| `gest3015_learned_today_2026-09-11.svg` | What was learned on 2026-09-11 (L2 + GEST3015 mapping) |
| `gest3015_orbital_atlas_2026-09-11.svg` | Poster: learned-today band, kT scale, three species columns |

Missing MATLAB panels become dashed placeholders unless you pass `--strict`. Optional `--png` uses cairosvg when installed.

### Room temperature

Orbital **shape** does not change with T. kT(300 K) = 25.9 meV = 208 cm⁻¹. Temperature enters Fermi–Dirac occupation (Si, TiO2), Boltzmann occupation of Eu3+ 7F_J, and 300 K lattice constants. Every energy diagram carries a kT bar.

### Scope

Hydrogenic Z_eff clouds (Clementi–Raimondi) and idealised geometries. Not DFT, not XRD, and not a universal hybridization assignment for d- or f-block. For TiO2 use ligand-field/MO theory; for Eu3+ the 4f shell is buried inside 5s/5p.

Tests: `cd tools && python -m pytest`. See `matlab/README.md` for the MATLAB package, Z_eff table, and references.

