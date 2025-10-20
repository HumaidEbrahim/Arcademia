extends Area2D

signal left_safe_area
signal entered_safe_area

var original_position: Vector2
@onready var main_ui_node = get_node("../main_ui")  
@onready var anim_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var splash_sound: AudioStreamPlayer2D = get_node("SplashSoundPlayer")

var track = load("res://music/Bongi_Blues/Bongi_Blues (mastered).mp3")

var _last_position: Vector2
var _schedule_check_running: bool = false
const _CHECK_DEBOUNCE := 0.15

# Track whether the player is currently off rocks
var _off_rock_since_last_reset: bool = false

func _ready() -> void:
	original_position = position
	monitoring = true
	monitorable = true
	_last_position = position
	_off_rock_since_last_reset = false
	
	MusicPlayer.play_stream(track, 2.0)

func _physics_process(_delta: float) -> void:
	if position != _last_position:
		if not _schedule_check_running:
			_schedule_check_running = true
			_check_after_debounce()
		_last_position = position
		_play_movement_animation()
	else:
		_play_idle_animation()

func _check_after_debounce() -> void:
	await get_tree().create_timer(_CHECK_DEBOUNCE).timeout
	_schedule_check_running = false
	_last_position = position
	check_reset_needed()

func check_reset_needed() -> void:
	var currently_on_rock = is_on_rock()

	# Reset condition: off rock AND not at original position
	if not currently_on_rock and position != original_position:
		_off_rock_since_last_reset = true  # mark that the player left a rock
		position = original_position
		print("Player reset to origin")

		# Only play splash if leaving rock caused reset
		if splash_sound and _off_rock_since_last_reset:
			splash_sound.play()
			_off_rock_since_last_reset = false  # reset the flag after playing sound

		emit_signal("left_safe_area")
		if main_ui_node and main_ui_node.has_method("_on_clear_pressed"):
			main_ui_node._on_clear_pressed()
		return

	# If player is safely on a rock, reset the off-rock tracker
	if currently_on_rock:
		_off_rock_since_last_reset = false
		emit_signal("entered_safe_area")

func is_on_rock() -> bool:
	for a in get_overlapping_areas():
		if a and a.is_in_group("Rocks"):
			return true

	for b in get_overlapping_bodies():
		if b and b.is_in_group("Rocks"):
			return true
		if b and b.get_parent() and b.get_parent().is_in_group("Rocks"):
			return true

	return false

func _play_movement_animation() -> void:
	if anim_sprite and anim_sprite.animation != "Boy_Jump":
		anim_sprite.play("Boy_Jump")

func _play_idle_animation() -> void:
	if anim_sprite and anim_sprite.animation != "Boy_Idle":
		anim_sprite.play("Boy_Idle")
