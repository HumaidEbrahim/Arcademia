extends Control

@onready var label_password: Label = $HeaderPanel/Label
@onready var line_edit_pin: LineEdit = $HeaderPanel/LineEdit
@onready var btn_enter: Button = $HeaderPanel/BtnEnter
@onready var btn_back: Button = $HeaderPanel/BtnBack
@onready var number_buttons: Dictionary = {
	0: $HeaderPanel/BtnZero as Button,
	1: $HeaderPanel/BtnOne as Button,
	2: $HeaderPanel/BtnTwo as Button,
	3: $HeaderPanel/BtnThree as Button,
	4: $HeaderPanel/BtnFour as Button,
	5: $HeaderPanel/BtnFive as Button,
	6: $HeaderPanel/BtnSix as Button,
	7: $HeaderPanel/BtnSeven as Button,
	8: $HeaderPanel/BtnEight as Button,
	9: $HeaderPanel/BtnNine as Button,
}

func _ready() -> void:
	for num in number_buttons:
		var button: Button = number_buttons[num]
		button.pressed.connect(add_num_to_pin.bind(num))
	btn_enter.pressed.connect(func(): validate_pin())

func add_num_to_pin(num: int) -> void:
	if line_edit_pin.text.length() < 4:
		line_edit_pin.text += str(num)

func is_pin_valid(entered_pin) -> bool:
	if entered_pin == entered_pin: # TODO fetch pin and check its valid
		return true
	else:
		return false

func validate_pin() -> void:
	var entered_pin = line_edit_pin.text
	
	if line_edit_pin.text.length() < 4: # Debatable if this is needed but I have it here for now
		label_password.text = "ENTER FULL PASSWORD"
		return 
		
	if is_pin_valid(entered_pin):
		pass # TODO go to next screen
	else:
		label_password.text = "INCORRECT PASSWORD"
		
	line_edit_pin.text = ""
		
		
	
