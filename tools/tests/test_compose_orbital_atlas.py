"""Tests for tools/compose_orbital_atlas.py."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

import compose_orbital_atlas as c

MINI_SVG = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 100" width="200" height="100">
  <defs><linearGradient id="g1"><stop offset="0" stop-color="#f00"/></linearGradient></defs>
  <rect x="0" y="0" width="200" height="100" fill="url(#g1)" id="bg"/>
  <use href="#bg"/>
</svg>
"""


def test_parse_viewbox_from_attribute() -> None:
    box = c.parse_viewbox('<svg viewBox="10 20 300 400"></svg>')
    assert box == (10.0, 20.0, 300.0, 400.0)


def test_parse_viewbox_from_mm_width() -> None:
    box = c.parse_viewbox('<svg width="25.4mm" height="12.7mm"></svg>')
    assert box[0] == 0.0 and box[1] == 0.0
    assert box[2] == pytest.approx(96.0, rel=1e-3)
    assert box[3] == pytest.approx(48.0, rel=1e-3)


def test_strip_prolog_and_extract() -> None:
    frag = c.extract_svg(MINI_SVG)
    assert frag.startswith("<svg")
    assert "<?xml" not in frag
    assert "DOCTYPE" not in frag
    assert frag.endswith("</svg>")


def test_prefix_ids_rewrites_url_and_href() -> None:
    frag = c.extract_svg(MINI_SVG)
    out = c.prefix_ids(frag, "si0_")
    assert 'id="si0_g1"' in out
    assert 'id="si0_bg"' in out
    assert "url(#si0_g1)" in out
    assert 'href="#si0_bg"' in out
    assert 'id="g1"' not in out


def test_placeholder_names_expected_file() -> None:
    html = c.placeholder_svg("si_filling.svg", 0, 0, 120, 80)
    assert "si_filling.svg" in html
    assert "missing panel" in html
    assert "stroke-dasharray" in html


def test_validate_repo_manifest(tmp_path: Path) -> None:
    tools = Path(__file__).resolve().parents[1]
    manifest = c.load_json(tools / "atlas_manifest.json")
    c.validate_manifest(manifest)
    learned = c.load_json(tools / "learned_today_2026-09-11.json")
    assert "items" in learned and learned["items"]


def test_compose_with_existing_repo_svgs_and_placeholders(tmp_path: Path) -> None:
    tools = Path(__file__).resolve().parents[1]
    export_dir = tmp_path / "export"
    export_dir.mkdir()
    (export_dir / "si_filling.svg").write_text(MINI_SVG, encoding="utf-8")
    out_dir = tmp_path / "out"
    manifest = c.load_json(tools / "atlas_manifest.json")
    manifest["export_dir"] = str(export_dir.relative_to(tmp_path))
    manifest["output_dir"] = str(out_dir.relative_to(tmp_path))
    man_path = tmp_path / "atlas_manifest.json"
    man_path.write_text(json.dumps(manifest), encoding="utf-8")
    learned_path = tools / "learned_today_2026-09-11.json"
    written = c.compose_all(
        root=tmp_path,
        manifest_path=man_path,
        learned_path=learned_path,
        strict=False,
        write_png=False,
    )
    names = {p.name for p in written}
    assert "si_orbitals_300K.svg" in names
    assert "tio2_orbitals_300K.svg" in names
    assert "eu3_orbitals_300K.svg" in names
    assert "gest3015_learned_today_2026-09-11.svg" in names
    assert "gest3015_orbital_atlas_2026-09-11.svg" in names
    si = (out_dir / "si_orbitals_300K.svg").read_text(encoding="utf-8")
    assert 'id="si0_' in si
    assert "missing panel" in si
    # Existing diamond-cubic SVG lives in the real repo; this tmp root has none,
    # so those panels must become named placeholders.
    assert "Diamond-cubic" in si or "si_diamond_cubic" in si or "missing panel" in si


def test_strict_fails_on_missing(tmp_path: Path) -> None:
    tools = Path(__file__).resolve().parents[1]
    manifest = c.load_json(tools / "atlas_manifest.json")
    manifest["export_dir"] = "export"
    manifest["output_dir"] = "out"
    man_path = tmp_path / "atlas_manifest.json"
    man_path.write_text(json.dumps(manifest), encoding="utf-8")
    (tmp_path / "export").mkdir()
    with pytest.raises(c.ComposeError):
        c.compose_all(
            root=tmp_path,
            manifest_path=man_path,
            learned_path=tools / "learned_today_2026-09-11.json",
            strict=True,
            write_png=False,
        )


def test_compose_real_repo_existing_svgs() -> None:
    """Inlines the two MATLAB SVGs already committed under src files for 9,11."""
    tools = Path(__file__).resolve().parents[1]
    root = c.repo_root_from(tools)
    diamond = root / "src files for 9,11" / "Diamond-cubic SI.svg"
    band = root / "src files for 9,11" / "Crystalline silicon_schematic indirect band gap.svg"
    assert diamond.is_file() and band.is_file()
    raw = diamond.read_text(encoding="utf-8", errors="replace")
    frag = c.extract_svg(raw)
    box = c.parse_viewbox(frag)
    assert box[2] > 0 and box[3] > 0
    prefixed = c.prefix_ids(frag, "dia_")
    # MATLAB Qt export of this figure has no id= attributes; prefixing is a no-op
    # and must not corrupt the embedded PNG payload.
    assert "data:image/png;base64" in prefixed
    assert prefixed.startswith("<svg")
    box_band = c.parse_viewbox(c.extract_svg(band.read_text(encoding="utf-8", errors="replace")))
    assert box_band[2] > 0 and box_band[3] > 0
