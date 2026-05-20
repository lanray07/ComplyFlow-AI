from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "AppStoreConnect" / "screenshots"
ZIP_PATH = ROOT / "AppStoreConnect" / "ComplyFlowAI-AppStore-Screenshots.zip"

PHONE_SIZES = {
    "iphone-6_5": (1284, 2778),
    "iphone-6_9": (1290, 2796),
}

IPAD_SIZES = {
    "ipad-13": (2064, 2752),
    "ipad-12_9": (2048, 2732),
}

SCREENS = [
    ("01-dashboard", "Dashboard"),
    ("02-inspection", "Inspection"),
    ("03-ai-analysis", "AI Analysis"),
    ("04-sop-generator", "SOP Generator"),
    ("05-incident-report", "Incident Report"),
    ("06-audit-readiness", "Audit Readiness"),
    ("07-reminders", "Reminders"),
    ("08-reports", "Reports"),
    ("09-business-profile", "Business Profile"),
    ("10-paywall", "Subscriptions"),
]

COLORS = {
    "bg": "#F6F8FB",
    "surface": "#FFFFFF",
    "surface2": "#F8FAFC",
    "line": "#D9E2EF",
    "text": "#0F172A",
    "muted": "#64748B",
    "blue": "#2563EB",
    "blue2": "#DBEAFE",
    "cyan": "#0EA5E9",
    "green": "#0F766E",
    "green2": "#DCFCE7",
    "amber": "#D97706",
    "amber2": "#FEF3C7",
    "red": "#DC2626",
    "red2": "#FEE2E2",
    "charcoal": "#111827",
    "dark": "#0B1220",
    "purple": "#7C3AED",
    "purple2": "#EDE9FE",
}


def font_path(name):
    candidate = Path("C:/Windows/Fonts") / name
    return str(candidate) if candidate.exists() else None


def load_font(size, weight="regular"):
    names = {
        "regular": "segoeui.ttf",
        "semibold": "seguisb.ttf",
        "bold": "segoeuib.ttf",
    }
    path = font_path(names.get(weight, "segoeui.ttf"))
    if path:
        return ImageFont.truetype(path, size)
    return ImageFont.load_default()


class Canvas:
    def __init__(self, width, height, kind):
        self.w = width
        self.h = height
        self.kind = kind
        self.scale = min(width / (1284 if kind == "phone" else 2048), height / (2778 if kind == "phone" else 2732))
        self.img = Image.new("RGB", (width, height), COLORS["bg"])
        self.d = ImageDraw.Draw(self.img)

    def s(self, value):
        return int(round(value * self.scale))

    def f(self, size, weight="regular"):
        return load_font(max(8, self.s(size)), weight)

    def text(self, xy, value, size=34, fill=None, weight="regular", anchor=None):
        self.d.text(xy, value, font=self.f(size, weight), fill=fill or COLORS["text"], anchor=anchor)

    def text_box(self, xy, value, max_width, size=34, fill=None, weight="regular", line_gap=10, max_lines=None):
        x, y = xy
        lines = wrap_text(self.d, value, self.f(size, weight), max_width)
        if max_lines:
            lines = lines[:max_lines]
            if len(wrap_text(self.d, value, self.f(size, weight), max_width)) > max_lines:
                lines[-1] = trim_to_width(self.d, lines[-1] + "...", self.f(size, weight), max_width)
        for line in lines:
            self.text((x, y), line, size, fill, weight)
            y += self.s(size + line_gap)
        return y

    def rect(self, box, radius=24, fill=None, outline=None, width=1):
        x0, y0, x1, y1 = box
        clamped_radius = min(self.s(radius), abs(x1 - x0) // 2, abs(y1 - y0) // 2)
        self.d.rounded_rectangle(box, radius=clamped_radius, fill=fill, outline=outline, width=max(1, self.s(width)))

    def line(self, points, fill=None, width=4):
        self.d.line(points, fill=fill or COLORS["line"], width=max(1, self.s(width)))

    def pill(self, box, value, fill, text_fill=None, size=24, weight="semibold"):
        self.rect(box, radius=999, fill=fill)
        self.center_text(box, value, size, text_fill or COLORS["text"], weight)

    def center_text(self, box, value, size=30, fill=None, weight="regular"):
        font = self.f(size, weight)
        bbox = self.d.textbbox((0, 0), value, font=font)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        x = box[0] + (box[2] - box[0] - tw) / 2
        y = box[1] + (box[3] - box[1] - th) / 2 - self.s(2)
        self.d.text((x, y), value, font=font, fill=fill or COLORS["text"])


def wrap_text(draw, text, font, max_width):
    words = text.split()
    lines = []
    current = ""
    for word in words:
        test = word if not current else f"{current} {word}"
        if draw.textbbox((0, 0), test, font=font)[2] <= max_width:
            current = test
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def trim_to_width(draw, text, font, max_width):
    while text and draw.textbbox((0, 0), text, font=font)[2] > max_width:
        text = text[:-4] + "..."
    return text


def card(c, x, y, w, h, fill=None, outline=None, radius=28):
    c.rect((x, y, x + w, y + h), radius=radius, fill=fill or COLORS["surface"], outline=outline or COLORS["line"], width=2)


def status_bar(c):
    h = c.s(96)
    c.text((c.s(64), c.s(34)), "9:41", 28, weight="semibold")
    x = c.w - c.s(204)
    for i, bar_h in enumerate([16, 22, 28, 34]):
        c.rect((x + c.s(i * 18), c.s(58 - bar_h), x + c.s(i * 18 + 11), c.s(58)), 3, COLORS["text"])
    c.rect((c.w - c.s(108), c.s(31), c.w - c.s(44), c.s(57)), 12, None, COLORS["text"], 4)
    c.rect((c.w - c.s(100), c.s(37), c.w - c.s(62), c.s(51)), 7, COLORS["text"])
    c.rect((c.w - c.s(39), c.s(40), c.w - c.s(31), c.s(49)), 3, COLORS["text"])
    return h


def phone_shell(c, title, subtitle, badge=None):
    c.text((c.s(64), c.s(76)), "ComplyFlow AI", 36, weight="bold")
    c.pill((c.w - c.s(282), c.s(70), c.w - c.s(64), c.s(120)), "Mock AI On", COLORS["blue2"], COLORS["blue"], 22)
    y = c.s(168)
    if badge:
        c.pill((c.s(64), y, c.s(64 + 240), y + c.s(46)), badge, COLORS["surface"], COLORS["blue"], 20)
        y += c.s(78)
    c.text((c.s(64), y), title, 56, weight="bold")
    y = c.text_box((c.s(64), y + c.s(76)), subtitle, c.w - c.s(128), 30, COLORS["muted"], max_lines=2)
    return y + c.s(34), c.h - c.s(180)


def tab_bar(c, selected):
    h = c.s(160)
    y = c.h - h
    c.rect((0, y, c.w, c.h), 0, COLORS["surface"], COLORS["line"], 1)
    items = [("Home", "H"), ("Work", "W"), ("AI", "A"), ("Reports", "R")]
    step = c.w / len(items)
    for idx, (label, icon) in enumerate(items):
        cx = int(step * idx + step / 2)
        selected_item = label == selected
        color = COLORS["blue"] if selected_item else COLORS["muted"]
        c.rect((cx - c.s(26), y + c.s(30), cx + c.s(26), y + c.s(82)), 16, COLORS["blue2"] if selected_item else COLORS["surface2"])
        c.center_text((cx - c.s(26), y + c.s(30), cx + c.s(26), y + c.s(82)), icon, 22, color, "bold")
        c.text((cx, y + c.s(96)), label, 20, color, "semibold" if selected_item else "regular", anchor="ma")


def metric(c, x, y, w, h, value, label, color):
    card(c, x, y, w, h)
    c.text((x + c.s(26), y + c.s(26)), value, 42, color, "bold")
    c.text_box((x + c.s(26), y + c.s(86)), label, w - c.s(52), 22, COLORS["muted"], max_lines=2)


def row(c, x, y, w, title, detail, status=None, color=None):
    card(c, x, y, w, c.s(118), COLORS["surface"])
    c.text((x + c.s(28), y + c.s(25)), title, 28, weight="semibold")
    c.text((x + c.s(28), y + c.s(68)), detail, 22, COLORS["muted"])
    if status:
        c.pill((x + w - c.s(190), y + c.s(34), x + w - c.s(26), y + c.s(78)), status, color or COLORS["blue2"], COLORS["text"], 20)


def check_row(c, x, y, text, state="pass"):
    colors = {
        "pass": (COLORS["green2"], COLORS["green"], "PASS"),
        "fail": (COLORS["red2"], COLORS["red"], "FAIL"),
        "warn": (COLORS["amber2"], COLORS["amber"], "WATCH"),
    }
    fill, color, label = colors[state]
    c.pill((x, y, x + c.s(104), y + c.s(42)), label, fill, color, 18)
    c.text((x + c.s(126), y + c.s(4)), text, 24, COLORS["text"], "semibold")


def draw_dashboard_phone(c):
    y, bottom = phone_shell(c, "Field-ready compliance dashboard", "Track inspections, incidents, audit readiness and recurring safety work in one fast mobile view.", "Dashboard")
    card(c, c.s(64), y, c.w - c.s(128), c.s(330), COLORS["dark"], None)
    c.text((c.s(104), y + c.s(42)), "Audit readiness", 30, "#E2E8F0", "semibold")
    c.text((c.s(104), y + c.s(102)), "86%", 88, "#FFFFFF", "bold")
    c.text((c.s(104), y + c.s(214)), "Ready for routine operational checks", 26, "#CBD5E1")
    c.rect((c.s(104), y + c.s(268), c.w - c.s(104), y + c.s(292)), 12, "#1E293B")
    c.rect((c.s(104), y + c.s(268), c.s(104 + 870), y + c.s(292)), 12, COLORS["cyan"])
    y += c.s(374)
    gap = c.s(18)
    w = (c.w - c.s(128) - gap) // 2
    metric(c, c.s(64), y, w, c.s(156), "7", "Upcoming inspections", COLORS["blue"])
    metric(c, c.s(64) + w + gap, y, w, c.s(156), "2", "Overdue tasks", COLORS["red"])
    y += c.s(188)
    metric(c, c.s(64), y, w, c.s(156), "3", "Open incidents", COLORS["amber"])
    metric(c, c.s(64) + w + gap, y, w, c.s(156), "12", "Recent reports", COLORS["green"])
    y += c.s(202)
    c.text((c.s(64), y), "Quick actions", 34, weight="bold")
    y += c.s(58)
    actions = [("New Inspection", COLORS["blue2"], COLORS["blue"]), ("Generate SOP", COLORS["green2"], COLORS["green"]), ("Report Incident", COLORS["red2"], COLORS["red"]), ("New Audit", COLORS["purple2"], COLORS["purple"])]
    for idx, (name, fill, color) in enumerate(actions):
        ax = c.s(64) + (idx % 2) * (w + gap)
        ay = y + (idx // 2) * c.s(116)
        card(c, ax, ay, w, c.s(92), fill, None, 22)
        c.center_text((ax, ay, ax + w, ay + c.s(92)), name, 23, color, "semibold")
    tab_bar(c, "Home")


def draw_inspection_phone(c):
    y, bottom = phone_shell(c, "Document inspections with evidence", "Create field checklists, add photos, dictate notes and flag risk levels before the team leaves site.", "Inspection")
    card(c, c.s(64), y, c.w - c.s(128), c.s(182))
    c.text((c.s(100), y + c.s(34)), "Site Inspection", 38, weight="bold")
    c.text((c.s(100), y + c.s(92)), "North Yard Loading Bay", 26, COLORS["muted"])
    c.pill((c.w - c.s(256), y + c.s(50), c.w - c.s(100), y + c.s(96)), "High", COLORS["red2"], COLORS["red"], 22)
    y += c.s(224)
    card(c, c.s(64), y, c.w - c.s(128), c.s(420))
    c.text((c.s(100), y + c.s(34)), "Checklist", 34, weight="bold")
    check_row(c, c.s(100), y + c.s(104), "PPE signage visible", "pass")
    check_row(c, c.s(100), y + c.s(174), "Fire extinguisher tagged", "pass")
    check_row(c, c.s(100), y + c.s(244), "Trip hazard near bay door", "fail")
    check_row(c, c.s(100), y + c.s(314), "Forklift lane needs repainting", "warn")
    y += c.s(462)
    c.text((c.s(64), y), "Evidence", 34, weight="bold")
    y += c.s(58)
    x = c.s(64)
    for i, color in enumerate(["#DCEBFF", "#E0F2FE", "#EEF2FF"]):
        card(c, x + i * c.s(250), y, c.s(220), c.s(170), color, None, 24)
        c.center_text((x + i * c.s(250), y, x + i * c.s(250) + c.s(220), y + c.s(170)), f"Photo {i+1}", 24, COLORS["muted"], "semibold")
    y += c.s(216)
    card(c, c.s(64), y, c.w - c.s(128), c.s(170), COLORS["surface"])
    c.pill((c.s(98), y + c.s(42), c.s(256), y + c.s(92)), "Voice", COLORS["blue2"], COLORS["blue"], 22)
    c.text((c.s(286), y + c.s(44)), "Dictated notes converted to text", 28, weight="semibold")
    c.text((c.s(286), y + c.s(88)), "Loose pallet blocking emergency route.", 22, COLORS["muted"])
    tab_bar(c, "Work")


def draw_ai_analysis_phone(c):
    y, bottom = phone_shell(c, "AI inspection analysis", "Generate cautious summaries, risk areas, corrective actions and follow-up reminders for review.", "Mock AI")
    card(c, c.s(64), y, c.w - c.s(128), c.s(276), COLORS["dark"])
    c.text((c.s(104), y + c.s(40)), "AI risk summary", 32, "#E2E8F0", "semibold")
    c.text_box((c.s(104), y + c.s(100)), "Trip hazards and blocked routes require supervisor review before shift handover.", c.w - c.s(208), 34, "#FFFFFF", "bold", max_lines=3)
    y += c.s(318)
    card(c, c.s(64), y, c.w - c.s(128), c.s(220))
    c.text((c.s(100), y + c.s(34)), "Severity scoring", 34, weight="bold")
    severities = [("Low", 18, COLORS["green"]), ("Medium", 34, COLORS["amber"]), ("High", 76, COLORS["red"]), ("Critical", 12, COLORS["purple"])]
    yy = y + c.s(96)
    for label, pct, color in severities:
        c.text((c.s(100), yy), label, 22, COLORS["muted"], "semibold")
        c.rect((c.s(250), yy + c.s(8), c.w - c.s(160), yy + c.s(28)), 10, COLORS["surface2"])
        c.rect((c.s(250), yy + c.s(8), c.s(250) + int((c.w - c.s(410)) * pct / 100), yy + c.s(28)), 10, color)
        yy += c.s(38)
    y += c.s(262)
    c.text((c.s(64), y), "Corrective actions", 34, weight="bold")
    y += c.s(58)
    row(c, c.s(64), y, c.w - c.s(128), "Clear loading bay route", "Assign supervisor and record completion", "High", COLORS["red2"])
    row(c, c.s(64), y + c.s(138), c.w - c.s(128), "Replace floor marking", "Schedule repaint within 7 days", "Medium", COLORS["amber2"])
    row(c, c.s(64), y + c.s(276), c.w - c.s(128), "Add weekly follow-up", "Reminder created for site lead", "Open", COLORS["blue2"])
    y += c.s(438)
    card(c, c.s(64), y, c.w - c.s(128), c.s(138), COLORS["amber2"], None)
    c.text_box((c.s(100), y + c.s(34)), "AI suggestions must be reviewed. Not legal advice or regulatory certification.", c.w - c.s(200), 24, "#92400E", "semibold", max_lines=2)
    tab_bar(c, "AI")


def draw_sop_phone(c):
    y, bottom = phone_shell(c, "Generate editable SOPs", "Turn task details, equipment and safety requirements into structured operating procedures.", "SOP")
    card(c, c.s(64), y, c.w - c.s(128), c.s(290))
    c.text((c.s(100), y + c.s(34)), "SOP request", 34, weight="bold")
    c.text((c.s(100), y + c.s(94)), "Task", 22, COLORS["muted"], "semibold")
    c.text((c.s(100), y + c.s(128)), "Roof ladder setup and inspection", 30, weight="semibold")
    c.text((c.s(100), y + c.s(188)), "Equipment", 22, COLORS["muted"], "semibold")
    c.text((c.s(100), y + c.s(222)), "Extension ladder, PPE, fall arrest kit", 26, COLORS["muted"])
    y += c.s(332)
    card(c, c.s(64), y, c.w - c.s(128), c.s(520), COLORS["surface"])
    c.text((c.s(100), y + c.s(36)), "Generated SOP", 34, weight="bold")
    steps = [
        "1. Inspect ground conditions and weather.",
        "2. Verify ladder rating and visible damage.",
        "3. Establish exclusion zone and spotter role.",
        "4. Secure ladder at safe angle before access.",
        "5. Record photos and supervisor sign-off.",
    ]
    yy = y + c.s(100)
    for step in steps:
        yy = c.text_box((c.s(100), yy), step, c.w - c.s(200), 25, COLORS["text"], "regular", max_lines=1)
        yy += c.s(16)
    c.pill((c.s(100), y + c.s(442), c.s(330), y + c.s(492)), "PPE Required", COLORS["red2"], COLORS["red"], 20)
    c.pill((c.s(354), y + c.s(442), c.s(592), y + c.s(492)), "Supervisor", COLORS["blue2"], COLORS["blue"], 20)
    y += c.s(562)
    card(c, c.s(64), y, c.w - c.s(128), c.s(190), COLORS["green2"], None)
    c.text((c.s(100), y + c.s(38)), "Ready to edit, save or export PDF", 30, COLORS["green"], "bold")
    c.text_box((c.s(100), y + c.s(90)), "Includes safety warnings, checklist, emergency steps and supervisor notes.", c.w - c.s(200), 24, "#166534", max_lines=2)
    tab_bar(c, "AI")


def draw_incident_phone(c):
    y, bottom = phone_shell(c, "Incident reporting from site", "Capture people involved, evidence, witness notes, injury level and corrective action details.", "Incident")
    card(c, c.s(64), y, c.w - c.s(128), c.s(268))
    c.text((c.s(100), y + c.s(34)), "Slip near loading bay", 36, weight="bold")
    c.text((c.s(100), y + c.s(92)), "Warehouse B - 14:20", 26, COLORS["muted"])
    c.pill((c.s(100), y + c.s(150), c.s(292), y + c.s(198)), "Minor injury", COLORS["amber2"], COLORS["amber"], 20)
    c.pill((c.s(316), y + c.s(150), c.s(496), y + c.s(198)), "Open", COLORS["blue2"], COLORS["blue"], 20)
    y += c.s(310)
    card(c, c.s(64), y, c.w - c.s(128), c.s(360))
    c.text((c.s(100), y + c.s(34)), "Incident details", 34, weight="bold")
    details = [
        ("People involved", "1 employee, 1 witness"),
        ("Photos", "2 attached"),
        ("Witness notes", "Area was wet after delivery"),
    ]
    yy = y + c.s(104)
    for label, value in details:
        c.text((c.s(100), yy), label, 22, COLORS["muted"], "semibold")
        c.text((c.s(430), yy), value, 25, COLORS["text"], "semibold")
        yy += c.s(76)
    y += c.s(402)
    card(c, c.s(64), y, c.w - c.s(128), c.s(430), COLORS["surface"])
    c.text((c.s(100), y + c.s(36)), "AI corrective action plan", 34, weight="bold")
    actions = ["Clean and isolate wet area", "Add temporary warning signage", "Review delivery spill procedure", "Schedule follow-up inspection"]
    yy = y + c.s(108)
    for item in actions:
        c.rect((c.s(100), yy + c.s(4), c.s(132), yy + c.s(36)), 16, COLORS["green"])
        c.line([(c.s(108), yy + c.s(22)), (c.s(120), yy + c.s(34)), (c.s(132), yy + c.s(10))], "#FFFFFF", 4)
        c.text((c.s(158), yy), item, 25, COLORS["text"], "semibold")
        yy += c.s(70)
    y += c.s(474)
    row(c, c.s(64), y, c.w - c.s(128), "Follow-up checklist", "Assigned to site supervisor", "Due 24h", COLORS["red2"])
    tab_bar(c, "Work")


def draw_audit_phone(c):
    y, bottom = phone_shell(c, "Audit readiness scoring", "Spot missing records, high-risk gaps and suggested improvements before formal review.", "Audit")
    card(c, c.s(64), y, c.w - c.s(128), c.s(330), COLORS["dark"])
    c.text((c.s(104), y + c.s(42)), "Safety audit readiness", 31, "#E2E8F0", "semibold")
    c.text((c.s(104), y + c.s(106)), "74", 86, "#FFFFFF", "bold")
    c.text((c.s(228), y + c.s(146)), "/100", 38, "#94A3B8", "bold")
    c.pill((c.w - c.s(350), y + c.s(112), c.w - c.s(104), y + c.s(164)), "Needs review", COLORS["amber2"], COLORS["amber"], 22)
    c.text((c.s(104), y + c.s(232)), "5 missing items. 2 high-risk gaps.", 26, "#CBD5E1")
    y += c.s(374)
    c.text((c.s(64), y), "Missing items", 34, weight="bold")
    y += c.s(58)
    row(c, c.s(64), y, c.w - c.s(128), "Equipment service log", "Last service date not recorded", "High", COLORS["red2"])
    row(c, c.s(64), y + c.s(138), c.w - c.s(128), "Staff training evidence", "Two renewals due this month", "Medium", COLORS["amber2"])
    row(c, c.s(64), y + c.s(276), c.w - c.s(128), "Insurance certificate", "Expires in 18 days", "Due", COLORS["blue2"])
    y += c.s(436)
    card(c, c.s(64), y, c.w - c.s(128), c.s(270), COLORS["surface"])
    c.text((c.s(100), y + c.s(34)), "Roadmap", 34, weight="bold")
    c.text_box((c.s(100), y + c.s(96)), "1. Collect missing certificates. 2. Close high-risk findings. 3. Export audit summary with recommendations.", c.w - c.s(200), 27, COLORS["text"], max_lines=4)
    tab_bar(c, "AI")


def draw_reminders_phone(c):
    y, bottom = phone_shell(c, "Recurring compliance reminders", "Track due dates for inspections, certificates, insurance, servicing and training renewals.", "Reminders")
    card(c, c.s(64), y, c.w - c.s(128), c.s(160), COLORS["blue"])
    c.text((c.s(104), y + c.s(36)), "Notifications enabled", 34, "#FFFFFF", "bold")
    c.text((c.s(104), y + c.s(88)), "Local reminders stay on device.", 25, "#DBEAFE")
    y += c.s(204)
    c.text((c.s(64), y), "Upcoming", 34, weight="bold")
    y += c.s(58)
    row(c, c.s(64), y, c.w - c.s(128), "Vehicle inspection", "Tomorrow - Van 04", "Due", COLORS["blue2"])
    row(c, c.s(64), y + c.s(138), c.w - c.s(128), "Insurance renewal", "18 May 2026", "Urgent", COLORS["red2"])
    row(c, c.s(64), y + c.s(276), c.w - c.s(128), "Forklift service", "22 May 2026", "Open", COLORS["amber2"])
    row(c, c.s(64), y + c.s(414), c.w - c.s(128), "Staff training", "31 May 2026", "Plan", COLORS["green2"])
    y += c.s(592)
    card(c, c.s(64), y, c.w - c.s(128), c.s(240))
    c.text((c.s(100), y + c.s(34)), "Completion trend", 34, weight="bold")
    base_y = y + c.s(184)
    xs = [c.s(120), c.s(270), c.s(420), c.s(570), c.s(720), c.s(870), c.s(1020)]
    vals = [70, 116, 92, 148, 132, 170, 156]
    for i, val in enumerate(vals):
        c.rect((xs[i], base_y - c.s(val), xs[i] + c.s(44), base_y), 12, COLORS["blue"] if i == len(vals) - 1 else "#BFDBFE")
    tab_bar(c, "Work")


def draw_reports_phone(c):
    y, bottom = phone_shell(c, "Export audit-ready reports", "Create inspection reports, incident reports, SOP PDFs, audit summaries and corrective action plans.", "Reports")
    card(c, c.s(64), y, c.w - c.s(128), c.s(590), COLORS["surface"])
    c.text((c.s(100), y + c.s(34)), "Report preview", 36, weight="bold")
    c.rect((c.s(100), y + c.s(100), c.w - c.s(100), y + c.s(500)), 16, COLORS["surface2"], COLORS["line"], 2)
    c.text((c.s(138), y + c.s(132)), "Site Inspection Report", 30, weight="bold")
    c.text((c.s(138), y + c.s(184)), "Business details", 22, COLORS["muted"])
    c.line([(c.s(138), y + c.s(232)), (c.w - c.s(138), y + c.s(232))], COLORS["line"], 3)
    c.text((c.s(138), y + c.s(264)), "Findings", 22, COLORS["muted"])
    c.line([(c.s(138), y + c.s(312)), (c.w - c.s(138), y + c.s(312))], COLORS["line"], 3)
    c.text((c.s(138), y + c.s(344)), "Photos and signatures", 22, COLORS["muted"])
    c.line([(c.s(138), y + c.s(392)), (c.w - c.s(138), y + c.s(392))], COLORS["line"], 3)
    c.text((c.s(138), y + c.s(424)), "Recommendations", 22, COLORS["muted"])
    c.pill((c.w - c.s(350), y + c.s(522), c.w - c.s(100), y + c.s(572)), "Export PDF", COLORS["blue"], "#FFFFFF", 22)
    y += c.s(634)
    row(c, c.s(64), y, c.w - c.s(128), "Inspection reports", "12 generated this month", "PDF", COLORS["green2"])
    row(c, c.s(64), y + c.s(138), c.w - c.s(128), "Incident summaries", "3 open follow-ups", "Share", COLORS["blue2"])
    row(c, c.s(64), y + c.s(276), c.w - c.s(128), "Corrective action plans", "8 assigned actions", "Pro", COLORS["purple2"])
    tab_bar(c, "Reports")


def draw_profile_phone(c):
    y, bottom = phone_shell(c, "Central business profile", "Keep locations, team size, certificates, insurance dates and safety notes in one place.", "Profile")
    card(c, c.s(64), y, c.w - c.s(128), c.s(280), COLORS["dark"])
    c.text((c.s(104), y + c.s(42)), "Northline Facilities", 40, "#FFFFFF", "bold")
    c.text((c.s(104), y + c.s(104)), "Facilities management - Small Team", 28, "#CBD5E1")
    c.pill((c.s(104), y + c.s(176), c.s(304), y + c.s(226)), "3 locations", COLORS["blue2"], COLORS["blue"], 21)
    c.pill((c.s(330), y + c.s(176), c.s(560), y + c.s(226)), "12 team", COLORS["green2"], COLORS["green"], 21)
    y += c.s(324)
    row(c, c.s(64), y, c.w - c.s(128), "Insurance expiry", "Public liability - 18 Jun 2026", "Due soon", COLORS["amber2"])
    row(c, c.s(64), y + c.s(138), c.w - c.s(128), "Certification expiry", "First aid renewal - 31 May 2026", "Open", COLORS["blue2"])
    row(c, c.s(64), y + c.s(276), c.w - c.s(128), "Safety notes", "Wet-floor checks after evening deliveries", "Saved", COLORS["green2"])
    y += c.s(456)
    c.text((c.s(64), y), "Team placeholders", 34, weight="bold")
    y += c.s(58)
    roles = ["Owner", "Supervisor", "Inspector"]
    for idx, role in enumerate(roles):
        x = c.s(64) + idx * c.s(380)
        card(c, x, y, c.s(340), c.s(170), COLORS["surface"])
        c.rect((x + c.s(28), y + c.s(28), x + c.s(88), y + c.s(88)), 30, COLORS["blue2"])
        c.center_text((x + c.s(28), y + c.s(28), x + c.s(88), y + c.s(88)), role[0], 24, COLORS["blue"], "bold")
        c.text((x + c.s(28), y + c.s(108)), role, 26, weight="semibold")
    tab_bar(c, "Work")


def draw_paywall_phone(c):
    y, bottom = phone_shell(c, "Unlock Pro compliance tools", "StoreKit 2 subscriptions unlock unlimited inspections, SOPs, audit scoring, PDF exports and reminders.", "Paywall")
    plans = [
        ("Pro Monthly", "$24.99 / month", COLORS["blue"], True),
        ("Pro Yearly", "$199.99 / year", COLORS["green"], False),
        ("Business Monthly", "$99.99 / month", COLORS["purple"], False),
    ]
    for name, price, color, selected in plans:
        card(c, c.s(64), y, c.w - c.s(128), c.s(190), COLORS["surface2"] if selected else COLORS["surface"], color if selected else COLORS["line"], 28)
        c.text((c.s(100), y + c.s(34)), name, 34, weight="bold")
        c.text((c.s(100), y + c.s(92)), price, 31, color, "bold")
        if selected:
            c.pill((c.w - c.s(308), y + c.s(56), c.w - c.s(100), y + c.s(106)), "Selected", COLORS["blue2"], COLORS["blue"], 20)
        y += c.s(220)
    card(c, c.s(64), y, c.w - c.s(128), c.s(410), COLORS["dark"])
    c.text((c.s(100), y + c.s(40)), "Paid plans include", 36, "#FFFFFF", "bold")
    yy = y + c.s(118)
    for item in ["Unlimited inspections and SOPs", "Audit scoring and reports", "PDF exports and reminders", "AI corrective action plans"]:
        c.rect((c.s(100), yy + c.s(4), c.s(132), yy + c.s(36)), 16, COLORS["cyan"])
        c.line([(c.s(108), yy + c.s(22)), (c.s(120), yy + c.s(34)), (c.s(132), yy + c.s(10))], COLORS["dark"], 4)
        c.text((c.s(158), yy), item, 26, "#E2E8F0", "semibold")
        yy += c.s(68)
    y += c.s(454)
    c.pill((c.s(64), y, c.w - c.s(64), y + c.s(88)), "Continue with Pro", COLORS["blue"], "#FFFFFF", 30, "bold")
    c.text_box((c.s(84), y + c.s(120)), "Subscriptions renew automatically until cancelled. AI suggestions must be reviewed.", c.w - c.s(168), 22, COLORS["muted"], max_lines=2)
    tab_bar(c, "AI")


PHONE_DRAWERS = [
    draw_dashboard_phone,
    draw_inspection_phone,
    draw_ai_analysis_phone,
    draw_sop_phone,
    draw_incident_phone,
    draw_audit_phone,
    draw_reminders_phone,
    draw_reports_phone,
    draw_profile_phone,
    draw_paywall_phone,
]


def ipad_shell(c, selected):
    c.text((c.s(64), c.s(76)), "ComplyFlow AI", 38, weight="bold")
    c.pill((c.w - c.s(320), c.s(70), c.w - c.s(64), c.s(120)), "Mock AI On", COLORS["blue2"], COLORS["blue"], 22)
    sidebar_x, sidebar_y = c.s(64), c.s(170)
    sidebar_w, sidebar_h = c.s(360), c.h - c.s(320)
    card(c, sidebar_x, sidebar_y, sidebar_w, sidebar_h, COLORS["surface"])
    nav = ["Dashboard", "Inspection", "AI Analysis", "SOP", "Incidents", "Audits", "Reminders", "Reports", "Profile", "Plans"]
    yy = sidebar_y + c.s(42)
    for item in nav:
        active = item == selected
        fill = COLORS["blue2"] if active else COLORS["surface"]
        color = COLORS["blue"] if active else COLORS["muted"]
        c.rect((sidebar_x + c.s(24), yy, sidebar_x + sidebar_w - c.s(24), yy + c.s(66)), 20, fill)
        c.text((sidebar_x + c.s(50), yy + c.s(17)), item, 24, color, "semibold" if active else "regular")
        yy += c.s(82)
    return c.s(470), c.s(170), c.w - c.s(534), c.h - c.s(270)


def ipad_header(c, x, y, title, subtitle):
    c.text((x, y), title, 60, weight="bold")
    return c.text_box((x, y + c.s(82)), subtitle, c.w - x - c.s(80), 30, COLORS["muted"], max_lines=2) + c.s(36)


def draw_dashboard_ipad(c):
    x, y, w, h = ipad_shell(c, "Dashboard")
    y = ipad_header(c, x, y, "Operations dashboard", "A complete compliance snapshot for inspections, incidents, audit readiness, reminders and recent reports.")
    card(c, x, y, w, c.s(420), COLORS["dark"])
    c.text((x + c.s(44), y + c.s(46)), "Audit readiness", 34, "#E2E8F0", "semibold")
    c.text((x + c.s(44), y + c.s(118)), "86%", 92, "#FFFFFF", "bold")
    c.text((x + c.s(44), y + c.s(240)), "Ready for operational checks", 28, "#CBD5E1")
    c.rect((x + c.s(44), y + c.s(320), x + w - c.s(44), y + c.s(348)), 14, "#1E293B")
    c.rect((x + c.s(44), y + c.s(320), x + c.s(44) + int((w - c.s(88)) * .86), y + c.s(348)), 14, COLORS["cyan"])
    y += c.s(470)
    gap = c.s(28)
    mw = (w - gap * 3) // 4
    for i, (value, label, color) in enumerate([("7", "Upcoming inspections", COLORS["blue"]), ("2", "Overdue tasks", COLORS["red"]), ("3", "Open incidents", COLORS["amber"]), ("12", "Recent reports", COLORS["green"])]):
        metric(c, x + i * (mw + gap), y, mw, c.s(190), value, label, color)
    y += c.s(240)
    row(c, x, y, w, "Compliance reminders", "Insurance renewal, forklift service and training checks due this week", "Open", COLORS["blue2"])
    row(c, x, y + c.s(140), w, "Recent inspection report", "Site inspection exported with photos and recommendations", "PDF", COLORS["green2"])


def draw_inspection_ipad(c):
    x, y, w, h = ipad_shell(c, "Inspection")
    y = ipad_header(c, x, y, "Inspection workspace", "Build pass/fail checklists, attach evidence and capture voice-to-text notes from site.")
    left = int(w * .58)
    card(c, x, y, left - c.s(16), c.s(620))
    c.text((x + c.s(40), y + c.s(40)), "Site Inspection", 40, weight="bold")
    c.text((x + c.s(40), y + c.s(102)), "North Yard Loading Bay", 28, COLORS["muted"])
    for idx, item in enumerate([("PPE signage visible", "pass"), ("Fire extinguisher tagged", "pass"), ("Trip hazard near bay door", "fail"), ("Forklift lane needs repainting", "warn")]):
        check_row(c, x + c.s(40), y + c.s(190 + idx * 86), item[0], item[1])
    card(c, x + left + c.s(16), y, w - left - c.s(16), c.s(620), COLORS["surface"])
    c.text((x + left + c.s(56), y + c.s(40)), "Evidence", 40, weight="bold")
    for idx in range(3):
        py = y + c.s(116 + idx * 148)
        card(c, x + left + c.s(56), py, w - left - c.s(128), c.s(116), ["#DCEBFF", "#E0F2FE", "#EEF2FF"][idx], None)
        c.center_text((x + left + c.s(56), py, x + w - c.s(56), py + c.s(116)), f"Photo evidence {idx + 1}", 25, COLORS["muted"], "semibold")
    row(c, x, y + c.s(670), w, "Voice notes", "Loose pallet blocking emergency route converted to text", "Saved", COLORS["blue2"])


def draw_ai_ipad(c):
    x, y, w, h = ipad_shell(c, "AI Analysis")
    y = ipad_header(c, x, y, "AI analysis review", "Review structured findings, risk areas, corrective actions and reminders before they become reports.")
    card(c, x, y, w, c.s(360), COLORS["dark"])
    c.text((x + c.s(44), y + c.s(46)), "AI risk summary", 34, "#E2E8F0", "semibold")
    c.text_box((x + c.s(44), y + c.s(116)), "Trip hazards and blocked routes require supervisor review before shift handover.", w - c.s(88), 44, "#FFFFFF", "bold", max_lines=2)
    y += c.s(410)
    col = (w - c.s(28)) // 2
    card(c, x, y, col, c.s(430))
    c.text((x + c.s(40), y + c.s(40)), "Severity", 38, weight="bold")
    for idx, (label, pct, color) in enumerate([("Low", 18, COLORS["green"]), ("Medium", 34, COLORS["amber"]), ("High", 76, COLORS["red"]), ("Critical", 12, COLORS["purple"])]):
        yy = y + c.s(120 + idx * 70)
        c.text((x + c.s(40), yy), label, 24, COLORS["muted"], "semibold")
        c.rect((x + c.s(190), yy + c.s(10), x + col - c.s(40), yy + c.s(32)), 10, COLORS["surface2"])
        c.rect((x + c.s(190), yy + c.s(10), x + c.s(190) + int((col - c.s(230)) * pct / 100), yy + c.s(32)), 10, color)
    card(c, x + col + c.s(28), y, col, c.s(430))
    c.text((x + col + c.s(68), y + c.s(40)), "Actions", 38, weight="bold")
    for idx, item in enumerate(["Clear loading bay route", "Replace floor marking", "Add weekly follow-up", "Assign supervisor"]):
        check_row(c, x + col + c.s(68), y + c.s(118 + idx * 72), item, "warn" if idx == 1 else "pass")
    row(c, x, y + c.s(480), w, "Safety disclaimer", "AI suggestions must be reviewed and are not legal advice or certification", "Required", COLORS["amber2"])


def draw_sop_ipad(c):
    x, y, w, h = ipad_shell(c, "SOP")
    y = ipad_header(c, x, y, "SOP generator", "Generate editable step-by-step procedures with PPE, emergency steps and supervisor notes.")
    card(c, x, y, int(w * .38), c.s(620))
    c.text((x + c.s(38), y + c.s(40)), "Request", 38, weight="bold")
    labels = [("Business type", "Roofing"), ("Task", "Ladder setup"), ("Equipment", "Ladder, PPE, fall kit"), ("Safety needs", "Fall prevention")]
    yy = y + c.s(118)
    for label, value in labels:
        c.text((x + c.s(38), yy), label, 22, COLORS["muted"], "semibold")
        c.text_box((x + c.s(38), yy + c.s(34)), value, int(w * .32), 27, COLORS["text"], "semibold", max_lines=1)
        yy += c.s(104)
    rx = x + int(w * .38) + c.s(28)
    rw = w - int(w * .38) - c.s(28)
    card(c, rx, y, rw, c.s(620))
    c.text((rx + c.s(40), y + c.s(40)), "Generated SOP", 38, weight="bold")
    steps = ["Inspect ground and weather", "Verify ladder condition", "Create exclusion zone", "Secure ladder and use spotter", "Record photos and supervisor sign-off"]
    for idx, step in enumerate(steps):
        row(c, rx + c.s(40), y + c.s(110 + idx * 92), rw - c.s(80), f"{idx + 1}. {step}", "Editable procedure step")
    row(c, x, y + c.s(670), w, "PDF export", "Save SOP and export a report-ready document", "Pro", COLORS["purple2"])


def draw_incident_ipad(c):
    x, y, w, h = ipad_shell(c, "Incidents")
    y = ipad_header(c, x, y, "Incident reporting", "Capture evidence, injury level, witness notes and AI-assisted corrective action plans.")
    card(c, x, y, w, c.s(250))
    c.text((x + c.s(40), y + c.s(40)), "Slip near loading bay", 44, weight="bold")
    c.text((x + c.s(40), y + c.s(110)), "Warehouse B - 14:20 - 1 employee, 1 witness", 30, COLORS["muted"])
    c.pill((x + c.s(40), y + c.s(174), x + c.s(270), y + c.s(226)), "Minor injury", COLORS["amber2"], COLORS["amber"], 22)
    c.pill((x + c.s(296), y + c.s(174), x + c.s(456), y + c.s(226)), "Open", COLORS["blue2"], COLORS["blue"], 22)
    y += c.s(300)
    col = (w - c.s(28)) // 2
    card(c, x, y, col, c.s(470))
    c.text((x + c.s(40), y + c.s(40)), "Evidence", 38, weight="bold")
    for idx in range(2):
        card(c, x + c.s(40), y + c.s(116 + idx * 146), col - c.s(80), c.s(110), "#E0F2FE", None)
        c.center_text((x + c.s(40), y + c.s(116 + idx * 146), x + col - c.s(40), y + c.s(226 + idx * 146)), f"Incident photo {idx + 1}", 24, COLORS["muted"], "semibold")
    card(c, x + col + c.s(28), y, col, c.s(470))
    c.text((x + col + c.s(68), y + c.s(40)), "Corrective action plan", 38, weight="bold")
    for idx, item in enumerate(["Clean and isolate wet area", "Add warning signage", "Review spill procedure", "Schedule follow-up"]):
        check_row(c, x + col + c.s(68), y + c.s(116 + idx * 72), item, "pass")
    row(c, x, y + c.s(520), w, "Witness notes", "Area was wet after delivery. Supervisor notified.", "Saved", COLORS["green2"])


def draw_audit_ipad(c):
    x, y, w, h = ipad_shell(c, "Audits")
    y = ipad_header(c, x, y, "Audit readiness", "Score readiness, identify missing records and prepare a corrective action roadmap.")
    card(c, x, y, w, c.s(340), COLORS["dark"])
    c.text((x + c.s(44), y + c.s(46)), "Safety audit readiness", 34, "#E2E8F0", "semibold")
    c.text((x + c.s(44), y + c.s(112)), "74", 92, "#FFFFFF", "bold")
    c.text((x + c.s(170), y + c.s(154)), "/100", 42, "#94A3B8", "bold")
    c.text((x + c.s(44), y + c.s(246)), "5 missing items. 2 high-risk gaps.", 29, "#CBD5E1")
    y += c.s(390)
    row(c, x, y, w, "Equipment service log", "Last service date not recorded", "High", COLORS["red2"])
    row(c, x, y + c.s(140), w, "Staff training evidence", "Two renewals due this month", "Medium", COLORS["amber2"])
    row(c, x, y + c.s(280), w, "Insurance certificate", "Expires in 18 days", "Due", COLORS["blue2"])
    card(c, x, y + c.s(460), w, c.s(210), COLORS["surface"])
    c.text((x + c.s(40), y + c.s(500)), "Corrective roadmap", 38, weight="bold")
    c.text_box((x + c.s(40), y + c.s(566)), "Collect missing certificates, close high-risk findings, then export the audit summary with recommendations.", w - c.s(80), 28, COLORS["muted"], max_lines=2)


def draw_reminders_ipad(c):
    x, y, w, h = ipad_shell(c, "Reminders")
    y = ipad_header(c, x, y, "Compliance reminders", "Track due dates for inspections, certificates, insurance, servicing and staff training.")
    card(c, x, y, w, c.s(150), COLORS["blue"])
    c.text((x + c.s(44), y + c.s(36)), "Local notifications enabled", 38, "#FFFFFF", "bold")
    c.text((x + c.s(44), y + c.s(92)), "Reminders stay on device and support field follow-through.", 28, "#DBEAFE")
    y += c.s(200)
    row(c, x, y, w, "Vehicle inspection", "Tomorrow - Van 04", "Due", COLORS["blue2"])
    row(c, x, y + c.s(140), w, "Insurance renewal", "18 May 2026", "Urgent", COLORS["red2"])
    row(c, x, y + c.s(280), w, "Forklift service", "22 May 2026", "Open", COLORS["amber2"])
    row(c, x, y + c.s(420), w, "Staff training", "31 May 2026", "Plan", COLORS["green2"])
    card(c, x, y + c.s(600), w, c.s(230))
    c.text((x + c.s(40), y + c.s(638)), "Completion trend", 38, weight="bold")
    base_y = y + c.s(790)
    for idx, val in enumerate([70, 116, 92, 148, 132, 170, 156, 186]):
        bx = x + c.s(420 + idx * 90)
        c.rect((bx, base_y - c.s(val), bx + c.s(48), base_y), 12, COLORS["blue"] if idx == 7 else "#BFDBFE")


def draw_reports_ipad(c):
    x, y, w, h = ipad_shell(c, "Reports")
    y = ipad_header(c, x, y, "Reports center", "Generate inspection reports, SOP PDFs, incident summaries, audit reports and action plans.")
    card(c, x, y, int(w * .52), c.s(690))
    c.text((x + c.s(40), y + c.s(40)), "PDF preview", 42, weight="bold")
    c.rect((x + c.s(40), y + c.s(120), x + int(w * .52) - c.s(40), y + c.s(590)), 18, COLORS["surface2"], COLORS["line"], 2)
    for idx, label in enumerate(["Business details", "Findings", "Photos", "Signatures", "Recommendations"]):
        yy = y + c.s(170 + idx * 76)
        c.text((x + c.s(86), yy), label, 26, COLORS["muted"], "semibold")
        c.line([(x + c.s(86), yy + c.s(44)), (x + int(w * .52) - c.s(86), yy + c.s(44))], COLORS["line"], 3)
    rx = x + int(w * .52) + c.s(28)
    rw = w - int(w * .52) - c.s(28)
    row(c, rx, y, rw, "Inspection reports", "12 generated this month", "PDF", COLORS["green2"])
    row(c, rx, y + c.s(140), rw, "Incident summaries", "3 open follow-ups", "Share", COLORS["blue2"])
    row(c, rx, y + c.s(280), rw, "SOP documents", "4 ready for export", "SOP", COLORS["purple2"])
    row(c, rx, y + c.s(420), rw, "Action plans", "8 assigned actions", "Pro", COLORS["amber2"])
    c.pill((rx, y + c.s(590), rx + rw, y + c.s(670)), "Export PDF", COLORS["blue"], "#FFFFFF", 30, "bold")


def draw_profile_ipad(c):
    x, y, w, h = ipad_shell(c, "Profile")
    y = ipad_header(c, x, y, "Business profile", "Centralize business details, locations, insurance, certifications, safety notes and team placeholders.")
    card(c, x, y, w, c.s(290), COLORS["dark"])
    c.text((x + c.s(44), y + c.s(44)), "Northline Facilities", 48, "#FFFFFF", "bold")
    c.text((x + c.s(44), y + c.s(118)), "Facilities management - Small Team", 30, "#CBD5E1")
    c.pill((x + c.s(44), y + c.s(196), x + c.s(260), y + c.s(250)), "3 locations", COLORS["blue2"], COLORS["blue"], 22)
    c.pill((x + c.s(290), y + c.s(196), x + c.s(500), y + c.s(250)), "12 team", COLORS["green2"], COLORS["green"], 22)
    y += c.s(340)
    row(c, x, y, w, "Insurance expiry", "Public liability - 18 Jun 2026", "Due soon", COLORS["amber2"])
    row(c, x, y + c.s(140), w, "Certification expiry", "First aid renewal - 31 May 2026", "Open", COLORS["blue2"])
    row(c, x, y + c.s(280), w, "Safety notes", "Wet-floor checks after evening deliveries", "Saved", COLORS["green2"])
    y += c.s(470)
    for idx, role in enumerate(["Owner", "Supervisor", "Inspector"]):
        cw = (w - c.s(56)) // 3
        cx = x + idx * (cw + c.s(28))
        card(c, cx, y, cw, c.s(180))
        c.rect((cx + c.s(34), y + c.s(34), cx + c.s(100), y + c.s(100)), 33, COLORS["blue2"])
        c.center_text((cx + c.s(34), y + c.s(34), cx + c.s(100), y + c.s(100)), role[0], 26, COLORS["blue"], "bold")
        c.text((cx + c.s(34), y + c.s(122)), role, 30, weight="semibold")


def draw_paywall_ipad(c):
    x, y, w, h = ipad_shell(c, "Plans")
    y = ipad_header(c, x, y, "StoreKit 2 subscriptions", "Unlock unlimited inspections, SOP generation, audit scoring, PDF exports, reminders and advanced reports.")
    plans = [("Business Monthly", "$99.99 / month", COLORS["purple"], "Level 1"), ("Pro Monthly", "$24.99 / month", COLORS["blue"], "Level 2"), ("Pro Yearly", "$199.99 / year", COLORS["green"], "Level 2")]
    col = (w - c.s(56)) // 3
    for idx, (name, price, color, level) in enumerate(plans):
        px = x + idx * (col + c.s(28))
        card(c, px, y, col, c.s(320), COLORS["surface2"] if idx == 0 else COLORS["surface"], color if idx == 0 else COLORS["line"], 28)
        c.text((px + c.s(34), y + c.s(40)), name, 34, weight="bold")
        c.text_box((px + c.s(34), y + c.s(106)), price, col - c.s(68), 28, color, "bold", max_lines=2)
        c.pill((px + c.s(34), y + c.s(220), px + c.s(190), y + c.s(272)), level, COLORS["blue2"], COLORS["blue"], 20)
    y += c.s(380)
    card(c, x, y, w, c.s(390), COLORS["dark"])
    c.text((x + c.s(44), y + c.s(44)), "Paid plans include", 42, "#FFFFFF", "bold")
    items = ["Unlimited inspections and SOPs", "Audit scoring and reports", "PDF exports and reminders", "AI corrective action plans", "Multi-site and team placeholders"]
    for idx, item in enumerate(items):
        xx = x + c.s(44) + (idx % 2) * int(w * .48)
        yy = y + c.s(132 + (idx // 2) * 80)
        c.rect((xx, yy + c.s(4), xx + c.s(34), yy + c.s(38)), 17, COLORS["cyan"])
        c.line([(xx + c.s(8), yy + c.s(23)), (xx + c.s(20), yy + c.s(35)), (xx + c.s(34), yy + c.s(10))], COLORS["dark"], 4)
        c.text((xx + c.s(54), yy), item, 28, "#E2E8F0", "semibold")


IPAD_DRAWERS = [
    draw_dashboard_ipad,
    draw_inspection_ipad,
    draw_ai_ipad,
    draw_sop_ipad,
    draw_incident_ipad,
    draw_audit_ipad,
    draw_reminders_ipad,
    draw_reports_ipad,
    draw_profile_ipad,
    draw_paywall_ipad,
]


def save_set(name, size, kind, drawers):
    target = OUT / name
    target.mkdir(parents=True, exist_ok=True)
    paths = []
    for (slug, _), drawer in zip(SCREENS, drawers):
        c = Canvas(size[0], size[1], kind)
        drawer(c)
        path = target / f"{slug}.png"
        c.img.save(path, "PNG", optimize=True)
        paths.append(path)
    return paths


def write_manifest(all_paths):
    lines = [
        "# ComplyFlow AI App Store Screenshots",
        "",
        "Generated screenshot pack for App Store Connect.",
        "",
        "Apple accepts 1 to 10 PNG/JPG screenshots per display size. This pack includes 10 portrait screenshots for iPhone and iPad.",
        "",
        "## Included Sets",
        "",
    ]
    for name, size in {**PHONE_SIZES, **IPAD_SIZES}.items():
        lines.append(f"- `{name}`: {size[0]} x {size[1]} PNG")
    lines.extend(["", "## Screens", ""])
    for slug, title in SCREENS:
        lines.append(f"- `{slug}.png`: {title}")
    lines.extend(["", "## Files", ""])
    for path in all_paths:
        lines.append(f"- `{path.relative_to(ROOT)}`")
    (OUT / "README.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_zip():
    if ZIP_PATH.exists():
        ZIP_PATH.unlink()
    with ZipFile(ZIP_PATH, "w", ZIP_DEFLATED) as zf:
        for path in OUT.rglob("*.png"):
            zf.write(path, path.relative_to(ROOT))
        readme = OUT / "README.md"
        if readme.exists():
            zf.write(readme, readme.relative_to(ROOT))


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    all_paths = []
    for name, size in PHONE_SIZES.items():
        all_paths.extend(save_set(name, size, "phone", PHONE_DRAWERS))
    for name, size in IPAD_SIZES.items():
        all_paths.extend(save_set(name, size, "ipad", IPAD_DRAWERS))
    write_manifest(all_paths)
    write_zip()
    print(f"Generated {len(all_paths)} screenshots")
    print(OUT)
    print(ZIP_PATH)


if __name__ == "__main__":
    main()
