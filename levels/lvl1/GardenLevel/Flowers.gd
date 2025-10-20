extends Area2D
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	sprite.pause()
func action_watered():
	sprite.play("grow")

func action_planted():
	sprite.play("plant")
	
