extends TextureButton



signal finished



@export var target_sprite: NodePath
@export var step_size: int = 50
@export var move_duration: float = 0.5
@export var move_direction: String = "Right"



var move_offset: Vector2 = Vector2.ZERO          

var sprite: Area2D



func _ready() -> void:

	# Safely find the player node

	var root_node = get_tree().get_root()

	sprite = root_node.find_child("Player", true, false) as Area2D



	# Convert string to vector

	match move_direction.to_lower():

		"right":

			move_offset = Vector2(step_size, 0)

		"left":

			move_offset = Vector2(-step_size, 0)

		"up":

			move_offset = Vector2(0, -step_size)

		"down":

			move_offset = Vector2(0, step_size)

		_:

			move_offset = Vector2.ZERO



func spriteAnimation() -> void:

	if not is_instance_valid(sprite):

		push_error("Player not assigned or invalid.")

		return



	var end_pos = sprite.position + move_offset

	var tween = get_tree().create_tween()

	tween.tween_property(sprite, "position", end_pos, move_duration)



	# Wait for the tween to complete before emitting the signal

	await tween.finished



	emit_signal("finished")



func _on_pressed() -> void:

	# Call the async function and wait for it to complete

	await spriteAnimation()
