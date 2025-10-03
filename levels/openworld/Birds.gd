extends AnimatedSprite2D

@export var min_speed := 60.0
@export var max_speed := 160.0
@export var bob_amplitude := 8   
@export var bob_speed_factor := 1.0
@export var min_height = 100
@export var max_height = 370

var speed := 100.0
var direction := Vector2(1, 0)
var base_y := 0.0
var bob_phase := 0.0


# RandomNumberGenerator instance (recommended)
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	spawn()
	
	
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
		visible = false
		spawn()
	elif position.x < -margin:
		position.x = vp_rect.size.x + margin
		visible = false
		spawn()

func spawn():
	if rng.randf() < 0.5:
		visible = true
		speed = rng.randf_range(min_speed, max_speed)
		position.y = rng.randi_range(min_height, max_height)
		bob_amplitude = rng.randi_range(8,20)
		bob_phase = rng.randf() * TAU
		base_y = position.y
