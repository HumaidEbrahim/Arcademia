extends Area2D

@onready var anim = $Sprite2D
var last_position: Vector2

func _ready() -> void:
	last_position = position

func _process(_delta: float) -> void:
	if position != last_position:
		if anim.is_playing() == false:
			anim.play()
	else:
		if anim.is_playing():
			anim.pause()

	last_position = position
