# Holo Defense — Reward Panel StyleBox Resources
# ================================================
# All files target Godot 4 / GDScript.
# Drop this folder into res://ui/styles/reward_panels/

## FILE LIST

panel_base.tres           — PanelContainer "panel" style (dark glass, rounded, blue border)
panel_header.tres         — PanelContainer or ColorRect at top of each panel (header bar)
panel_total_row.tres      — PanelContainer for the currency total row at bottom of panel 2
metric_tile_default.tres  — PanelContainer for plain grid tiles (enemies killed, time)
metric_tile_highlight.tres— PanelContainer for the blue-accent tile (wave reached)
metric_tile_gold.tres     — PanelContainer for the gold-accent tile (score / best)
item_row_hover.tres       — Button or PanelContainer hover bg for item list rows
btn_primary_normal.tres   — Button "normal" StyleBox (Play again)
btn_primary_hover.tres    — Button "hover" StyleBox
btn_primary_pressed.tres  — Button "pressed" StyleBox
btn_secondary_normal.tres — Button "normal" StyleBox (Main menu)
btn_secondary_hover.tres  — Button "hover" StyleBox
btn_secondary_pressed.tres— Button "pressed" StyleBox
separator_glow.tres       — HSeparator above the total row (bright)
separator_subtle.tres     — HSeparator between stat rows (dim)


## PANEL 1 — RUN SUMMARY (2×2 metric grid)

PanelContainer
  └── add_theme_stylebox_override("panel", panel_base.tres)
	  └── VBoxContainer
			├── PanelContainer  [header]
			│     └── add_theme_stylebox_override("panel", panel_header.tres)
			│         └── HBoxContainer
			│               ├── Label  "RUN SUMMARY"
			│               └── Label  "VICTORY"  (badge)
			└── GridContainer  (columns = 2, padding 16px)
				  ├── PanelContainer  add_theme_stylebox_override("panel", metric_tile_highlight.tres)
				  │     └── VBoxContainer
				  │           ├── Label  "WAVE REACHED"   (label style — small, muted)
				  │           ├── Label  "24"             (value style — large, blue)
				  │           └── Label  "of 25 total"    (sub style — tiny, muted)
				  ├── PanelContainer  add_theme_stylebox_override("panel", metric_tile_gold.tres)
				  │     └── VBoxContainer  [SCORE tile]
				  ├── PanelContainer  add_theme_stylebox_override("panel", metric_tile_default.tres)
				  │     └── VBoxContainer  [ENEMIES KILLED tile]
				  └── PanelContainer  add_theme_stylebox_override("panel", metric_tile_default.tres)
						└── VBoxContainer  [TIME SURVIVED tile]


## PANEL 2 — CURRENCY EARNED

PanelContainer
  └── add_theme_stylebox_override("panel", panel_base.tres)
	  └── VBoxContainer
			├── PanelContainer   [header — panel_header.tres]
			├── VBoxContainer    [stat rows, padding 16/18]
			│     ├── HBoxContainer  [Base reward row]
			│     ├── HSeparator     add_theme_stylebox_override("separator", separator_subtle.tres)
			│     ├── HBoxContainer  [Wave bonus row]
			│     ├── HSeparator     separator_subtle.tres
			│     ├── HBoxContainer  [Kill bonus row]
			│     ├── HSeparator     separator_subtle.tres
			│     └── HBoxContainer  [Difficulty multiplier row]
			├── HSeparator           add_theme_stylebox_override("separator", separator_glow.tres)
			└── PanelContainer       add_theme_stylebox_override("panel", panel_total_row.tres)
				  └── HBoxContainer
						├── Label  "TOTAL"
						└── Label  "1,038 shards"


## PANEL 3 — ITEMS UNLOCKED

PanelContainer
  └── add_theme_stylebox_override("panel", panel_base.tres)
	  └── VBoxContainer
			├── PanelContainer  [header — panel_header.tres]
			└── VBoxContainer   [item list, padding 16/18]
				  └── (repeat per item):
						Button or PanelContainer
						  add_theme_stylebox_override("normal",  item_row_hover.tres)  ← hover only;
						  leave normal state as StyleBoxEmpty for the transparent default
						  └── HBoxContainer
								├── PanelContainer  [icon box — metric_tile_default.tres, 36×36]
								│     └── Label  "★"
								├── VBoxContainer
								│     ├── Label  "Void Prism"   (name)
								│     └── Label  "Rare turret mod"  (desc)
								└── Label  "×1"  (quantity)


## PANEL 4 — ACTION BUTTONS

PanelContainer
  └── add_theme_stylebox_override("panel", panel_base.tres)  ← or StyleBoxEmpty if you want no bg
	  └── HBoxContainer  [padding 14/18]
			├── Button  "MAIN MENU"
			│     add_theme_stylebox_override("normal",  btn_secondary_normal.tres)
			│     add_theme_stylebox_override("hover",   btn_secondary_hover.tres)
			│     add_theme_stylebox_override("pressed", btn_secondary_pressed.tres)
			└── Button  "PLAY AGAIN"
				  add_theme_stylebox_override("normal",  btn_primary_normal.tres)
				  add_theme_stylebox_override("hover",   btn_primary_hover.tres)
				  add_theme_stylebox_override("pressed", btn_primary_pressed.tres)


## COLORS FOR LABELS (add to your Theme or set per-node)

Muted label (section headers, descriptions):
  Color(0.63, 0.75, 0.94, 0.65)   →  rgba(160, 190, 240, 0.65)

Primary value text (numbers):
  Color(0.78, 0.87, 1.0, 1.0)     →  #c8deff

Green value (bonuses, positive deltas):
  Color(0.36, 0.91, 0.66, 1.0)    →  #5de8a8

Gold value (score, multipliers):
  Color(0.96, 0.78, 0.26, 1.0)    →  #f5c842

Purple value (rare/epic items):
  Color(0.75, 0.52, 0.99, 1.0)    →  #c084fc

Total value text (large number):
  Color(0.91, 0.95, 1.0, 1.0)     →  #e8f2ff

Badge text — victory:  Color(0.36, 0.91, 0.66, 1.0)
Badge text — wave:     Color(0.48, 0.67, 1.0, 1.0)
Badge text — rare:     Color(0.75, 0.52, 0.99, 1.0)
