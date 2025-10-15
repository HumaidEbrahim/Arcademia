# res://ui/menu/Login/new_student.gd
extends Control

const STUDENT_SELECTION_PATH := "res://ui/menu/StudentScreens/student_selection.tscn"
const AVATAR_MENU_PATH := "res://ui/menu/StudentScreens/avatar_selection.tscn"


@onready var btn_back  : BaseButton = $Card/BtnBack
@onready var btn_enter : BaseButton = $Card/BtnEnter

# Player name character selection
@onready var label_enter_name: Label = $Card/Label
#Character 1
@onready var label_one: Label = $Input/ScrollOne/LabelOne
@onready var btn_up_one: Button = $Input/ScrollOne/ScrollUpOne
@onready var btn_down_one: Button = $Input/ScrollOne/ScrollDownOne
#Character 2
@onready var label_two: Label = $Input/ScrollTwo/LabelTwo
@onready var btn_up_two: Button = $Input/ScrollTwo/ScrollUpTwo
@onready var btn_down_two: Button = $Input/ScrollTwo/ScrollDownTwo
#Character 3
@onready var label_three: Label = $Input/ScrollThree/LabelThree
@onready var btn_up_three: Button = $Input/ScrollThree/ScrollUpThree
@onready var btn_down_three: Button = $Input/ScrollThree/ScrollDownThree
#Character 4
@onready var label_four: Label = $Input/ScrollFour/LabelFour
@onready var btn_up_four: Button = $Input/ScrollFour/ScrollUpFour
@onready var btn_down_four: Button = $Input/ScrollFour/ScrollDownFour
#Character 5
@onready var label_five: Label = $Input/ScrollFive/LabelFive
@onready var btn_up_five: Button = $Input/ScrollFive/ScrollUpFive
@onready var btn_down_five: Button = $Input/ScrollFive/ScrollDownFive
#Character 6
@onready var label_six: Label = $Input/ScrollSix/LabelSix
@onready var btn_up_six: Button = $Input/ScrollSix/ScrollUpSix
@onready var btn_down_six: Button = $Input/ScrollSix/ScrollDownSix


func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	btn_enter.pressed.connect(_on_enter_pressed)
	btn_down_one.grab_focus()  # optional: start focused for Enter/joystick A
							   # Changed focus to first cycle button

	# Name character select cyling 
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
		# Ask the user to select at least 3 characters.
		label_enter_name.text = "ENTER AT LEAST \n THREE CHARACTERS"
	else:
		ProfileDB.add_student(newPlayerName, 0)
		Global.PersonToEdit = newPlayerName
		Global.ActiveStudent = Global.PersonToEdit
		print(Global.ActiveStudent);
		get_tree().change_scene_to_file(AVATAR_MENU_PATH)
		
	
	
# Player name selection
var alphabet = ['-', 'Z','Y','X','W','V','U','T','S','R','Q','P','O','N','M','L','K','J','I','H','G','F','E','D','C','B','A']
#var alphabet := ['-', 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']

func _cycle_char_up(characterLabel: Label) -> void:
	var currentChar = characterLabel.text
	var currentPos = alphabet.find(currentChar)
	var nextPos = 0

	if currentPos == 0:
		nextPos = alphabet.size() - 1
	else:
		nextPos = currentPos - 1

	characterLabel.text = alphabet[nextPos]

func _cycle_char_down(characterLabel: Label) -> void:
	var currentChar = characterLabel.text
	var currentPos = alphabet.find(currentChar)
	var nextPos = 0
	
	if currentPos == 26:
		nextPos = 0
	else: 
		nextPos = currentPos + 1
	characterLabel.text = alphabet[nextPos]
	
	
