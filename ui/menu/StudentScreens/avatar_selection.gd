extends Control

const GAME_PATH := "res://Levels/openworld/FarmMap.tscn"
@onready var btn_boy : BaseButton = $Background/Boy
@onready var btn_girl : BaseButton = $Background/Girl

var PersonToUpdate :String = Global.PersonToEdit;

func _ready():
	btn_girl.pressed.connect(_on_girl_pressed)
	btn_boy.pressed.connect(_on_boy_pressed)
	btn_boy.grab_focus()

func _on_girl_pressed():
	ProfileDB.update_student(PersonToUpdate,"",1);
	Global.SelectedCharacter = 1;
	get_tree().change_scene_to_file(GAME_PATH)
	Global.ActiveStudent = PersonToUpdate;

func _on_boy_pressed():
	ProfileDB.update_student(PersonToUpdate,"",0);
	Global.SelectedCharacter = 0;
	get_tree().change_scene_to_file(GAME_PATH)
	Global.ActiveStudent = PersonToUpdate;
