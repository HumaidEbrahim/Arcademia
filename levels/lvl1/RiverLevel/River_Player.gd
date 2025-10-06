extends Area2D

signal left_safe_area
signal entered_safe_area

var original_position: Vector2
@onready var main_ui_node = get_node("../main_ui")  
@onready var anim_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")  # <-- reference to the AnimatedSprite2D

# Movement-detection helpers
var _last_position: Vector2
var _schedule_check_running: bool = false
const _CHECK_DEBOUNCE := 0.15 

func _ready() -> void:
	original_position = position
	monitoring = true
	monitorable = true
	_last_position = position

func _physics_process(_delta: float) -> void:
	# Detect movement
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
	# If still moving, let physics process restart the timer
	if position != _last_position:
		_schedule_check_running = false
		return

	_schedule_check_running = false
	_last_position = position
	check_safe_position()

func check_safe_position() -> void:
	if not is_on_rock():
		print("Not on a rock! Resetting to origin.")
		position = original_position
		emit_signal("left_safe_area")
		if main_ui_node and main_ui_node.has_method("_on_clear_pressed"):
			main_ui_node._on_clear_pressed()
	else:
		print("Player is safe on a rock.")
		emit_signal("entered_safe_area")

func is_on_rock() -> bool:
	for a in get_overlapping_areas():
		if a and a.is_in_group("Rocks"):
			print("Standing on rock (area): ", a.name)
			return true

	for b in get_overlapping_bodies():
		if b and b.is_in_group("Rocks"):
			print("Standing on rock (body): ", b.name)
			return true
		if b and b.get_parent() and b.get_parent().is_in_group("Rocks"):
			print("Standing on rock (body parent): ", b.get_parent().name)
			return true

	return false

# --- Animation helpers ---
func _play_movement_animation() -> void:
	if anim_sprite and anim_sprite.animation != "Boy_Jump":
		anim_sprite.play("Boy_Jump")

func _play_idle_animation() -> void:
	if anim_sprite and anim_sprite.animation != "Boy_Idle":
		anim_sprite.play("Boy_Idle")
