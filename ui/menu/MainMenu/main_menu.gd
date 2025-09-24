# res://ui/menu/MainMenu/main_menu.gd
extends Control

const STUDENT_SELECTION_PATH := "res://ui/menu/Selection/student_selection.tscn"

@onready var btn_back: BaseButton = $CenterContainer/Menu/BtnBack

func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(STUDENT_SELECTION_PATH)
