# res://ui/menu/StudentScreens/update_student.gd
extends Control

const STUDENT_SELECTION_PATH := "res://ui/menu/Selection/student_selection.tscn"
const MAIN_MENU_PATH         := "res://ui/menu/StudentMenu/main_menu.tscn"
const PROFILE_MANAGEMENT_PATH := "res://ui/menu/TeacherProfileManagement/profile_management.tscn"

var PersonToUpdate: String = Global.PersonToEdit

# --------- Bottom buttons ---------
@onready var btn_back  : BaseButton = $Card/BtnBack
@onready var btn_enter : BaseButton = $Card/BtnEnter

# --------- NAME INPUT (6-character spinner) ---------
@onready var label_enter_name: Label = $Card/Label
# Char 1
@onready var label_one:      Label  = $Card/Input/ScrollOne/LabelOne
@onready var btn_up_one:     BaseButton = $Card/Input/ScrollOne/ScrollUpOne
@onready var btn_down_one:   BaseButton = $Card/Input/ScrollOne/ScrollDownOne
# Char 2
@onready var label_two:      Label  = $Card/Input/ScrollTwo/LabelTwo
@onready var btn_up_two:     BaseButton = $Card/Input/ScrollTwo/ScrollUpTwo
@onready var btn_down_two:   BaseButton = $Card/Input/ScrollTwo/ScrollDownTwo
# Char 3
@onready var label_three:    Label  = $Card/Input/ScrollThree/LabelThree
@onready var btn_up_three:   BaseButton = $Card/Input/ScrollThree/ScrollUpThree
@onready var btn_down_three: BaseButton = $Card/Input/ScrollThree/ScrollDownThree
# Char 4
@onready var label_four:     Label  = $Card/Input/ScrollFour/LabelFour
@onready var btn_up_four:    BaseButton = $Card/Input/ScrollFour/ScrollUpFour
@onready var btn_down_four:  BaseButton = $Card/Input/ScrollFour/ScrollDownFour
# Char 5
@onready var label_five:     Label  = $Card/Input/ScrollFive/LabelFive
@onready var btn_up_five:    BaseButton = $Card/Input/ScrollFive/ScrollUpFive
@onready var btn_down_five:  BaseButton = $Card/Input/ScrollFive/ScrollDownFive
# Char 6
@onready var label_six:      Label  = $Card/Input/ScrollSix/LabelSix
@onready var btn_up_six:     BaseButton = $Card/Input/ScrollSix/ScrollUpSix
@onready var btn_down_six:   BaseButton = $Card/Input/ScrollSix/ScrollDownSix

# --------- AVATAR PANEL (right) ---------
@onready var avatar_image : TextureRect = $CardAvatar/AvatarImage
@onready var btn_switch   : Button      = $CardAvatar/BtnSwitch

# --------- AVATAR textures ---------
const AVATAR_BOY  : Texture2D = preload("res://assets/IngeUI/UIAvatars/stickerboy.png")
const AVATAR_GIRL : Texture2D = preload("res://assets/IngeUI/UIAvatars/stickergirl.png")

# --------- WHITE FOCUS ICONS ---------
const ICON_UP_WHITE   : Texture2D = preload("res://assets/IngeUI/UIIcons/triangleupwhite.png")
const ICON_DOWN_WHITE : Texture2D = preload("res://assets/IngeUI/UIIcons/triangledownwhite.png")

# --------- DATA ---------
# 0 = boy, 1 = girl
var selected_character: int = 0
var alphabet := ['-', 'Z','Y','X','W','V','U','T','S','R','Q','P','O','N','M','L','K','J','I','H','G','F','E','D','C','B','A']
# var alphabet := ['-', 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']

func _ready() -> void:
	# Wire buttons
	btn_back.pressed.connect(_on_back_pressed)
	btn_enter.pressed.connect(_on_enter_pressed)

	# Name spinners wiring
	label_enter_name.text = "ENTER NAME"
	btn_up_one.pressed.connect(func(): _cycle_char_up(label_one))
	btn_down_one.pressed.connect(func(): _cycle_char_down(label_one))

	btn_up_two.pressed.connect(func(): _cycle_char_up(label_two))
	btn_down_two.pressed.connect(func(): _cycle_char_down(label_two))

	btn_up_three.pressed.connect(func(): _cycle_char_up(label_three))
	btn_down_three.pressed.connect(func(): _cycle_char_down(label_three))

	btn_up_four.pressed.connect(func(): _cycle_char_up(label_four))
	btn_down_four.pressed.connect(func(): _cycle_char_down(label_four))

	btn_up_five.pressed.connect(func(): _cycle_char_up(label_five))
	btn_down_five.pressed.connect(func(): _cycle_char_down(label_five))

	btn_up_six.pressed.connect(func(): _cycle_char_up(label_six))
	btn_down_six.pressed.connect(func(): _cycle_char_down(label_six))

	# Pre-fill the spinner with the existing name
	_populate_name_spinners(PersonToUpdate)

	# Avatar: start from the user's current avatar (fallback to 0 if missing)
	selected_character = _get_current_avatar_index(PersonToUpdate)
	Global.SelectedCharacter = selected_character
	_update_avatar_visuals()
	btn_switch.pressed.connect(_on_switch_avatar)

	# ---- Focus → white icon wiring for ALL scroll buttons ----
	# Works for Button or TextureButton.
	_attach_focus_icon(btn_up_one,   ICON_UP_WHITE)
	_attach_focus_icon(btn_down_one, ICON_DOWN_WHITE)
	_attach_focus_icon(btn_up_two,   ICON_UP_WHITE)
	_attach_focus_icon(btn_down_two, ICON_DOWN_WHITE)
	_attach_focus_icon(btn_up_three, ICON_UP_WHITE)
	_attach_focus_icon(btn_down_three, ICON_DOWN_WHITE)
	_attach_focus_icon(btn_up_four,  ICON_UP_WHITE)
	_attach_focus_icon(btn_down_four,ICON_DOWN_WHITE)
	_attach_focus_icon(btn_up_five,  ICON_UP_WHITE)
	_attach_focus_icon(btn_down_five,ICON_DOWN_WHITE)
	_attach_focus_icon(btn_up_six,   ICON_UP_WHITE)
	_attach_focus_icon(btn_down_six, ICON_DOWN_WHITE)

	# Give initial focus so the effect is visible immediately
	btn_down_one.grab_focus()


# =========================================================
# Helpers: Focus icon handling (Option 3)
# =========================================================
func _attach_focus_icon(btn: BaseButton, white_tex: Texture2D) -> void:
	# If it's a TextureButton, use built-in focused texture.
	if btn is TextureButton:
		var tb := btn as TextureButton
		tb.texture_focused = white_tex
		tb.focus_mode = Control.FOCUS_ALL
		return

	# Otherwise treat it as a regular Button using the `icon` property.
	# Save the original icon once, then swap on focus in/out.
	if btn is Button:
		var b := btn as Button
		b.focus_mode = Control.FOCUS_ALL
		var original_icon: Texture2D = b.icon
		b.focus_entered.connect(func(): b.icon = white_tex)
		b.focus_exited.connect(func():  b.icon = original_icon)


# --------- NAVIGATION ---------
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(PROFILE_MANAGEMENT_PATH)

func _on_enter_pressed() -> void: # check for appropriate length and Read/Save entered name 
	var nameLabels = [label_one, label_two, label_three, label_four, label_five, label_six]
	var charCount = 0
	var newPlayerName = ""
	
	for label in nameLabels:
		if label.text != '-':
			charCount += 1
			newPlayerName += label.text
			
	if charCount < 3:
		label_enter_name.text = "ENTER AT LEAST \n THREE CHARACTERS"
	else:
		ProfileDB.update_student(PersonToUpdate, newPlayerName, selected_character)
		get_tree().change_scene_to_file(PROFILE_MANAGEMENT_PATH)


# --------- NAME SPINNER HELPERS ---------
func _populate_name_spinners(name_str: String) -> void:
	# Fill up to 6 chars; remaining positions are '-'
	var chars := []
	for i in name_str.length():
		if i < 6:
			chars.append(name_str[i].to_upper())
	for i in range(chars.size(), 6):
		chars.append('-')

	label_one.text   = chars[0]
	label_two.text   = chars[1]
	label_three.text = chars[2]
	label_four.text  = chars[3]
	label_five.text  = chars[4]
	label_six.text   = chars[5]

func _collect_name_from_spinners() -> String:
	var lbls := [label_one, label_two, label_three, label_four, label_five, label_six]
	var out := ""
	for l in lbls:
		if l.text != "-":
			out += l.text
	return out

func _cycle_char_up(character_label: Label) -> void:
	var current_pos := alphabet.find(character_label.text)
	var next_pos := (current_pos - 1 + alphabet.size()) % alphabet.size()
	character_label.text = alphabet[next_pos]

func _cycle_char_down(character_label: Label) -> void:
	var current_pos := alphabet.find(character_label.text)
	var next_pos := (current_pos + 1) % alphabet.size()
	character_label.text = alphabet[next_pos]


# --------- AVATAR HELPERS ---------
func _on_switch_avatar() -> void:
	selected_character = (selected_character + 1) % 2
	_update_avatar_visuals()

func _update_avatar_visuals() -> void:
	if selected_character == 1:
		avatar_image.texture = AVATAR_GIRL
		btn_switch.text = "Switch"
	else:
		avatar_image.texture = AVATAR_BOY
		btn_switch.text = "Switch"

func _get_current_avatar_index(student_name: String) -> int:
	# Prefer helper if you added ProfileDB.get_avatar_of(...)
	if "get_avatar_of" in ProfileDB:
		return int(ProfileDB.get_avatar_of(student_name))

	# Fallback: search the list directly
	for s in ProfileDB.students:
		if String(s.get("name","")) == student_name:
			return int(s.get("avatar", 0))
	return 0
