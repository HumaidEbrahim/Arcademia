extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")
@onready var player = $Sprite2D

var has_feed = false
var area = null
var last_position: Vector2
var error = false
var is_animating = false
var feed = ""
var pickup = ""

signal levelWon(error:bool)

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	label.text = "Feed the chickens"
	last_position = position
	
	if Global.SelectedCharacter == 1:
			pickup = "Girl_Pickup"
			feed = "Girl_Feed"
	elif Global.SelectedCharacter == 0:
			pickup = "Boy_Pickup"
			feed = "Boy_Feed"
	

func _process(delta: float) -> void:
	
	if not is_animating:
		last_position = Utils.update_animation(self,last_position,true)
		
	
func action_pickup():
	if area and area.name == "Feed" and not has_feed:
		is_animating = true
		player.play(pickup)
		await player.animation_finished
		is_animating = false
		has_feed = true
		area.queue_free()
	else:
		label.text = "Go to the bag and pickup feed"
		error = true
		
func action_feed():
	if area and area.name.begins_with("Chicken") and has_feed:
		area.add_to_group("fed")
		is_animating = true
		player.play(feed)
		await player.animation_finished
		is_animating = false
		var anim = area.get_node("AnimatedSprite2D")
		if anim:
			anim.play("eat")
		check_win()
	elif area and area.name.begins_with("Chicken") and not has_feed:
		label.text = "Pickup feed first"
		error = true
	else:
		label.text = "Go to a chicken to feed it"
		error = true

func _on_area_entered(area2):
	area = area2

func _on_area_exited(area2):
	if area == area2:
		area = null

func check_win():
	var fed = get_tree().get_nodes_in_group("fed").size()
	if fed == 3:
		emit_signal("levelWon",error)
