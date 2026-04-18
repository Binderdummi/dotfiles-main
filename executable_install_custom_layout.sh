#!/usr/bin/env bash
set -euo pipefail

# Prompt for the symbols file path
read -rp "Path to your XKB symbols file: " SYMBOLS_FILE

[[ -f "$SYMBOLS_FILE" ]] || { echo "File not found: $SYMBOLS_FILE"; exit 1; }

# Derive layout name from filename
LAYOUT_NAME="$(basename "$SYMBOLS_FILE")"

XKB_BASE="/usr/share/X11/xkb"

echo "Installing layout '$LAYOUT_NAME'..."

# Copy symbols file
sudo cp "$SYMBOLS_FILE" "${XKB_BASE}/symbols/${LAYOUT_NAME}"
sudo chmod 644 "${XKB_BASE}/symbols/${LAYOUT_NAME}"

# Register in evdev.lst (X11)
if ! grep -q "^  ${LAYOUT_NAME} " "${XKB_BASE}/rules/evdev.lst" 2>/dev/null; then
    sudo sed -i "/^! layout/a\\  ${LAYOUT_NAME}              ${LAYOUT_NAME}" \
        "${XKB_BASE}/rules/evdev.lst"
fi

# Register in evdev.xml (Wayland)
if ! grep -q ">${LAYOUT_NAME}<" "${XKB_BASE}/rules/evdev.xml" 2>/dev/null; then
    sudo python3 - "${XKB_BASE}/rules/evdev.xml" "$LAYOUT_NAME" << 'PYEOF'
import sys
xml_path, name = sys.argv[1], sys.argv[2]
entry = f"""    <layout>
      <configItem>
        <n>{name}</n>
        <shortDescription>{name}</shortDescription>
        <description>{name}</description>
        <languageList><iso639Id>eng</iso639Id></languageList>
      </configItem>
      <variantList/>
    </layout>
"""
content = open(xml_path).read()
open(xml_path, "w").write(content.replace("</layoutList>", entry + "  </layoutList>", 1))
PYEOF
fi

# Activate for current session
SESSION="${XDG_SESSION_TYPE:-unknown}"
if [[ "$SESSION" == "x11" ]] && command -v setxkbmap &>/dev/null; then
    setxkbmap "$LAYOUT_NAME"
    echo "Activated via setxkbmap."
elif [[ "$SESSION" == "wayland" ]] && command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', '${LAYOUT_NAME}')]"
    echo "Activated via gsettings."
else
    echo "Layout installed. Select '$LAYOUT_NAME' in your keyboard settings to activate."
fi

echo "Done."
