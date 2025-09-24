# res://ui/menu/Login/new_student.gd
extends Control

const STUDENT_SELECTION_PATH := "res://ui/menu/Selection/student_selection.tscn"
const MAIN_MENU_PATH := "res://ui/menu/MainMenu/main_menu.tscn"

@onready var btn_back  : BaseButton = $Card/BtnBack
@onready var btn_enter : BaseButton = $Card/BtnEnter

func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	btn_enter.pressed.connect(_on_enter_pressed)
	btn_enter.grab_focus()  # optional: start focused for Enter/joystick A

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(STUDENT_SELECTION_PATH)

func _on_enter_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
