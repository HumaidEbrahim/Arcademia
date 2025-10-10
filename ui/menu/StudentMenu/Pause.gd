extends Node

var is_paused := false
var pause_scene_path := "res://ui/menu/StudentMenu/main_menu.tscn"
var pause_scene_instance :Node= null

func _input(event):
	if event.is_action_pressed("btn_4"):
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	
	
	if is_paused:
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
