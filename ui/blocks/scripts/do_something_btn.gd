extends TextureButton

signal finished

@export var target_sprite: NodePath
@export var step_size: int = 50
@export var move_duration: float = 0.5
@export var move_direction: String = "Right"

var move_offset: Vector2 = Vector2.ZERO          
var sprite: Area2D

var initial_polygon: Polygon2D
var focus_polygon: Polygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#sprite = get_parent().get_parent().get_parent().find_child("Player") as Area2D
	
	sprite = get_tree().get_root().find_child("Player", true, false) as Area2D
	
	initial_polygon = $"Initial" 
	focus_polygon = $"Focus"
	
	initial_polygon.visible = true
	focus_polygon.visible = false
	
	# Convert string to vector using match statement properly
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
	
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "position", end_pos, move_duration)
	
	#while elapsed < move_duration:
		#var delta = get_process_delta_time()
		#elapsed += delta
		#await get_tree().process_frame

	#sprite.position = end_pos
	
	# Add delay
	await get_tree().create_timer(move_duration+0.2).timeout
	
	#IMPORTANT - Send finished signal so next item in que can start
	emit_signal("finished")

func _on_pressed() -> void:
	await spriteAnimation()


func _on_focus_entered() -> void:
	initial_polygon.visible = false
	focus_polygon.visible = true

func _on_focus_exited() -> void:
	initial_polygon.visible = true
	focus_polygon.visible = false
