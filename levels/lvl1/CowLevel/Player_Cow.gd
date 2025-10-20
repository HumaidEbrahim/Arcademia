extends Area2D

# --- Nodes ---
@onready var label = get_parent().get_node("TextBox/Text")
@onready var player_sprite = $Sprite2D
@onready var gate = get_parent().get_node("Gate")

# --- Player Node & Sounds ---
var player_node: Node = null
var whistle_sound: AudioStreamPlayer2D = null
var open_gate_sound: AudioStreamPlayer2D = null
var close_gate_sound: AudioStreamPlayer2D = null
var error_sound: AudioStreamPlayer2D = null
var sheep_baa_sound: AudioStreamPlayer2D = null
var cow_moo_sound: AudioStreamPlayer2D = null

signal levelWon(error: bool)

# --- Variables ---
var chosen_animal = null
var gate_opened: bool = false
var cow_count: int = 0
var error: bool = false
var animals = []
var whistle_anim = ""
var open_anim = ""
var idle_anim = ""
var is_animating = false
var track = load("res://music/Moo Melody.mp3")

func _ready():
	# Connect Area2D signal
	area_entered.connect(_on_area_entered)

	# Play background music
	MusicPlayer.play_stream(track, 2.0)

	# Set animations based on selected character
	if Global.SelectedCharacter == 1:
		whistle_anim = "Girl_Whistle"
		open_anim = "Girl_Open"
		idle_anim = "Girl_Idle"
	elif Global.SelectedCharacter == 0:
		whistle_anim = "Boy_Whistle"
		open_anim = "Boy_Open"
		idle_anim = "Boy_Idle"

	# Safely assign the Player node using the exact path
	player_node = get_tree().get_current_scene().get_node(
        "MainUI/HBoxContainer/GameArea/SubViewportContainer/SubViewport/Player"
	)

	if player_node:
		whistle_sound = player_node.get_node("WhistleSoundPlayer")
		open_gate_sound = player_node.get_node("OpenGateSound")
		close_gate_sound = player_node.get_node("CloseGateSound")
		error_sound = player_node.get_node("SheepErrorSound")
		sheep_baa_sound = player_node.get_node("SheepBaaSound")  # FIXED path
		cow_moo_sound = player_node.get_node("CowMooSound")

func _process(delta):
	if not is_animating:
		player_sprite.play(idle_anim)

# --- Player actions ---
func action_whistle():
	label.text = "Whistle"

	if whistle_sound:
		whistle_sound.play()

	is_animating = true
	player_sprite.play(whistle_anim)
	await player_sprite.animation_finished
	is_animating = false

	animals = get_tree().get_nodes_in_group("animals")
	if animals.size() == 0:
		chosen_animal = null
		return

	chosen_animal = animals.pick_random()
	var sprite = chosen_animal.get_node("AnimatedSprite2D")
	sprite.play()

	print("You whistled for " + chosen_animal.name)

	if chosen_animal.name.to_lower().contains("sheep"):
		chosen_animal.remove_from_group("animals")

# --- Move animals ---
func move_animal(animal: Node2D, gate_opened_now: bool):
	var sprite = animal.get_node("AnimatedSprite2D")
	sprite.play("walk")

	var target_pos: Vector2
	var duration: float

	if gate_opened_now:
		target_pos = Vector2(1500, randi_range(467, 615))
		duration = 5.0
	else:
		target_pos = animal.position + Vector2(80, randf_range(-10, 10))
		duration = 2.0

	var tween = get_tree().create_tween()
	tween.tween_property(animal, "position", target_pos, duration)
	tween.tween_callback(func(): sprite.pause())

# --- Gate actions ---
func action_openGate():
	if not gate_opened:
		gate.play()
		if open_gate_sound:
			open_gate_sound.play()
	gate_opened = true

	if chosen_animal:
		move_animal(chosen_animal, gate_opened)

func action_closeGate():
	if gate_opened:
		gate.play_backwards()
		if close_gate_sound:
			close_gate_sound.play()
	gate_opened = false

	if chosen_animal:
		move_animal(chosen_animal, gate_opened)

# --- Area entered (animals) ---
func _on_area_entered(area2):
	if not area2.is_in_group("animals"):
		return

	area2.remove_from_group("animals")

	var name_lower = area2.name.to_lower()

	if name_lower.contains("sheep"):
		label.text = "Whoops, you allowed a sheep in!"
		error = true
		print("Sheep entered! Playing sounds...")
		if error_sound:
			error_sound.play()
		if sheep_baa_sound:
			sheep_baa_sound.play()  # WILL NOW PLAY

	elif name_lower.contains("cow"):
		label.text = "Nicely done!"
		cow_count += 1
		if cow_moo_sound:
			cow_moo_sound.play()
		check_win()

# --- Helpers ---
func get_chosen_animal():
	return chosen_animal

func check_win():
	if cow_count == 3:
		print("Win condition reached! Emitting signal...")
		emit_signal("levelWon", error)
