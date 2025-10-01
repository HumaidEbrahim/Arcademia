extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")
@onready var player = $Sprite2D

var area = null
var last_position: Vector2
var success = 0

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	last_position = position
	

func _process(delta: float) -> void:

	last_position = Utils.update_animation(self,last_position,true)
	
func action_water():
	if area and area.name.contains("Full"):
		label.text = "water"
		area.action_watered()
		success += 1
		check_win()
	else:
		label.text = "You can only water a pot that has a plant."
	
func action_plant(): 
	if area and area.name.contains("Empty"):
		label.text = "plant"
		area.action_planted()
		success += 1
		check_win()
	else:
		label.text = "You can only plant a new plant in an empty pot."
		

func _on_area_entered(area2):
	area = area2

func _on_area_exited(area2):
	if area == area2:
		area = null

func check_win():
	if success == 6:
		print("won")
	
