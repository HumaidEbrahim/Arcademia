extends Area2D

# --- Signals ---
signal left_safe_area
signal entered_safe_area
signal levelWon(error: bool)

# --- Variables ---
var original_position: Vector2
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var splash_sound: AudioStreamPlayer2D = $SplashSoundPlayer
@onready var win_screen: CanvasItem
@onready var text_box_label: Label = get_tree().get_current_scene().get_node("MainUI/HBoxContainer/GameArea/SubViewportContainer/SubViewport/TextBox/Text")
@onready var win_node: Area2D = get_tree().get_current_scene().get_node("MainUI/HBoxContainer/GameArea/SubViewportContainer/SubViewport/WinNode")
var track = load("res://music/Bongi_Blues/Bongi_Blues (mastered).mp3")
var error = false

var _last_position: Vector2
var _schedule_check_running: bool = false
const _CHECK_DEBOUNCE := 0.15
var _has_played_splash: bool = false
const MOVE_THRESHOLD := 0.1
var _jump_played_for_current_slot: bool = false

# --- Animations names based on gender ---
var idle_anim: String
var jump_anim: String

# --- Life cycle ---
func _ready() -> void:
	win_node.area_entered.connect(win_level)
	original_position = position
	monitoring = true
	monitorable = true
	_last_position = position
	_has_played_splash = false
	_jump_played_for_current_slot = false

	# Correctly get WinScreen from current scene
	win_screen = get_tree().get_current_scene().get_node("MainUI/HBoxContainer/WinScreen")
	if win_screen:
		win_screen.visible = false

	#  Display starting message
	if text_box_label:
		text_box_label.text = "Cross the river!"

	# Set animations based on selected character
	if "SelectedCharacter" in Global:
		if Global.SelectedCharacter == 0:
			idle_anim = "Boy_Idle"
			jump_anim = "Boy_Jump"
		elif Global.SelectedCharacter == 1:
			idle_anim = "Girl_Idle"
			jump_anim = "Girl_Jump"

	MusicPlayer.play_stream(track, 2.0)
	_play_idle_animation()

# --- Physics / movement ---
func _physics_process(delta: float) -> void:
	var distance_moved = position.distance_to(_last_position)

	# --- Flip sprite based on horizontal movement ---
	var delta_x = position.x - _last_position.x
	if delta_x < -0.01:
		anim_sprite.flip_h = true
	elif delta_x > 0.01:
		anim_sprite.flip_h = false

	# --- Handle animations ---
	if distance_moved > MOVE_THRESHOLD:
		if not _jump_played_for_current_slot:
			_play_movement_animation()
			_jump_played_for_current_slot = true
	else:
		if _jump_played_for_current_slot:
			_jump_played_for_current_slot = false
		_play_idle_animation()

	_last_position = position

	if not _schedule_check_running:
		_schedule_check_running = true
		_check_after_debounce()

# --- Debounced splash/reset ---
func _check_after_debounce() -> void:
	await get_tree().create_timer(_CHECK_DEBOUNCE).timeout
	_schedule_check_running = false
	check_reset_needed()

# --- Splash / reset ---
func check_reset_needed() -> void:
	var currently_on_rock = is_on_rock()

	if not currently_on_rock and position != original_position:
		position = original_position
		if not _has_played_splash and splash_sound:
			splash_sound.play()
			_has_played_splash = true
		emit_signal("left_safe_area")

		#  Update textbox message on reset
		if text_box_label:
			text_box_label.text = "You fell in the water, try again!"

		return

	if currently_on_rock:
		_has_played_splash = false
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

# --- Animations ---
func _play_movement_animation() -> void:
	if not anim_sprite or jump_anim == "":
		return

	if anim_sprite.animation != jump_anim or not anim_sprite.is_playing():
		anim_sprite.animation = jump_anim
		anim_sprite.frame = 0
		anim_sprite.play()

func _play_idle_animation() -> void:
	if not anim_sprite or idle_anim == "":
		return

	if anim_sprite.animation != idle_anim or not anim_sprite.is_playing():
		anim_sprite.animation = idle_anim
		anim_sprite.frame = 0
		anim_sprite.play()

# --- Level completion ---
func win_level(player):
	if player == self:
		print("WIN LEVEL TRIGGERED! error =", error)
		emit_signal("levelWon", error)
