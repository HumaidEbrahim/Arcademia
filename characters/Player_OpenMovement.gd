extends CharacterBody2D

var bottom_y = 900;
var top_y = bottom_y - 170;
@export var left_bound := 300;
@export var right_bound := 1300;
@export var bottom_bound := 900;
@export var top_bound := bottom_bound - 170;
var min_scale = 0.20;
var max_scale = 0.5;
var anim_sprite : AnimatedSprite2D;
var last_direction := Vector2();
var depth :float = 0;
var scale_factor = 0;

#Walk Sound Variables
var walk_sounds = []
var current_sound_index = 0
var is_walking = false
var walk_timer : Timer

func _ready():
	anim_sprite = $AnimatedSprite2D;
	scale_factor = lerp(max_scale, min_scale, depth);
	scale = Vector2.ONE * scale_factor;
	walk_timer = $WalkTimer
	# Populate the array with your AudioStreamPlayer nodes
	walk_sounds.append($WalkSoundPlayer1)
	walk_sounds.append($WalkSoundPlayer2)
	walk_sounds.append($WalkSoundPlayer3)
	walk_sounds.append($WalkSoundPlayer4)
	
	# Connect the timer's timeout signal
	walk_timer.timeout.connect(on_walk_timer_timeout)
	scale_factor = lerp(max_scale, min_scale, depth)
	scale = Vector2.ONE * scale_factor

func on_walk_timer_timeout():
	if is_walking:
		var current_sound = walk_sounds[current_sound_index]
		
		# Add a safety check to make sure the node is valid
		if current_sound != null:
			current_sound.play()
		else:
			# This will help you debug which sound is missing
			print("Error: AudioStreamPlayer at index ", current_sound_index, " is null.")
		# Move to the next sound, looping back to the beginning
		current_sound_index = (current_sound_index + 1) % walk_sounds.size()
		# Restart the timer for the next step
		walk_timer.start()


func _physics_process(delta: float) -> void:
	var input_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	var input_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up");
	var direction = Vector2(input_x, input_y).normalized();
	# Get depth factor (0 at bottom, 1 at top)
	depth = get_depth_factor(position.y);
	
	# Scale character (same as before)
	scale_factor = lerp(max_scale, min_scale, depth);
	scale = Vector2.ONE * scale_factor;
	
	# Speeds
	var x_speed = 150.0; # always the same
	var y_speed = lerp(150.0, 50.0, depth);  # only vertical changes
	
	# Apply movement
	velocity = Vector2(direction.x * x_speed, direction.y * y_speed);
	position += velocity * delta;
	position.x = clamp(position.x, left_bound, right_bound);
	position.y = clamp(position.y, top_bound, bottom_bound);
	
	if direction.length() > 0:
		# Character is moving
		if not is_walking:
			is_walking = true
			# Start the timer to trigger the first sound
			walk_timer.start()
		depth = get_depth_factor(position.y);
		last_direction = direction;
		play_walk_animation(direction);
	else:
		# Character has stopped
		if is_walking:
			is_walking = false
			walk_timer.stop()
			# Stop all walking sounds immediately
			for sound in walk_sounds:
				sound.stop()
		play_idle_animation(last_direction);
	
		
func get_depth_factor(y):
	return clamp((bottom_y - y) / (bottom_y - top_y), 0.0, 1.0);
	
func play_walk_animation(direction):
	if direction.x > 0:
		anim_sprite.play("Girl_Walk");
		anim_sprite.flip_h = false;
	elif direction.x < 0:
		anim_sprite.flip_h = true;
		anim_sprite.play("Girl_Walk");
	if direction.y > 0:
		anim_sprite.play("Girl_Walk");
	elif direction.y < 0:
		anim_sprite.play("Girl_Walk");
		

func play_idle_animation(direction):
	if direction.x > 0:
		anim_sprite.play("Girl_Idle");
		anim_sprite.flip_h = false;
	elif direction.x < 0:
		anim_sprite.flip_h = true;
		anim_sprite.play("Girl_Idle");
	if direction.y > 0:
		anim_sprite.play("Girl_Idle");
	elif direction.y < 0:
		anim_sprite.play("Girl_Idle");
		
