# res://ui/menu/MainMenu/main_menu.gd
extends Control

const STUDENT_SELECTION_PATH := "res://ui/menu/Selection/student_selection.tscn"
const NEWGAME_SELECTION_PATH := ""

@onready var btn_back: BaseButton = $CenterContainer/Menu/BtnBack
@onready var btn_NewGame: BaseButton = $CenterContainer/Menu/BtnNewGame

func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	btn_NewGame.pressed.connect(_on_new_game_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(STUDENT_SELECTION_PATH)
	
func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file(NEWGAME_SELECTION_PATH)
