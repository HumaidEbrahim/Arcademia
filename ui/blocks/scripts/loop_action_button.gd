extends TextureButton

signal finished

var initial_top_polygon: Polygon2D
var focus_top_polygon: Polygon2D

var indent_change_value: int = 1 
@export var default_loop_count: int = 2
var loop_count_label: Label

# Edit mode variables
var is_editing_count: bool = false
var current_count: int = 1
var min_count: int = 2
var max_count: int = 9

func _ready():
	initial_top_polygon = $Initial_Top
	focus_top_polygon = $Focus_Top
	
	initial_top_polygon.visible = true
	focus_top_polygon.visible = false
	
	find_loop_count_label()
	current_count = default_loop_count
	update_label_display()

func find_loop_count_label():
	# Search for label among children
	for child in get_children():
		if child is Label:
			loop_count_label = child
			return

func update_label_display():
	if loop_count_label:
		if is_editing_count:
			# Show editing state with brackets or different color
			loop_count_label.text = "[" + str(current_count) + "]"
			loop_count_label.modulate = Color(1, 1, 0.5)  # Yellowish tint
		else:
			loop_count_label.text = str(current_count)
			loop_count_label.modulate = Color.WHITE

func _input(event):
	# Only handle input when this button has focus
	if not has_focus():
		return
		
	# Handle editing mode toggle (using a shoulder button or trigger)
	if event.is_action_pressed("btn_4"):  # F button - enter/exit edit mode
		is_editing_count = !is_editing_count
		update_label_display()
		get_viewport().set_input_as_handled()
		return
	
	# Handle count adjustment when in edit mode
	if is_editing_count:
		if event.is_action_pressed("ui_down"):
			current_count = max(min_count, current_count - 1)
			update_label_display()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			current_count = min(max_count, current_count + 1)
			update_label_display()
			get_viewport().set_input_as_handled()

func _on_focus_entered() -> void:
	initial_top_polygon.visible = false
	focus_top_polygon.visible = true

func _on_focus_exited() -> void:
	initial_top_polygon.visible = true
	focus_top_polygon.visible = false
	
	# Exit edit mode when losing focus
	if is_editing_count:
		is_editing_count = false
		update_label_display()

func _on_pressed() -> void:
	finished.emit()

func get_loop_count() -> int:
	return current_count

func set_loop_count(count: int) -> void:
	current_count = clamp(count, min_count, max_count)
	update_label_display()
