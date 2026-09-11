# MATLAB Visualizers — GEST3015 Smart Materials

These scripts were developed to support HKBU **GEST3015: Smart Materials — Structures and Properties**, within the Green Energy and Smart Technology (GEST) programme, Department of Physics. They extend this repository's p-orbital / quantum-numbers learning guide into periodic-table structure, coordination geometry, and semiconductor (silicon) structure-property visualization.

## Files

### `idgeometryexplorer.m`
A single MATLAB class providing:
- An explicit, validated dataset of all 118 elements (`Z = 1` to `118`), with atomic numbers stored directly rather than inferred from table position (avoids the common lanthanide/actinide row-skip error, e.g. Hf = 72, not 58).
- `plotPeriodicTable(symbol)` — periodic table coloured by block (s/p/d/f), with one element highlighted. Block colour is explicitly **not** a hybridization assignment.
- `plotComplex(metal, oxidationState, electronCount, ligands, geometry, note)` — idealised coordination-geometry visualizer (linear, tetrahedral, square planar, trigonal bipyramidal, octahedral, trigonal prismatic, pentagonal bipyramidal, square antiprismatic, tricapped trigonal prismatic).
- `validateElementData()` — automated checks confirming dataset integrity.
- `runExamples()` — demonstration cases (Fe(II) octahedral, Pt(II) square planar, Eu(III) square antiprismatic).

**Scope and caveats:** these are idealised ligand-position models, not orbital wavefunctions, DFT results, or crystallographic structures. d-block and f-block coordination geometry is compound-specific; interpret electronic structure via ligand-field/molecular-orbital theory, not a default hybridization label.

### `silicon_diamond_cubic_visualizer.m`
Visualizes the diamond-cubic structure of crystalline silicon: a selected Si atom, its four nearest Si neighbours (ideal tetrahedral coordination, bond angle ≈ 109.471°), and the conventional cubic unit cell. Nearest-neighbour distance is computed as `sqrt(3)·a/4` from the lattice parameter `a` (default 5.431 Å).

**Scope:** an ideal crystal-structure model, not an orbital or band-structure calculation.

### `silicon_indirect_band_diagram_corrected.m`
A schematic E–k diagram showing why silicon has an **indirect** band gap: the valence-band maximum sits at Γ while the conduction-band minimum lies along Δ toward X, so optical transitions near the gap require both a photon and a phonon. Default `Eg = 1.12 eV` (representative room-temperature value; adjust per your cited source).

**Scope:** a qualitative teaching schematic, not a fitted or first-principles band structure.

## Orbital atlas SVG export (Si, TiO2, Eu3+ at 300 K)

Hydrogenic radial functions, real spherical harmonics, sp/sp2/sp3 hybrids, and 300 K occupation diagrams for the three GEST3015 case studies. Run this **in MATLAB R2026a** so the SVGs are vector (or MATLAB's own rasterization for 3-D panels). Octave is only a CI/preview stand-in and stamps `generator: Octave` in `svg/matlab_export/manifest.json`.

```matlab
cd matlab
make_orbital_atlas_svgs
```

That runs `orb.selfTest`, then:

| Driver | Panels written under `svg/matlab_export/` |
|--------|-------------------------------------------|
| `si_orbital_atlas_svg.m` | `si_filling.svg`, `si_radial_P.svg`, `si_sp3_cross_section.svg`, `si_sp3_tetrahedron.svg`, `si_bands_300K.svg` |
| `tio2_orbital_atlas_svg.m` | `tio2_filling.svg`, `tio2_3d_angular.svg`, `tio2_octahedron_lft.svg`, `tio2_oxygen_sp2.svg`, `tio2_radial_bond.svg`, `tio2_bands_300K.svg` |
| `eu3_orbital_atlas_svg.m` | `eu3_filling.svg`, `eu3_4f_angular.svg`, `eu3_radial_shielding.svg`, `eu3_polyhedra.svg`, `eu3_ladder_300K.svg` |
| `kt_scale_svg.m` | `kt_scale.svg` |

Then compose sheets with stdlib Python:

```bash
python tools/compose_orbital_atlas.py
```

### `+orb` package (MATLAB and Octave)

| Function | Role |
|----------|------|
| `radialR` / `radialP` | Hydrogenic R_nl and P(r)=r²R² (Beiser 6.7, Table 6.1 convention) |
| `realY` | Real s, p, d, f angular functions |
| `hybrid` | sp, sp2, sp3 coefficient sets (Beiser 8.5 / L2) |
| `zeff` | Clementi–Raimondi Z_eff (Si 3s 4.903, 3p 4.285; O 2p 4.453; Ti 3d 8.141; Eu 4f 24.32, 5s 18.59, 5p 16.56) |
| `slaterZeff` | Slater-rule cross-check (Si 3p 4.15, O 2p 4.55, Ti 3d 3.65) |
| `boltzmann` | g_i exp(−E_i/kT)/Z (Beiser 9.2) |
| `selfTest` | Normalisation, r_mp(1s/2p/3d), Y orthonormality, hybrid orthonormality, Eu3+ 300 K populations |

**Room temperature:** orbital shape is T-independent. kT(300 K)=25.9 meV=208 cm⁻¹ sets Fermi–Dirac (Si, TiO2) and Boltzmann (Eu3+ 7F_J ≈ 65.7 / 32.0 / 2.2 %) occupation, plus 300 K lattice constants.

**Scope:** hydrogenic Z_eff teaching clouds and idealised polyhedra. Not DFT, not crystallographic coordinates. TiO2 electronic structure is ligand-field/MO (not a `d2sp3` assignment). Eu3+ 4f is buried inside 5s/5p — no hybrid label.

## Suggested usage sequence (structure visualizers)

```matlab
idgeometryexplorer.validateElementData();
idgeometryexplorer.plotPeriodicTable('Si');
silicon_diamond_cubic_visualizer;
silicon_indirect_band_diagram_corrected;
idgeometryexplorer.runExamples();
```

## Course context

GEST3015 covers: (I) structure of solids, (II) atomic bonding, (III) electronic structure in solids, (IV) semiconductors, (V) smart materials — applied studies (e.g. solar cells). These scripts primarily support sections I–IV; combine the silicon figures with a p–n junction/solar-cell diagram to address section V and CILO 5.

## References

- NIST, Periodic Table of the Elements / Atomic Properties of the Elements.
- A. Beiser, *Concepts of Modern Physics*, 6th ed., McGraw-Hill, 2003, §§6.7, 7.4–7.8, 8.5, 9.2, 9.10, 10.3, 10.6–10.7.
- E. Clementi and D. L. Raimondi, *J. Chem. Phys.* **38**, 2686 (1963); E. Clementi, D. L. Raimondi, W. P. Reinhardt, *J. Chem. Phys.* **47**, 1300 (1967).
- K. Binnemans, *Coord. Chem. Rev.* **295**, 1 (2015) (Eu3+ free-ion 7F_J and 5D0).
- R. D. Shannon, *Acta Cryst.* A**32**, 751 (1976) (Eu3+ ionic radius, CN 8).
- Representative silicon indirect band gap ≈ 1.1–1.12 eV at 300 K (value depends on temperature, strain, doping, and measurement convention — verify against your cited source before submission).
