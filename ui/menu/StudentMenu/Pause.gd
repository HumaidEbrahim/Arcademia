extends Node


var pause_scene_path := "res://ui/menu/StudentMenu/main_menu.tscn"
var pause_scene_instance :Node= null
@onready var scenes = ["FarmMap","GardenLevel","BarnLevel","FarmRiverLevel","BarnLevel","TractorLevel","CowLevel"]


	
func _input(event):
	if event.is_action_pressed("btn_pause"):
		var scene = get_tree().current_scene.name
		if scene in scenes:
			toggle_pause()

func toggle_pause():
	Global.GamePaused = !Global.GamePaused
	
	if Global.GamePaused:
		show_main_menu()
	else:
		hide_main_menu()

func show_main_menu():
	if pause_scene_instance == null:
		var scene = load(pause_scene_path)
		pause_scene_instance = scene.instantiate()
		get_tree().root.add_child(pause_scene_instance)
	pause_scene_instance.visible = true

func hide_main_menu():
	if pause_scene_instance:
		pause_scene_instance.queue_free()
		pause_scene_instance = null
