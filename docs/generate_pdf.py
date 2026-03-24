import sys, os
sys.stdout.reconfigure(encoding='utf-8')
from fpdf import FPDF

class PDF(FPDF):
    def header(self):
        if self.page_no() > 1:
            self.set_font('gothic', '', 8)
            self.set_text_color(150, 150, 150)
            self.cell(0, 5, '신안 마켓연금 정책 제안서', align='R')
            self.ln(8)

    def footer(self):
        self.set_y(-15)
        self.set_font('gothic', '', 8)
        self.set_text_color(150, 150, 150)
        self.cell(0, 10, str(self.page_no()), align='C')

    def section_title(self, title):
        self.set_font('gothic', 'B', 16)
        self.set_text_color(21, 101, 192)
        x, y = self.get_x(), self.get_y()
        self.set_fill_color(21, 101, 192)
        self.rect(x, y+1, 3, 10, 'F')
        self.set_x(x + 8)
        self.multi_cell(0, 8, title)
        self.ln(4)

    def sub_title(self, title):
        self.set_font('gothic', 'B', 13)
        self.set_text_color(51, 51, 51)
        self.multi_cell(0, 7, title)
        self.ln(2)

    def body_text(self, text):
        self.set_font('gothic', '', 10.5)
        self.set_text_color(33, 33, 33)
        self.multi_cell(0, 6.5, text)
        self.ln(2)

    def quote_box(self, text):
        x, y = self.get_x(), self.get_y()
        w = self.w - self.l_margin - self.r_margin
        self.set_font('gothic', '', 11)
        self.set_fill_color(245, 247, 250)
        self.set_draw_color(21, 101, 192)
        self.rect(x, y, w, 30, 'DF')
        self.set_fill_color(21, 101, 192)
        self.rect(x, y, 3, 30, 'F')
        self.set_xy(x + 10, y + 8)
        self.set_text_color(33, 33, 33)
        self.multi_cell(w - 20, 7, text)
        self.set_y(y + 34)

    def bold_text(self, text):
        self.set_font('gothic', 'B', 10.5)
        self.set_text_color(21, 101, 192)
        self.multi_cell(0, 6.5, text)
        self.set_font('gothic', '', 10.5)
        self.set_text_color(33, 33, 33)
        self.ln(1)

    def add_table(self, headers, data, col_widths=None):
        w = self.w - self.l_margin - self.r_margin
        if col_widths is None:
            cw = w / len(headers)
            col_widths = [cw] * len(headers)
        self.set_font('gothic', 'B', 9.5)
        self.set_fill_color(227, 242, 253)
        self.set_text_color(21, 101, 192)
        self.set_draw_color(187, 222, 251)
        for i, h in enumerate(headers):
            self.cell(col_widths[i], 8, h, 1, 0, 'L', True)
        self.ln()
        self.set_font('gothic', '', 9.5)
        self.set_text_color(33, 33, 33)
        self.set_draw_color(224, 224, 224)
        for ri, row in enumerate(data):
            fill = ri % 2 == 1
            if fill:
                self.set_fill_color(250, 250, 250)
            for i, cell in enumerate(row):
                self.cell(col_widths[i], 8, str(cell)[:60], 1, 0, 'L', fill)
            self.ln()
        self.ln(4)

    def check_break(self, h=40):
        if self.get_y() + h > self.h - 25:
            self.add_page()

font_path = 'C:/Windows/Fonts/malgun.ttf'
bold_path = 'C:/Windows/Fonts/malgunbd.ttf'

pdf = PDF('P', 'mm', 'A4')
pdf.set_auto_page_break(auto=True, margin=20)
pdf.add_font('gothic', '', font_path, uni=True)
pdf.add_font('gothic', 'B', bold_path, uni=True)

w = 210 - 20 - 20  # A4 width minus margins
cw2 = [w*0.3, w*0.7]

# ===== PAGE 1: TITLE =====
pdf.add_page()
pdf.ln(30)
pdf.set_font('gothic', '', 11)
pdf.set_text_color(100, 100, 100)
pdf.cell(0, 6, '2026\ub144 6\uc6d4 \uc2e0\uc548\uad70\uc218 \uc120\uac70 \uc815\ucc45 \uc81c\uc548\uc11c', align='C')
pdf.ln(20)
pdf.set_font('gothic', 'B', 28)
pdf.set_text_color(21, 101, 192)
pdf.cell(0, 14, '\uc2e0\uc548 \ub9c8\ucf13\uc5f0\uae08', align='C')
pdf.ln(14)
pdf.cell(0, 14, '\uc815\ucc45 \uc81c\uc548\uc11c', align='C')
pdf.ln(20)
pdf.set_font('gothic', '', 12)
pdf.set_text_color(80, 80, 80)
pdf.cell(0, 7, '\ubc15\uc6b0\ub7c9 \uc804 \uc2e0\uc548\uad70\uc218\ub2d8\uaed8 \ub4dc\ub9ac\ub294', align='C')
pdf.ln(7)
pdf.cell(0, 7, '\ud587\ube5b\xb7\ubc14\ub78c\uc5f0\uae08\uc5d0 \uc774\uc740 \uc138 \ubc88\uc9f8 \uae30\ubcf8\uc18c\ub4dd \uc7ac\uc6d0 \ubaa8\ub378 \uc81c\uc548', align='C')
pdf.ln(25)
pdf.quote_box('"\ud587\ube5b\uc774 \uc8fc\ubbfc \uac83\uc774 \ub418\uace0, \ubc14\ub78c\uc774 \uc8fc\ubbfc \uac83\uc774 \ub418\uc5c8\uc2b5\ub2c8\ub2e4.\n\uc774\uc81c \uc628\ub77c\uc778 \uc2dc\uc7a5\ub3c4 \uc8fc\ubbfc \uac83\uc774 \ub420 \ucc28\ub840\uc785\ub2c8\ub2e4."')
pdf.ln(30)
pdf.set_font('gothic', '', 10)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 6, '2026\ub144 4\uc6d4 | \uc2e0\uc548 \ub9c8\ucf13\uc5f0\uae08 \ucd94\uc9c4 \uc900\ube44\uc704', align='C')
pdf.ln(8)
pdf.cell(0, 6, '\uc81c\uc548\uc790: \uc7a5\uacbd\uc218 | 010-4250-6116', align='C')

# ===== PAGE 2: Background =====
pdf.add_page()
pdf.section_title('1. \uc81c\uc548 \ubc30\uacbd \u2014 \uc2e0\uc548\uc774 \ub9cc\ub4e4\uc5b4\uc628 \uc5ed\uc0ac')
pdf.body_text('\ubc15\uc6b0\ub7c9 \uc804 \uad70\uc218\ub2d8\uc740 \uc7ac\uc784 \uae30\uac04 \ub3d9\uc548 \uc804\uad6d \uc5b4\ub514\uc5d0\ub3c4 \uc5c6\ub358 \uc77c\uc744 \ud574\ub0c8\uc2b5\ub2c8\ub2e4.')
pdf.bold_text('  \u00b7 2018\ub144: \uc804\uad6d \ucd5c\ucd08 \uc2e0\uc7ac\uc0dd\uc5d0\ub108\uc9c0 \uac1c\ubc1c\uc774\uc775 \uacf5\uc720\uc81c(\ud587\ube5b\uc5f0\uae08) \uc870\ub840 \uc81c\uc815')
pdf.bold_text('  \u00b7 2022\ub144: \ubc14\ub78c\uc5f0\uae08\uc73c\ub85c \ud655\ub300 \uc801\uc6a9')
pdf.bold_text('  \u00b7 \uacb0\uacfc: \uc804\uad6d 228\uac1c \uc9c0\uc790\uccb4 \ubca4\uce58\ub9c8\ud0b9, \ub300\ud1b5\ub839 \uacf5\uac1c \uce6d\ucc2c')
pdf.ln(2)
pdf.body_text('\uc774\uc81c 2026\ub144 \uad70\uc218 \uc120\uac70\uc5d0\uc11c, \uc138 \ubc88\uc9f8 \uc774\uc57c\uae30\ub97c \uc4f8 \uc2dc\uac04\uc785\ub2c8\ub2e4.')

pdf.ln(6)
pdf.section_title('2. \uc654 \'\ub9c8\ucf13\uc5f0\uae08\'\uc778\uac00? \u2014 \uc774\ub860\uc801 \uadfc\uac70')
pdf.sub_title('\uc624\uc2a4\ud2b8\ub86c\uc758 \uacf5\uc720 \uc790\uc6d0 \uc774\ub860 \u2014 \uc138 \ubc88\uc9f8 \uc801\uc6a9')
pdf.quote_box('"\uacf5\uc720 \uc790\uc6d0\uc740 \uc815\ubd80\uc758 \ub3c5\uc810\ub3c4, \uae30\uc5c5\uc758 \uc0ac\uc720\ud654\ub3c4 \uc544\ub2cc\n\uc8fc\ubbfc \uacf5\ub3d9\uccb4\uc758 \uc790\uce58 \uad00\ub9ac\ub85c \uc9c0\uc18d \uac00\ub2a5\ud574\uc9c4\ub2e4."')

pdf.ln(2)
cw5 = [w*0.12, w*0.13, w*0.22, w*0.30, w*0.23]
pdf.add_table(
    ['\uad6c\ubd84', '\uacf5\uc720 \uc790\uc6d0', '\ubb38\uc81c', '\ud574\uacb0\ucc45', '\ud604\ud669'],
    [
        ['\ud587\ube5b\uc5f0\uae08', '\ud0dc\uc591\uad11', '\uc678\uc9c0 \uae30\uc5c5 \ub3c5\uc2dd', '\uc8fc\ubbfc \ud611\ub3d9\uc870\ud569 + \uc774\uc775 \ubc30\ubd84', '\u2705 \uc804\uad6d \ubaa8\ub378'],
        ['\ubc14\ub78c\uc5f0\uae08', '\ud48d\ub825', '\ub3d9\uc77c \ubb38\uc81c', '\ub3d9\uc77c \uc6d0\uce59 \ud655\ub300', '\u2705 \uc131\uacf5 \uc6b4\uc601'],
        ['\ub9c8\ucf13\uc5f0\uae08', '\uc628\ub77c\uc778 \uc2dc\uc7a5', '\ucfe0\ud321\xb7\ub124\uc774\ubc84 \ub3c5\uc2dd', '\uc8fc\ubbfc \uc9c1\uac70\ub798 + \uc774\uc775 \ubc30\ubd84', '\ud83d\udd1c \uc81c\uc548'],
    ],
    cw5
)

pdf.body_text('\uc2e0\uc548\uad70 1,004\uac1c \uc12c \uc8fc\ubbfc\ub4e4\uc774 \ud0a4\uc6b0\uace0 \uc7a1\uc740 \ub18d\uc218\uc0b0\ubb3c. \uadf8 \ud310\ub9e4 \uc218\uc775\uc774 \uc9c0\uae08 \uc5b4\ub514\ub85c \uac11\ub2c8\uae4c?')
pdf.bold_text('\ucfe0\ud321\uc740 10~15%, \ub124\uc774\ubc84 \uc2a4\ub9c8\ud2b8\uc2a4\ud1a0\uc5b4\ub294 5~7%\ub97c \uac00\uc838\uac11\ub2c8\ub2e4.')
pdf.bold_text('\uc628\ub77c\uc778 \uc2dc\uc7a5\uc740 \uc2e0\uc548\uad70 \uc8fc\ubbfc\ub4e4\uc758 \uacf5\uc720 \uc790\uc6d0\uc785\ub2c8\ub2e4. \uadf8 \uc774\uc775\uc774 \uc8fc\ubbfc\uc5d0\uac8c \ub3cc\uc544\uc640\uc57c \ud569\ub2c8\ub2e4.')

# ===== PAGE 3: What is Market Pension =====
pdf.add_page()
pdf.section_title('3. \ub9c8\ucf13\uc5f0\uae08\uc774\ub780 \ubb34\uc5c7\uc778\uac00?')
pdf.quote_box('\uc2e0\uc548\uad70 \uc8fc\ubbfc\uc774 \uc0dd\uc0b0\ud55c \ub18d\uc218\uc0b0\ubb3c\uc744 \uad70 \uc9c1\uc601 \uc628\ub77c\uc778 \ud50c\ub7ab\ud3fc\uc73c\ub85c \uc9c1\uc811 \ud310\ub9e4\ud558\uace0,\n\uadf8 \ud310\ub9e4 \uc218\uc775\uc758 \uc77c\ubd80\ub97c \uc804\uccb4 \uc8fc\ubbfc \uae30\ubcf8\uc18c\ub4dd(\ub9c8\ucf13\uc5f0\uae08)\uc73c\ub85c \ubc30\ubd84\ud558\ub294 \uc81c\ub3c4')

pdf.ln(2)
pdf.sub_title('\uc218\uc775 \ubc30\ubd84 \uc124\uacc4\uc548')
cw3 = [w*0.45, w*0.12, w*0.43]
pdf.add_table(
    ['\ud56d\ubaa9', '\ube44\uc728', '\uc124\uba85'],
    [
        ['\uc0dd\uc0b0 \uc8fc\ubbfc \uc9c1\uc811 \uc18c\ub4dd', '80%', '\uc911\uac04 \uc720\ud1b5 \uc5c6\uc774 \uc8fc\ubbfc\uc5d0\uac8c \uc9c1\uc811'],
        ['\ubb3c\ub958\ube44', '8%', '\ub3c4\uc11c \uc9c0\uc5ed \ubc30\uc1a1 \uc9c0\uc6d0 \ud3ec\ud568'],
        ['\ud50c\ub7ab\ud3fc \uc6b4\uc601\ube44', '5%', '\uc571 \uc6b4\uc601\xb7\uc720\uc9c0\ubcf4\uc218'],
        ['\ub9c8\ucf13\uc5f0\uae08 \uacf5\uc775\uae30\uae08', '7%', '\uace0\ub839\xb7\ucde8\uc57d 4% + \uacf5\ub3d9\uccb4 3%'],
    ],
    cw3
)

pdf.ln(4)
pdf.section_title('4. \uace0\ud5a5\ub9c8\ucf13 \u2014 AI\uac00 \ub514\uc9c0\ud138 \ubb38\ud131\uc744 \uc5c6\uc560\ub2e4')
pdf.bold_text('"\uc0ac\uc9c4 \ud55c \uc7a5\uc774\uba74 \ub429\ub2c8\ub2e4"')
pdf.body_text('[1\ub2e8\uacc4] \ud560\uba38\ub2c8\uac00 \uc2a4\ub9c8\ud2b8\ud3f0\uc73c\ub85c \ucc9c\uc77c\uc5fc \uc0ac\uc9c4\uc744 \ucc0d\uc2b5\ub2c8\ub2e4')
pdf.body_text('[2\ub2e8\uacc4] AI\uac00 \uc790\ub3d9 \ubd84\uc11d (3\ucd08) \u2192 \uc0c1\ud488\uba85, \uc124\uba85, \uac00\uaca9 \uc790\ub3d9 \uc0dd\uc131')
pdf.body_text('[3\ub2e8\uacc4] [\ub4f1\ub85d] \ubc84\ud2bc\ub9cc \ub204\ub974\uba74 \ub05d! \u2192 \uc804\uad6d \uc5b4\ub514\uc11c\ub098 \uc8fc\ubb38 \uac00\ub2a5!')

pdf.ln(4)
pdf.sub_title('\ucfe0\ud321\uacfc \ubb34\uc5c7\uc774 \ub2e4\ub978\uac00?')
cw4 = [w*0.2, w*0.4, w*0.4]
pdf.add_table(
    ['\uad6c\ubd84', '\ucfe0\ud321/\ub124\uc774\ubc84', '\uace0\ud5a5\ub9c8\ucf13'],
    [
        ['\uc218\uc218\ub8cc', '10~15%', '5% (\ub098\uba38\uc9c0 \uc8fc\ubbfc \ud658\uc6d0)'],
        ['\uc0c1\ud488 \ub4f1\ub85d', '\ubcf5\uc7a1 (30\ubd84)', '\uc0ac\uc9c4 \ud55c \uc7a5 (3\ubd84)'],
        ['\ud310\ub9e4\uc790-\uad6c\ub9e4\uc790', '\uc18c\ud1b5 \ucc28\ub2e8', '\uc9c1\uc811 \uc804\ud654\xb7\ucc44\ud305'],
        ['AI \ud65c\uc6a9', '\ud6a8\uc728 (\ube60\ub978 \ubc30\uc1a1)', '\uc0ac\ub78c (\ub514\uc9c0\ud138 \uc18c\uc678 \ud574\uc18c)'],
        ['\uc218\uc775 \uadc0\uc18d', '\ub300\uae30\uc5c5', '\uc8fc\ubbfc (\ub9c8\ucf13\uc5f0\uae08)'],
    ],
    cw4
)

# ===== PAGE 4: 5 Reasons =====
pdf.add_page()
pdf.section_title('5. \uc120\uac70 \uacf5\uc57d\uc73c\ub85c \ucc44\ud0dd\ud574\uc57c \ud558\ub294 5\uac00\uc9c0 \uc774\uc720')

reasons = [
    ('\uc774\uc720 1: \uac80\uc99d\ub41c \ubc15\uc6b0\ub7c9 \ucca0\ud559\uc758 \ud655\uc7a5',
     '\ud587\ube5b\xb7\ubc14\ub78c\uc5f0\uae08\uacfc \ub3d9\uc77c\ud55c \uc6d0\uce59\uc758 \uc138 \ubc88\uc9f8 \uc801\uc6a9. \uc0c8\ub85c\uc6b4 \uc2e4\ud5d8\uc774 \uc544\ub2d9\ub2c8\ub2e4.\n\uc8fc\ubbfc\ub4e4\uc740 "\ub610 \ubc15\uc6b0\ub7c9\uc774 \ud574\ub0c8\ub2e4"\uace0 \ubc18\uc751\ud560 \uac83\uc785\ub2c8\ub2e4.'),
    ('\uc774\uc720 2: \ub514\uc9c0\ud138 \uaca9\ucc28 \ud574\uc18c \u2014 \uc2dc\ub300\uc801 \uc0ac\uba85',
     '\uc12c \uc8fc\ubbfc\ub4e4\uc774 \uc628\ub77c\uc778 \ud310\ub9e4\uc5d0\uc11c \uc18c\uc678\ub418\uc9c0 \uc54a\ub3c4\ub85d \uc0ac\uc9c4 \ud55c \uc7a5\uc73c\ub85c \ub4f1\ub85d \uac00\ub2a5.\n"\ub514\uc9c0\ud138\uc5d0\uc11c\ub3c4 \uc18c\uc678\ub418\uc9c0 \uc54a\ub294 \uc2e0\uc548"\uc740 \uac15\ub825\ud55c \uc120\uac70 \uba54\uc2dc\uc9c0\uc785\ub2c8\ub2e4.'),
    ('\uc774\uc720 3: \uc778\uad6c \uc18c\uba78 \uc704\uae30 \ub300\uc751',
     '\uc628\ub77c\uc778 \ud310\ub9e4 \uc18c\ub4dd\uc774 \uc0dd\uae30\uba74 \uc12c\uc5d0 \ub0a8\uc744 \uc774\uc720\uac00 \uc0dd\uae41\ub2c8\ub2e4.\n"\uc12c\uc5d0\uc11c \uba39\uace0 \uc0b4 \uc218 \uc788\ub2e4"\ub294 \ud76c\ub9dd\uc774 \uac00\uc7a5 \uac15\ub825\ud55c \uadc0\ub18d \uc720\uc778\uc785\ub2c8\ub2e4.'),
    ('\uc774\uc720 4: \ud589\uc815\xb7\uc815\uce58\uc801 \uc2e4\ud604 \uac00\ub2a5\uc131 \ub192\uc74c',
     '\uc774\uc775\uacf5\uc720 \uc870\ub840 \uc131\uacf5\uc73c\ub85c \uc8fc\ubbfc\xb7\uc758\ud68c \uc124\ub4dd \uae30\ubc18 \uc644\ube44.\n\ub18d\uc2dd\ud488\ubd80\xb7\ud589\uc548\ubd80 \uad6d\ube44 \uc5f0\uacc4 \uac00\ub2a5. \ud611\ub3d9\uc870\ud569 \uc124\ub9bd 3\uac1c\uc6d4 \uac00\ub2a5.'),
    ('\uc774\uc720 5: \uc804\uad6d 3\ud638 \ud601\uc2e0 \uc0ac\ub840',
     '\ud587\ube5b\uc5f0\uae08(1\ud638) \u2192 \ubc14\ub78c\uc5f0\uae08(2\ud638) \u2192 \ub9c8\ucf13\uc5f0\uae08(3\ud638)\n\uc2e0\uc548\uad70\uc744 \ub2e4\uc2dc \uc804\uad6d \uc5b8\ub860 \uc911\uc2ec\uc5d0 \uc62c\ub824\ub193\uace0, \ubc15\uc6b0\ub7c9 \uc804 \uad70\uc218\uc758 \uc815\uce58 \ube0c\ub79c\ub4dc\ub97c \uac15\ud654\ud569\ub2c8\ub2e4.'),
]
for title, body in reasons:
    pdf.check_break(35)
    pdf.sub_title(title)
    pdf.body_text(body)
    pdf.ln(2)

# ===== PAGE 5: Plan + Budget =====
pdf.add_page()
pdf.section_title('6. \ub2e8\uacc4\ubcc4 \uc2e4\ud589 \uacc4\ud68d')
cw6 = [w*0.15, w*0.25, w*0.60]
pdf.add_table(
    ['\ub2e8\uacc4', '\uc2dc\uae30', '\ub0b4\uc6a9'],
    [
        ['\uacf5\uc57d \ubc1c\ud45c', '\uc120\uac70 \uae30\uac04', '"\ub2f9\uc120 \uc2dc \ub9c8\ucf13\uc5f0\uae08 \ud611\ub3d9\uc870\ud569 \uc124\ub9bd" \uacf5\uc57d'],
        ['1\ub2e8\uacc4', '\ub2f9\uc120 \ud6c4 1~3\uac1c\uc6d4', '\ud611\ub3d9\uc870\ud569 \ubc95\uc778 \uc124\ub9bd, \uace0\ud5a5\ub9c8\ucf13 \uc571 MVP'],
        ['2\ub2e8\uacc4', '4~12\uac1c\uc6d4', '\ucc38\uc5ec \uc0dd\uc0b0\uc790 100\uba85, \uc6d4 \uac70\ub798\uc561 5,000\ub9cc \uc6d0'],
        ['3\ub2e8\uacc4', '1~2\ub144', '\uc804\ub0a8\ub3c4 \ud655\uc0b0, \uc804\uad6d 113\uac1c \uad70 \ubaa8\ub378 \uc218\ucd9c'],
        ['\ucd5c\uc885', '2~3\ub144', '\ub9c8\ucf13\uc5f0\uae08 \u2192 \uc2e0\uc548\ud615 \uae30\ubcf8\uc18c\ub4dd 3\ub300 \uc7ac\uc6d0 \uc644\uc131'],
    ],
    cw6
)

pdf.ln(4)
pdf.section_title('7. \uc608\uc0b0 \uacc4\ud68d')
cw7 = [w*0.35, w*0.25, w*0.40]
pdf.add_table(
    ['\ud56d\ubaa9', '1\ub144\ucc28', '\ube44\uace0'],
    [
        ['\uc571 \uac1c\ubc1c\xb7\uace0\ub3c4\ud654', '2,000\ub9cc\uc6d0', '\ud575\uc2ec \uae30\ub2a5 + AI \uace0\ub3c4\ud654'],
        ['AI API \ube44\uc6a9', '500\ub9cc\uc6d0', 'OpenAI \uc0ac\uc6a9\ub8cc'],
        ['\uc11c\ubc84\xb7\uc778\ud504\ub77c', '300\ub9cc\uc6d0', 'Firebase \ud074\ub77c\uc6b0\ub4dc'],
        ['\ub18d\uc5b4\ubbfc \uad50\uc721', '800\ub9cc\uc6d0', '\ucc3e\uc544\uac00\ub294 \uc2a4\ub9c8\ud2b8\ud3f0 \uad50\uc721 (10\ud68c)'],
        ['\ub9c8\ucf00\ud305\xb7\ud64d\ubcf4', '700\ub9cc\uc6d0', '\uc628\ub77c\uc778 \uad11\uace0 + \uc9c0\uc5ed \ud64d\ubcf4'],
        ['\uc6b4\uc601\ube44', '700\ub9cc\uc6d0', '\ub9c8\uc744\ud65c\ub3d9\uac00 \uc778\uac74\ube44'],
        ['\ud569\uacc4', '5,000\ub9cc\uc6d0', '\uad6d\ube44 \uc5f0\uacc4 \uc2dc \uad70\ube44 \ubd80\ub2f4 \ucd5c\uc18c\ud654'],
    ],
    cw7
)

pdf.ln(4)
pdf.section_title('8. \uae30\ub300 \ud6a8\uacfc')
pdf.add_table(
    ['\ud6a8\uacfc', '\ub0b4\uc6a9'],
    [
        ['\uc8fc\ubbfc \uc18c\ub4dd \uc99d\uac00', '\uc720\ud1b5 \uc218\uc218\ub8cc \uc808\uac10\uc73c\ub85c \ud310\ub9e4 \uc218\uc775 20~30% \uc99d\uac00'],
        ['\uae30\ubcf8\uc18c\ub4dd \uc7ac\uc6d0', '\ud587\ube5b\xb7\ubc14\ub78c\uc5d0 \uc774\uc5b4 3\ub300 \uc7ac\uc6d0 \uc644\uc131'],
        ['\uc778\uad6c \uc720\uc785', '\uc628\ub77c\uc778 \uc18c\ub4dd \ucc3d\ucd9c\ub85c \uccad\ub144 \uadc0\ub18d\xb7\uadc0\ub3c4 \uc720\uc778'],
        ['\uc804\uad6d \ube0c\ub79c\ub4dc', '\uc2e0\uc548\uad70 3\ubc88\uc9f8 \ud601\uc2e0 \ubaa8\ub378 \uc804\uad6d \uc5b8\ub860 \uc8fc\ubaa9'],
        ['\uad6d\ube44 \uc5f0\uacc4', '\ub18d\uc2dd\ud488\ubd80\xb7\ud589\uc548\ubd80 \uc9c0\uc6d0\uc0ac\uc5c5 \uc7ac\uc815 \ud655\ubcf4'],
    ],
    cw2
)

# ===== FINAL PAGE: Conclusion =====
pdf.add_page()
pdf.ln(20)
pdf.set_font('gothic', 'B', 18)
pdf.set_text_color(21, 101, 192)
pdf.cell(0, 12, '"\ubc15\uc6b0\ub7c9\uc774 \ub3cc\uc544\uc624\uba74,', align='C')
pdf.ln(12)
pdf.cell(0, 12, '\uc2e0\uc548\uc758 \ubc14\ub2e4\ub3c4, \ub545\ub3c4, \uc628\ub77c\uc778\ub3c4', align='C')
pdf.ln(12)
pdf.cell(0, 12, '\ubaa8\ub450 \uc8fc\ubbfc \uac83\uc774 \ub429\ub2c8\ub2e4."', align='C')

pdf.ln(24)
pdf.set_font('gothic', '', 13)
pdf.set_text_color(80, 80, 80)
pdf.cell(0, 9, '\u2600 \ud587\ube5b\uc740 \uc8fc\ubbfc \uac83\uc774 \ub418\uc5c8\uc2b5\ub2c8\ub2e4.', align='C')
pdf.ln(9)
pdf.cell(0, 9, '\ud83c\udf2c \ubc14\ub78c\uc740 \uc8fc\ubbfc \uac83\uc774 \ub418\uc5c8\uc2b5\ub2c8\ub2e4.', align='C')
pdf.ln(12)
pdf.set_font('gothic', 'B', 14)
pdf.set_text_color(21, 101, 192)
pdf.cell(0, 9, '\ud83d\uded2 \uc774\uc81c \uc628\ub77c\uc778 \uc2dc\uc7a5\ub3c4 \uc8fc\ubbfc \uac83\uc73c\ub85c \ub9cc\ub4e4\uaca0\uc2b5\ub2c8\ub2e4.', align='C')

pdf.ln(20)
pdf.set_font('gothic', '', 11)
pdf.set_text_color(100, 100, 100)
pdf.cell(0, 7, '"\uc790\ub9bd\uc758 \ubcf5\uc9c0 \u2014 \ubc15\uc6b0\ub7c9 \uc804 \uad70\uc218\uc758 \ucca0\ud559\uc740 \uc544\uc9c1 \uc644\uc131\ub418\uc9c0 \uc54a\uc558\uc2b5\ub2c8\ub2e4.', align='C')
pdf.ln(7)
pdf.cell(0, 7, '\ub9c8\ucf13\uc5f0\uae08\uc774 \uadf8 \ub9c8\uc9c0\ub9c9 \ud37c\uc990 \uc870\uac01\uc785\ub2c8\ub2e4."', align='C')

pdf.ln(30)
pdf.set_draw_color(200, 200, 200)
pdf.line(pdf.l_margin, pdf.get_y(), pdf.w - pdf.r_margin, pdf.get_y())
pdf.ln(8)
pdf.set_font('gothic', '', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, '2026\ub144 4\uc6d4 | \uc2e0\uc548 \ub9c8\ucf13\uc5f0\uae08 \ucd94\uc9c4 \uc900\ube44\uc704', align='C')
pdf.ln(5)
pdf.cell(0, 5, '\uc81c\uc548\uc790: \uc7a5\uacbd\uc218 | 010-4250-6116 | nanoset@naver.com', align='C')

output = os.path.join(os.path.dirname(__file__), '\uc815\ucc45\uc81c\uc548\uc11c_\uc2e0\uc548_\ub9c8\ucf13\uc5f0\uae08_v2.pdf')
pdf.output(output)
print(f'PDF \uc0dd\uc131 \uc644\ub8cc: {output}')
print(f'\ud398\uc774\uc9c0 \uc218: {pdf.page_no()}')
