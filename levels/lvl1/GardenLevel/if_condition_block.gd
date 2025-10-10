extends TextureButton

signal finished

var initial_polygon: Polygon2D
var focus_polygon: Polygon2D

# This marks it as an if-block start (increases indentation)
var indent_change_value: int = 1 

@export var condition_type: String = "has_plant"

var sprite: Area2D  # Reference to player to check conditions

func _ready():
	# Get visual state polygons - matching your Action_btn structure
	initial_polygon = $"Initial" 
	focus_polygon = $"Focus"
	
	# Show initial state, hide focus state
	initial_polygon.visible = true
	focus_polygon.visible = false

func _on_focus_entered() -> void:
	initial_polygon.visible = false
	focus_polygon.visible = true

func _on_focus_exited() -> void:
	initial_polygon.visible = true
	focus_polygon.visible = false

func _on_pressed() -> void:
	# The condition check happens in main_ui.gd during execution
	finished.emit()

# This method will be called by main_ui.gd to evaluate the condition
func check_condition() -> bool:
	if not sprite:
		push_error("Player not assigned to if-block")
		return false
	
	# Check if player is in an area (pot)
	if sprite.has_method("get_current_area"):
		var current_area = sprite.get_current_area()
		if not current_area:
			return false
		
		# Get the AnimatedSprite2D from the pot
		var animated_sprite = current_area.get_node_or_null("AnimatedSprite2D")
		if not animated_sprite:
			return false
		
		match condition_type.to_lower():
			"has_plant":
				if animated_sprite.animation == "grow" and not animated_sprite.is_playing():
					return true
				return false
				
			"is_empty":
				if animated_sprite.animation == "" or (animated_sprite.animation == "plant" and animated_sprite.frame == 0):
					return true
				return false
			"gate_opened":
				print("open")
			"gate_closed":
				print("closed")
	
	return false
