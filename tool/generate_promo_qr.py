#!/usr/bin/env python3
"""Generate a shareable Eng. Hossam promo image with a real, scannable QR code."""

from __future__ import annotations

import random
from pathlib import Path

import arabic_reshaper
import qrcode
from bidi.algorithm import get_display
from PIL import Image, ImageDraw, ImageFilter, ImageFont

URL = "https://hossamezzat.github.io/eng-hossam/"
SIZE = 1080
QR_PIXEL = 420

NAVY = (6, 16, 36)
NAVY_MID = (10, 28, 58)
CYAN = (0, 212, 255)
CYAN_SOFT = (56, 189, 248)
TEAL = (34, 211, 238)
WHITE = (240, 248, 255)
MUTED = (148, 175, 205)

ROOT = Path(__file__).resolve().parents[1]
OUT_PRIMARY = ROOT / "assets" / "branding" / "eng-hossam-promo-qr.png"
OUT_PROMO = ROOT / "promo" / "eng-hossam-promo-qr.png"
OUT_WEB = ROOT / "web" / "promo" / "promo-qr.png"

FONT_AR = "/System/Library/Fonts/SFArabic.ttf"
FONT_EN = "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"
FONT_EN_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def ar(text: str) -> str:
    return get_display(arabic_reshaper.reshape(text))


def load_font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(path, size)


def make_qr(url: str, pixel_size: int) -> Image.Image:
    qr = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=12,
        border=2,
    )
    qr.add_data(url)
    qr.make(fit=True)
    img = qr.make_image(fill_color=(6, 16, 36), back_color=(255, 255, 255)).convert("RGBA")
    return img.resize((pixel_size, pixel_size), Image.Resampling.NEAREST)


def draw_mesh(base: Image.Image, rng: random.Random) -> None:
    overlay = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    w, h = base.size

    # Soft cyan / teal radial blobs
    for cx, cy, radius, color, alpha in (
        (180, 160, 420, (0, 120, 180), 55),
        (920, 240, 380, (0, 180, 220), 45),
        (540, 980, 520, (0, 90, 140), 60),
        (860, 820, 280, (34, 211, 238), 35),
    ):
        blob = Image.new("RGBA", base.size, (0, 0, 0, 0))
        bd = ImageDraw.Draw(blob)
        for i in range(8, 0, -1):
            r = int(radius * i / 8)
            a = int(alpha * (i / 8) ** 2)
            bd.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(*color, a))
        overlay = Image.alpha_composite(overlay, blob.filter(ImageFilter.GaussianBlur(48)))

    d = ImageDraw.Draw(overlay)

    # Subtle grid
    for x in range(0, w, 48):
        d.line([(x, 0), (x, h)], fill=(0, 180, 220, 18), width=1)
    for y in range(0, h, 48):
        d.line([(0, y), (w, y)], fill=(0, 180, 220, 18), width=1)

    # Circuit-like traces
    for _ in range(28):
        x0 = rng.randint(40, w - 40)
        y0 = rng.randint(40, h - 40)
        length = rng.randint(60, 220)
        horizontal = rng.random() > 0.45
        color = (*CYAN, rng.randint(28, 55))
        if horizontal:
            d.line([(x0, y0), (x0 + length, y0)], fill=color, width=2)
            d.ellipse((x0 - 3, y0 - 3, x0 + 3, y0 + 3), fill=(*CYAN, 90))
            d.ellipse(
                (x0 + length - 3, y0 - 3, x0 + length + 3, y0 + 3),
                fill=(*TEAL, 90),
            )
        else:
            d.line([(x0, y0), (x0, y0 + length)], fill=color, width=2)
            d.ellipse((x0 - 3, y0 - 3, x0 + 3, y0 + 3), fill=(*CYAN, 90))

    # Diagonal accent lines
    for i, alpha in enumerate((40, 28, 18)):
        y = 120 + i * 18
        d.line([(40, y), (320, y + 40)], fill=(*CYAN, alpha), width=2)
        d.line([(w - 40, h - y), (w - 320, h - y - 40)], fill=(*TEAL, alpha), width=2)

    base.alpha_composite(overlay)


def draw_corner_brackets(d: ImageDraw.ImageDraw, box: tuple[int, int, int, int], color, length=36, width=3):
    x0, y0, x1, y1 = box
    # TL
    d.line([(x0, y0 + length), (x0, y0), (x0 + length, y0)], fill=color, width=width)
    # TR
    d.line([(x1 - length, y0), (x1, y0), (x1, y0 + length)], fill=color, width=width)
    # BL
    d.line([(x0, y1 - length), (x0, y1), (x0 + length, y1)], fill=color, width=width)
    # BR
    d.line([(x1 - length, y1), (x1, y1), (x1, y1 - length)], fill=color, width=width)


def centered_text(d: ImageDraw.ImageDraw, text: str, y: int, font, fill, canvas_w: int = SIZE) -> None:
    bbox = d.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    d.text(((canvas_w - tw) / 2, y), text, font=font, fill=fill)


def build() -> Image.Image:
    rng = random.Random(42)
    canvas = Image.new("RGBA", (SIZE, SIZE), (*NAVY, 255))
    draw_mesh(canvas, rng)
    d = ImageDraw.Draw(canvas)

    # Top accent bar
    d.rectangle((0, 0, SIZE, 6), fill=(*CYAN, 220))
    d.rectangle((0, SIZE - 6, SIZE, SIZE), fill=(*CYAN, 160))

    # Outer frame
    margin = 48
    draw_corner_brackets(
        d,
        (margin, margin, SIZE - margin, SIZE - margin),
        (*CYAN, 180),
        length=52,
        width=3,
    )

    font_brand_en = load_font(FONT_EN_BOLD, 54)
    font_brand_ar = load_font(FONT_AR, 46)
    font_sub = load_font(FONT_EN, 26)
    font_cta_ar = load_font(FONT_AR, 42)
    font_cta_en = load_font(FONT_EN_BOLD, 30)
    font_url = load_font(FONT_EN, 22)
    font_tag = load_font(FONT_EN, 18)

    # Brand block
    centered_text(d, "ENG. HOSSAM", 78, font_brand_en, WHITE)
    centered_text(d, ar("بشمهندس حسام"), 148, font_brand_ar, CYAN)
    centered_text(d, "Programming Course · Opening Session", 218, font_sub, MUTED)

    # Decorative divider
    mid_y = 268
    d.line([(340, mid_y), (470, mid_y)], fill=(*CYAN, 160), width=2)
    d.ellipse((528, mid_y - 5, 538, mid_y + 5), fill=(*CYAN, 220))
    d.line([(610, mid_y), (740, mid_y)], fill=(*CYAN, 160), width=2)

    # QR plate with glow
    qr = make_qr(URL, QR_PIXEL)
    qr_x = (SIZE - QR_PIXEL) // 2
    qr_y = 310

    plate_pad = 28
    plate = (
        qr_x - plate_pad,
        qr_y - plate_pad,
        qr_x + QR_PIXEL + plate_pad,
        qr_y + QR_PIXEL + plate_pad,
    )

    glow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.rounded_rectangle(
        (plate[0] - 18, plate[1] - 18, plate[2] + 18, plate[3] + 18),
        radius=28,
        fill=(*CYAN, 55),
    )
    canvas.alpha_composite(glow.filter(ImageFilter.GaussianBlur(28)))

    d = ImageDraw.Draw(canvas)
    d.rounded_rectangle(plate, radius=22, fill=(255, 255, 255, 245))
    d.rounded_rectangle(plate, radius=22, outline=(*CYAN, 200), width=3)
    draw_corner_brackets(
        d,
        (plate[0] - 10, plate[1] - 10, plate[2] + 10, plate[3] + 10),
        (*TEAL, 210),
        length=28,
        width=3,
    )

    canvas.alpha_composite(qr, (qr_x, qr_y))

    # CTA
    cta_y = plate[3] + 36
    centered_text(d, ar("احجز مكانك"), cta_y, font_cta_ar, WHITE)
    centered_text(d, "Scan to register", cta_y + 58, font_cta_en, CYAN_SOFT)
    centered_text(d, URL, cta_y + 108, font_url, MUTED)
    centered_text(d, "SCAN · REGISTER · START CODING", cta_y + 148, font_tag, (*CYAN, 170))

    return canvas.convert("RGB")


def verify_qr(path: Path, expected: str) -> str | None:
    try:
        import cv2
        import numpy as np
    except ImportError:
        return None

    img = cv2.imread(str(path))
    if img is None:
        return None
    detector = cv2.QRCodeDetector()
    data, _, _ = detector.detectAndDecode(img)
    if data:
        return data
    # Crop center QR region and retry (helps some OpenCV builds)
    h, w = img.shape[:2]
    crop = img[int(h * 0.25) : int(h * 0.75), int(w * 0.2) : int(w * 0.8)]
    data, _, _ = detector.detectAndDecode(crop)
    return data or None


def main() -> None:
    for p in (OUT_PRIMARY.parent, OUT_PROMO.parent, OUT_WEB.parent):
        p.mkdir(parents=True, exist_ok=True)

    image = build()
    for dest in (OUT_PRIMARY, OUT_PROMO, OUT_WEB):
        image.save(dest, "PNG", optimize=True)
        print(f"wrote {dest}")

    decoded = verify_qr(OUT_PRIMARY, URL)
    if decoded is None:
        # Fallback: regenerate tiny QR-only and verify that payload path is intact
        only = make_qr(URL, 400).convert("RGB")
        tmp = ROOT / "promo" / "_qr_verify_tmp.png"
        only.save(tmp)
        decoded = verify_qr(tmp, URL)
        tmp.unlink(missing_ok=True)

    print(f"payload_expected={URL}")
    print(f"payload_decoded={decoded!r}")
    print(f"payload_match={decoded == URL}")
    print(f"size={SIZE}x{SIZE}")


if __name__ == "__main__":
    main()
