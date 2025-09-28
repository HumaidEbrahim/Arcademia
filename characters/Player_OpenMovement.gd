extends CharacterBody2D

# Boundaries
@export var left_bound: float = 300
@export var right_bound: float = 1300
@export var bottom_bound: float = 900
@export var top_bound: float = 730  # bottom_bound - 170

# Scaling
var min_scale: float = 0.20
var max_scale: float = 0.5
var depth: float = 0.0
var scale_factor: float = 0.0

# Animation
var anim_sprite: AnimatedSprite2D
var walk: String = ""
var idle: String = ""
var last_direction: Vector2 = Vector2.ZERO

# Walk sounds
var walk_sounds: Array = []

func _ready():
	anim_sprite = $AnimatedSprite2D

	# Initialize walk sounds
	walk_sounds = [
		$WalkSoundPlayer1,
		$WalkSoundPlayer2,
		$WalkSoundPlayer3,
		$WalkSoundPlayer4
	]

	# Configure walk timer
	$WalkTimer.wait_time = 0.4
	$WalkTimer.one_shot = false
	$WalkTimer.autostart = false
	$WalkTimer.timeout.connect(_on_WalkTimer_timeout)

	# Character selection
	if Global.SelectedCharacter == 0:
		walk = "Girl_Walk"
		idle = "Girl_Idle"
	elif Global.SelectedCharacter == 1:
		walk = "Boy_Walk"
		idle = "Boy_Idle"

func _physics_process(delta: float) -> void:
	var input_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var input_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var direction = Vector2(input_x, input_y).normalized()

	# Calculate depth (0 bottom, 1 top)
	depth = get_depth_factor(position.y)
	
	# Apply scaling
	scale_factor = lerp(max_scale, min_scale, depth)
	scale = Vector2.ONE * scale_factor

	# Movement speeds
	var x_speed = 150.0
	var y_speed = lerp(150.0, 50.0, depth)

	# Apply velocity
	velocity = Vector2(direction.x * x_speed, direction.y * y_speed)
	position += velocity * delta

	# Clamp position
	position.x = clamp(position.x, left_bound, right_bound)
	position.y = clamp(position.y, top_bound, bottom_bound)

	# Play animations and footsteps
	if direction.length() > 0:
		last_direction = direction
		play_walk_animation(direction)
		if $WalkTimer.is_stopped():
			$WalkTimer.start()
	else:
		play_idle_animation(last_direction)
		$WalkTimer.stop()

func get_depth_factor(y: float) -> float:
	return clamp((bottom_bound - y) / (bottom_bound - top_bound), 0.0, 1.0)

func play_walk_animation(direction: Vector2) -> void:
	anim_sprite.play(walk)
	anim_sprite.flip_h = direction.x < 0

func play_idle_animation(direction: Vector2) -> void:
	anim_sprite.play(idle)
	anim_sprite.flip_h = direction.x < 0

# Called when the WalkTimer times out
func _on_WalkTimer_timeout() -> void:
	if walk_sounds.size() == 0:
		return
	var index = randi() % walk_sounds.size()
	walk_sounds[index].play()
