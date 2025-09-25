extends Control

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


func add_num_to_pin(num: int) -> void:
	if line_edit_pin.text.length() < 4:
		line_edit_pin.text += str(num)

func validate_pin() -> void:
	# TODO check the entered pin is valid 
	print(line_edit_pin.text)
	pass
