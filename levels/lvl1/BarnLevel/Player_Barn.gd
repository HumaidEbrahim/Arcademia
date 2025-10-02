extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")
@onready var player = $Sprite2D

var has_feed = false
var area = null
var last_position: Vector2


func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	label.text = "Feed the chickens"
	last_position = position
	

func _process(delta: float) -> void:

	last_position = Utils.update_animation(self,last_position,true)
		
	
func action_pickup():
	if area and area.name == "Feed" and not has_feed:
		has_feed = true
		area.queue_free()
	else:
		label.text = "Go to the bag and pickup"
		
func action_feed():
	if area and area.name.begins_with("Chicken") and has_feed:
		area.add_to_group("fed")
	
		var anim = area.get_node("AnimatedSprite2D")
		if anim:
			anim.play("eat")
		check_win()
	elif area and area.name.begins_with("Chicken") and not has_feed:
		label.text = "Pickup feed first"
	else:
		label.text = "Go to a chicken to feed it"

func _on_area_entered(area2):
	area = area2

func _on_area_exited(area2):
	if area == area2:
		area = null

func check_win():
	var fed = get_tree().get_nodes_in_group("fed").size()
	
	if fed == 3:
		label.text = "Chickens are all fed"
