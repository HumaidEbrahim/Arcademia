# res://ui/menu/UIScripts/StudentSelection.gd
extends Control

# ---- Scene change paths ----
const PATH_BACK: String          = "res://ui/menu/StartScreen/user_selection.tscn"
const PATH_NEW_STUDENT: String   = "res://ui/menu/StudentScreens/new_student.tscn"
const PATH_AFTER_SELECT: String  = "res://ui/menu/StudentMenu/main_menu.tscn"

# ---- Assets ----
const PATH_FONT: String = "res://assets/IngeUI/LilitaOne-Regular.ttf"
@onready var UI_FONT: Font = preload(PATH_FONT)

# ---- Node refs (match your scene tree) ----
@onready var root_vbox: VBoxContainer = $MarginContainer/VBoxContainer
@onready var title_panel: Panel      = $MarginContainer/VBoxContainer/TitlePanel
@onready var title_label: Label      = $MarginContainer/VBoxContainer/TitlePanel/TitleLabel
@onready var scroll: ScrollContainer = $MarginContainer/VBoxContainer/Scroll
@onready var list:   VBoxContainer   = $MarginContainer/VBoxContainer/Scroll/List
@onready var back:   Button          = $MarginContainer/VBoxContainer/Back

# Created at runtime to center the list in the scroll area
var _center_wrap: CenterContainer

# ---- Layout constants (tweak these) ----
const ROW_HEIGHT := 96           # button height
const MAX_ROWS   := 6
const LIST_WIDTH := 820          # button width (LONGER)
const SCROLLBAR_PAD := 48        # extra width so the scrollbar sits a bit left of screen edge

func _ready() -> void:
	_style_title_chip()
	_style_back_plank()

	# Center the list horizontally inside the ScrollContainer
	_center_horizontally()

	_refresh_list()

	# Push "Back" down
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND
	root_vbox.add_child(spacer)
	root_vbox.move_child(spacer, back.get_index())

	# Keep scroll showing exactly MAX_ROWS
	resized.connect(_fit_scroll_height)
	_fit_scroll_height()

	# Navigation via joystick/keyboard
	set_process_unhandled_input(true)
	_focus_first_button()

# =======================
#   INPUT (JOYSTICK / KB)
# =======================

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_move_focus(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_move_focus(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		var f := get_viewport().gui_get_focus_owner()
		if f is Button:
			f.emit_signal("pressed")
			#get_viewport().set_input_as_handled()

func _list_buttons() -> Array[Button]:
	var out: Array[Button] = []
	for c in list.get_children():
		if c is Button:
			out.append(c)
	return out

func _focus_first_button() -> void:
	var btns := _list_buttons()
	if btns.size() > 0:
		btns[0].grab_focus()
		scroll.ensure_control_visible(btns[0])

func _move_focus(step: int) -> void:
	var btns := _list_buttons()
	if btns.is_empty():
		return

	var current := get_viewport().gui_get_focus_owner()

	# If focus is on Back and we're going down, stay on Back; if going up, go to last list item
	if current == back:
		if step < 0:
			btns[btns.size() - 1].grab_focus()
			scroll.ensure_control_visible(btns.back())
		return

	# We're inside the list; move within list first
	var idx := btns.find(current)
	if idx == -1:
		idx = 0
	var next_idx := idx + step

	# If moving past last item -> go to Back; before first -> stay at first (or wrap to Back if you prefer)
	if next_idx >= btns.size():
		back.grab_focus()
		return
	elif next_idx < 0:
		btns[0].grab_focus()
		scroll.ensure_control_visible(btns[0])
		return

	btns[next_idx].grab_focus()
	scroll.ensure_control_visible(btns[next_idx])

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

#Style for the HEADERPANEL
func _style_title_chip() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#AE6625EE")
	sb.border_color = Color("#3B1F0A")
	_apply_border_all(sb, 4)
	_apply_corner_radius_all(sb, 28)
	sb.content_margin_left = 48
	sb.content_margin_right = 48
	sb.content_margin_top = 18
	sb.content_margin_bottom = 18
	title_panel.add_theme_stylebox_override("panel", sb)
	title_panel.custom_minimum_size.y = 110

	title_label.text = "STUDENT PROFILES"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color("#F1B68F"))
	title_label.add_theme_font_override("font", UI_FONT)
	title_label.add_theme_font_size_override("font_size", 52)

#Style for the BACK BUTTON
func _style_back_plank() -> void:
	var base := StyleBoxFlat.new()
	base.bg_color = Color("#AE6625EE")
	base.border_color = Color("#3B1F0A")
	_apply_border_all(base, 3)
	_apply_corner_radius_all(base, 25)
	base.content_margin_left = 20
	base.content_margin_right = 20
	base.content_margin_top = 12
	base.content_margin_bottom = 12

	var hov := base.duplicate()
	hov.bg_color = Color("EC924CE7")

	var prs := base.duplicate()
	prs.bg_color = Color("#CC7328")

	back.add_theme_stylebox_override("normal", base)
	back.add_theme_stylebox_override("hover",  hov)
	back.add_theme_stylebox_override("focus",hov)
	back.add_theme_stylebox_override("pressed", prs)
	back.add_theme_color_override("font_color", Color("#FFFFFF"))
	back.add_theme_font_override("font", UI_FONT)
	back.add_theme_font_size_override("font_size", 36)
	back.focus_mode = Control.FOCUS_ALL
	back.pressed.connect(func(): get_tree().change_scene_to_file(PATH_BACK))

# =======================
#   LAYOUT / SCROLL
# =======================

func _center_horizontally() -> void:
	# No horizontal scrolling; we control width manually.
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	# Make the ScrollContainer itself a centered, fixed width area so the
	# scrollbar appears just to the right of the buttons (not at screen edge).
	scroll.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	scroll.custom_minimum_size.x = LIST_WIDTH + SCROLLBAR_PAD

	# Wrap the List inside a CenterContainer so the buttons are centered.
	_center_wrap = CenterContainer.new()
	_center_wrap.size_flags_horizontal = Control.SIZE_EXPAND
	_center_wrap.size_flags_vertical = 0

	scroll.remove_child(list)
	_center_wrap.add_child(list)
	scroll.add_child(_center_wrap)

	# VBox: vertical layout only; spacing between rows
	list.add_theme_constant_override("separation", 14)
	list.size_flags_horizontal = 0
	list.size_flags_vertical = 0

func _fit_scroll_height() -> void:
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

	var new_btn := _make_plank_button("  +  New Profile  +  ", true)
	new_btn.pressed.connect(func():
		get_tree().change_scene_to_file(PATH_NEW_STUDENT))
	list.add_child(new_btn)

	for s in ProfileDB.sorted_students():
		var name: String = String(s.get("name", ""))
		var btn := _make_plank_button(name, false)
		# capture both the index (avatar number) and the student data
		var avatar_num = int(s.get("avatar", 0))
		btn.pressed.connect(func(avatar :int= avatar_num):
			Global.SelectedCharacter = avatar;
			get_tree().change_scene_to_file(PATH_AFTER_SELECT)
)
		list.add_child(btn)

	await get_tree().process_frame
	_fit_scroll_height()
	_focus_first_button()

# =======================
#   BUTTON FACTORY
# =======================

func _make_plank_button(text: String, accent: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_ALL

	# Fixed width; CenterContainer keeps it centered
	b.custom_minimum_size = Vector2(LIST_WIDTH, ROW_HEIGHT)
	b.size_flags_horizontal = 0

	var base := StyleBoxFlat.new()
	if accent:
		base.bg_color = Color("#F4C842")
		base.border_color = Color("#D1A935")
	else:
		base.bg_color = Color("#AE6625EE")
		base.border_color = Color("#3B1F0A")

	_apply_border_all(base, 3)
	_apply_corner_radius_all(base, 25)
	base.content_margin_left = 24
	base.content_margin_right = 24
	base.content_margin_top = 14
	base.content_margin_bottom = 14

	var hov := base.duplicate()
	hov.bg_color = Color("#F7D454") if accent else Color("#F2913A")

	var prs := base.duplicate()
	prs.bg_color = Color("#AE6625EE") if accent else Color("EC924CE7")

	b.add_theme_stylebox_override("normal", base)
	b.add_theme_stylebox_override("hover",  hov)
	b.add_theme_stylebox_override("focus",hov)
	b.add_theme_stylebox_override("pressed", prs)
	b.add_theme_color_override("font_color", Color("#FFFFFF"))
	b.add_theme_font_override("font", UI_FONT)
	b.add_theme_font_size_override("font_size", 40)

	return b
