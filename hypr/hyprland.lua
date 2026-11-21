-- Hyprland Lua config (converted from hyprland.conf)
-- Wiki: https://wiki.hypr.land/Configuring/Start/


------------------
---- MONITORS ----
------------------

-- Monitor AOC (144Hz) - Posição inicial (0x0)
hl.monitor({
    output   = "DP-2",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1,
})

-- Monitor Acer (60Hz) - Posicionado à direita do principal (1920x0)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "1920x0",
    scale    = 1,
})


---------------------
---- PROGRAMAS ------
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"


-------------------------------
---- VARIÁVEIS DE AMBIENTE ----
-------------------------------

-- Tema escuro para apps Qt
hl.env("QT_QPA_PLATFORMTHEME", "kvantum")

-- Forçar backend Wayland no Qt e GTK
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    -- Dark mode
    hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"')  -- GTK3
    hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"') -- GTK4

    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
end)


----------------
---- CORES -----
----------------

-- Reads $name = value lines from colors.conf (the old hyprlang format),
-- so your color generator can keep writing that file.
local function load_hypr_colors(path)
    local colors = {}
    local f = io.open(path, "r")
    if not f then return colors end
   for raw in f:lines() do
    local line = raw:gsub("#.*$", "")
        local name, value = line:match("^%s*%$([%w_]+)%s*=%s*(.-)%s*$")
        if name and value ~= "" then
            colors[name] = value
        end
    end
    f:close()
    return colors
end

local colors = load_hypr_colors(os.getenv("HOME") .. "/.config/hypr/colors.conf")


-----------------------
---- APARÊNCIA --------
-----------------------

hl.config({
    general = {
        gaps_in  = 7,
        gaps_out = 17,

        border_size = 2,

        col = {
            active_border   = colors.secondary or "rgba(33ccffee)",
            inactive_border = colors.outline_variant or "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 8,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range   = 4,
        },
    },

    -- Abrir uma janela nova sai do modo tela cheia e divide a tela
    misc = {
        on_focus_under_fullscreen = 2,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
    },
})


---------------------
---- ATALHOS --------
---------------------

local mainMod = "SUPER"

-- Atalhos de aplicativo
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("pkill rofi || ~/.config/rofi/launchers/type-1/launcher.sh"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.config/waybar/scripts/launch.sh"))

-- Gerenciamento de janelas
hl.bind(mainMod .. " + Escape", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + M", hl.dsp.exit())

-- Alternar modo tela cheia (maximizado, mantém gaps e waybar)
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Mover o foco entre janelas com SUPER + setas
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- SUPER + [0-9]: mudar de área de trabalho
-- SUPER + SHIFT + [0-9]: mover a janela ativa para a área de trabalho
for i = 1, 10 do
    local key = i % 10 -- workspace 10 usa a tecla 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end


------------------------
---- REGRAS DE JANELA ---
------------------------

hl.window_rule({
    -- Ignore maximize requests from all apps
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

--- Screenshots
-- SUPER + SHIFT + S: select an area and copy it to the clipboard
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- SUPER + SHIFT + A: select an area and save it to a file
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd('grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png'))

-- SUPER + SHIFT + P: whole screen, saved to a file
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd('grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png'))