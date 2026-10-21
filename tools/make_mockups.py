"""A-Z UI 목업 이미지 생성 (제출용)

레퍼런스 분석에서 뽑은 색 토큰(design.md 2.2)을 그대로 사용한다.
"""
from PIL import Image, ImageDraw, ImageFont
import os, math

W, H = 1600, 1000  # 데스크톱 목업
PW, PH = 480, 960  # 폰 목업

# ── 디자인 토큰 (design.md 2.2)
SPACE = (243, 243, 250)
SPACE2 = (238, 238, 247)
EDGE = (232, 234, 246)
SURFACE = (255, 255, 255)
LINE = (217, 225, 237)
MUTED = (182, 182, 191)
INK = (48, 47, 53)
INK_STRONG = (9, 9, 17)
INK_SUB = (114, 110, 118)
PRIMARY = (75, 92, 222)
PRIMARY2 = (106, 59, 217)

CAT_COLORS = [
    (41, 112, 252), (0, 192, 128), (233, 152, 11),
    (222, 87, 163), (92, 74, 236), (24, 183, 145),
    (246, 32, 102), (209, 158, 4), (106, 59, 217),
]
CAT_TEXT = [
    (21, 99, 252), (0, 128, 85), (153, 100, 7),
    (203, 40, 132), (92, 74, 236), (16, 124, 99),
    (221, 9, 78), (139, 105, 3), (106, 59, 217),
]
UNCAT = (134, 141, 167)

def get_font(size):
    for p in [
        "C:/Windows/Fonts/malgun.ttf",
        "C:/Windows/Fonts/malgunbd.ttf",
        "C:/Windows/Fonts/seguiemj.ttf",
    ]:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()

F10 = get_font(10)
F12 = get_font(12)
F13 = get_font(13)
F14 = get_font(14)
F16 = get_font(16)
F18 = get_font(18)
F20 = get_font(20)
F24 = get_font(24)
F28 = get_font(28)
F32 = get_font(32)
F36 = get_font(36)
F42 = get_font(42)

def rounded_rect(d, xy, r, fill=None, outline=None, width=1):
    d.rounded_rectangle(xy, radius=r, fill=fill, outline=outline, width=width)

def pill(d, x, y, text, font, fg, bg, pad_x=12, pad_y=6):
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    rounded_rect(d, (x, y, x + tw + pad_x * 2, y + th + pad_y * 2), (th + pad_y * 2) // 2, fill=bg)
    d.text((x + pad_x, y + pad_y - bbox[1]), text, fill=fg, font=font)
    return tw + pad_x * 2, th + pad_y * 2

def draw_bg(img, d):
    """옅은 라벤더 방사형 배경 + 링"""
    d.rectangle((0, 0, img.width, img.height), fill=SPACE)
    cx, cy = img.width // 2, img.height // 2
    for r in range(200, 900, 120):
        alpha = max(8, 40 - r // 30)
        overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.ellipse((cx - r, cy - r * 0.6, cx + r, cy + r * 0.6), outline=(255, 255, 255, alpha), width=2)
        img.paste(Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB"))

# ══════════════════════════════════════════════════════════════
# 1. 시작 화면
# ══════════════════════════════════════════════════════════════
def make_start():
    img = Image.new("RGB", (W, H), SPACE)
    d = ImageDraw.Draw(img)
    draw_bg(img, d)

    # 로고 + 제목
    cx = W // 2
    d.ellipse((cx - 20, 80, cx + 20, 120), outline=PRIMARY, width=3)
    d.ellipse((cx - 8, 92, cx + 8, 108), fill=PRIMARY)

    # A - Z (2색)
    bbox_a = d.textbbox((0, 0), "A", font=F42)
    aw = bbox_a[2] - bbox_a[0]
    d.text((cx - aw - 8, 140), "A", fill=INK_STRONG, font=F42)
    d.text((cx - 8, 140), " - ", fill=MUTED, font=F42)
    d.text((cx + 48, 140), "Z", fill=CAT_COLORS[0], font=F42)

    d.text((cx - 120, 200), "PHOTO // VIDEO // MEMO", fill=INK_SUB, font=F14)

    # 2 large buttons
    for i, (label, icon, x) in enumerate([("+  NEW VAULT", "+", cx - 340), (">  OPEN FOLDER", ">", cx + 20)]):
        rounded_rect(d, (x, 260, x + 320, 330), 16, fill=SURFACE, outline=LINE, width=2)
        d.text((x + 24, 282), label, fill=INK, font=F18)

    # RECENT
    d.text((cx - 340, 370), "RECENT", fill=INK_SUB, font=F14)
    for i, (name, info, color) in enumerate([
        ("D:\\A-Z vault", "437 posts · 2h ago", PRIMARY),
        ("E:\\backup\\A-Z vault", "(missing)", MUTED),
    ]):
        y = 400 + i * 52
        d.ellipse((cx - 330, y + 10, cx - 310, y + 30), fill=color)
        d.text((cx - 290, y + 10), name, fill=INK, font=F16)
        d.text((cx + 20, y + 12), info, fill=INK_SUB, font=F13)

    # NEW VAULT
    d.text((cx - 340, 530), "NEW VAULT  >  WHERE?", fill=INK_SUB, font=F14)

    volumes = [
        ("C:", "local", "120 GB free", PRIMARY),
        ("D:", "local", "1.2 TB free", CAT_COLORS[1]),
        ("E:", "usb", "64 GB free", CAT_COLORS[2]),
        ("Z:", "network", "! slow", MUTED),
    ]
    for i, (name, typ, space, color) in enumerate(volumes):
        x = cx - 340 + (i % 2) * 350
        y = 570 + (i // 2) * 60
        rounded_rect(d, (x, y, x + 320, y + 48), 12, fill=SURFACE, outline=LINE, width=1)
        d.ellipse((x + 12, y + 14, x + 34, y + 36), fill=color)
        d.text((x + 44, y + 14), name, fill=INK_STRONG, font=F16)
        d.text((x + 90, y + 16), typ, fill=INK_SUB, font=F12)
        d.text((x + 180, y + 16), space, fill=INK_SUB, font=F12)

    # Name input + create
    rounded_rect(d, (cx - 340, 710, cx + 120, 756), 12, fill=SURFACE, outline=LINE, width=2)
    d.text((cx - 320, 722), "A-Z vault", fill=INK, font=F16)

    # checkbox
    rounded_rect(d, (cx + 140, 720, cx + 164, 744), 4, fill=PRIMARY)
    d.text((cx + 150, 722), "✓", fill=SURFACE, font=F14)
    d.text((cx + 172, 722), "with samples", fill=INK_SUB, font=F13)

    # Create button
    rounded_rect(d, (cx - 80, 780, cx + 200, 836), 28, fill=PRIMARY)
    d.text((cx + 18, 794), "CREATE", fill=SURFACE, font=F20)

    img.save("mockup_1_start.png", quality=95)
    print("1_start done")

# ══════════════════════════════════════════════════════════════
# 2. 피드 뷰 (데스크톱 3단)
# ══════════════════════════════════════════════════════════════
def make_feed():
    img = Image.new("RGB", (W, H), SPACE)
    d = ImageDraw.Draw(img)
    draw_bg(img, d)

    # ── Top bar
    rounded_rect(d, (24, 16, 240, 56), 20, fill=SURFACE, outline=LINE, width=1)
    d.text((40, 26), "  search ...", fill=MUTED, font=F14)

    # A - Z center
    d.text((W // 2 - 80, 18), "A", fill=INK_STRONG, font=F36)
    d.text((W // 2 - 40, 18), " - ", fill=MUTED, font=F36)
    d.text((W // 2 + 10, 18), "Z", fill=CAT_COLORS[0], font=F36)
    d.text((W // 2 - 80, 58), "PHOTO // VIDEO // MEMO", fill=INK_SUB, font=F10)

    # Status pill
    pill(d, W - 280, 18, "437 | 300 | 40", F13, INK_SUB, SURFACE)

    # ── Left legend
    lx = 24
    d.text((lx, 80), "CATEGORIES", fill=INK_SUB, font=F12)
    cats = [("science", 128, 0), ("design", 42, 1), ("travel", 97, 2), ("none", 15, 8)]
    for i, (name, count, ci) in enumerate(cats):
        y = 110 + i * 36
        rounded_rect(d, (lx, y, lx + 200, y + 28), 14, fill=SURFACE, outline=LINE, width=1)
        c = CAT_COLORS[ci] if ci < len(CAT_COLORS) else UNCAT
        d.ellipse((lx + 10, y + 8, lx + 24, y + 22), fill=c)
        d.text((lx + 32, y + 6), name, fill=INK, font=F13)
        d.text((lx + 150, y + 7), str(count), fill=INK_SUB, font=F12)

    # Type filter
    d.text((lx, 280), "TYPE", fill=INK_SUB, font=F12)
    for i, label in enumerate(["all", "photo", "video", "memo"]):
        x = lx + (i % 2) * 100
        y = 308 + (i // 2) * 32
        bg = PRIMARY if i == 0 else SURFACE
        fg = SURFACE if i == 0 else INK
        rounded_rect(d, (x, y, x + 88, y + 26), 13, fill=bg, outline=LINE, width=1)
        d.text((x + 16, y + 5), label, fill=fg, font=F12)

    # ── Center feed
    fx = 260
    fw = 600

    # Composer
    rounded_rect(d, (fx, 80, fx + fw, 140), 16, fill=SURFACE, outline=LINE, width=1)
    d.text((fx + 20, 95), "what's on your mind?  #tag works", fill=MUTED, font=F14)
    rounded_rect(d, (fx + fw - 100, 108, fx + fw - 20, 132), 12, fill=PRIMARY)
    d.text((fx + fw - 80, 112), "POST", fill=SURFACE, font=F13)

    # Cards
    cards = [
        {"cat": "science", "ci": 0, "time": "2h ago", "text": "3D 지식 그래프 레퍼런스\n카테고리별 구체와 궤도 링 #레퍼런스", "media": 1, "starred": True},
        {"cat": "design", "ci": 1, "time": "5h ago", "text": "궤도 링 색감 연구\n레퍼런스에서 뽑은 색으로 링 네 개를 그려 봤다 #색감", "media": 4, "starred": False},
        {"cat": "travel", "ci": 2, "time": "1d ago", "text": "제주도 사진 정리 #여행 #제주", "media": 2, "starred": False},
    ]
    for ci, card in enumerate(cards):
        y = 160 + ci * 230
        rounded_rect(d, (fx, y, fx + fw, y + 210), 16, fill=SURFACE, outline=LINE, width=2)

        # Avatar circle
        c = CAT_COLORS[card["ci"]]
        d.ellipse((fx + 16, y + 16, fx + 52, y + 52), outline=c, width=3)

        # Header
        d.text((fx + 62, y + 16), card["cat"], fill=INK_STRONG, font=F14)
        d.text((fx + 62, y + 34), card["time"], fill=INK_SUB, font=F11 if hasattr(d, 'F11') else F12)
        if card["starred"]:
            d.text((fx + fw - 36, y + 16), "★", fill=CAT_COLORS[2], font=F18)

        # Body text
        lines = card["text"].split("\n")
        for li, line in enumerate(lines):
            d.text((fx + 20, y + 62 + li * 20), line, fill=INK, font=F14)

        # Media grid
        my = y + 110
        if card["media"] == 1:
            rounded_rect(d, (fx + 20, my, fx + fw - 20, my + 80), 12, fill=EDGE)
            d.text((fx + fw // 2 - 20, my + 30), "▶ 0:58", fill=INK_SUB, font=F14)
        elif card["media"] == 2:
            for mi in range(2):
                mx = fx + 20 + mi * ((fw - 44) // 2 + 4)
                rounded_rect(d, (mx, my, mx + (fw - 44) // 2, my + 80), 12, fill=EDGE)
        elif card["media"] == 4:
            for mi in range(4):
                mx = fx + 20 + (mi % 2) * ((fw - 44) // 2 + 4)
                myy = my + (mi // 2) * 42
                rounded_rect(d, (mx, myy, mx + (fw - 44) // 2, myy + 38), 8, fill=EDGE)

        # Tags
        tag = card["text"].split("#")[-1].strip() if "#" in card["text"] else ""
        if tag:
            pill(d, fx + 20, y + 185, "#" + tag.split()[0], F11 if hasattr(d, 'F11') else F12, CAT_TEXT[card["ci"]], SPACE2, 8, 3)

    # ── Right navigator
    nx = 890
    nw = 280
    rounded_rect(d, (nx, 80, nx + nw, 420), 20, fill=SURFACE, outline=LINE, width=2)
    d.text((nx + 20, 95), "NAVIGATOR", fill=INK_SUB, font=F12)
    d.ellipse((nx + 20, 125, nx + 36, 141), fill=CAT_COLORS[0])
    d.text((nx + 42, 124), "science", fill=INK, font=F13)
    d.text((nx + 20, 160), "3D 지식 그래프", fill=INK_STRONG, font=F20)
    rounded_rect(d, (nx + 20, 200, nx + nw - 20, 300), 12, fill=EDGE)
    d.text((nx + 40, 240), "thumbnail", fill=MUTED, font=F14)
    d.text((nx + 20, 315), "카테고리별 구체와 궤도 링...", fill=INK_SUB, font=F12)
    d.text((nx + 20, 340), "2026-08-17 · tags 2 · links 3", fill=MUTED, font=F11 if hasattr(d, 'F11') else F12)

    rounded_rect(d, (nx + 20, 365, nx + nw - 100, 395), 15, fill=PRIMARY)
    d.text((nx + 36, 372), "OPEN FILE", fill=SURFACE, font=F12)
    rounded_rect(d, (nx + nw - 90, 365, nx + nw - 20, 395), 15, fill=SURFACE, outline=LINE, width=1)
    d.text((nx + nw - 80, 372), "CLOSE", fill=INK, font=F12)

    # ── Bottom control bar
    cy = H - 60
    rounded_rect(d, (W // 2 - 280, cy, W // 2 + 280, cy + 44), 22, fill=SURFACE, outline=LINE, width=2)
    # mascot
    d.ellipse((W // 2 - 250, cy + 10, W // 2 - 226, cy + 34), outline=PRIMARY, width=2)
    # buttons
    for i, (label, active) in enumerate([("FEED", True), ("orbit", False)]):
        x = W // 2 - 160 + i * 100
        if active:
            rounded_rect(d, (x, cy + 8, x + 80, cy + 36), 18, fill=PRIMARY)
            d.text((x + 18, cy + 14), label, fill=SURFACE, font=F13)
        else:
            d.text((x + 18, cy + 14), label, fill=INK_SUB, font=F13)
    d.text((W // 2 + 60, cy + 14), "< prev    next >", fill=INK_SUB, font=F13)

    # import button
    rounded_rect(d, (24, cy, 160, cy + 44), 22, fill=SURFACE, outline=LINE, width=1)
    d.text((44, cy + 14), "IMPORT", fill=INK, font=F13)

    img.save("mockup_2_feed.png", quality=95)
    print("2_feed done")

# ══════════════════════════════════════════════════════════════
# 3. 궤도 뷰
# ══════════════════════════════════════════════════════════════
def make_orbit():
    img = Image.new("RGB", (W, H), SPACE)
    d = ImageDraw.Draw(img)
    draw_bg(img, d)

    # top bar (same)
    rounded_rect(d, (24, 16, 240, 56), 20, fill=SURFACE, outline=LINE, width=1)
    d.text((40, 26), "  search ...", fill=MUTED, font=F14)
    d.text((W // 2 - 80, 18), "A", fill=INK_STRONG, font=F36)
    d.text((W // 2 - 40, 18), " - ", fill=MUTED, font=F36)
    d.text((W // 2 + 10, 18), "Z", fill=CAT_COLORS[0], font=F36)
    pill(d, W - 280, 18, "437 | 300 | 40", F13, INK_SUB, SURFACE)

    # Left legend (dimmed)
    lx = 24
    for i, (name, count, ci) in enumerate([("science", 128, 0), ("design", 42, 1), ("travel", 97, 2), ("none", 15, 8)]):
        y = 110 + i * 36
        rounded_rect(d, (lx, y, lx + 200, y + 28), 14, fill=SURFACE, outline=LINE, width=1)
        c = CAT_COLORS[ci] if ci < len(CAT_COLORS) else UNCAT
        d.ellipse((lx + 10, y + 8, lx + 24, y + 22), fill=c)
        d.text((lx + 32, y + 6), name, fill=INK, font=F13)
        d.text((lx + 150, y + 7), str(count), fill=INK_SUB, font=F12)

    # ── 3D orbit scene (center)
    ox, oy = W // 2, H // 2 - 20

    # Large orbit rings
    for r, alpha in [(380, 25), (320, 35), (260, 45)]:
        overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.ellipse((ox - r, oy - r * 0.45, ox + r, oy + r * 0.45), outline=(75, 92, 222, alpha), width=3)
        img.paste(Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB"))

    # Category spheres
    spheres = [
        (ox - 220, oy - 80, 90, CAT_COLORS[0], "SCIENCE"),
        (ox + 180, oy - 40, 75, CAT_COLORS[1], "DESIGN"),
        (ox - 60, oy + 120, 65, CAT_COLORS[2], "TRAVEL"),
        (ox + 240, oy + 100, 55, CAT_COLORS[8], "NONE"),
    ]
    for sx, sy, sr, color, name in spheres:
        # glow
        overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.ellipse((sx - sr - 20, sy - sr - 20, sx + sr + 20, sy + sr + 20), fill=(*color, 30))
        img.paste(Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB"))
        d = ImageDraw.Draw(img)
        # sphere
        overlay2 = Image.new("RGBA", img.size, (0, 0, 0, 0))
        od2 = ImageDraw.Draw(overlay2)
        od2.ellipse((sx - sr, sy - sr, sx + sr, sy + sr), fill=(*color, 60), outline=(*color, 150), width=3)
        img.paste(Image.alpha_composite(img.convert("RGBA"), overlay2).convert("RGB"))
        d = ImageDraw.Draw(img)
        # highlight
        d.arc((sx - sr, sy - sr, sx + sr, sy + sr), 200, 280, fill=SURFACE, width=2)
        # name below
        d.text((sx - sr, sy + sr + 8), name, fill=color, font=F14)

    # Node dots
    nodes = [
        (ox - 180, oy - 120, 6, CAT_COLORS[0]), (ox - 140, oy - 60, 5, CAT_COLORS[0]),
        (ox - 100, oy - 140, 4, CAT_COLORS[0]), (ox - 200, oy - 30, 5, CAT_COLORS[0]),
        (ox + 140, oy - 80, 6, CAT_COLORS[1]), (ox + 200, oy - 20, 5, CAT_COLORS[1]),
        (ox + 160, oy + 20, 4, CAT_COLORS[1]),
        (ox - 30, oy + 80, 5, CAT_COLORS[2]), (ox + 20, oy + 140, 6, CAT_COLORS[2]),
    ]
    for nx, ny, nr, nc in nodes:
        d.ellipse((nx - nr, ny - nr, nx + nr, ny + nr), fill=nc)

    # Link lines
    link_pairs = [(0, 1), (1, 2), (4, 5), (5, 6), (7, 8)]
    for a, b in link_pairs:
        d.line((nodes[a][0], nodes[a][1], nodes[b][0], nodes[b][1]), fill=(*MUTED, 80), width=1)

    # Label pills (near nodes)
    labels = [
        (ox - 240, oy - 160, "SCIENCE note", CAT_COLORS[0]),
        (ox + 140, oy - 120, "DESIGN ref", CAT_COLORS[1]),
    ]
    for lx, ly, text, color in labels:
        pill(d, lx, ly, text, F12, INK, SURFACE, 10, 4)

    # Selected label
    pill(d, ox - 30, oy + 160, "★ TRAVEL", F13, SURFACE, CAT_TEXT[2], 12, 6)

    # ── Right navigator (same as feed)
    nx2 = 890
    nw2 = 280
    rounded_rect(d, (nx2, 80, nx2 + nw2, 420), 20, fill=SURFACE, outline=LINE, width=2)
    d.text((nx2 + 20, 95), "NAVIGATOR", fill=INK_SUB, font=F12)
    d.ellipse((nx2 + 20, 125, nx2 + 36, 141), fill=CAT_COLORS[2])
    d.text((nx2 + 42, 124), "travel", fill=INK, font=F13)
    d.text((nx2 + 20, 160), "제주도 사진", fill=INK_STRONG, font=F20)
    rounded_rect(d, (nx2 + 20, 200, nx2 + nw2 - 20, 300), 12, fill=EDGE)
    d.text((nx2 + 20, 315), "여행 사진 모음...", fill=INK_SUB, font=F12)
    rounded_rect(d, (nx2 + 20, 365, nx2 + nw2 - 100, 395), 15, fill=PRIMARY)
    d.text((nx2 + 36, 372), "OPEN FILE", fill=SURFACE, font=F12)
    rounded_rect(d, (nx2 + nw2 - 90, 365, nx2 + nw2 - 20, 395), 15, fill=SURFACE, outline=LINE, width=1)
    d.text((nx2 + nw2 - 80, 372), "CLOSE", fill=INK, font=F12)

    # ── Bottom bar
    cy = H - 60
    rounded_rect(d, (W // 2 - 280, cy, W // 2 + 280, cy + 44), 22, fill=SURFACE, outline=LINE, width=2)
    for i, (label, active) in enumerate([("feed", False), ("ORBIT", True)]):
        x = W // 2 - 160 + i * 100
        if active:
            rounded_rect(d, (x, cy + 8, x + 80, cy + 36), 18, fill=PRIMARY)
            d.text((x + 18, cy + 14), label, fill=SURFACE, font=F13)
        else:
            d.text((x + 18, cy + 14), label, fill=INK_SUB, font=F13)
    d.text((W // 2 + 60, cy + 14), "< prev    next >", fill=INK_SUB, font=F13)

    # Gesture hints
    d.text((W - 320, H - 30), "DRAG ROTATE · WHEEL ZOOM · TAP SELECT", fill=MUTED, font=F11 if hasattr(d, 'F11') else F12)

    img.save("mockup_3_orbit.png", quality=95)
    print("3_orbit done")

# ══════════════════════════════════════════════════════════════
# 4. 폰 화면 (1단)
# ══════════════════════════════════════════════════════════════
def make_phone():
    img = Image.new("RGB", (PW, PH), SPACE)
    d = ImageDraw.Draw(img)
    draw_bg(img, d)

    # top
    d.text((24, 20), "≡", fill=INK, font=F24)
    d.text((PW // 2 - 30, 22), "A", fill=INK_STRONG, font=F28)
    d.text((PW // 2 - 8, 22), "-", fill=MUTED, font=F28)
    d.text((PW // 2 + 14, 22), "Z", fill=CAT_COLORS[0], font=F28)
    d.text((PW - 50, 24), "?", fill=INK_SUB, font=F20)

    # status
    pill(d, 24, 60, "437 | 300 | 40", F11 if hasattr(d, 'F11') else F12, INK_SUB, SURFACE)

    # Cards
    cards = [
        {"cat": "design", "ci": 1, "time": "2h ago", "text": "궤도 링 색감 #색감", "media": 2, "starred": True},
        {"cat": "science", "ci": 0, "time": "5h ago", "text": "레퍼런스 분석 #3D", "media": 1, "starred": False},
    ]
    for ci, card in enumerate(cards):
        y = 105 + ci * 200
        rounded_rect(d, (16, y, PW - 16, y + 185), 16, fill=SURFACE, outline=LINE, width=2)
        c = CAT_COLORS[card["ci"]]
        d.ellipse((32, y + 16, 60, y + 44), outline=c, width=2)
        d.text((68, y + 16), card["cat"], fill=INK_STRONG, font=F13)
        d.text((68, y + 34), card["time"], fill=INK_SUB, font=F10)
        if card["starred"]:
            d.text((PW - 48, y + 16), "★", fill=CAT_COLORS[2], font=F16)
        d.text((32, y + 58), card["text"], fill=INK, font=F14)

        my = y + 85
        if card["media"] == 1:
            rounded_rect(d, (32, my, PW - 32, my + 70), 12, fill=EDGE)
        else:
            for mi in range(2):
                mx = 32 + mi * ((PW - 68) // 2 + 4)
                rounded_rect(d, (mx, my, mx + (PW - 68) // 2, my + 70), 12, fill=EDGE)

    # Bottom bar
    cy = PH - 80
    rounded_rect(d, (24, cy, PW - 24, cy + 56), 28, fill=SURFACE, outline=LINE, width=2)
    rounded_rect(d, (50, cy + 12, 160, cy + 44), 16, fill=PRIMARY)
    d.text((80, cy + 18), "FEED", fill=SURFACE, font=F14)
    d.text((180, cy + 18), "orbit", fill=INK_SUB, font=F14)
    rounded_rect(d, (PW - 90, cy + 12, PW - 50, cy + 44), 16, fill=PRIMARY)
    d.text((PW - 80, cy + 16), "+", fill=SURFACE, font=F18)

    img.save("mockup_4_phone.png", quality=95)
    print("4_phone done")

if __name__ == "__main__":
    os.makedirs("design", exist_ok=True)
    os.chdir("design")
    make_start()
    make_feed()
    make_orbit()
    make_phone()
    print("all done")
