"""Generate App Store screenshots 1242x2688 (iPhone 6.5 inch)"""
from PIL import Image, ImageDraw, ImageFont
import math

W, H = 1242, 2688
MINT = (29, 158, 117)
MINT_LIGHT = (232, 245, 238)
WHITE = (255, 255, 255)
DARK = (26, 26, 26)
GRAY = (136, 136, 128)
CORAL = (240, 153, 123)

def get_font(size):
    for f in ['msyh.ttc', 'msjh.ttc', 'arial.ttf', 'C:\\Windows\\Fonts\\msjh.ttc', 'C:\\Windows\\Fonts\\msyh.ttc']:
        try:
            return ImageFont.truetype(f, size)
        except:
            continue
    return ImageFont.load_default()

def draw_rounded_rect(draw, xy, radius, fill):
    x0, y0, x1, y1 = xy
    draw.rectangle([x0+radius, y0, x1-radius, y1], fill=fill)
    draw.rectangle([x0, y0+radius, x1, y1-radius], fill=fill)
    draw.pieslice([x0, y0, x0+2*radius, y0+2*radius], 180, 270, fill=fill)
    draw.pieslice([x1-2*radius, y0, x1, y0+2*radius], 270, 360, fill=fill)
    draw.pieslice([x0, y1-2*radius, x0+2*radius, y1], 90, 180, fill=fill)
    draw.pieslice([x1-2*radius, y1-2*radius, x1, y1], 0, 90, fill=fill)

def gradient_bg(img):
    for y in range(H):
        ratio = y / H
        r = int(29 + ratio * 15)
        g = int(158 + ratio * 30)
        b = int(117 + ratio * 20)
        for x in range(W):
            img.putpixel((x, y), (r, g, b))

def screenshot_1():
    """Screenshot 1: Smart Scan hero"""
    img = Image.new('RGB', (W, H), WHITE)
    draw = ImageDraw.Draw(img)
    gradient_bg(img)
    draw = ImageDraw.Draw(img)

    # Title
    font_big = get_font(80)
    font_sub = get_font(40)

    draw.text((W//2 - 280, 200), '智慧掃描', fill=WHITE, font=font_big)
    draw.text((W//2 - 360, 320), '一鍵找出所有可清理的項目', fill=(255,255,255,200), font=font_sub)

    # Mock phone screen
    phone_x, phone_y = 121, 500
    phone_w, phone_h = 1000, 1900
    draw_rounded_rect(draw, (phone_x, phone_y, phone_x+phone_w, phone_y+phone_h), 40, WHITE)

    # Inside phone: storage card mock
    card_x, card_y = phone_x+50, phone_y+80
    draw_rounded_rect(draw, (card_x, card_y, card_x+900, card_y+300), 24, (247, 247, 245))

    # Donut
    cx, cy = card_x + 150, card_y + 150
    for r in range(60, 68):
        for angle in range(360):
            rad = math.radians(angle)
            px = int(cx + r * math.cos(rad))
            py = int(cy + r * math.sin(rad))
            if angle < 252:  # 70%
                img.putpixel((px, py), MINT)
            else:
                img.putpixel((px, py), (224, 224, 220))

    font_pct = get_font(36)
    font_sm = get_font(20)
    draw.text((cx-30, cy-22), '70%', fill=DARK, font=font_pct)
    draw.text((cx-30, cy+18), '已使用', fill=GRAY, font=font_sm)

    # Storage text
    font_lg = get_font(52)
    draw.text((card_x+300, card_y+60), '45.2 GB', fill=DARK, font=font_lg)
    draw.text((card_x+300, card_y+130), '共 64 GB', fill=GRAY, font=font_sub)

    # Scan button mock
    btn_y = card_y + 360
    draw_rounded_rect(draw, (card_x, btn_y, card_x+900, btn_y+100), 50, MINT)
    font_btn = get_font(36)
    draw.text((card_x+320, btn_y+28), '智慧掃描  AI', fill=WHITE, font=font_btn)

    # Feature cards
    features = [('重複照片', '247 張', CORAL), ('相似照片', '89 張', (229,163,26)), ('螢幕截圖', '156 張', MINT), ('大型檔案', '12 個', (157,106,255))]
    fy = btn_y + 160
    for i, (name, count, color) in enumerate(features):
        fx = card_x + (i % 2) * 460
        ffy = fy + (i // 2) * 180
        draw_rounded_rect(draw, (fx, ffy, fx+430, ffy+160), 20, (250, 250, 248))
        draw_rounded_rect(draw, (fx+20, ffy+20, fx+70, ffy+70), 12, color)
        draw.text((fx+90, ffy+25), name, fill=DARK, font=get_font(30))
        draw.text((fx+90, ffy+70), count, fill=GRAY, font=get_font(24))

    img.save(r'C:\Users\AsusGaming\cleanup_flutter\screenshot_1.png')
    print('Screenshot 1 saved')

def screenshot_2():
    """Screenshot 2: Duplicate photos"""
    img = Image.new('RGB', (W, H), WHITE)
    draw = ImageDraw.Draw(img)
    gradient_bg(img)
    draw = ImageDraw.Draw(img)

    font_big = get_font(80)
    font_sub = get_font(40)

    draw.text((W//2 - 280, 200), '重複照片', fill=WHITE, font=font_big)
    draw.text((W//2 - 400, 320), 'AI 自動偵測，一鍵批量刪除', fill=WHITE, font=font_sub)

    # Mock phone
    phone_x, phone_y = 121, 500
    phone_w, phone_h = 1000, 1900
    draw_rounded_rect(draw, (phone_x, phone_y, phone_x+phone_w, phone_y+phone_h), 40, WHITE)

    # Results header
    draw.text((phone_x+60, phone_y+60), '可以釋放 2.3 GB', fill=MINT, font=get_font(44))

    # Photo grid mock
    colors = [(200,180,160), (180,200,180), (160,180,200), (200,160,180),
              (190,190,170), (170,190,190), (190,170,190), (180,180,180)]
    for i in range(8):
        px = phone_x + 60 + (i % 3) * 300
        py = phone_y + 180 + (i // 3) * 300
        draw_rounded_rect(draw, (px, py, px+280, py+280), 16, colors[i % len(colors)])
        # Best badge on first
        if i == 0:
            draw_rounded_rect(draw, (px+10, py+10, px+90, py+45), 8, MINT)
            draw.text((px+18, py+14), '最佳', fill=WHITE, font=get_font(22))
        # Check mark on others
        elif i < 6:
            draw_rounded_rect(draw, (px+230, py+230, px+270, py+270), 20, (59, 130, 246))

    # Bottom button
    btn_y = phone_y + 1600
    draw_rounded_rect(draw, (phone_x+60, btn_y, phone_x+940, btn_y+100), 50, CORAL)
    draw.text((phone_x+300, btn_y+25), '刪除 5 個項目', fill=WHITE, font=get_font(36))

    img.save(r'C:\Users\AsusGaming\cleanup_flutter\screenshot_2.png')
    print('Screenshot 2 saved')

def screenshot_3():
    """Screenshot 3: Secret Space"""
    img = Image.new('RGB', (W, H), WHITE)
    draw = ImageDraw.Draw(img)
    gradient_bg(img)
    draw = ImageDraw.Draw(img)

    font_big = get_font(80)
    font_sub = get_font(40)

    draw.text((W//2 - 280, 200), '私密空間', fill=WHITE, font=font_big)
    draw.text((W//2 - 400, 320), '軍事級加密保護你的隱私', fill=WHITE, font=font_sub)

    # Mock phone
    phone_x, phone_y = 121, 500
    phone_w, phone_h = 1000, 1900
    draw_rounded_rect(draw, (phone_x, phone_y, phone_x+phone_w, phone_y+phone_h), 40, WHITE)

    # Lock icon
    cx = phone_x + phone_w // 2
    cy = phone_y + 500
    # Circle
    for r in range(80, 90):
        for angle in range(360):
            rad = math.radians(angle)
            px = int(cx + r * math.cos(rad))
            py = int(cy + r * math.sin(rad))
            if 0 <= px < W and 0 <= py < H:
                img.putpixel((px, py), MINT)

    # Shield shape
    draw_rounded_rect(draw, (cx-50, cy-40, cx+50, cy+50), 12, MINT)
    draw_rounded_rect(draw, (cx-15, cy-10, cx+15, cy+25), 4, WHITE)

    # PIN dots
    dot_y = cy + 200
    for i in range(4):
        dx = cx - 120 + i * 80
        draw_rounded_rect(draw, (dx-15, dot_y-15, dx+15, dot_y+15), 15, (200, 200, 196) if i > 1 else DARK)

    # Features
    features = ['AES-256 加密保護', 'Face ID / 指紋解鎖', '隱藏照片和影片', '密碼保護，安全無憂']
    for i, feat in enumerate(features):
        fy = cy + 350 + i * 100
        draw_rounded_rect(draw, (phone_x+60, fy, phone_x+940, fy+80), 12, MINT_LIGHT)
        draw.text((phone_x+120, fy+20), f'✓  {feat}', fill=MINT, font=get_font(30))

    img.save(r'C:\Users\AsusGaming\cleanup_flutter\screenshot_3.png')
    print('Screenshot 3 saved')

# Generate all
screenshot_1()
screenshot_2()
screenshot_3()
print('All screenshots generated!')
