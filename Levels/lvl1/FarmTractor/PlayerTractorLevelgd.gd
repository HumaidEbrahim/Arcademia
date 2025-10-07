extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")
@onready var anim = $Sprite2D
@onready var harvest_sound: AudioStreamPlayer2D = $"../Player/PlayerCutSound"

var last_position: Vector2
var area = null
var error = false

signal levelWon(error: bool)

func _ready() -> void:
	label.text = "Harvest all the corn"
	last_position = position
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(_delta: float) -> void:
	if position != last_position:
		if anim.is_playing() == false:
			anim.play()
			if position < last_position:
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

	# Play harvest sound
	if harvest_sound:
		harvest_sound.stop()  # ensure it restarts if already playing
		harvest_sound.play()

	if get_tree().get_nodes_in_group("Mielies").is_empty():
		emit_signal("levelWon", error)

func _on_area_exited(area2):
	if area == area2:
		area = null
