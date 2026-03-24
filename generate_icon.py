"""고향마켓 앱 아이콘 생성"""
from PIL import Image, ImageDraw, ImageFont
import math

def create_app_icon(size=1024):
    """고향마켓 앱 아이콘 생성 - 초록 배경 + 집/마켓 심볼"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 배경: 둥근 사각형 (초록색 그라데이션 효과)
    # 메인 초록색: #2E7D32 (AppColors.primary와 유사)
    bg_color = (46, 125, 50)  # #2E7D32

    # 둥근 사각형 배경
    radius = size // 5  # 둥근 모서리
    draw.rounded_rectangle(
        [(0, 0), (size - 1, size - 1)],
        radius=radius,
        fill=bg_color
    )

    # 약간 밝은 초록 원형 배경 효과 (중앙)
    center = size // 2
    circle_r = int(size * 0.35)
    for i in range(circle_r, 0, -1):
        alpha = int(30 * (1 - i / circle_r))
        overlay_color = (255, 255, 255, alpha)
        draw.ellipse(
            [center - i, center - i - size//10, center + i, center + i - size//10],
            fill=None,
            outline=overlay_color
        )

    # 집 아이콘 (고향 = 집) - 심플한 디자인
    white = (255, 255, 255)

    # 집 지붕 (삼각형)
    roof_top = (center, int(size * 0.15))
    roof_left = (int(size * 0.15), int(size * 0.45))
    roof_right = (int(size * 0.85), int(size * 0.45))
    draw.polygon([roof_top, roof_left, roof_right], fill=white)

    # 지붕 안쪽 (초록색으로 빼기 효과)
    inner_top = (center, int(size * 0.22))
    inner_left = (int(size * 0.22), int(size * 0.43))
    inner_right = (int(size * 0.78), int(size * 0.43))
    draw.polygon([inner_top, inner_left, inner_right], fill=bg_color)

    # 집 몸체 (사각형)
    body_left = int(size * 0.22)
    body_right = int(size * 0.78)
    body_top = int(size * 0.43)
    body_bottom = int(size * 0.72)
    draw.rectangle(
        [body_left, body_top, body_right, body_bottom],
        fill=white
    )

    # 집 안쪽 (초록색)
    inner_margin = int(size * 0.04)
    draw.rectangle(
        [body_left + inner_margin, body_top + inner_margin,
         body_right - inner_margin, body_bottom],
        fill=bg_color
    )

    # 문 (가운데)
    door_w = int(size * 0.12)
    door_h = int(size * 0.18)
    door_x = center - door_w // 2
    door_y = body_bottom - door_h
    draw.rounded_rectangle(
        [door_x, door_y, door_x + door_w, body_bottom],
        radius=int(size * 0.02),
        fill=white
    )

    # 창문 2개
    win_size = int(size * 0.08)
    win_y = int(size * 0.50)
    # 왼쪽 창
    draw.rounded_rectangle(
        [int(size * 0.30), win_y, int(size * 0.30) + win_size, win_y + win_size],
        radius=int(size * 0.01),
        fill=white
    )
    # 오른쪽 창
    draw.rounded_rectangle(
        [int(size * 0.62), win_y, int(size * 0.62) + win_size, win_y + win_size],
        radius=int(size * 0.01),
        fill=white
    )

    # "고향마켓" 텍스트
    try:
        font_size = int(size * 0.12)
        font = ImageFont.truetype('C:/Windows/Fonts/malgunbd.ttf', font_size)
        text = "고향마켓"
        bbox = draw.textbbox((0, 0), text, font=font)
        text_w = bbox[2] - bbox[0]
        text_x = (size - text_w) // 2
        text_y = int(size * 0.76)
        draw.text((text_x, text_y), text, fill=white, font=font)
    except Exception as e:
        print(f"Font error: {e}")

    return img


def create_foreground_icon(size=1024):
    """Adaptive icon용 foreground (투명 배경)"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    white = (255, 255, 255)
    center = size // 2

    # 집 지붕
    roof_top = (center, int(size * 0.18))
    roof_left = (int(size * 0.18), int(size * 0.48))
    roof_right = (int(size * 0.82), int(size * 0.48))
    draw.polygon([roof_top, roof_left, roof_right], fill=white)

    # 지붕 안쪽
    bg_color = (46, 125, 50)
    inner_top = (center, int(size * 0.25))
    inner_left = (int(size * 0.25), int(size * 0.46))
    inner_right = (int(size * 0.75), int(size * 0.46))
    draw.polygon([inner_top, inner_left, inner_right], fill=bg_color)

    # 집 몸체
    body_left = int(size * 0.25)
    body_right = int(size * 0.75)
    body_top = int(size * 0.46)
    body_bottom = int(size * 0.72)
    draw.rectangle([body_left, body_top, body_right, body_bottom], fill=white)

    # 안쪽
    m = int(size * 0.04)
    draw.rectangle([body_left + m, body_top + m, body_right - m, body_bottom], fill=bg_color)

    # 문
    dw = int(size * 0.10)
    dh = int(size * 0.16)
    dx = center - dw // 2
    dy = body_bottom - dh
    draw.rounded_rectangle([dx, dy, dx + dw, body_bottom], radius=int(size * 0.02), fill=white)

    # 창문
    ws = int(size * 0.07)
    wy = int(size * 0.52)
    draw.rounded_rectangle([int(size * 0.32), wy, int(size * 0.32) + ws, wy + ws], radius=3, fill=white)
    draw.rounded_rectangle([int(size * 0.61), wy, int(size * 0.61) + ws, wy + ws], radius=3, fill=white)

    # 텍스트
    try:
        font = ImageFont.truetype('C:/Windows/Fonts/malgunbd.ttf', int(size * 0.10))
        text = "고향마켓"
        bbox = draw.textbbox((0, 0), text, font=font)
        tw = bbox[2] - bbox[0]
        draw.text(((size - tw) // 2, int(size * 0.76)), text, fill=white, font=font)
    except:
        pass

    return img


if __name__ == '__main__':
    import os

    # 메인 아이콘 (1024x1024)
    icon = create_app_icon(1024)
    icon.save('assets/icon/app_icon.png')
    print("app_icon.png (1024x1024) saved")

    # 다양한 크기 생성
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    res_dir = 'android/app/src/main/res'
    for folder, s in sizes.items():
        path = f'{res_dir}/{folder}'
        os.makedirs(path, exist_ok=True)
        resized = icon.resize((s, s), Image.LANCZOS)
        resized.save(f'{path}/ic_launcher.png')
        print(f"{folder}/ic_launcher.png ({s}x{s}) saved")

    # Foreground for adaptive icon
    fg = create_foreground_icon(1024)
    fg.save('assets/icon/app_icon_foreground.png')
    print("app_icon_foreground.png saved")

    # iOS용 (1024x1024, 배경 꽉 차게)
    icon.save('assets/icon/app_icon_ios.png')
    print("app_icon_ios.png saved")

    print("\nDone! All icons generated.")
