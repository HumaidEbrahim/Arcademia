extends TextureButton

signal finished

var initial_top_polygon: Polygon2D
var focus_top_polygon: Polygon2D

# Indentation control
var indent_change_value: int = 1 

# Loop count - can be set via label or fallback to default
@export var default_loop_count: int = 3
var loop_count_label: Label

func _ready():
	initial_top_polygon = $Initial_Top
	focus_top_polygon = $Focus_Top
	
	initial_top_polygon.visible = true
	focus_top_polygon.visible = false
	
	# Search for label more thoroughly
	find_loop_count_label()

func find_loop_count_label():
	# Try direct child access first
	for child in get_children():
		if child is Label:
			loop_count_label = child
			return
	
	# Try by name with path notation
	if has_node("LoopCountLabel"):
		loop_count_label = $LoopCountLabel
	elif has_node("Count"):
		loop_count_label = $Count  
	elif has_node("Label"):
		loop_count_label = $Label
	
	# Last resort - recursive search
	if not loop_count_label:
		loop_count_label = find_child("*", false) as Label

func _on_focus_entered() -> void:
	initial_top_polygon.visible = false
	focus_top_polygon.visible = true

func _on_focus_exited() -> void:
	initial_top_polygon.visible = true
	focus_top_polygon.visible = false

func _on_pressed() -> void:
	finished.emit()

func get_loop_count() -> int:
	# Try to get count from label first
	if loop_count_label and loop_count_label.text.is_valid_int():
		var label_count = loop_count_label.text.to_int()
		return max(1, label_count)  # Ensure at least 1 iteration
	
	# Fallback to default if no valid label
	return default_loop_count

func set_loop_count(count: int) -> void:
	var new_count = max(1, count)
	# Update default as backup
	default_loop_count = new_count
