extends TextureButton

signal finished

@export var level_bound = 0
@export var step_size: int = 50
@export var move_duration: float = 0.5
@export var move_direction: String = "Right"

var move_offset: Vector2 = Vector2.ZERO          
var sprite: Area2D = null
var initial_polygon: Polygon2D
var focus_polygon: Polygon2D

func _ready() -> void:
##### Removed this and set the player location in the main_ui #####
##### This path is only valid when the button is in its original position in the editor #####
# Called when the node enters the scene tree for the first time.
	#sprite = get_parent().get_parent().get_parent().find_child("Player") as Area2D
	
	# Get visual state polygons
	initial_polygon = $"Initial" 
	focus_polygon = $"Focus"
	
	# Show initial state, hide focus state
	initial_polygon.visible = true
	focus_polygon.visible = false

func _on_pressed() -> void:
	# Convert string to vector
	# Convert string to vector using match statement properly
	
	# Set movement direction based on exported string
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
			
	spriteAnimation()

	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN

func _process(delta: float) -> void:
	pass

func spriteAnimation() -> void:
	# Check if the target was successfully assigned.
	if not is_instance_valid(sprite):
		push_error("Player not assigned")
		emit_signal("finished") # IMPORTANT: Still emit signal to avoid a freeze.
		return
	var start_pos = sprite.position
	var end_pos = start_pos + move_offset
	
	match move_direction.to_lower():
		"right":
			end_pos.x = clamp(end_pos.x, start_pos.x, level_bound)
		"left":
			end_pos.x = clamp(end_pos.x, level_bound, start_pos.x)
		"up":
			end_pos.y = clamp(end_pos.y, level_bound, start_pos.y)
		"down":
			end_pos.y = clamp(end_pos.y, start_pos.y, level_bound)
			
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "position", end_pos, move_duration)
	
	# Wait for the tween to finish
	await tween.finished
	
	# IMPORTANT - Send finished signal so next item in queue can start
	emit_signal("finished")

func _on_focus_entered() -> void:
	initial_polygon.visible = false
	focus_polygon.visible = true

func _on_focus_exited() -> void:
	initial_polygon.visible = true
	focus_polygon.visible = false
