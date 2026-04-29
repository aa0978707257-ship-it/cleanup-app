"""Generate App Store icon 1024x1024"""
from PIL import Image, ImageDraw, ImageFont
import math

SIZE = 1024

img = Image.new('RGB', (SIZE, SIZE), '#FFFFFF')
draw = ImageDraw.Draw(img)

# Background gradient (top-left to bottom-right, mint green)
for y in range(SIZE):
    for x in range(SIZE):
        ratio = (x + y) / (SIZE * 2)
        r = int(29 + ratio * 10)    # 1D -> 27
        g = int(158 + ratio * 40)   # 9E -> C6
        b = int(117 + ratio * 30)   # 75 -> 93
        img.putpixel((x, y), (r, g, b))

# Draw a white sparkle/broom icon shape in center
cx, cy = SIZE // 2, SIZE // 2

# Large white circle as base
for r in range(200):
    alpha = max(0, 255 - r)
    for angle in range(360):
        rad = math.radians(angle)
        x = int(cx + r * math.cos(rad))
        y = int(cy + r * math.sin(rad))
        if 0 <= x < SIZE and 0 <= y < SIZE:
            bg = img.getpixel((x, y))
            blend = int(r / 200 * 255)
            nr = (bg[0] * blend + 255 * (255 - blend)) // 255
            ng = (bg[1] * blend + 255 * (255 - blend)) // 255
            nb = (bg[2] * blend + 255 * (255 - blend)) // 255
            img.putpixel((x, y), (nr, ng, nb))

# Draw sparkle stars
def draw_star(draw, cx, cy, size, color):
    """Draw a 4-point star"""
    points = [
        (cx, cy - size),       # top
        (cx + size//4, cy - size//4),
        (cx + size, cy),       # right
        (cx + size//4, cy + size//4),
        (cx, cy + size),       # bottom
        (cx - size//4, cy + size//4),
        (cx - size, cy),       # left
        (cx - size//4, cy - size//4),
    ]
    draw.polygon(points, fill=color)

# Main star
draw_star(draw, cx, cy - 30, 120, '#FFFFFF')

# Small stars
draw_star(draw, cx + 160, cy - 150, 40, '#FFFFFF')
draw_star(draw, cx - 140, cy + 120, 30, '#FFFFFF')
draw_star(draw, cx + 120, cy + 100, 25, '#FFFFFF')

# Bottom text area - subtle
try:
    font = ImageFont.truetype("arial.ttf", 120)
except:
    font = ImageFont.load_default()

# Draw "C" letter centered below stars
draw.text((cx - 35, cy + 100), "C", fill='#FFFFFF', font=font)

# Save
output = r'C:\Users\AsusGaming\cleanup_flutter\AppIcon1024.png'
img.save(output, 'PNG')
print(f'Icon saved: {output}')
print(f'Size: {img.size}')
