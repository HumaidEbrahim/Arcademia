extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")
@onready var player = $Sprite2D
@onready var gate = get_parent().get_node("Gate")
@onready var whistle_sound: AudioStreamPlayer2D = get_node("../Player/WhistleSoundPlayer")  # <-- add your whistle sound node

signal levelWon(error:bool)

var area = null
var gate_opened:bool = false
var chosen_animal = null
var cow_count:int = 0
var error:bool = false
var animals = null

func _ready():
	area_entered.connect(_on_area_entered)

func action_whistle():
	label.text = "Whistle"
	
	# --- Play whistle sound ---
	if whistle_sound:
		whistle_sound.play()
	
	animals = get_tree().get_nodes_in_group("animals")
	if animals.size():
		return
	chosen_animal = animals.pick_random()
	print(chosen_animal)
	
	var sprite = chosen_animal.get_node("AnimatedSprite2D")
	sprite.play()
	
	var target_pos = 0
	var duration = 3
	if gate_opened:
		target_pos = Vector2(1500, randi_range(467, 615))
	else:
		target_pos = chosen_animal.position + Vector2(50, 2)
		duration = 1
	
	var tween = get_tree().create_tween()
	tween.tween_property(chosen_animal, "position", target_pos, duration)
	tween.tween_callback(func():sprite.pause())
	print("whistle done")

func action_openGate():
	if not gate_opened:
		gate.play()
	gate_opened = true
	print("opened")

func action_closeGate():
	if gate_opened:
		gate.play_backwards()
	gate_opened = false
	print("closed")
	
func _on_area_entered(area2):
	area2.remove_from_group("animals")
	print(animals)
	if area2.name.contains("Sheep"):
		label.text = "Whoops, you allowed a sheep in!"
		error = true
	else: 
		label.text = "cow!"
		cow_count += 1
	
	check_win()

func check_win():
	print(cow_count)
	if cow_count == 3:
		emit_signal("levelWon", error)
