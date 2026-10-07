# p-Orbital Interactive Learning Guide

This repository is a GEST 3015 Fundamentals prep project for learning and visualizing p-orbitals, quantum numbers, and related atomic and solid-state concepts. It combines an interactive HTML learning guide with supporting MATLAB and Python tools for generating educational orbital-atlas visuals.

## Overview

The project includes:

- A browser-based interactive learning page covering p-orbitals, quantum numbers, and related chemistry/physics concepts.
- Source fragments that were merged into a complete HTML experience.
- MATLAB scripts for periodic-table, crystal-structure, and band-diagram visualizers.
- Python utilities for composing SVG outputs from MATLAB-generated panels.
- Generated SVG assets for classroom and study use.

## Repository contents

- `Quantum Numbers & p-Orbitals Combined.html` — the main interactive webpage to open in a browser.
- `Quantum Numbers & p-Orbitals1.html` — first partial source fragment.
- `Quantum Numvers and p-Orbitals2.html` — second partial source fragment (the original filename contains a typo).
- `matlab/` — MATLAB visualizers and supporting functions for orbital and materials content.
- `tools/` — Python utilities for assembling SVG outputs and related workflows.
- `svg/` — generated SVG assets and export directories.
- `src files for 9,11/` — supporting source assets used by the learning materials.
- `Skills/` — additional project skill assets.

## Quick start

1. Open `Quantum Numbers & p-Orbitals Combined.html` in a web browser.
2. Navigate through the sections such as:
   - Infographic Builder
   - Feynman Simulator
   - 3D Viewer
   - Orbital Game
   - Compare Matrix
   - Flashcards
   - How to Use

## MATLAB and SVG workflow

To generate the orbital-atlas SVG panels in MATLAB:

```matlab
cd matlab
make_orbital_atlas_svgs
```

This writes the exported SVG panels under `svg/matlab_export/`.

To compose the final sheets with Python:

```bash
python tools/compose_orbital_atlas.py
```

The generated outputs are placed in `svg/` and include orbital-atlas sheets for the main case studies used in the course.

## Project structure

```text
.
├── Quantum Numbers & p-Orbitals Combined.html
├── Quantum Numbers & p-Orbitals1.html
├── Quantum Numvers and p-Orbitals2.html
├── README.md
├── matlab/
├── tools/
├── svg/
├── src files for 9,11/
├── Skills/
├── .gitignore
└── skills-lock.json
```

## Notes

- The combined HTML file is the recommended version to use because it contains the merged, complete interactive experience.
- The original fragment files are retained as reference material for tracing the development of each section.
- MATLAB content is intended for educational use and is built around idealized models and teaching approximations rather than full first-principles simulations.
- Sensitive credentials or secrets should not be stored in repository files; use environment variables or secure secret-management tools instead.

## Course context

This repository supports learning objectives tied to GEST 3015, especially around:

- quantum numbers and atomic orbitals
- p-orbital shapes and orientations
- electronic structure concepts
- simple visualization of atomic and material behavior

## License and usage

This project is intended for educational and course-support use. Please retain attribution in any derivative or classroom materials that reuse the content.
