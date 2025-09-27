# res://ui/menu/Login/new_student.gd
extends Control

const PROFILE_MANAGEMENT_PATH := "res://ui/menu/TeacherProfileManagement/profile_management.tscn"

# --- Avatar textures (boy first) ---
const AVATAR_BOY  : Texture2D = preload("res://assets/IngeUI/UIAvatars/stickerboy.png")
const AVATAR_GIRL : Texture2D = preload("res://assets/IngeUI/UIAvatars/stickergirl.png")

@onready var btn_back  : BaseButton = $BtnBack
@onready var btn_enter : BaseButton = $BtnEnter

# ----- NAME INPUT (6-character spinner) -----
@onready var label_enter_name: Label = $Card/Label
# Character 1
@onready var label_one:  Label  = $Card/Input/ScrollOne/LabelOne
@onready var btn_up_one: Button = $Card/Input/ScrollOne/ScrollUpOne
@onready var btn_down_one: Button = $Card/Input/ScrollOne/ScrollDownOne
# Character 2
@onready var label_two:  Label  = $Card/Input/ScrollTwo/LabelTwo
@onready var btn_up_two: Button = $Card/Input/ScrollTwo/ScrollUpTwo
@onready var btn_down_two: Button = $Card/Input/ScrollTwo/ScrollDownTwo
# Character 3
@onready var label_three:  Label  = $Card/Input/ScrollThree/LabelThree
@onready var btn_up_three: Button = $Card/Input/ScrollThree/ScrollUpThree
@onready var btn_down_three: Button = $Card/Input/ScrollThree/ScrollDownThree
# Character 4
@onready var label_four:  Label  = $Card/Input/ScrollFour/LabelFour
@onready var btn_up_four: Button = $Card/Input/ScrollFour/ScrollUpFour
@onready var btn_down_four: Button = $Card/Input/ScrollFour/ScrollDownFour
# Character 5
@onready var label_five:  Label  = $Card/Input/ScrollFive/LabelFive
@onready var btn_up_five: Button = $Card/Input/ScrollFive/ScrollUpFive
@onready var btn_down_five: Button = $Card/Input/ScrollFive/ScrollDownFive
# Character 6
@onready var label_six:  Label  = $Card/Input/ScrollSix/LabelSix
@onready var btn_up_six: Button = $Card/Input/ScrollSix/ScrollUpSix
@onready var btn_down_six: Button = $Card/Input/ScrollSix/ScrollDownSix

# ----- AVATAR PANEL (right) -----

@onready var avatar_image : TextureRect = $CardAvatar/AvatarImage
@onready var btn_switch   : Button      = $CardAvatar/BtnSwitch

# ----- DATA -----
# 0 = boy, 1 = girl
var selected_character: int = 0

# Alphabet for spinners
var alphabet := ['-', 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']

func _ready() -> void:
	# Buttons
	btn_back.pressed.connect(_on_back_pressed)
	btn_enter.pressed.connect(_on_enter_pressed)
	btn_down_one.grab_focus()

	# Name spinners
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

	# Avatar panel
	selected_character = int(Global.SelectedCharacter)  # start from global (boy=0 default)
	_update_avatar_visuals()
	btn_switch.pressed.connect(_on_switch_avatar)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(PROFILE_MANAGEMENT_PATH)

func _on_enter_pressed() -> void:
	var name_labels := [label_one, label_two, label_three, label_four, label_five, label_six]
	var char_count := 0
	var new_player_name := ""

	for l in name_labels:
		if l.text != "-":
			char_count += 1
			new_player_name += l.text

	if char_count < 3:
		label_enter_name.text = "ENTER AT LEAST \n THREE CHARACTERS"
		return

	# Persist avatar selection and create the student
	ProfileDB.add_student(new_player_name, selected_character)
	get_tree().change_scene_to_file(PROFILE_MANAGEMENT_PATH)

# ---------- Name spinners ----------
func _cycle_char_up(character_label: Label) -> void:
	var current_char := character_label.text
	var current_pos := alphabet.find(current_char)
	var next_pos := (current_pos - 1 + alphabet.size()) % alphabet.size()
	character_label.text = alphabet[next_pos]

func _cycle_char_down(character_label: Label) -> void:
	var current_char := character_label.text
	var current_pos := alphabet.find(current_char)
	var next_pos := (current_pos + 1) % alphabet.size()
	character_label.text = alphabet[next_pos]

# ---------- Avatar panel ----------
func _on_switch_avatar() -> void:
	# Toggle 0 <-> 1
	selected_character = (selected_character + 1) % 2
	Global.SelectedCharacter = selected_character
	_update_avatar_visuals()

func _update_avatar_visuals() -> void:
	if selected_character == 0:
		avatar_image.texture = AVATAR_GIRL
		btn_switch.text = "Switch"
	else:
		avatar_image.texture = AVATAR_BOY
		btn_switch.text = "Switch"
	
