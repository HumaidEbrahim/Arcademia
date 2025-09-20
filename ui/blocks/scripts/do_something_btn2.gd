extends TextureButton

signal finished

@export var target_sprite: NodePath

var sprite: Area2D

func _ready() -> void:
	var root_node = get_tree().get_root()
	sprite = root_node.find_child("Player", true, false) as Area2D

func spriteAnimation() -> void:
	if not is_instance_valid(sprite):
		push_error("Player not assigned or invalid.")
		return

	# Instantly move the sprite 50 pixels to the left.
	sprite.position.x -= 50

	# Wait for a 0.5-second delay before proceeding.
	await get_tree().create_timer(0.5).timeout

	emit_signal("finished")

func _on_pressed() -> void:
	# Wait for the spriteAnimation to complete.
	await spriteAnimation()
