extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")
@onready var player = $Sprite2D
@onready var gate = get_parent().get_node("Gate")

# --- Audio ---
@onready var player_node = get_tree().get_current_scene().get_node("MainUI/HBoxContainer/GameArea/SubViewportContainer/SubViewport/Player")
@onready var whistle_sound: AudioStreamPlayer2D = player_node.get_node("WhistleSoundPlayer")
@onready var open_gate_sound: AudioStreamPlayer2D = player_node.get_node("OpenGateSound")
@onready var close_gate_sound: AudioStreamPlayer2D = player_node.get_node("CloseGateSound")
@onready var error_sound: AudioStreamPlayer2D = player_node.get_node("SheepErrorSound")
@onready var sheep_baa_sound: AudioStreamPlayer2D = player_node.get_node("SheepBaaSound")
@onready var cow_moo_sound: AudioStreamPlayer2D = player_node.get_node("CowMooSound")  # <-- NEW

signal levelWon(error: bool)

var area = null
var gate_opened: bool = false
var chosen_animal = null
var cow_count: int = 0
var error: bool = false
var animals = null
var whistle =""
var open = ""
var idle = ""
var is_animating = false
var track = load("res://music/Moo Melody.mp3")

func _ready():
	area_entered.connect(_on_area_entered)
	
	MusicPlayer.play_stream(track, 2.0)
	
	if Global.SelectedCharacter == 1:
		whistle = "Girl_Whistle"
		open = "Girl_Open"
		idle = "Girl_Idle"
	elif Global.SelectedCharacter == 0:
		whistle = "Boy_Whistle"
		open = "Boy_Open"
		idle = "Boy_Idle"

func _process(delta):
	if not is_animating:
		player.play(idle)
		
# --- Player actions ---
func action_whistle():
	label.text = "Whistle"
	
	
	if whistle_sound:
		whistle_sound.play()
	
	is_animating = true
	player.play(whistle)
	await player.animation_finished
	is_animating = false

	animals = get_tree().get_nodes_in_group("animals")
	if animals.size() == 0:
		return
	chosen_animal = animals.pick_random()
	var sprite = chosen_animal.get_node("AnimatedSprite2D")
	sprite.play()

	var target_pos = Vector2()
	var duration = 3
	if gate_opened:
		target_pos = Vector2(1500, randi_range(467, 615))
	else:
		target_pos = chosen_animal.position + Vector2(50, 2)
		duration = 1

	var tween = get_tree().create_tween()
	tween.tween_property(chosen_animal, "position", target_pos, duration)
	tween.tween_callback(func(): sprite.pause())

func action_openGate():
	if not gate_opened:
		gate.play()
		if open_gate_sound:
			open_gate_sound.play()
	gate_opened = true

func action_closeGate():
	if gate_opened:
		gate.play_backwards()
		if close_gate_sound:
			close_gate_sound.play()
	gate_opened = false

# --- Detect animals entering the area ---
func _on_area_entered(area2):
	if not area2.is_in_group("animals"):
		return

	area2.remove_from_group("animals")

	if area2.name.contains("Sheep"):
		label.text = "Whoops, you allowed a sheep in!"
		error = true
		if error_sound:
			error_sound.play()
		if sheep_baa_sound:
			sheep_baa_sound.play()
	else: 
		label.text = "cow!"
		cow_count += 1
		if cow_moo_sound:
			cow_moo_sound.play()  # <-- play cow sound

	check_win()

func check_win():
	if cow_count == 3:
		emit_signal("levelWon", error)
