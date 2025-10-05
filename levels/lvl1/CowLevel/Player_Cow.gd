extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")
@onready var player = $Sprite2D
@onready var animals = get_tree().get_nodes_in_group("animals")

var has_feed = false
var area = null
var last_position: Vector2
var gate_opened:bool = false

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	last_position = position

			
	
func action_whistle():
	label.text = "Whistle"
	var chosen_animal = animals.pick_random()
	var sprite = chosen_animal.get_node("AnimatedSprite2D")
	sprite.play()
	
	var target_pos = 0
	if gate_opened:
		target_pos = Vector2(1500, randi_range(467, 615))
	else:
		target_pos = Vector2(830, randi_range(467, 615))
		
	
	var tween = get_tree().create_tween()
	tween.tween_property(chosen_animal, "position", target_pos, 7)
	tween.tween_callback(func():sprite.pause())

	
		

func _on_area_entered(area2):
	area = area2

func _on_area_exited(area2):
	if area == area2:
		area = null

func check_win():
	var fed = get_tree().get_nodes_in_group("fed").size()
	
	if fed == 3:
		label.text = "Chickens are all fed"
