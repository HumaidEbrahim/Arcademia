# res://ui/menu/StudentScreens/update_student.gd
extends Control

const STUDENT_SELECTION_PATH := "res://ui/menu/Selection/student_selection.tscn"
const MAIN_MENU_PATH := "res://ui/menu/StudentMenu/main_menu.tscn"
const PROFILE_MANAGEMENT_PATH := "res://ui/menu/TeacherProfileManagement/profile_management.tscn"
const SCORING_PATH := "res://ui/menu/TeacherProfileManagement/scoring.tscn"

var PersonToUpdate: String = Global.PersonToEdit

# --------- Bottom buttons ---------
@onready var btn_back  : BaseButton = $Card/BtnBack
@onready var btn_enter : BaseButton = $Card/BtnEnter
@onready var btn_score : BaseButton = $Card/BtnScore
@onready var btn_delete: BaseButton = $Card/BtnDelete

# --------- NAME INPUT ---------
@onready var label_enter_name: Label = $Card/Label
@onready var label_one: Label = $Card/Input/ScrollOne/LabelOne
@onready var btn_up_one: BaseButton = $Card/Input/ScrollOne/ScrollUpOne
@onready var btn_down_one: BaseButton = $Card/Input/ScrollOne/ScrollDownOne
@onready var label_two: Label = $Card/Input/ScrollTwo/LabelTwo
@onready var btn_up_two: BaseButton = $Card/Input/ScrollTwo/ScrollUpTwo
@onready var btn_down_two: BaseButton = $Card/Input/ScrollTwo/ScrollDownTwo
@onready var label_three: Label = $Card/Input/ScrollThree/LabelThree
@onready var btn_up_three: BaseButton = $Card/Input/ScrollThree/ScrollUpThree
@onready var btn_down_three: BaseButton = $Card/Input/ScrollThree/ScrollDownThree
@onready var label_four: Label = $Card/Input/ScrollFour/LabelFour
@onready var btn_up_four: BaseButton = $Card/Input/ScrollFour/ScrollUpFour
@onready var btn_down_four: BaseButton = $Card/Input/ScrollFour/ScrollDownFour
@onready var label_five: Label = $Card/Input/ScrollFive/LabelFive
@onready var btn_up_five: BaseButton = $Card/Input/ScrollFive/ScrollUpFive
@onready var btn_down_five: BaseButton = $Card/Input/ScrollFive/ScrollDownFive
@onready var label_six: Label = $Card/Input/ScrollSix/LabelSix
@onready var btn_up_six: BaseButton = $Card/Input/ScrollSix/ScrollUpSix
@onready var btn_down_six: BaseButton = $Card/Input/ScrollSix/ScrollDownSix

# --------- AVATAR PANEL ---------
@onready var avatar_image : TextureRect = $CardAvatar/AvatarImage
@onready var btn_switch   : Button      = $CardAvatar/BtnSwitch

# --------- AVATAR textures ---------
const AVATAR_BOY  : Texture2D = preload("res://assets/IngeUI/UIAvatars/stickerboy.png")
const AVATAR_GIRL : Texture2D = preload("res://assets/IngeUI/UIAvatars/stickergirl.png")
const ICON_UP_WHITE   : Texture2D = preload("res://assets/IngeUI/UIIcons/triangleupwhite.png")
const ICON_DOWN_WHITE : Texture2D = preload("res://assets/IngeUI/UIIcons/triangledownwhite.png")

# --------- DATA ---------
var selected_character: int = 0
var alphabet := ['-', 'Z','Y','X','W','V','U','T','S','R','Q','P','O','N','M','L','K','J','I','H','G','F','E','D','C','B','A']


func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	btn_enter.pressed.connect(_on_enter_pressed)
	btn_score.pressed.connect(_on_score_pressed)
	btn_delete.pressed.connect(_on_delete_pressed)

	# Name spinners
	label_enter_name.text = "ENTER NAME"
	for i in [btn_up_one, btn_down_one, btn_up_two, btn_down_two, btn_up_three, btn_down_three,
		btn_up_four, btn_down_four, btn_up_five, btn_down_five, btn_up_six, btn_down_six]:
		i.focus_mode = Control.FOCUS_ALL

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

	_populate_name_spinners(PersonToUpdate)

	selected_character = _get_current_avatar_index(PersonToUpdate)
	Global.SelectedCharacter = selected_character
	_update_avatar_visuals()
	btn_switch.pressed.connect(_on_switch_avatar)


# ---------------- BUTTONS ----------------
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(PROFILE_MANAGEMENT_PATH)

func _on_enter_pressed() -> void:
	var new_name := _collect_name_from_spinners()
	if new_name.length() < 3:
		label_enter_name.text = "ENTER AT LEAST \nTHREE CHARACTERS"
		return
	ProfileDB.update_student(PersonToUpdate, new_name, selected_character)
	Global.PersonToEdit = new_name
	get_tree().change_scene_to_file(PROFILE_MANAGEMENT_PATH)

func _on_score_pressed() -> void:
	Global.PersonToEdit = PersonToUpdate
	get_tree().change_scene_to_file(SCORING_PATH)

func _on_delete_pressed() -> void:
	if ProfileDB.delete_student(PersonToUpdate):
		print("Deleted student: ", PersonToUpdate)
	get_tree().change_scene_to_file(PROFILE_MANAGEMENT_PATH)


# ---------------- NAME SPINNER HELPERS ----------------
func _populate_name_spinners(name_str: String) -> void:
	var chars := []
	for i in name_str.length():
		if i < 6:
			chars.append(name_str[i].to_upper())
	for i in range(chars.size(), 6):
		chars.append('-')

	label_one.text = chars[0]
	label_two.text = chars[1]
	label_three.text = chars[2]
	label_four.text = chars[3]
	label_five.text = chars[4]
	label_six.text = chars[5]

func _collect_name_from_spinners() -> String:
	var lbls := [label_one, label_two, label_three, label_four, label_five, label_six]
	var out := ""
	for l in lbls:
		if l.text != "-":
			out += l.text
	return out

func _cycle_char_up(lbl: Label) -> void:
	var current_pos := alphabet.find(lbl.text)
	var next_pos := (current_pos - 1 + alphabet.size()) % alphabet.size()
	lbl.text = alphabet[next_pos]

func _cycle_char_down(lbl: Label) -> void:
	var current_pos := alphabet.find(lbl.text)
	var next_pos := (current_pos + 1) % alphabet.size()
	lbl.text = alphabet[next_pos]


# ---------------- AVATAR ----------------
func _on_switch_avatar() -> void:
	selected_character = (selected_character + 1) % 2
	_update_avatar_visuals()

func _update_avatar_visuals() -> void:
	if selected_character == 1:
		avatar_image.texture = AVATAR_GIRL
	else:
		avatar_image.texture = AVATAR_BOY

func _get_current_avatar_index(student_name: String) -> int:
	for s in ProfileDB.students:
		if String(s.get("name", "")) == student_name:
			return int(s.get("avatar", 0))
	return 0
