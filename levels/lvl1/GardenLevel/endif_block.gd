extends TextureButton

signal finished

var initial_polygon: Polygon2D
var focus_polygon: Polygon2D

# This decreases indentation level
var indent_change_value: int = -1 

func _ready():
	# Get visual state polygons - matching your structure
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
	finished.emit()
