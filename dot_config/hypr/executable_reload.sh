pkill hyprpaper
pkill waybar
pkill sway_nc
pkill kanata
pkill ydotoold
hyprctl reload
hyprpaper &
waybar -s .config/waybar/mocha/style.css -c .config/waybar/mocha/config.jsonc &
swaync &
hyprctl setcursor Bibata-Modern-Ice 24 &
kanata -c /home/archibald_baller/.kanata.kbd &
systemctl --user start hyprpolkitagent &
hyprpm reload -n &
ydotoold &
