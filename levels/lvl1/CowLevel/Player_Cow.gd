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
		chosen_animal = null
		return
	
	chosen_animal = animals.pick_random()
	var sprite = chosen_animal.get_node("AnimatedSprite2D")
	sprite.play()
	
	print("You whistled for " + chosen_animal.name)
	
	if chosen_animal.name.contains("Sheep"):
		print("remove sheep")
		chosen_animal.remove_from_group("animals")


func move_animal(animal: Node2D, gate_opened_now: bool):
	var sprite = animal.get_node("AnimatedSprite2D")
	sprite.play("walk")

	var target_pos = animal.position
	var duration = 1.5

	if gate_opened_now:
		target_pos = Vector2(1500,  randi_range(467, 615))
		duration = 5.0
	else:
		target_pos = animal.position + Vector2(80, randf_range(-10, 10))
		duration = 2.0

	var tween = get_tree().create_tween()
	tween.tween_property(animal, "position", target_pos, duration)
	tween.tween_callback(func(): sprite.pause())



func action_openGate():
	if not gate_opened:
		gate.play()
		if open_gate_sound:
			open_gate_sound.play()
	gate_opened = true
	
	# if an animal was called, move it now
	if chosen_animal:
		move_animal(chosen_animal, gate_opened)


func action_closeGate():
	if gate_opened:
		gate.play_backwards()
		if close_gate_sound:
			close_gate_sound.play()
	gate_opened = false
	
	# move animal
	if chosen_animal:
		move_animal(chosen_animal, gate_opened)


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
			
	elif area2.name.contains("Cow"):
		area2.remove_from_group("animals")
		label.text = "Nicely done!"
		cow_count += 1
		check_win()
		if cow_moo_sound:
			cow_moo_sound.play()  

func get_chosen_animal():
	return chosen_animal

func check_win():
	print("Checking win")
	print(cow_count)
	if cow_count == 3:
		emit_signal("levelWon", error)
