from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "AppStoreAssets" / "screenshots"
REF = ROOT / "AppStoreAssets" / "reference"
ICON = ROOT / "AppStoreAssets" / "icon" / "markit-icon-1024.png"

SCREENS = {
    "home": REF / "actual-watermark-home.png",
    "puzzle": REF / "actual-puzzle-tab.png",
    "editor": REF / "actual-watermark-editor.png",
}

FONT_CJK = "/System/Library/Fonts/Hiragino Sans GB.ttc"
FONT_LATIN = "/System/Library/Fonts/SFNS.ttf"

INK = (31, 33, 32)
MUTED = (104, 106, 101)
PAPER = (248, 244, 235)
GRAPHITE = (25, 27, 27)
TEAL = (46, 131, 126)
AMBER = (226, 157, 48)

LANCZOS = getattr(getattr(Image, "Resampling", Image), "LANCZOS", Image.LANCZOS)


def font(size):
    try:
        return ImageFont.truetype(FONT_CJK, size=size)
    except OSError:
        try:
            return ImageFont.truetype(FONT_LATIN, size=size)
        except OSError:
            return ImageFont.load_default()


def gradient(size):
    w, h = size
    img = Image.new("RGB", size, PAPER)
    pix = img.load()
    for y in range(h):
        ty = y / max(1, h - 1)
        for x in range(w):
            tx = x / max(1, w - 1)
            warm = int(12 * (1 - ty))
            cool = int(12 * tx * ty)
            pix[x, y] = (
                min(255, 246 + warm - cool),
                min(255, 241 + warm - cool // 2),
                min(255, 231 + warm + cool),
            )
    return img.convert("RGBA")


def text_center(draw, text, x, y, fnt, fill=INK, spacing=10):
    lines = text.split("\n")
    boxes = [draw.textbbox((0, 0), line, font=fnt) for line in lines]
    total_h = sum(b[3] - b[1] for b in boxes) + spacing * (len(lines) - 1)
    cursor = y - total_h // 2
    for line, box in zip(lines, boxes):
        tw = box[2] - box[0]
        th = box[3] - box[1]
        draw.text((x - tw // 2, cursor), line, font=fnt, fill=fill)
        cursor += th + spacing


def shadow(base, box, radius, blur, alpha=60, offset=(0, 24)):
    x0, y0, x1, y1 = box
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle(
        (x0 + offset[0], y0 + offset[1], x1 + offset[0], y1 + offset[1]),
        radius=radius,
        fill=(0, 0, 0, alpha),
    )
    base.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))


def crop_to_ratio(img, ratio):
    w, h = img.size
    current = w / h
    if current > ratio:
        nw = int(h * ratio)
        x = (w - nw) // 2
        return img.crop((x, 0, x + nw, h))
    nh = int(w / ratio)
    y = (h - nh) // 2
    return img.crop((0, y, w, y + nh))


def rounded_paste(base, image, box, radius):
    x0, y0, x1, y1 = box
    resized = image.resize((x1 - x0, y1 - y0), LANCZOS).convert("RGBA")
    mask = Image.new("L", resized.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, resized.width, resized.height), radius=radius, fill=255)
    base.paste(resized, (x0, y0), mask)


def draw_logo(base, scale):
    d = ImageDraw.Draw(base)
    icon_size = int(108 * scale)
    icon = Image.open(ICON).resize((icon_size, icon_size), LANCZOS).convert("RGBA")
    x, y = int(82 * scale), int(74 * scale)
    base.alpha_composite(icon, (x, y))
    d.text((x + icon_size + int(28 * scale), y + int(28 * scale)), "markit", font=font(int(43 * scale)), fill=INK)


def draw_phone(base, screen_name, center_x, top_y, phone_w, crop=None):
    screen = Image.open(SCREENS[screen_name]).convert("RGB")
    if crop:
        x0, y0, x1, y1 = crop
        screen = screen.crop((x0, y0, x1, y1))
    aspect = screen.width / screen.height
    phone_h = int(phone_w / aspect)
    x0 = int(center_x - phone_w / 2)
    y0 = int(top_y)
    x1, y1 = x0 + int(phone_w), y0 + phone_h
    radius = max(24, int(phone_w * 0.105))
    shadow(base, (x0, y0, x1, y1), radius, blur=max(18, int(phone_w * 0.035)), alpha=58)
    d = ImageDraw.Draw(base)
    d.rounded_rectangle((x0 - 7, y0 - 7, x1 + 7, y1 + 7), radius=radius + 7, fill=(16, 17, 17))
    rounded_paste(base, screen, (x0, y0, x1, y1), radius)
    return (x0, y0, x1, y1)


def draw_badges(base, labels, y, scale):
    d = ImageDraw.Draw(base)
    total = 0
    widths = []
    f = font(int(19 * scale))
    for label in labels:
        b = d.textbbox((0, 0), label, font=f)
        w = (b[2] - b[0]) + int(40 * scale)
        widths.append(w)
        total += w
    total += int(16 * scale) * (len(labels) - 1)
    x = (base.width - total) // 2
    for idx, label in enumerate(labels):
        w = widths[idx]
        fill = (255, 255, 255, 215) if idx != 1 else (32, 34, 34, 235)
        text_fill = INK if idx != 1 else (255, 255, 255)
        d.rounded_rectangle((x, y, x + w, y + int(44 * scale)), radius=int(22 * scale), fill=fill)
        text_center(d, label, x + w // 2, y + int(23 * scale), f, fill=text_fill, spacing=0)
        x += w + int(16 * scale)


def page(size, title, subtitle, screen_name, filename, badges=None, phone_scale=0.71, top_factor=0.36, crop=None):
    w, h = size
    scale = w / 1290
    if h / w < 1.9:
        phone_scale = min(phone_scale, 0.56)
    img = gradient(size)
    d = ImageDraw.Draw(img)
    draw_logo(img, scale)
    text_center(d, title, w // 2, int(332 * scale), font(int(66 * scale)), fill=INK, spacing=int(8 * scale))
    text_center(d, subtitle, w // 2, int(476 * scale), font(int(28 * scale)), fill=MUTED, spacing=int(7 * scale))
    if badges:
        draw_badges(img, badges, int(548 * scale), scale)
    top_y = max(int(h * top_factor), int(650 * scale))
    draw_phone(img, screen_name, w // 2, top_y, int(w * phone_scale), crop=crop)
    out_dir = OUT / filename[0]
    out_dir.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(out_dir / filename[1], quality=96)


def detail_page(size, filename):
    w, h = size
    scale = w / 1290
    img = gradient(size)
    d = ImageDraw.Draw(img)
    draw_logo(img, scale)
    text_center(d, "真实界面\n重新包装", w // 2, int(330 * scale), font(int(64 * scale)), fill=INK, spacing=int(8 * scale))
    text_center(d, "截图来自当前 App，只做适合商店展示的外层排版。", w // 2, int(482 * scale), font(int(27 * scale)), fill=MUTED)
    editor_crop = (0, 520, 1320, 2500)
    home_crop = (0, 0, 1320, 1900)
    draw_phone(img, "editor", int(w * 0.32), int(h * 0.39), int(w * 0.50), crop=editor_crop)
    draw_phone(img, "home", int(w * 0.70), int(h * 0.46), int(w * 0.42), crop=home_crop)
    d.rounded_rectangle((int(118 * scale), h - int(176 * scale), w - int(118 * scale), h - int(102 * scale)), radius=int(37 * scale), fill=(255, 255, 255, 220))
    text_center(d, "水印模板 · 拼图布局 · 保存分享", w // 2, h - int(139 * scale), font(int(25 * scale)), fill=INK)
    out_dir = OUT / filename[0]
    out_dir.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(out_dir / filename[1], quality=96)


def main():
    specs = [
        ("6.9-inch", (1290, 2796)),
        ("6.5-inch", (1242, 2688)),
        ("5.5-inch", (1242, 2208)),
    ]
    for name, size in specs:
        page(
            size,
            "一张照片\n生成相机水印",
            "保留你当前应用的真实界面，重点展示模板选择流程。",
            "home",
            (name, "01-real-watermark-home.png"),
            badges=["真实截图", "水印模板", "本地处理"],
            phone_scale=0.74,
            top_factor=0.25,
        )
        page(
            size,
            "EXIF 参数\n自动成卡",
            "机型、光圈、快门、ISO 和焦段在编辑页里直接预览。",
            "editor",
            (name, "02-real-editor.png"),
            badges=["自动读取", "可编辑", "保存到相册"],
            phone_scale=0.74,
            top_factor=0.25,
        )
        page(
            size,
            "相机拼图\n做成作品封面",
            "拼图区域使用真实卡片，外层只做商店级包装。",
            "puzzle",
            (name, "03-real-puzzle-tab.png"),
            badges=["M11 / Q3", "小红书 / Ins", "多图布局"],
            phone_scale=0.74,
            top_factor=0.25,
        )
        detail_page(size, (name, "04-real-ui-montage.png"))


if __name__ == "__main__":
    main()
