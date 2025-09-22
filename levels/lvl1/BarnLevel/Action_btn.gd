extends TextureButton

signal finished

@export var action: String
var sprite: Area2D

func _ready():
	sprite = get_parent().get_parent().get_parent().find_child("Player") as Area2D

func call_action():
	if not sprite:
		push_error("Player not assigned")
		return
	if sprite:
		match action.to_lower():
			"pickup":
				sprite.action_pickup()
				print("called pickup")
			"feed":
				sprite.action_feed()
				print("called feed")
			
			
	await get_tree().create_timer(0.2).timeout
	emit_signal("finished")

func _on_pressed():
	await call_action()
