extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")

@onready var anim = $Sprite2D
var last_position: Vector2
var area = null
var error = false

signal levelWon(error:bool)

var track = load("res://music/Bongi Farm/Bongi Farm (mastered).mp3")

func _ready() -> void:
	label.text = "Harvest all the corn"
	last_position = position
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	MusicPlayer.play_stream(track, 2.0)

func _process(_delta: float) -> void:
	if position != last_position:
		if anim.is_playing() == false:
			anim.play()
			if(position < last_position):
				anim.flip_h = false
			else:
				anim.flip_h = true
	else:
		if anim.is_playing():
			anim.pause()

	last_position = position

func _on_area_entered(area2):
	area = area2
	area2.visible = false
	area2.remove_from_group("Mielies")
	if get_tree().get_nodes_in_group("Mielies").is_empty():
		emit_signal("levelWon",error)

func _on_area_exited(area2):
	if area == area2:
		area = null
