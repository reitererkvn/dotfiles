import os
import sys
import socket
from pathlib import Path
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

assets_path = str(Path.home() / ".config/hypr/assets")
if assets_path not in sys.path:
    sys.path.append(assets_path)
import colors

# System-Envs
USER = os.getenv("USER", "kevin")
HOSTNAME = socket.gethostname()
HOME_DIR = os.path.expanduser("~")

# Definition der kritischen Prozesse (Naturwissenschaftliche Signalisierung)
CRITICAL_PROCS = ["ssh", "sudo", "su", "root"]

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

    # 1. Daten-Demultiplexing
    raw_signal = tab.title.strip()
    signal_parts = raw_signal.split(":::")

    active_process = signal_parts[0]
    raw_path = signal_parts[1] if len(signal_parts) > 1 else raw_signal

    # Pfad-Auflösung
    if raw_path.startswith(HOME_DIR):
        path = raw_path.replace(HOME_DIR, "~", 1)
    else:
        path = raw_path

    if not path or path == "kitty":
        path = "~"

    is_critical = any(proc in active_process for proc in CRITICAL_PROCS)

    # 2. Statischer Global-Prompt
    if index == 1:
        # Heuristik für dynamische User-Erkennung
        current_user = f"{USER}" # Fallback (kevin)

        # Fall 1: Shell sendet explizit user@host
        if "@" in active_process:
            current_user = active_process.split("@")[0]
        # Fall 2: Wenn wir im absoluten root-Verzeichnis sind
        elif path.startswith("/root") or path == "/root":
            current_user = "root"
        # Fall 3: Der Prozess ist eine direkte Rechte-Eskalation
        elif active_process.startswith("su ") or active_process == "su":
            current_user = "root"

        screen.cursor.bold = True
        screen.cursor.fg = as_rgb(int(colors.TEXTCOLOR2[:6], 16))
        screen.cursor.bg = as_rgb(int(colors.BACKGROUND0[:6], 16))

        prompt = f"  {current_user}  {HOSTNAME} │"
        screen.draw(prompt)
        screen.cursor.bold = False

    # 3. Dynamischer Tab-Render
    screen.cursor.bold = tab.is_active

    # Anti-Flicker State-Machine
    if is_critical:
        # ALERT: Zeigt den gefährlichen Prozessnamen in Rot
        screen.cursor.fg = as_rgb(int(colors.WARNING_COLOR, 16))
        display_title = f"   {active_process} "
    elif active_process != "idle":
        # NEU: Normale laufende Prozesse (zeigt Befehl + Pfad)
        color_active = colors.TEXTCOLOR2[:6] if tab.is_active else colors.TEXTCOLOR3[:6]
        screen.cursor.fg = as_rgb(int(color_active, 16))
        display_title = f"   {active_process} "
    else:
        # NORMAL: Zeigt IMMER den aktuellen Pfad des Tabs
        # Befehle im Millisekundenbereich werden gerendert, stören aber die Pfadanzeige nicht
        screen.cursor.fg = as_rgb(int(colors.TEXTCOLOR2, 16)) if tab.is_active else as_rgb(int(colors.TEXTCOLOR3, 16))
        display_title = f"   {path} "

    screen.draw(display_title)
    screen.cursor.bold = False

    # 4. Trennstrich
    screen.cursor.fg = as_rgb(int(colors.TEXTCOLOR3, 16))
    if not is_last:
        screen.draw(" | ")
    else:
        screen.draw(" ")

    return screen.cursor.x
