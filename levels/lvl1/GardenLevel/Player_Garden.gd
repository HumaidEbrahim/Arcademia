extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")
@onready var player = $Sprite2D

signal levelWon(error:bool) 

var area = null
var last_position: Vector2
var completed_areas:Array = []
var success = 0
var error = false

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	last_position = position
	

func _process(delta: float) -> void:

	last_position = Utils.update_animation(self,last_position,true)
	
func action_water():
	if area and area.name.contains("Full"):
		
		if area.name not in completed_areas:
			completed_areas.append(area.name)
			area.action_watered()
			success += 1
			check_win()
		else:
			error = true
			label.text = "You've already watered this plant"
	else:
		label.text = "You can only water a pot that has a plant."
		error = true
	
func action_plant(): 
	if area and area.name.contains("Empty"):
		
		if area.name not in completed_areas:
			completed_areas.append(area.name)
			area.action_planted()
			success += 1
			check_win()
		else:
			error = true
			label.text = "You've already planted something here"
	else:
		label.text = "You can only plant a new plant in an empty pot."
		error = true
		

func _on_area_entered(area2):
	area = area2

func _on_area_exited(area2):
	if area == area2:
		area = null

func check_win():
	if success == 6:
		emit_signal("levelWon",error)
		print("won")
		
