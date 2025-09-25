extends AnimatedSprite2D

@export var min_speed := 60.0
@export var max_speed := 160.0
@export var bob_amplitude := 8.0     # pixels
@export var bob_speed_factor := 1.0

var speed := 100.0
var direction := Vector2(1, 0)
var base_y := 0.0
var bob_phase := 0.0

# RandomNumberGenerator instance (recommended)
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	# set a random speed using RNG
	speed = rng.randf_range(min_speed, max_speed)
	base_y = position.y
	bob_phase = rng.randf() * TAU
	
	# Start the sprite animation - FIXED
	play("Birds_Fly") # Use your actual animation name
	
	set_process(true)

func _process(delta):
	# horizontal move
	position.x += direction.x * speed * delta

	# bobbing (sinusoidal)
	bob_phase += delta * (speed / 100.0) * bob_speed_factor
	position.y = base_y + sin(bob_phase) * bob_amplitude

	# viewport wrapping (respawn from opposite side)
	var vp_rect = get_viewport().get_visible_rect()
	var margin = 80
	if position.x > vp_rect.size.x + margin:
		position.x = -margin
	elif position.x < -margin:
		position.x = vp_rect.size.x + margin
