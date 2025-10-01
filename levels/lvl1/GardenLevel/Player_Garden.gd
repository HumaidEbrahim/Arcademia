extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")
@onready var player = $Sprite2D

var has_feed = false
var area = null
var last_position: Vector2


func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	last_position = position
	

func _process(delta: float) -> void:

	last_position = Utils.update_animation(self,last_position,true)
	

		
	

func _on_area_entered(area2):
	area = area2

func _on_area_exited(area2):
	if area == area2:
		area = null

#func check_win():
	
