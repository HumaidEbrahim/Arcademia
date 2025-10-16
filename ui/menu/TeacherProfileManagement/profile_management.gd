extends Control

# ---- Scene change paths ----
const PATH_BACK: String          = "res://ui/menu/StartScreen/user_selection.tscn"
const PATH_NEW_STUDENT: String   = "res://ui/menu/TeacherProfileManagement/insert.tscn"
const PATH_AFTER_SELECT: String  = ""
const UPDATE_PATH := "res://ui/menu/TeacherProfileManagement/update.tscn"

# ---- Assets ----
const PATH_FONT:   String = "res://assets/IngeUI/LilitaOne-Regular.ttf"
const PATH_STAR:   String = "res://assets/IngeUI/UIIcons/star.png"
const PATH_PENCIL: String = "res://assets/IngeUI/UIIcons/pencil.png"
const PATH_TRASH:  String = "res://assets/IngeUI/UIIcons/trash.png"

@onready var UI_FONT: Font          = preload(PATH_FONT)
@onready var STAR_ICON: Texture2D   = preload(PATH_STAR)
@onready var PENCIL_ICON: Texture2D = preload(PATH_PENCIL)
@onready var TRASH_ICON: Texture2D  = preload(PATH_TRASH)

# ---- Node refs ----
@onready var root_vbox: VBoxContainer = $MarginContainer/VBoxContainer
@onready var title_panel: Panel      = $MarginContainer/VBoxContainer/TitlePanel
@onready var title_label: Label      = $MarginContainer/VBoxContainer/TitlePanel/TitleLabel
@onready var scroll: ScrollContainer = $MarginContainer/VBoxContainer/Scroll
@onready var list: VBoxContainer     = $MarginContainer/VBoxContainer/Scroll/List
@onready var back: Button            = $MarginContainer/VBoxContainer/Back

# ---- Layout constants ----
const ROW_HEIGHT := 96
const LIST_WIDTH := 820
const SCROLLBAR_PAD := 48
const ICON_SIZE := 32
const ICON_SPACING := 12

var _center_wrap: CenterContainer

# =======================
# READY
# =======================
func _ready() -> void:
	_style_title_chip()
	_style_back_plank()
	_center_horizontally()
	_refresh_list()

	# Push back button down
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND
	root_vbox.add_child(spacer)
	root_vbox.move_child(spacer, back.get_index())

	resized.connect(_fit_scroll_height)
	_fit_scroll_height()

	set_process_unhandled_input(true)
	_focus_first_button()

# =======================
# INPUT NAVIGATION
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
		if f is Button or f is TextureButton:
			f.emit_signal("pressed")

func _list_buttons() -> Array:
	var out: Array = []
	for row in list.get_children():
		if row is Panel:
			var hb := row.get_node_or_null("HBox")
			if hb:
				for child in hb.get_children():
					if child is Button or child is TextureButton:
						out.append(child)
	 # Back button included at end
	return out

func _focus_first_button() -> void:
	var btns := _list_buttons()
	if btns.size() > 0:
		btns[0].grab_focus()
		scroll.ensure_control_visible(btns[0])

func _move_focus(step: int) -> void:
		var btns := _list_buttons()
		if btns.is_empty(): return
		if(back.has_focus()):
			btns[0].grab_focus();
			scroll.ensure_control_visible(btns[0])
			return
		var current := get_viewport().gui_get_focus_owner()
		var idx := btns.find(current)
		if idx == -1: idx = 0
		var next_idx := idx + step
		back.focus_mode = FOCUS_NONE
		if next_idx >= btns.size():
			back.focus_mode = FOCUS_ALL
			back.grab_focus();
			return
		elif next_idx < 0:
			back.focus_mode = FOCUS_ALL;
			back.grab_focus()
			scroll.ensure_control_visible(btns[btns.size() - 1])
			return
		back.focus_mode = Control.FOCUS_NONE
		btns[next_idx].grab_focus()
		scroll.ensure_control_visible(btns[next_idx])

# =======================
# STYLES / HELPERS
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
	sb.bg_color = Color("#AE6625EE")
	sb.border_color = Color("#3B1F0A")
	_apply_border_all(sb, 4)
	_apply_corner_radius_all(sb, 28)
	title_panel.add_theme_stylebox_override("panel", sb)
	title_panel.custom_minimum_size.y = 110

	title_label.text = "PROFILE MANAGEMENT"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color("#F1B68F"))
	title_label.add_theme_font_override("font", UI_FONT)
	title_label.add_theme_font_size_override("font_size", 52)

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
	hov.bg_color = Color("#EC924CE7")
	var prs := base.duplicate()
	prs.bg_color = Color("#CC7328")

	back.add_theme_stylebox_override("normal", base)
	back.add_theme_stylebox_override("hover", hov)
	back.add_theme_stylebox_override("focus", hov)
	back.add_theme_stylebox_override("pressed", prs)
	back.add_theme_color_override("font_color", Color("#FFFFFF"))
	back.add_theme_font_override("font", UI_FONT)
	back.add_theme_font_size_override("font_size", 36)
	back.focus_mode = Control.FOCUS_NONE
	back.pressed.connect(func(): get_tree().change_scene_to_file(PATH_BACK))

# =======================
# LAYOUT / SCROLL
# =======================
func _center_horizontally() -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	scroll.custom_minimum_size.x = LIST_WIDTH + SCROLLBAR_PAD

	_center_wrap = CenterContainer.new()
	_center_wrap.size_flags_horizontal = Control.SIZE_EXPAND
	_center_wrap.size_flags_vertical = 0

	scroll.remove_child(list)
	_center_wrap.add_child(list)
	scroll.add_child(_center_wrap)

	list.add_theme_constant_override("separation", 14)
	list.size_flags_horizontal = 0
	list.size_flags_vertical = 0

func _fit_scroll_height() -> void:
	var sep := 12
	if list != null:
		sep = list.get_theme_constant("separation")
	scroll.custom_minimum_size.y = (ROW_HEIGHT * 6) + (sep * (6 - 1))

# =======================
# POPULATE LIST
# =======================
func _refresh_list() -> void:
	for c in list.get_children():
		c.queue_free()

	# New Profile row
	var new_row := _make_row_panel("  +  New Profile  +  ", true, true)
	var new_btn: Button = new_row.get_node("HBox/MainButton")
	new_btn.pressed.connect(func(): get_tree().change_scene_to_file(PATH_NEW_STUDENT))
	list.add_child(new_row)

	# Existing profiles
	for s in ProfileDB.sorted_students():
		var student_name: String = String(s.get("name", ""))
		var row := _make_row_panel(student_name, false, false)
		var main_btn: Button = row.get_node("HBox/MainButton")
		main_btn.pressed.connect(func():
			Global.PersonToEdit = student_name
			get_tree().change_scene_to_file(UPDATE_PATH)
		)
		list.add_child(row)

	await get_tree().process_frame
	_fit_scroll_height()
	_focus_first_button()

# =======================
# ROW FACTORY
# =======================
func _make_row_panel(text: String, accent: bool, is_new: bool) -> Panel:
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(LIST_WIDTH, ROW_HEIGHT)

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#F4C842") if accent else Color("#AE6625EE")
	sb.border_color = Color("#D1A935") if accent else Color("#3B1F0A")
	_apply_border_all(sb, 3)
	_apply_corner_radius_all(sb, 22)
	panel.add_theme_stylebox_override("panel", sb)

	var h := HBoxContainer.new()
	h.name = "HBox"
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.custom_minimum_size = Vector2(LIST_WIDTH, ROW_HEIGHT)
	h.add_theme_constant_override("separation", ICON_SPACING)
	panel.add_child(h)

	# Main button
	var btn := Button.new()
	btn.name = "MainButton"
	btn.text = text
	btn.focus_mode = Control.FOCUS_ALL
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_override("font", UI_FONT)
	btn.add_theme_font_size_override("font_size", 36)
	btn.add_theme_color_override("font_color", Color.WHITE)
	var bstyle := StyleBoxFlat.new()
	bstyle.bg_color = Color(0,0,0,0)
	var vstyle := StyleBoxFlat.new()
	vstyle.bg_color = Color(0.9, 0.85, 0.084, 1.0)
	btn.add_theme_stylebox_override("normal", bstyle)
	btn.add_theme_stylebox_override("hover", bstyle)
	btn.add_theme_stylebox_override("pressed", bstyle)

	var hov := sb.duplicate()
	hov.bg_color = Color("EC924CE7")
	btn.add_theme_stylebox_override("focus", hov)
	h.add_child(btn)

	# Right-side icons
	#if not is_new:
	#	h.add_child(_make_icon_button(STAR_ICON, func(): _on_star_clicked(text)))
	#	h.add_child(_make_icon_button(TRASH_ICON, func(): _on_delete_clicked(text)))

	return panel

#func _make_icon_button(tex: Texture2D, cb: Callable) -> TextureButton:
#	var t := TextureButton.new()
#	t.texture_normal = tex
#	t.focus_mode = Control.FOCUS_ALL
#	t.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
#	t.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
#	t.modulate = Color.WHITE
#	t.mouse_entered.connect(func(): t.modulate = Color(1.1,1.1,1.1))
#	t.mouse_exited.connect(func(): if not t.has_focus(): t.modulate = Color.WHITE)
#	t.focus_entered.connect(func(): t.modulate = Color(0.9, 0.85, 0.084, 1.0))
#	t.focus_exited.connect(func(): t.modulate = Color.WHITE)
#	t.pressed.connect(cb)
#	return t

# =======================
# ICON CALLBACKS
# =======================
#func _on_star_clicked(student_name: String) -> void:
#	print("Star clicked:", student_name)

#func _on_edit_clicked(student_name: String) -> void:
#	Global.PersonToEdit = student_name
#	get_tree().change_scene_to_file(UPDATE_PATH)

#func _on_delete_clicked(student_name: String) -> void:
#	Global.PersonToGogga = student_name
#	ProfileDB.delete_student(student_name)
#	get_tree().reload_current_scene()
