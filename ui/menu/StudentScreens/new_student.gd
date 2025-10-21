# res://ui/menu/Login/new_student.gd
extends Control

const STUDENT_SELECTION_PATH := "res://ui/menu/StudentScreens/student_selection.tscn"
const AVATAR_MENU_PATH       := "res://ui/menu/StudentScreens/avatar_selection.tscn"

# Focus icons (white)
const ICON_UP_WHITE   : Texture2D = preload("res://assets/IngeUI/UIIcons/triangleupwhite.png")
const ICON_DOWN_WHITE : Texture2D = preload("res://assets/IngeUI/UIIcons/triangledownwhite.png")

@onready var btn_back  : BaseButton = $Card/BtnBack
@onready var btn_enter : BaseButton = $Card/BtnEnter

# Player name character selection
@onready var label_enter_name: Label = $Card/Label
# Character 1
@onready var label_one:      Label      = $Input/ScrollOne/LabelOne
@onready var btn_up_one:     BaseButton = $Input/ScrollOne/ScrollUpOne
@onready var btn_down_one:   BaseButton = $Input/ScrollOne/ScrollDownOne
# Character 2
@onready var label_two:      Label      = $Input/ScrollTwo/LabelTwo
@onready var btn_up_two:     BaseButton = $Input/ScrollTwo/ScrollUpTwo
@onready var btn_down_two:   BaseButton = $Input/ScrollTwo/ScrollDownTwo
# Character 3
@onready var label_three:    Label      = $Input/ScrollThree/LabelThree
@onready var btn_up_three:   BaseButton = $Input/ScrollThree/ScrollUpThree
@onready var btn_down_three: BaseButton = $Input/ScrollThree/ScrollDownThree
# Character 4
@onready var label_four:     Label      = $Input/ScrollFour/LabelFour
@onready var btn_up_four:    BaseButton = $Input/ScrollFour/ScrollUpFour
@onready var btn_down_four:  BaseButton = $Input/ScrollFour/ScrollDownFour
# Character 5
@onready var label_five:     Label      = $Input/ScrollFive/LabelFive
@onready var btn_up_five:    BaseButton = $Input/ScrollFive/ScrollUpFive
@onready var btn_down_five:  BaseButton = $Input/ScrollFive/ScrollDownFive
# Character 6
@onready var label_six:      Label      = $Input/ScrollSix/LabelSix
@onready var btn_up_six:     BaseButton = $Input/ScrollSix/ScrollUpSix
@onready var btn_down_six:   BaseButton = $Input/ScrollSix/ScrollDownSix

func _ready() -> void:
	# Navigation buttons
	btn_back.pressed.connect(_on_back_pressed)
	btn_enter.pressed.connect(_on_enter_pressed)

	# Name character select cycling
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

	# Focus → white icon wiring for ALL scroll buttons
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

	# Start focus on first down arrow so the effect is visible
	btn_down_one.grab_focus()

# Helper: focus icon handling (works for Button and TextureButton)
func _attach_focus_icon(btn: BaseButton, white_tex: Texture2D) -> void:
	# TextureButton path: use built-in focused texture
	if btn is TextureButton:
		var tb := btn as TextureButton
		tb.texture_focused = white_tex
		tb.focus_mode = Control.FOCUS_ALL
		return

	# Button path: swap icon on focus/blur
	if btn is Button:
		var b := btn as Button
		b.focus_mode = Control.FOCUS_ALL
		var original_icon: Texture2D = b.icon
		b.focus_entered.connect(func(): b.icon = white_tex)
		b.focus_exited.connect(func():  b.icon = original_icon)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(STUDENT_SELECTION_PATH)

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
		ProfileDB.add_student(newPlayerName, 0)
		Global.PersonToEdit = newPlayerName
		Global.ActiveStudent = Global.PersonToEdit
		print(Global.ActiveStudent)
		get_tree().change_scene_to_file(AVATAR_MENU_PATH)

# Player name selection
#var alphabet = ['-', 'Z','Y','X','W','V','U','T','S','R','Q','P','O','N','M','L','K','J','I','H','G','F','E','D','C','B','A']
var alphabet := ['-', 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']

func _cycle_char_up(characterLabel: Label) -> void:
	var currentPos = alphabet.find(characterLabel.text)
	var nextPos = (currentPos - 1 + alphabet.size()) % alphabet.size()
	characterLabel.text = alphabet[nextPos]

func _cycle_char_down(characterLabel: Label) -> void:
	var currentPos = alphabet.find(characterLabel.text)
	var nextPos = (currentPos + 1) % alphabet.size()
	characterLabel.text = alphabet[nextPos]
