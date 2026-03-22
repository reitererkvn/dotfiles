import os
import socket
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

# 1. System-Envs nativ aus dem OS auslesen
USER = os.getenv("USER")
# POSIX-Call für garantierte Maschinen-Identifikation
HOSTNAME = socket.gethostname()
HOME_DIR = os.path.expanduser("~")

TEXTCOLOR1 = os.getenv("TEXTCOLOR1", "FFFFFF")[:6]
TEXTCOLOR2 = os.getenv("TEXTCOLOR2", "FFFFFF")[:6]
TEXTCOLOR3 = os.getenv("TEXTCOLOR3", "FFFFFF")[:6]
TEXTCOLOR4 = os.getenv("TEXTCOLOR4", "FFFFFF")[:6]
BACKGROUND0 = os.getenv("BACKGROUND0", "FFFFFF")[:6]


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData
) -> int:

    # 2. Prompt injizieren (Nur vor Tab 1)
    if index == 1:
        screen.cursor.bold = True

        raw_title = tab.title.strip()

        if raw_title.startswith(HOME_DIR):
            path = raw_title.replace(HOME_DIR, "~", 1)
        else:
            path = raw_title

        if not path or path == "kitty":
            path = "~"

        # KORREKTUR: Direkte Übergabe der Variable (String) in den int-Cast
        screen.cursor.fg = as_rgb(int(TEXTCOLOR2, 16))
        screen.cursor.bg = as_rgb(int(BACKGROUND0, 16))

        prompt = f"  {USER}  {HOSTNAME} │ "
        screen.draw(prompt)

        screen.cursor.bold = False

    # 3. Den eigentlichen Tab rendern
    screen.cursor.bold = tab.is_active

    # KORREKTUR: Direkte Übergabe der Variablen
    screen.cursor.fg = as_rgb(int(TEXTCOLOR2, 16)) if tab.is_active else as_rgb(int(TEXTCOLOR3, 16))

    screen.draw(f"  {tab.title} ")
    screen.cursor.bold = False

    # 4. Manueller Trennstrich
    # KORREKTUR: Direkte Übergabe der Variable
    screen.cursor.fg = as_rgb(int(TEXTCOLOR3, 16))
    if not is_last:
        screen.draw(" | ")
    else:
        screen.draw(" ")

    return screen.cursor.x
