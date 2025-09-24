# res://ui/menu/UIScripts/StudentSelection.gd
extends Control

# ---- Scene change paths ----
const PATH_BACK: String          = "res://ui/menu/Selection/user_selection.tscn"
const PATH_NEW_STUDENT: String   = "res://ui/menu/Login/new_student.tscn"
const PATH_AFTER_SELECT: String  = "res://ui/menu/MainMenu/main_menu.tscn"

# ---- Node refs (match your scene tree) ----
@onready var title_panel: Panel      = $MarginContainer/VBoxContainer/TitlePanel
@onready var title_label: Label      = $MarginContainer/VBoxContainer/TitlePanel/TitleLabel
@onready var scroll: ScrollContainer = $MarginContainer/VBoxContainer/Scroll
@onready var list:   VBoxContainer   = $MarginContainer/VBoxContainer/Scroll/List
@onready var back:   Button          = $MarginContainer/VBoxContainer/Back

# ---- Layout constants ----
const ROW_HEIGHT := 84
const MAX_ROWS   := 5

func _ready() -> void:
	_style_title_chip()
	_style_back_plank()
	_refresh_list()
	resized.connect(_fit_scroll_height)   # Control's resize signal in Godot 4
	_fit_scroll_height()

# =======================
#   STYLES / HELPERS
# =======================

func _apply_border_all(sb: StyleBoxFlat, w: int) -> void:
	for s in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		sb.set_border_width(s, w)

func _apply_corner_radius_all(sb: StyleBoxFlat, r: int) -> void:
	sb.corner_radius_top_left = r
	sb.corner_radius_top_right = r
	sb.corner_radius_bottom_left = r
	sb.corner_radius_bottom_right = r

func _style_title_chip() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#9C6735")
	sb.border_color = Color("#6E4623")
	_apply_border_all(sb, 3)
	_apply_corner_radius_all(sb, 24)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	title_panel.add_theme_stylebox_override("panel", sb)

	title_label.text = "STUDENT PROFILES"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color("#AE6625"))
	title_label.add_theme_font_size_override("font_size", 44)

func _style_back_plank() -> void:
	var base := StyleBoxFlat.new()
	base.bg_color = Color("#A2703D")
	base.border_color = Color("#6E4623")
	_apply_border_all(base, 3)
	_apply_corner_radius_all(base, 22)
	base.content_margin_left = 18
	base.content_margin_right = 18
	base.content_margin_top = 10
	base.content_margin_bottom = 10

	var hov := base.duplicate()
	hov.bg_color = Color("#B8824B")

	var prs := base.duplicate()
	prs.bg_color = Color("#7D5530")

	back.add_theme_stylebox_override("normal", base)
	back.add_theme_stylebox_override("hover",  hov)
	back.add_theme_stylebox_override("pressed", prs)
	back.add_theme_color_override("font_color", Color("#FFF6DF"))
	back.add_theme_font_size_override("font_size", 34)
	back.focus_mode = Control.FOCUS_ALL
	back.pressed.connect(func(): get_tree().change_scene_to_file(PATH_BACK))

# =======================
#   LAYOUT / SCROLL
# =======================

func _fit_scroll_height() -> void:
	# Show exactly 5 rows; overflow scrolls
	var sep := 12
	if list != null:
		sep = list.get_theme_constant("separation")
	scroll.custom_minimum_size.y = (ROW_HEIGHT * MAX_ROWS) + (sep * (MAX_ROWS - 1))

# =======================
#   POPULATE LIST
# =======================

func _refresh_list() -> void:
	for c in list.get_children():
		c.queue_free()

	# Top: New Profile (accent)
	var new_btn := _make_plank_button("  +  New Profile  +  ", true)
	new_btn.pressed.connect(func():
		get_tree().change_scene_to_file(PATH_NEW_STUDENT))
	list.add_child(new_btn)

	# Existing students (alphabetical) -> Main Menu
	for s in ProfileDB.sorted_students():
		var name: String = String(s.get("name", ""))
		var btn := _make_plank_button(name, false)
		btn.pressed.connect(func():
			ProfileDB.set_active(name)
			get_tree().change_scene_to_file(PATH_AFTER_SELECT))
		list.add_child(btn)

	await get_tree().process_frame
	_fit_scroll_height()

# =======================
#   BUTTON FACTORY
# =======================

func _make_plank_button(text: String, accent: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_ALL
	b.custom_minimum_size.y = ROW_HEIGHT

	var base := StyleBoxFlat.new()
	base.bg_color = Color("#B8824B") if accent else Color("#A2703D")
	base.border_color = Color("#6E4623")
	_apply_border_all(base, 3)
	_apply_corner_radius_all(base, 22)
	base.content_margin_left = 18
	base.content_margin_right = 18
	base.content_margin_top = 10
	base.content_margin_bottom = 10

	var hov := base.duplicate()
	hov.bg_color = Color("#C89156") if accent else Color("#B8824B")

	var prs := base.duplicate()
	prs.bg_color = Color("#98693C") if accent else Color("#7D5530")

	b.add_theme_stylebox_override("normal", base)
	b.add_theme_stylebox_override("hover",  hov)
	b.add_theme_stylebox_override("pressed", prs)
	b.add_theme_color_override("font_color", Color("#FFF6DF"))
	b.add_theme_font_size_override("font_size", 38)

	return b
