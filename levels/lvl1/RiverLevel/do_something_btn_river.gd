extends TextureButton

signal finished

@export var level_bound = 0           # Maximum allowed position in movement direction
@export var step_size: int = 50       # How far each move goes
@export var move_duration: float = 0.5
@export var move_direction: String = "Right"

var move_offset: Vector2 = Vector2.ZERO
var sprite: Area2D
var reset_position: Vector2 = Vector2.ZERO  # Player spawn point

func _ready() -> void:
	# Grab the player node
	sprite = get_parent().get_parent().get_parent().find_child("Player") as Area2D
	if sprite:
		reset_position = sprite.position  # Save original spawn point
	
	# Pre-calculate move offset (still relative to step_size)
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
	if not sprite:
		push_error("Player not assigned")
		return
	
	var start_pos = sprite.position
	var end_pos = start_pos + move_offset  # Always relative to current position
	
	# Clamp so we never go past level bounds
	match move_direction.to_lower():
		"right":
			if end_pos.x > level_bound:
				end_pos.x = level_bound
		"left":
			if end_pos.x < level_bound:
				end_pos.x = level_bound
		"up":
			if end_pos.y < level_bound:
				end_pos.y = level_bound
		"down":
			if end_pos.y > level_bound:
				end_pos.y = level_bound
	
	# Tween the movement
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "position", end_pos, move_duration)
	await get_tree().create_timer(move_duration + 0.1).timeout
	
	# Check if landed on a rock
	if not is_on_rock():
		sprite.position = reset_position
	
	# Signal that this action finished
	emit_signal("finished")

func is_on_rock() -> bool:
	if not sprite:
		return false
	
	# Check all overlapping areas; if any are in the "Rocks" group, we are safe
	for area in sprite.get_overlapping_areas():
		if area.is_in_group("Rocks"):
			return true
	return false

func _on_pressed() -> void:
	await spriteAnimation()
