"""고향마켓 스플래시 화면 이미지 생성"""
from PIL import Image, ImageDraw, ImageFont

def create_splash(width=1080, height=1920):
    """스플래시 화면: 초록 배경 + 집 아이콘 + 텍스트"""
    img = Image.new('RGBA', (width, height), (46, 125, 50, 255))  # #2E7D32
    draw = ImageDraw.Draw(img)

    cx = width // 2
    cy = height // 2 - 100

    # 집 아이콘 (중앙, 크게)
    icon_size = 280
    white = (255, 255, 255)

    # 집 지붕
    roof_top = (cx, cy - icon_size // 2)
    roof_left = (cx - icon_size // 2, cy)
    roof_right = (cx + icon_size // 2, cy)
    draw.polygon([roof_top, roof_left, roof_right], fill=white)

    # 지붕 안쪽
    bg = (46, 125, 50)
    m = 30
    inner_top = (cx, cy - icon_size // 2 + m + 10)
    inner_left = (cx - icon_size // 2 + m, cy - 5)
    inner_right = (cx + icon_size // 2 - m, cy - 5)
    draw.polygon([inner_top, inner_left, inner_right], fill=bg)

    # 집 몸체
    bw = icon_size - 60
    bh = int(icon_size * 0.55)
    draw.rectangle([cx - bw//2, cy, cx + bw//2, cy + bh], fill=white)

    # 안쪽
    im = 15
    draw.rectangle([cx - bw//2 + im, cy + im, cx + bw//2 - im, cy + bh], fill=bg)

    # 문
    dw, dh = 40, 70
    draw.rounded_rectangle(
        [cx - dw//2, cy + bh - dh, cx + dw//2, cy + bh],
        radius=8, fill=white
    )

    # 창문 2개
    ws = 30
    wy = cy + 30
    draw.rounded_rectangle([cx - 70, wy, cx - 70 + ws, wy + ws], radius=4, fill=white)
    draw.rounded_rectangle([cx + 40, wy, cx + 40 + ws, wy + ws], radius=4, fill=white)

    # "고향마켓" 텍스트
    try:
        font_big = ImageFont.truetype('C:/Windows/Fonts/malgunbd.ttf', 72)
        font_sub = ImageFont.truetype('C:/Windows/Fonts/malgun.ttf', 28)
        font_small = ImageFont.truetype('C:/Windows/Fonts/malgun.ttf', 20)

        # 메인 타이틀
        text = "고향마켓"
        bbox = draw.textbbox((0, 0), text, font=font_big)
        tw = bbox[2] - bbox[0]
        draw.text(((width - tw) // 2, cy + bh + 50), text, fill=white, font=font_big)

        # 서브 타이틀
        sub = "신안군 AI 농수산물 직거래"
        bbox2 = draw.textbbox((0, 0), sub, font=font_sub)
        tw2 = bbox2[2] - bbox2[0]
        draw.text(((width - tw2) // 2, cy + bh + 140), sub, fill=(200, 230, 200), font=font_sub)

        # 하단 문구
        bottom = "사진 한 장이면 판매 시작"
        bbox3 = draw.textbbox((0, 0), bottom, font=font_small)
        tw3 = bbox3[2] - bbox3[0]
        draw.text(((width - tw3) // 2, height - 120), bottom, fill=(150, 200, 150), font=font_small)

    except Exception as e:
        print(f"Font error: {e}")

    return img


if __name__ == '__main__':
    import os

    # 스플래시 이미지 생성
    splash = create_splash(1080, 1920)

    # Android mipmap에 저장 (각 해상도)
    res_dir = 'android/app/src/main/res'
    sizes = {
        'mipmap-mdpi': (240, 427),
        'mipmap-hdpi': (360, 640),
        'mipmap-xhdpi': (480, 853),
        'mipmap-xxhdpi': (720, 1280),
        'mipmap-xxxhdpi': (1080, 1920),
    }

    for folder, (w, h) in sizes.items():
        path = f'{res_dir}/{folder}'
        os.makedirs(path, exist_ok=True)
        resized = splash.resize((w, h), Image.LANCZOS)
        resized.save(f'{path}/launch_image.png')
        print(f"{folder}/launch_image.png ({w}x{h}) saved")

    # assets에도 저장
    splash.save('assets/icon/splash.png')
    print("assets/icon/splash.png saved")

    print("\nDone!")
