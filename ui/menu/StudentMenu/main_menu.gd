# res://ui/menu/MainMenu/main_menu.gd
extends Control

const STUDENT_SELECTION_PATH := "res://ui/menu/StudentScreens/student_selection.tscn"
const NEWGAME_SELECTION_PATH := "res://Levels/openworld/FarmMap.tscn"

var new_music = load("res://music/Bongi Eepy/Bongi Eepy (mastered).mp3")

@onready var btn1: Button = $CenterContainer/Menu/BtnNewGame
@onready var btn2: Button = $CenterContainer/Menu/BtnResume
@onready var btn3: Button = $CenterContainer/Menu/BtnControls
@onready var btn4: Button = $CenterContainer/Menu/BtnBack

@onready var btn_back: BaseButton = $CenterContainer/Menu/BtnBack
@onready var btn_NewGame: BaseButton = $CenterContainer/Menu/BtnNewGame

var selected_index: int = 0
var buttons: Array

func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	btn_NewGame.pressed.connect(_on_new_game_pressed)
	btn2.pressed.connect(_on_resume)
	buttons = [btn1, btn2, btn3, btn4]
	buttons[selected_index].grab_focus()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(STUDENT_SELECTION_PATH)

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file(NEWGAME_SELECTION_PATH)
	
	MusicPlayer.play_stream(new_music, 2.5)

func _on_resume() -> void:
	MusicPlayer.play_stream(new_music, 2.5)
	Pause.toggle_pause()
