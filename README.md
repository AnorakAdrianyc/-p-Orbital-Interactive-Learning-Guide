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

You can download the file above and open it directly in a browser. All original interactive features (infographic builder, Feynman simulator, 3D viewer, orbital game, matrix, flashcards, dark mode) are preserved.
