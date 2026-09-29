#!/usr/bin/env python3
"""
Potta Finance - Wizard Image Generator
Creates PNG wizard images for Inno Setup 6

  WizardImageFile=installer-resources\potta_wizard_large.png
  WizardSmallImageFile=installer-resources\potta_wizard_small.png

Reads version automatically from VERSION.txt in the project root.
Requires: pip install Pillow numpy
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

try:
    import numpy as np
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False
    print("  ⚠ numpy not found logo bg removal disabled (pip install numpy)")

# ─── Brand Palette ─────────────────────────────────────────────────────────
DARK_GREEN  = (12,  48,  16)
MID_GREEN   = (21,  80,  26)     # #1B5E20 family
ACCENT      = (46, 125,  50)
LIGHT_GREEN = (165, 214, 167)
PALE        = (224, 242, 224)
STRIP       = (5,   20,   7)
WHITE       = (255, 255, 255)


# ─── Version reader ────────────────────────────────────────────────────────
def read_version(script_dir: str) -> str:
    for rel in ["..", os.path.join("..", ".."), "."]:
        p = os.path.abspath(os.path.join(script_dir, rel, "VERSION.txt"))
        if os.path.exists(p):
            v = open(p).read().strip()
            print(f"  Version : {v}  ({p})")
            return v
    print("  ⚠ VERSION.txt not found defaulting to 1.0")
    return "1.0"


# ─── Font loader ───────────────────────────────────────────────────────────
def font(bold: bool, size: int) -> ImageFont.FreeTypeFont:
    names = (
        ["arialbd.ttf", "calibrib.ttf", "segoeuib.ttf", "verdanab.ttf"]
        if bold else
        ["arial.ttf",   "calibri.ttf",  "segoeui.ttf",  "verdana.ttf"]
    )
    for n in names:
        try:
            return ImageFont.truetype(n, size)
        except Exception:
            pass
    return ImageFont.load_default()


# ─── Gradient ──────────────────────────────────────────────────────────────
def diagonal_gradient(W, H, c1, c2):
    img = Image.new("RGB", (W, H))
    px = []
    for y in range(H):
        for x in range(W):
            t = min(1.0, max(0.0, x / (W - 1) * 0.55 + y / (H - 1) * 0.45))
            px.append(tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3)))
    img.putdata(px)
    return img


# ─── Logo with auto background removal ────────────────────────────────────
def load_logo_rgba(path: str) -> Image.Image:
    """
    Load logo as RGBA. If the file has no alpha (black or white bg),
    remove the background automatically using luminance keying.
    """
    img = Image.open(path)
    if img.mode == "RGBA":
        return img

    img = img.convert("RGB")
    if not HAS_NUMPY:
        return img.convert("RGBA")

    arr = np.array(img).astype(float)
    lum = 0.299 * arr[:, :, 0] + 0.587 * arr[:, :, 1] + 0.114 * arr[:, :, 2]

    corners = [lum[0, 0], lum[0, -1], lum[-1, 0], lum[-1, -1]]
    dark_bg = (sum(corners) / 4) < 60

    if dark_bg:
        alpha = np.clip((lum - 8) / 35, 0, 1) * 255
    else:
        alpha = np.clip((255 - lum - 8) / 35, 0, 1) * 255

    rgba = np.dstack([arr.astype(np.uint8), alpha.astype(np.uint8)])
    return Image.fromarray(rgba, "RGBA")


def paste_logo(canvas, path, box_size, center_xy):
    logo = load_logo_rgba(path)
    ow, oh = logo.size
    scale = min(box_size / ow, box_size / oh)
    nw, nh = max(1, int(ow * scale)), max(1, int(oh * scale))
    logo = logo.resize((nw, nh), Image.Resampling.LANCZOS)
    cx, cy = center_xy
    canvas.paste(logo, (cx - nw // 2, cy - nh // 2), logo)


# ─── Drawing helpers ───────────────────────────────────────────────────────
def glow(canvas, cx, cy, r, rgb, alpha=50, blur=16):
    sz = r * 2 + blur * 6
    layer = Image.new("RGBA", (sz, sz), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    m = blur * 3
    d.ellipse([m, m, sz - m, sz - m], fill=(*rgb, alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    canvas.paste(layer, (cx - sz // 2, cy - sz // 2), layer)


def ring(draw, cx, cy, r, rgb, a=140, w=1):
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(*rgb, a), width=w)


def cx_text(draw, text, fnt, W):
    return int((W - draw.textlength(text, font=fnt)) // 2)


def geo_lines(draw, W, H):
    for o in range(0, 90, 20):
        draw.line([(W - o, 0), (W, o)], fill=(*LIGHT_GREEN, 14), width=1)
    for o in range(0, 65, 18):
        draw.line([(0, H - o), (o, H)], fill=(*LIGHT_GREEN, 10), width=1)


def dot_grid(draw, W, H):
    for y in range(16, H - 16, 16):
        for x in range(16, W - 16, 16):
            draw.point((x, y), fill=(*ACCENT, 16))


# ─── LARGE IMAGE  164 × 314 ───────────────────────────────────────────────
def create_large(logo_path, version, out_path):
    W, H = 164, 314
    canvas = diagonal_gradient(W, H, DARK_GREEN, MID_GREEN).convert("RGBA")
    draw   = ImageDraw.Draw(canvas, "RGBA")

    geo_lines(draw, W, H)
    dot_grid(draw, W, H)

    LCX, LCY = W // 2, 86

    glow(canvas, LCX, LCY, 48, ACCENT,      alpha=38, blur=22)
    glow(canvas, LCX, LCY, 28, LIGHT_GREEN, alpha=22, blur=10)
    ring(draw, LCX, LCY, 48, ACCENT,      a=50, w=1)
    ring(draw, LCX, LCY, 50, LIGHT_GREEN, a=20, w=1)

    if logo_path and os.path.exists(logo_path):
        paste_logo(canvas, logo_path, 82, (LCX, LCY))
        print("  ✓ Logo placed (large)")
    else:
        fnt_m = font(True, 46)
        tw = draw.textlength("P", font=fnt_m)
        draw.text((LCX - tw / 2, LCY - 30), "P", fill=(*ACCENT, 230), font=fnt_m)
        print("  ⚠ Logo not found monogram fallback")

    y = 148
    fnt_name = font(True, 13)
    draw.text((cx_text(draw, "Potta Finance", fnt_name, W), y),
              "Potta Finance", fill=WHITE, font=fnt_name)

    y += 20
    draw.line([(22, y), (W - 22, y)], fill=(*ACCENT, 90),       width=1)
    draw.line([(58, y), (W - 58, y)], fill=(*LIGHT_GREEN, 130), width=1)

    y += 11
    fnt_tag = font(False, 7)
    tag = "Inventory  \u00b7  Redefined"
    draw.text((cx_text(draw, tag, fnt_tag, W), y),
              tag, fill=(*LIGHT_GREEN, 165), font=fnt_tag)

    y += 20
    for x in range(30, W - 30, 6):
        if (x // 6) % 2 == 0:
            draw.point((x, y), fill=(*ACCENT, 55))

    y += 12
    fnt_feat = font(False, 9)
    for label in ["Cloud Sync", "Multi-Location", "Offline Mode"]:
        draw.text((18, y), "\u25c6", fill=(*ACCENT, 210), font=fnt_feat)
        draw.text((31, y), label,  fill=(*PALE, 215),    font=fnt_feat)
        y += 21

    draw.rectangle([(0, H - 26), (W, H)], fill=(*STRIP, 230))
    fnt_ver = font(False, 7)
    ver_str = f"v{version}"
    draw.text((cx_text(draw, ver_str, fnt_ver, W), H - 17),
              ver_str, fill=(*LIGHT_GREEN, 105), font=fnt_ver)

    canvas.convert("RGB").save(out_path, "PNG", optimize=True)
    print(f"  ✓ Large saved  \u2192 {out_path}  [164\u00d7314]")


# ─── SMALL IMAGE  55 × 55 ─────────────────────────────────────────────────
def create_small(logo_path, out_path):
    W, H = 55, 55
    canvas = diagonal_gradient(W, H, MID_GREEN, DARK_GREEN).convert("RGBA")
    draw   = ImageDraw.Draw(canvas, "RGBA")

    for o in range(0, 38, 14):
        draw.line([(W - o, 0), (W, o)], fill=(*LIGHT_GREEN, 14), width=1)

    cx, cy = W // 2, H // 2
    glow(canvas, cx, cy, 22, ACCENT,      alpha=48, blur=10)
    glow(canvas, cx, cy, 14, LIGHT_GREEN, alpha=25, blur=5)
    ring(draw, cx, cy, 24, ACCENT, a=55, w=1)

    if logo_path and os.path.exists(logo_path):
        paste_logo(canvas, logo_path, 42, (cx, cy))
        print("  ✓ Logo placed (small)")
    else:
        fnt_m = font(True, 24)
        tw = draw.textlength("P", font=fnt_m)
        draw.text((cx - tw / 2, cy - 15), "P", fill=(*ACCENT, 230), font=fnt_m)

    canvas.convert("RGB").save(out_path, "PNG", optimize=True)
    print(f"  ✓ Small saved  \u2192 {out_path}  [55\u00d755]")


# ─── Main ─────────────────────────────────────────────────────────────────
def main():
    print("=" * 58)
    print("  Potta Finance \u2014 Wizard Image Generator")
    print("=" * 58)

    script_dir = os.path.dirname(os.path.abspath(__file__))

    logo_candidates = [
        os.path.join(script_dir, "..", "Potta Finance", "Resources", "pottaLogo.png"),
        os.path.join(script_dir, "..", "Potta Finance", "Potta Finance",
                                       "Resources", "pottaLogo.png"),
        os.path.join(script_dir, "pottaLogo.png"),
        os.path.join(script_dir, "logo.png"),
    ]
    logo_path = next(
        (os.path.abspath(p) for p in logo_candidates if os.path.exists(p)),
        None
    )

    if logo_path:
        print(f"  Logo    : {logo_path}")
    else:
        print("  \u26a0 Logo not found \u2014 monogram will be used")

    version = read_version(script_dir)

    out_dir   = os.path.join(script_dir, "installer-resources")
    large_out = os.path.join(out_dir, "potta_wizard_large.png")
    small_out = os.path.join(out_dir, "potta_wizard_small.png")
    os.makedirs(out_dir, exist_ok=True)

    print()
    try:
        create_large(logo_path, version, large_out)
        create_small(logo_path, small_out)

        print()
        print("=" * 58)
        print("  \u2713 Done!  Add these lines to your .iss script:\n")
        print("    WizardImageFile=installer-resources\\potta_wizard_large.png")
        print("    WizardSmallImageFile=installer-resources\\potta_wizard_small.png")
        print()
        print("  Requires Inno Setup 6.x  \u2014  compile with F9")
        print("=" * 58)

    except Exception as e:
        import traceback
        print(f"\n  \u2717 ERROR: {e}")
        traceback.print_exc()
        print("\n  Make sure dependencies are installed:")
        print("    pip install Pillow numpy")


if __name__ == "__main__":
    main()
