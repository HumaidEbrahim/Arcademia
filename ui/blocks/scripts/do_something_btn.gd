extends TextureButton

signal finished

@export var level_bound = 0
@export var step_size: int = 50
@export var move_duration: float = 0.5
@export var move_direction: String = "Right"

var move_offset: Vector2 = Vector2.ZERO          
var sprite: Area2D
var initial_polygon: Polygon2D
var focus_polygon: Polygon2D

func _ready() -> void:
	# Find the player sprite in the scene
	sprite = get_tree().root.find_child("Player", true, false)
	
	# Get visual state polygons
	initial_polygon = $"Initial" 
	focus_polygon = $"Focus"
	
	# Show initial state, hide focus state
	initial_polygon.visible = true
	focus_polygon.visible = false
	
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
			
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN

func _process(delta: float) -> void:
	pass

func spriteAnimation() -> void:
	#Re-assign sprite if null (when the scene has been recreated)
	if sprite == null:
		sprite = get_tree().root.find_child("Player", true, false)
	
	if not sprite:
		push_error("Player not assigned")
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
	
	# Wait for animation plus small buffer
	await get_tree().create_timer(move_duration + 0.2).timeout
	
	# Signal that this action is complete
	emit_signal("finished")

func _on_pressed() -> void:
	await spriteAnimation()

func _on_focus_entered() -> void:
	initial_polygon.visible = false
	focus_polygon.visible = true

func _on_focus_exited() -> void:
	initial_polygon.visible = true
	focus_polygon.visible = false
