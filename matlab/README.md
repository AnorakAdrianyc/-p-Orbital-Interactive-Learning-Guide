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

## Suggested usage sequence

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
- A. Beiser, *Concepts of Modern Physics*, 6th ed., McGraw-Hill, 2003, ch. 10.
- Representative silicon indirect band gap ≈ 1.1–1.12 eV at 300 K (value depends on temperature, strain, doping, and measurement convention — verify against your cited source before submission).
