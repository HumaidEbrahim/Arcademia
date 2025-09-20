extends TextureButton

signal finished

@export var target_sprite: NodePath
@export var step_size: int = 50
@export var move_duration: float = 0.5
@export var move_direction: String = "Right"
@export var safe_area_path: NodePath
var sprite_original_position: Vector2
var safe_area: Area2D
@export var player_path: NodePath



var move_offset: Vector2 = Vector2.ZERO          
var sprite: Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player_path:
		sprite = get_node(player_path) as Area2D
	if not sprite:
		push_error("Player node not found! Check player_path.")
	return
	
	sprite = get_parent().get_parent().get_parent().find_child("Player") as Area2D
	if safe_area_path:
		safe_area = get_node(safe_area_path) as Area2D
	sprite_original_position = sprite.position


	# Convert string direction to vector
	match move_direction.to_lower():
		"right": move_offset = Vector2(step_size, 0)
		"left": move_offset = Vector2(-step_size, 0)
		"up": move_offset = Vector2(0, -step_size)
		"down": move_offset = Vector2(0, step_size)
		_: move_offset = Vector2.ZERO
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spriteAnimation() -> void:
	if not sprite:
		push_error("Player not assigned")
		return

	var start_pos = sprite.position
	var end_pos = start_pos + move_offset
	var elapsed = 0.0

	while elapsed < move_duration:
		var delta = get_process_delta_time()
		elapsed += delta
		sprite.position = start_pos.lerp(end_pos, min(elapsed / move_duration, 1))
		await get_tree().process_frame
	sprite.position = end_pos
	if not is_player_in_safe_area():
		sprite.position = sprite_original_position # Reset position
	
	# Add delay
	await get_tree().create_timer(0.5).timeout
	
	#IMPORTANT - Send finished signal so next item in que can start
	emit_signal("finished")

func _on_pressed() -> void:
	await spriteAnimation()
	
	
func is_player_in_safe_area() -> bool:
	if not safe_area or not sprite:
		return false
	return safe_area.get_overlapping_areas().has(sprite)
