extends Area2D

var has_feed = false
var area = null

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
func action_pickup():
	if area and area.name == "Feed" and not has_feed:
		has_feed = true
		print("Pickup")
		area.queue_free()
	else:
		print("go to the bag and pickup")
		
func action_feed():
	if area and area.name.begins_with("Chicken") and has_feed:
		area.add_to_group("fed")
		area.modulate = Color(0.7, 1.0, 0.7)
		var anim = area.get_node("AnimatedSprite2D")
		if anim:
			anim.play("default")
		check_win()
	elif area and area.name.begins_with("Chicken") and not has_feed:
		print("pickup feed first")
	else:
		print("go to chicken to feed it")

func _on_area_entered(area2):
	area = area2

func _on_area_exited(area2):
	if area == area2:
		area = null

func check_win():
	var fed = get_tree().get_nodes_in_group("fed").size()
	
	if fed == 2:
		print("Chickens are all fed")
