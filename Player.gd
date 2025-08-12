extends CharacterBody2D

@export var speed = 125
@onready var anim_sprite = $AnimatedSprite2D

# Stores the last movement direction to know which way to face.
var last_direction = Vector2(0, 1) # Default to facing down

func _physics_process(_delta):
	# Get input from your custom actions. We will check these in the next step.
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_direction != Vector2.ZERO:
		last_direction = input_direction
	
	velocity = input_direction * speed
	
	move_and_slide()
	
	update_animation()


func update_animation():
	var new_animation = "" # Will hold the name of the animation to play.

	if velocity.length() > 0:
		# --- WALKING STATE ---
		# If moving, we build a directional walk animation name.
		var anim_direction = "down"
		if last_direction.y < 0:
			anim_direction = "up"
		elif last_direction.y > 0:
			anim_direction = "down"
		elif last_direction.x < 0:
			anim_direction = "left"
		elif last_direction.x > 0:
			anim_direction = "right"
		
		new_animation = "walk_" + anim_direction
	else:
		# --- IDLE STATE ---
		# If not moving, we just use the "idle" animation.
		new_animation = "idle"

	# Play the animation only if it's not already playing.
	if anim_sprite.animation != new_animation:
		anim_sprite.play(new_animation)
