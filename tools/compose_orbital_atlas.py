#!/usr/bin/env python3
"""Compose GEST3015 orbital-atlas SVG sheets from MATLAB panel exports.

MATLAB (or Octave preview) writes one SVG per panel into ``svg/matlab_export/``.
This integrator inlines those panels — plus the diamond-cubic and E–k SVGs
already in the repo — into per-species sheets and one poster with a
"what I learned today" band.

The script is stdlib-only. Optional PNG snapshots use cairosvg if installed.
"""

from __future__ import annotations

import argparse
import json
import logging
import re
import sys
import xml.sax.saxutils as xml_escape
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)

_VIEWBOX_RE = re.compile(r"viewBox\s*=\s*[\"']([^\"']+)[\"']", re.I)
_WIDTH_RE = re.compile(r"\bwidth\s*=\s*[\"']([^\"']+)[\"']", re.I)
_HEIGHT_RE = re.compile(r"\bheight\s*=\s*[\"']([^\"']+)[\"']", re.I)
_SVG_OPEN_RE = re.compile(r"<svg\b[^>]*>", re.I | re.S)
_PROLOG_RE = re.compile(r"<\?xml[^>]*\?>\s*|<!DOCTYPE[^>]*>\s*", re.I | re.S)
_ID_RE = re.compile(r"\bid\s*=\s*[\"']([^\"']+)[\"']", re.I)
_LENGTH_RE = re.compile(r"^\s*([0-9.+\-eE]+)\s*([a-z%]*)\s*$", re.I)


class ComposeError(RuntimeError):
    """Raised when ``--strict`` is set and a required panel is missing."""


def repo_root_from(start: Path) -> Path:
    """Walk up from ``start`` until ``matlab/+orb`` is visible, else use CWD."""
    cur = start.resolve()
    if cur.is_file():
        cur = cur.parent
    for _ in range(8):
        if (cur / "matlab" / "+orb").is_dir():
            return cur
        if cur.parent == cur:
            break
        cur = cur.parent
    return Path.cwd()


def load_json(path: Path) -> dict[str, Any]:
    """Load a UTF-8 JSON object.

    Args:
        path: File to read.

    Returns:
        Parsed JSON object.

    Raises:
        ValueError: If the file is not a JSON object.
    """
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"{path} must contain a JSON object")
    return data


def parse_length(raw: str | None, default: float = 800.0) -> float:
    """Parse an SVG length, converting mm/cm/in/pt to user units (px at 96 dpi)."""
    if raw is None:
        return default
    match = _LENGTH_RE.match(raw)
    if not match:
        return default
    value = float(match.group(1))
    unit = match.group(2).lower()
    scale = {
        "": 1.0,
        "px": 1.0,
        "pt": 96.0 / 72.0,
        "in": 96.0,
        "mm": 96.0 / 25.4,
        "cm": 96.0 / 2.54,
        "%": 1.0,
    }.get(unit, 1.0)
    return value * scale


def parse_viewbox(svg_text: str) -> tuple[float, float, float, float]:
    """Return ``(min_x, min_y, width, height)`` from viewBox or width/height.

    Args:
        svg_text: Full SVG document or fragment.

    Returns:
        View-box tuple in user units.
    """
    match = _VIEWBOX_RE.search(svg_text)
    if match:
        parts = match.group(1).replace(",", " ").split()
        if len(parts) == 4:
            return (float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3]))
    width = parse_length(_WIDTH_RE.search(svg_text).group(1) if _WIDTH_RE.search(svg_text) else None)
    height = parse_length(
        _HEIGHT_RE.search(svg_text).group(1) if _HEIGHT_RE.search(svg_text) else None,
        default=600.0,
    )
    return (0.0, 0.0, width, height)


def strip_prolog(svg_text: str) -> str:
    """Remove XML declarations and DOCTYPE so the fragment can be nested."""
    return _PROLOG_RE.sub("", svg_text).strip()


def extract_svg(svg_text: str) -> str:
    """Return the outer ``<svg>...</svg>`` element, including the tags."""
    text = strip_prolog(svg_text)
    start = re.search(r"<svg\b", text, flags=re.I)
    end = text.lower().rfind("</svg>")
    if start is None or end < 0:
        raise ValueError("No <svg> element found")
    return text[start.start() : end + len("</svg>")]


def prefix_ids(svg_text: str, prefix: str) -> str:
    """Prefix every ``id`` and rewrite internal ``url(#id)`` / ``href="#id"`` refs.

    External ``href`` values (``http``, ``data:``, files) are left unchanged.
    Longer ids are rewritten first so prefixes are not applied twice.
    """
    ids = _ID_RE.findall(svg_text)
    unique = sorted(set(ids), key=len, reverse=True)
    out = svg_text
    for ident in unique:
        new_id = prefix + ident
        out = out.replace(f'id="{ident}"', f'id="{new_id}"')
        out = out.replace(f"id='{ident}'", f"id='{new_id}'")
        out = out.replace(f"url(#{ident})", f"url(#{new_id})")
        out = out.replace(f"url('#{ident}')", f"url('#{new_id}')")
        out = out.replace(f'url("#{ident}")', f'url("#{new_id}")')
        out = out.replace(f'href="#{ident}"', f'href="#{new_id}"')
        out = out.replace(f"href='#{ident}'", f"href='#{new_id}'")
        out = out.replace(f'xlink:href="#{ident}"', f'xlink:href="#{new_id}"')
    return out


def inject_placement(svg_el: str, x: float, y: float, width: float, height: float) -> str:
    """Add ``x/y/width/height`` to the opening ``<svg>`` tag of a nested fragment."""
    match = _SVG_OPEN_RE.search(svg_el)
    if match is None:
        raise ValueError("Nested fragment has no opening <svg> tag")
    opening = match.group(0)
    opening = _WIDTH_RE.sub("", opening)
    opening = _HEIGHT_RE.sub("", opening)
    extra = f' x="{x:.2f}" y="{y:.2f}" width="{width:.2f}" height="{height:.2f}" preserveAspectRatio="xMidYMid meet" '
    if opening.endswith("/>"):
        new_open = opening[:-2] + extra + "/>"
    else:
        new_open = opening[:-1] + extra + ">"
    return svg_el[: match.start()] + new_open + svg_el[match.end() :]


def placeholder_svg(filename: str, x: float, y: float, w: float, h: float) -> str:
    """Dashed box naming the expected MATLAB export file."""
    esc = xml_escape.escape(filename)
    return (
        f'<g transform="translate({x:.2f},{y:.2f})">'
        f'<rect x="1" y="1" width="{w-2:.2f}" height="{h-2:.2f}" '
        f'fill="#f0ebe3" stroke="#8a7f72" stroke-width="1.5" '
        f'stroke-dasharray="8 5"/>'
        f'<text x="{w/2:.2f}" y="{h/2 - 8:.2f}" text-anchor="middle" '
        f'font-family="Georgia, serif" font-size="13" fill="#5c564e">'
        f"missing panel</text>"
        f'<text x="{w/2:.2f}" y="{h/2 + 14:.2f}" text-anchor="middle" '
        f'font-family="monospace" font-size="11" fill="#0f5c63">{esc}</text>'
        f"</g>"
    )


def wrap_lines(text: str, width: int) -> list[str]:
    """Word-wrap ``text`` to about ``width`` characters per line."""
    words = text.split()
    lines: list[str] = []
    current: list[str] = []
    for word in words:
        trial = " ".join(current + [word])
        if current and len(trial) > width:
            lines.append(" ".join(current))
            current = [word]
        else:
            current.append(word)
    if current:
        lines.append(" ".join(current))
    return lines or [""]


def text_block(
    x: float,
    y: float,
    lines: list[str],
    *,
    size: int = 12,
    fill: str = "#1c1916",
    weight: str = "normal",
    anchor: str = "start",
    family: str = "Georgia, serif",
    leading: float | None = None,
) -> str:
    """Emit an SVG ``<text>`` with ``<tspan>`` lines."""
    dy = leading if leading is not None else size * 1.28
    esc_lines = [xml_escape.escape(line) for line in lines]
    tspans = []
    for i, line in enumerate(esc_lines):
        if i == 0:
            tspans.append(f'<tspan x="{x:.2f}" y="{y:.2f}">{line}</tspan>')
        else:
            tspans.append(f'<tspan x="{x:.2f}" dy="{dy:.1f}">{line}</tspan>')
    return (
        f'<text text-anchor="{anchor}" font-family="{family}" '
        f'font-size="{size}" font-weight="{weight}" fill="{fill}">'
        f"{''.join(tspans)}</text>"
    )


def resolve_panel_path(
    panel: dict[str, Any],
    *,
    export_dir: Path,
    existing: dict[str, str],
    root: Path,
) -> Path | None:
    """Map a manifest panel entry to a file path, or ``None`` if missing."""
    name = panel["file"]
    if panel.get("from") == "existing":
        rel = existing.get(name)
        if not rel:
            return None
        path = root / rel
        return path if path.is_file() else None
    path = export_dir / name
    return path if path.is_file() else None


def inline_panel(
    panel: dict[str, Any],
    *,
    export_dir: Path,
    existing: dict[str, str],
    root: Path,
    x: float,
    y: float,
    w: float,
    h: float,
    prefix: str,
    strict: bool,
) -> str:
    """Inline one panel SVG, or draw a placeholder naming the expected file."""
    path = resolve_panel_path(panel, export_dir=export_dir, existing=existing, root=root)
    expected = panel["file"]
    if path is None:
        msg = f"Missing panel {expected}"
        if strict:
            raise ComposeError(msg)
        logger.warning("%s — drawing placeholder", msg)
        label = expected
        if panel.get("from") == "existing":
            label = existing.get(expected, expected)
        return placeholder_svg(label, x, y, w, h)
    logger.info("Inlining %s", path)
    raw = path.read_text(encoding="utf-8", errors="replace")
    fragment = extract_svg(raw)
    fragment = prefix_ids(fragment, prefix)
    return inject_placement(fragment, x, y, w, h)


def caption_bar(x: float, y: float, w: float, h: float, caption: str, gest: str, ink: str, muted: str) -> str:
    """Caption strip under a panel."""
    lines = wrap_lines(caption, max(28, int(w / 7.2)))
    body = text_block(x + 6, y + 16, lines, size=11, fill=ink)
    tag = text_block(
        x + w - 8,
        y + 16,
        [f"GEST {gest}"] if gest else [],
        size=10,
        fill=muted,
        anchor="end",
        weight="bold",
        family="Helvetica, Arial, sans-serif",
    )
    return f'<rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" fill="#efe8dc" stroke="#d7cfc2"/>{body}{tag}'


def sheet_header(
    page: dict[str, Any],
    title: str,
    subtitle: str,
    width: float,
) -> str:
    """Title band used on every composed sheet."""
    m = page["margin"]
    parts = [
        f'<rect x="0" y="0" width="{width:.2f}" height="{page["header_h"]:.2f}" fill="#0f5c63"/>',
        text_block(m, 38, [title], size=22, fill="#f7f4ee", weight="bold"),
        text_block(m, 66, [subtitle], size=12, fill="#d5ecee"),
        text_block(
            width - m,
            38,
            ["GEST3015  ·  2026-09-11  ·  300 K"],
            size=12,
            fill="#d5ecee",
            anchor="end",
            family="Helvetica, Arial, sans-serif",
        ),
    ]
    return "".join(parts)


def sheet_footer(
    page: dict[str, Any],
    y: float,
    width: float,
    generator: str,
    extra: str,
) -> str:
    """Scope + provenance footer."""
    m = page["margin"]
    lines = [
        "Scope: hydrogenic Z_eff clouds and idealised geometries. Not DFT, not XRD, not a hybridization map for d/f-block.",
        extra,
        f"Panels: MATLAB R2026a on the course machine (overwrite svg/matlab_export/). Composer preview generator: {generator}.",
        (
            "Beiser, Concepts of Modern Physics, 6th ed.; Clementi–Raimondi 1963/1967; "
            "Binnemans, Coord. Chem. Rev. 295, 1 (2015); Shannon 1976."
        ),
    ]
    return (
        f'<rect x="0" y="{y:.2f}" width="{width:.2f}" height="{page["footer_h"]:.2f}" fill="#1c1916"/>'
        + text_block(m, y + 22, lines, size=10, fill="#d9d1c7", leading=16)
    )


def compose_species_sheet(
    spec: dict[str, Any],
    *,
    page: dict[str, Any],
    export_dir: Path,
    existing: dict[str, str],
    root: Path,
    generator: str,
    strict: bool,
) -> str:
    """Build one per-species SVG document."""
    width = float(page["width"])
    margin = float(page["margin"])
    gap = float(page["gap"])
    header_h = float(page["header_h"])
    footer_h = float(page["footer_h"])
    cap_h = float(page["caption_h"])
    cols = int(spec.get("columns", 2))
    panels = spec["panels"]
    inner_w = width - 2 * margin
    cell_w = (inner_w - (cols - 1) * gap) / cols
    cell_h = cell_w * 0.72
    n = len(panels)
    rows = (n + cols - 1) // cols
    height = header_h + rows * (cell_h + cap_h + gap) + footer_h + margin
    ink, muted = page["ink"], page["muted"]
    parts = [
        f'<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
        f'version="1.1" viewBox="0 0 {width:.0f} {height:.0f}" width="{width:.0f}" height="{height:.0f}">',
        f'<rect width="100%" height="100%" fill="{page["bg"]}"/>',
        sheet_header(
            page,
            spec["title"],
            f"Beiser {spec['beiser']}   ·   GEST3015 {spec['gest']}   ·   formula {spec['formula']}",
            width,
        ),
    ]
    for i, panel in enumerate(panels):
        r, c = divmod(i, cols)
        x = margin + c * (cell_w + gap)
        y = header_h + 8 + r * (cell_h + cap_h + gap)
        prefix = f"{spec['id']}{i}_"
        parts.append(
            inline_panel(
                panel,
                export_dir=export_dir,
                existing=existing,
                root=root,
                x=x,
                y=y,
                w=cell_w,
                h=cell_h,
                prefix=prefix,
                strict=strict,
            )
        )
        parts.append(
            caption_bar(
                x,
                y + cell_h,
                cell_w,
                cap_h,
                panel.get("caption", ""),
                panel.get("gest", spec["gest"]),
                ink,
                muted,
            )
        )
    footer_y = height - footer_h
    parts.append(
        sheet_footer(
            page,
            footer_y,
            width,
            generator,
            "Room T = 300 K: kT = 25.9 meV = 208 cm⁻¹. Orbital shape is T-independent; occupation is not.",
        )
    )
    parts.append("</svg>\n")
    return "".join(parts)


def compose_learned_sheet(
    learned: dict[str, Any],
    page: dict[str, Any],
    width: float | None = None,
) -> str:
    """Poster-width 'what I learned today' document."""
    width = float(width or page["width"])
    margin = float(page["margin"])
    items = learned["items"]
    y = float(page["header_h"]) + 16
    body_chunks: list[str] = []
    for item in items:
        body_chunks.append(
            text_block(margin, y, [item["heading"]], size=14, fill=page["accent"], weight="bold")
        )
        y += 20
        lines = wrap_lines(item["text"], 118)
        body_chunks.append(text_block(margin, y, lines, size=12, fill=page["ink"]))
        y += 16 * len(lines) + 14
    y += 8
    body_chunks.append(text_block(margin, y, ["Beiser map"], size=14, fill=page["accent"], weight="bold"))
    y += 20
    beiser_lines = wrap_lines(" · ".join(learned["beiser_map"]), 118)
    body_chunks.append(text_block(margin, y, beiser_lines, size=12, fill=page["ink"]))
    y += 16 * len(beiser_lines) + 18
    body_chunks.append(
        text_block(margin, y, ["GEST3015 sections: " + " · ".join(learned["gest3015_sections"])], size=12, fill=page["muted"])
    )
    y += 36
    height = y + float(page["footer_h"])
    parts = [
        f'<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" version="1.1" '
        f'viewBox="0 0 {width:.0f} {height:.0f}" '
        f'width="{width:.0f}" height="{height:.0f}">',
        f'<rect width="100%" height="100%" fill="{page["bg"]}"/>',
        sheet_header(page, learned["title"], f"{learned['course']}  ·  {learned['date']}", width),
        *body_chunks,
        sheet_footer(
            page,
            height - float(page["footer_h"]),
            width,
            "python compose_orbital_atlas.py",
            "Mapped from L2 Hybridization.pdf and src files for 9,11/Summary of 9,11 stuff.",
        ),
        "</svg>\n",
    ]
    return "".join(parts)


def compose_poster(
    manifest: dict[str, Any],
    learned: dict[str, Any],
    *,
    export_dir: Path,
    existing: dict[str, str],
    root: Path,
    generator: str,
    strict: bool,
) -> str:
    """Three-column poster: learned-today band, kT scale, then species rows."""
    page = manifest["page"]
    poster = manifest["poster"]
    width = float(poster["width"])
    margin = float(page["margin"])
    gap = float(page["gap"])
    header_h = float(page["header_h"])
    footer_h = float(page["footer_h"])
    learned_h = float(poster["learned_h"])
    kt_h = float(poster["kt_h"])
    row_h = float(poster["row_h"])
    cap_h = 36.0
    cols = ["si", "tio2", "eu3"]
    col_w = (width - 2 * margin - 2 * gap) / 3
    n_rows = len(poster["rows"])
    height = header_h + learned_h + kt_h + n_rows * (row_h + cap_h + gap) + footer_h + 24
    parts = [
        f'<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
        f'version="1.1" viewBox="0 0 {width:.0f} {height:.0f}" width="{width:.0f}" height="{height:.0f}">',
        f'<rect width="100%" height="100%" fill="{page["bg"]}"/>',
        sheet_header(
            page,
            poster["title"],
            "Beiser-level hydrogenic clouds · GEST3015 I–V · room temperature = 300 K",
            width,
        ),
    ]
    y = header_h + 8
    parts.append(
        f'<rect x="{margin:.2f}" y="{y:.2f}" width="{width - 2 * margin:.2f}" '
        f'height="{learned_h:.2f}" fill="#e7f2f3" stroke="#0f5c63"/>'
    )
    parts.append(
        text_block(margin + 12, y + 22, ["What I learned today"], size=16, fill=page["accent"], weight="bold")
    )
    bullets = [f"• {item['heading']}: {item['text']}" for item in learned["items"][:5]]
    wrapped: list[str] = []
    for bullet in bullets:
        wrapped.extend(wrap_lines(bullet, 145))
    parts.append(text_block(margin + 12, y + 44, wrapped[:11], size=11, fill=page["ink"], leading=14.5))
    y += learned_h + gap
    parts.append(
        inline_panel(
            {"file": manifest["kt_file"]},
            export_dir=export_dir,
            existing=existing,
            root=root,
            x=margin,
            y=y,
            w=width - 2 * margin,
            h=kt_h,
            prefix="kt_",
            strict=strict,
        )
    )
    y += kt_h + gap
    labels = {
        "si": "Si  (p-block, sp3)",
        "tio2": "TiO2  (d-block, LFT/MO)",
        "eu3": "Eu3+  (f-block, no hybrid)",
    }
    parts.append(
        text_block(
            margin,
            y - 4,
            ["  |  ".join(labels[c] for c in cols)],
            size=13,
            fill=page["accent"],
            weight="bold",
        )
    )
    y += 14
    for r_i, row in enumerate(poster["rows"]):
        for c_i, key in enumerate(cols):
            cell = row[key]
            x = margin + c_i * (col_w + gap)
            parts.append(
                inline_panel(
                    cell,
                    export_dir=export_dir,
                    existing=existing,
                    root=root,
                    x=x,
                    y=y,
                    w=col_w,
                    h=row_h,
                    prefix=f"p{r_i}{key}_",
                    strict=strict,
                )
            )
            parts.append(
                caption_bar(
                    x,
                    y + row_h,
                    col_w,
                    cap_h,
                    cell.get("caption", ""),
                    "",
                    page["ink"],
                    page["muted"],
                )
            )
        y += row_h + cap_h + gap
    parts.append(
        sheet_footer(
            page,
            height - footer_h,
            width,
            generator,
            "kT(300 K)=25.9 meV. Si Eg=1.12 eV. TiO2 Eg=3.0/3.2 eV. Eu3+ 7F1=379 cm⁻¹, 5D0=17227 cm⁻¹.",
        )
    )
    parts.append("</svg>\n")
    return "".join(parts)


def read_generator(export_dir: Path) -> str:
    """Read generator stamp from MATLAB/Octave manifest.json if present."""
    man = export_dir / "manifest.json"
    if not man.is_file():
        return "MATLAB export not yet run (placeholders or previous SVGs)"
    try:
        data = json.loads(man.read_text(encoding="utf-8"))
        return f"{data.get('generator', '?')} {data.get('version', '')}".strip()
    except json.JSONDecodeError:
        return "unreadable svg/matlab_export/manifest.json"


def maybe_png(svg_path: Path) -> None:
    """Write a PNG next to ``svg_path`` when cairosvg is importable."""
    try:
        import cairosvg  # type: ignore[import-not-found]
    except ImportError:
        logger.info("cairosvg not installed; skipping PNG for %s", svg_path.name)
        return
    png_path = svg_path.with_suffix(".png")
    cairosvg.svg2png(url=str(svg_path), write_to=str(png_path), background_color="white")
    logger.info("Wrote %s", png_path)


def validate_manifest(manifest: dict[str, Any]) -> None:
    """Check required keys so a typo fails in tests rather than at draw time."""
    for key in ("page", "species", "poster", "export_dir", "output_dir", "existing"):
        if key not in manifest:
            raise ValueError(f"atlas_manifest.json missing '{key}'")
    for sp_key in ("si", "tio2", "eu3"):
        if sp_key not in manifest["species"]:
            raise ValueError(f"species.{sp_key} missing")
        spec = manifest["species"][sp_key]
        if "panels" not in spec or not spec["panels"]:
            raise ValueError(f"species.{sp_key}.panels empty")
    if "rows" not in manifest["poster"]:
        raise ValueError("poster.rows missing")


def compose_all(
    *,
    root: Path,
    manifest_path: Path,
    learned_path: Path,
    strict: bool,
    write_png: bool,
) -> list[Path]:
    """Compose species sheets, learned-today sheet, and poster.

    Returns:
        Paths of written SVG files.
    """
    manifest = load_json(manifest_path)
    learned = load_json(learned_path)
    validate_manifest(manifest)
    export_dir = root / manifest["export_dir"]
    output_dir = root / manifest["output_dir"]
    output_dir.mkdir(parents=True, exist_ok=True)
    existing = {k: str(v) for k, v in manifest["existing"].items()}
    generator = read_generator(export_dir)
    written: list[Path] = []

    for spec in manifest["species"].values():
        svg = compose_species_sheet(
            spec,
            page=manifest["page"],
            export_dir=export_dir,
            existing=existing,
            root=root,
            generator=generator,
            strict=strict,
        )
        path = output_dir / spec["output"]
        path.write_text(svg, encoding="utf-8")
        logger.info("Wrote %s", path)
        written.append(path)

    learned_svg = compose_learned_sheet(learned, manifest["page"], width=float(manifest["page"]["width"]))
    learned_path_out = output_dir / manifest["learned_output"]
    learned_path_out.write_text(learned_svg, encoding="utf-8")
    logger.info("Wrote %s", learned_path_out)
    written.append(learned_path_out)

    poster_svg = compose_poster(
        manifest,
        learned,
        export_dir=export_dir,
        existing=existing,
        root=root,
        generator=generator,
        strict=strict,
    )
    poster_path = output_dir / manifest["poster"]["output"]
    poster_path.write_text(poster_svg, encoding="utf-8")
    logger.info("Wrote %s", poster_path)
    written.append(poster_path)

    if write_png:
        for path in written:
            maybe_png(path)
    return written


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse CLI arguments."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=None, help="Repository root (auto-detected).")
    parser.add_argument("--manifest", type=Path, default=None, help="atlas_manifest.json path.")
    parser.add_argument("--learned", type=Path, default=None, help="learned_today JSON path.")
    parser.add_argument("--strict", action="store_true", help="Fail if a panel SVG is missing.")
    parser.add_argument("--png", action="store_true", help="Also write PNG via cairosvg when installed.")
    parser.add_argument("-v", "--verbose", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    """CLI entry point. Returns a process exit code."""
    args = parse_args(argv)
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(levelname)s %(message)s",
    )
    tools_dir = Path(__file__).resolve().parent
    root = args.root or repo_root_from(tools_dir)
    manifest_path = args.manifest or (tools_dir / "atlas_manifest.json")
    learned_path = args.learned or (tools_dir / "learned_today_2026-09-11.json")
    try:
        compose_all(
            root=root,
            manifest_path=manifest_path,
            learned_path=learned_path,
            strict=args.strict,
            write_png=args.png,
        )
    except ComposeError as err:
        logger.error("%s", err)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
