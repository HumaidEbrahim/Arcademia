extends TextureButton

# Add the finished signal that the loop execution expects
signal finished

var initial_bottom_polygon: Polygon2D
var focus_bottom_polygon: Polygon2D

# This property will be used by main_ui.gd to decrease indentation level
var indent_change_value: int = -1 

func _ready():
	initial_bottom_polygon = $Initial_Bottom
	focus_bottom_polygon = $Focus_Bottom
	
	initial_bottom_polygon.visible = true
	focus_bottom_polygon.visible = false

func _on_focus_entered() -> void:
	initial_bottom_polygon.visible = false
	focus_bottom_polygon.visible = true

func _on_focus_exited() -> void:
	initial_bottom_polygon.visible = true
	focus_bottom_polygon.visible = false

# This method is called when the bottom loop action button is pressed during execution
func _on_pressed() -> void:
	finished.emit()
