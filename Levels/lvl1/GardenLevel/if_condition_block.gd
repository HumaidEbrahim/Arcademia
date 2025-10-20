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

	var animated_sprite = null
	var chosen_animal = null

	# Try to get area sprite
	if sprite.has_method("get_current_area"):
		var current_area = sprite.get_current_area()
		if current_area:
			animated_sprite = current_area.get_node_or_null("AnimatedSprite2D")

	# Try to get chosen animal
	if sprite.has_method("get_chosen_animal"):
		chosen_animal = sprite.get_chosen_animal()

	match condition_type.to_lower():
		"has_plant":
			if animated_sprite and animated_sprite.animation == "grow" and not animated_sprite.is_playing():
				return true
		"is_empty":
			if animated_sprite and (animated_sprite.animation == "" or (animated_sprite.animation == "plant" and animated_sprite.frame == 0)):
				return true
		"is_cow":
			if chosen_animal and chosen_animal.name.contains("Cow"):
				return true
		"not_cow":
			if chosen_animal and not chosen_animal.name.contains("Cow"):
				return true

	return false
