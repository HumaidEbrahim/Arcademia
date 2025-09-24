extends Area2D

@onready var anim = $Sprite2D
var last_position: Vector2
@export var left_bound := 100;
@export var right_bound := 1030;
@export var bottom_bound := 900;
@export var top_bound := 500;

func _ready() -> void:
	last_position = position

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
	if(position.x < left_bound || position.x > right_bound):
		position = last_position
	if(position.y < top_bound || position.y > bottom_bound ):
		position = last_position
	last_position = position
