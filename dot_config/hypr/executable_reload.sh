pkill hyprpaper
pkill waybar
pkill sway_nc
pkill kanata
pkill ydotoold
hyprpaper &
waybar -s .config/waybar/coffe/style.css -c .config/waybar/coffe/config.jsonc &
swaync &
hyprctl setcursor Bibata-Modern-Ice 24 &
kanata -c /home/archibald_baller/.kanata.kbd &
systemctl --user start hyprpolkitagent &
hyprpm reload -n &
ydotoold &
