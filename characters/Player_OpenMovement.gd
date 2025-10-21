extends CharacterBody2D

var bottom_y = 900;
var top_y = bottom_y - 170;
@export var left_bound := 300;
@export var right_bound := 1300;
@export var bottom_bound := 900;
@export var top_bound := bottom_bound - 170;
@export var min_scale = 0.20;
@export var max_scale = 0.5;
@export var x_speed = 150.0
@export var min_speed = 50.0
var anim_sprite : AnimatedSprite2D;
var last_direction := Vector2();
var depth :float = 0;
var scale_factor = 0;
var walk:String = ""
var idle:String = ""

@onready var walk_sounds = [
	$Walk1,
	$Walk2,
	$Walk3,
	$Walk4
]
@onready var walk_timer : Timer = $WalkTimer
var walk_sound_index : int = 0
var is_moving : bool = false


func _ready():
	anim_sprite = $AnimatedSprite2D;
	scale_factor = lerp(max_scale, min_scale, depth);
	scale = Vector2.ONE * scale_factor;

	
	if Global.SelectedCharacter == 1:
		walk = "Girl_Walk"
		idle = "Girl_Idle"
	elif Global.SelectedCharacter == 0:
		walk = "Boy_Walk"
		idle = "Boy_Idle"
		
	walk_timer.timeout.connect(_on_walk_timer_timeout)
		

func _physics_process(delta: float) -> void:
	var input_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var input_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var direction = Vector2(input_x, input_y).normalized()
	# Get depth factor (0 at bottom, 1 at top)
	depth = get_depth_factor(position.y)
	# Scale character
	scale_factor = lerp(max_scale, min_scale, depth)
	scale = Vector2.ONE * scale_factor
	# Speeds

	var y_speed = lerp(x_speed, min_speed, depth)
	# Apply movement
	velocity = Vector2(direction.x * x_speed, direction.y * y_speed)
	position += velocity * delta
	position.x = clamp(position.x, left_bound, right_bound)
	position.y = clamp(position.y, top_bound, bottom_bound)
	
	if direction.length() > 0:
		# Walking
		last_direction = direction
		play_walk_animation(direction)
		
		if not is_moving:
			is_moving = true
			walk_sounds[walk_sound_index].play()
			walk_sound_index = (walk_sound_index + 1) % walk_sounds.size()
			walk_timer.start()
	else:
		# Idle
		play_idle_animation(last_direction)
		if is_moving:
			is_moving = false
			walk_timer.stop()



func get_depth_factor(y):
	return clamp((bottom_y - y) / (bottom_y - top_y), 0.0, 1.0);
	
func play_walk_animation(direction):
	anim_sprite.play(walk);
	
	if direction.x > 0:
		anim_sprite.flip_h = false;
	elif direction.x < 0:
		anim_sprite.flip_h = true;
		
		
func play_idle_animation(direction):
	anim_sprite.play(idle);
	
	if direction.x > 0:
		anim_sprite.flip_h = false;
	elif direction.x < 0:
		anim_sprite.flip_h = true;
		
func _on_walk_timer_timeout() -> void:
	if is_moving:
		walk_sounds[walk_sound_index].play()
		walk_sound_index = (walk_sound_index + 1) % walk_sounds.size()
