extends Control

@onready var run_button = $HBoxContainer/ScriptPanel/RunClear/Run
@onready var clear_button = $HBoxContainer/ScriptPanel/RunClear/Clear

# Storage for commands to be executed in sequence
var executeQue: Array = []

# Indentation tracking for visual block hierarchy
var current_indent_level: int = 0
const INDENT_OFFSET: int = 23.5

# Loop execution settings
var loop_iterations: int = 3
# Note: is_executing is replaced by the runReset logic
# var is_executing: bool = false

# Block rearrangement variables
var is_in_move_mode: bool = false
var node_to_move = null

#Toggle for running / resetting
var runReset: bool = false
# Note: runInProgress is replaced by disabling the button
# var runInProgress: bool = false

var current_level: Node
var gameArea: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Grab focus on launch
	resetFocusToInit()
	
	if Global.populatedExecuteQue.size() >= 1:
		rebuildScriptQue()


func _process(delta: float) -> void:
	var scriptQuePanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	var functionsPanel = $HBoxContainer/FunctionPanel/VBoxContainer
	var runClearBtns = $HBoxContainer/ScriptPanel/RunClear
	
	# Block movement controls (only when in move mode)
	if is_in_move_mode:
		if Input.is_action_just_pressed("ui_up"):
			move_node_in_queue(-1)
		elif Input.is_action_just_pressed("ui_down"):
			move_node_in_queue(1)
	
	# A button - execute/select commands
	if Input.is_action_just_pressed("btn_1"):
		var focusedItem = get_viewport().gui_get_focus_owner()
		
		if focusedItem and functionsPanel.is_ancestor_of(focusedItem):
			execute_FunctionsPanel(focusedItem, scriptQuePanel)
			
		elif focusedItem and is_in_script_panel(focusedItem, scriptQuePanel):
			# This is now handled by move mode (btn_2)
			pass
			
		elif focusedItem and runClearBtns.is_ancestor_of(focusedItem):
			const_buttons_ScriptPanel(focusedItem, runClearBtns)
	
	# S button - toggle move mode
	if Input.is_action_just_pressed("btn_2"):
		if is_in_move_mode:
			# Drop the current selection
			is_in_move_mode = false
			if is_instance_valid(node_to_move):
				node_to_move.modulate = Color(1, 1, 1)
			node_to_move = null
		else:
			# Pick up focused item for moving
			var focusedItem = get_viewport().gui_get_focus_owner()
			if focusedItem and is_in_script_panel(focusedItem, scriptQuePanel):
				is_in_move_mode = true
				node_to_move = focusedItem
				node_to_move.modulate = Color(0.8, 1, 0.8)
	
	# D button - delete command
	if Input.is_action_just_pressed("btn_3"):
		if is_in_move_mode:
			return

		var focusedItem = get_viewport().gui_get_focus_owner()
		
		if focusedItem and is_in_script_panel(focusedItem, scriptQuePanel):
			delete_item_from_queue(focusedItem)
	
	# F button - used for editing loop count
	if Input.is_action_just_pressed("btn_4"):
		pass

func _on_run_pressed() -> void:
	# FIX: This function now correctly handles the two-stage run/reset logic
	# while calling the new, robust execute_commands function.
	if runReset:
		# If button is in "Reset" state, call the reset function
		resetPlayerScene()
		# The scene reload will handle resetting the button's state and text
		return

	# If button is in "Run" state, execute the sequence
	run_button.text = "Running..."
	run_button.disabled = true
	clear_button.disabled = true
	
	
	populateActionsArray()
	await execute_commands(executeQue)

	# After sequence is done, change button to "Reset" state
	run_button.text = "Reset"
	run_button.disabled = false
	clear_button.disabled = false
	runReset = true

func execute_commands(commands: Array) -> void:
	# FIX: This is the single, correct execution function that handles loops
	# and safely assigns sprites to only the buttons that need them.
	var player = get_node("HBoxContainer/GameArea/SubViewportContainer/SubViewport/Player")
	
	var i = 0
	while i < commands.size():
		var action = commands[i]
		var actual_button = get_actual_button(action)
		if not actual_button:
			i += 1
			continue

		if actual_button and is_top_loop_block(actual_button):
			var loop_end_index = find_matching_loop_end(commands, i)
			if loop_end_index != -1:
				var loop_commands = commands.slice(i + 1, loop_end_index)
				var iterations = actual_button.get_loop_count()
				for loop_count in range(iterations):
					await execute_commands(loop_commands)
				i = loop_end_index + 1
			else:
				print("Warning: Loop start found but no matching loop end!")
				i += 1
		elif actual_button and is_bottom_loop_block(actual_button):
			i += 1
		else:
			if "sprite" in actual_button:
				actual_button.sprite = player
			
			if actual_button.has_method("_on_pressed"):
				actual_button._on_pressed()
				await actual_button.finished
			
			i += 1

func is_top_loop_block(action) -> bool:
	return "indent_change_value" in action and action.indent_change_value > 0

func is_bottom_loop_block(action) -> bool:
	return "indent_change_value" in action and action.indent_change_value < 0

func find_matching_loop_end(commands: Array, start_index: int) -> int:
	var nest_level = 0
	for i in range(start_index + 1, commands.size()):
		var command = commands[i]
		var actual_command = get_actual_button(command)
		
		if actual_command and is_top_loop_block(actual_command):
			nest_level += 1
		elif actual_command and is_bottom_loop_block(actual_command):
			if nest_level == 0:
				return i
			else:
				nest_level -= 1
	return -1

func get_actual_button(container):
	if container is MarginContainer and container.get_child_count() > 0:
		return container.get_child(0)
	# This handles cases where a button might not be in a container
	return container

func _on_clear_pressed() -> void:
	var scriptQuePanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	
	if run_button.text == "Running...":
		return
	
	for child in scriptQuePanel.get_children():
		child.queue_free()
	executeQue.clear()
	current_indent_level = 0

#Reset player area scene
func resetPlayerScene() -> void:
	var scriptPanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	
	#Duplicate script panel into global array
	Global.populatedExecuteQue.clear()
	for child in scriptPanel.get_children():
		Global.populatedExecuteQue.append(child.duplicate())
	
	get_tree().reload_current_scene()

func rebuildScriptQue() -> void:
	var scriptPanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	
	#Clear script panel manually - avoids duplication event
	for child in scriptPanel.get_children():
		child.queue_free()
		
	for saved in Global.populatedExecuteQue:
		scriptPanel.add_child(saved)

#Add children of ScriptPanel container to execution array
func populateActionsArray() -> void:
	var scriptQuePanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	executeQue.clear()
	for child in scriptQuePanel.get_children():
		executeQue.append(child)
		
func toggleShow(itemToToggle: Object) -> void:
	if itemToToggle.visible == false:
		itemToToggle.show()
	elif itemToToggle.visible == true:
		itemToToggle.hide()

func execute_FunctionsPanel(button: Object, locationToPut: Object) -> void:
	var copy = button.duplicate()
	copy.position = Vector2.ZERO
	
	# Handle loop end blocks - adjust indent before placement
	if "indent_change_value" in copy and copy.indent_change_value < 0:
		current_indent_level += copy.indent_change_value
		current_indent_level = max(0, current_indent_level + copy.indent_change_value)
	
	# Wrap button in container with proper indentation
	var margin_container = MarginContainer.new()
	var indent_pixels = current_indent_level * INDENT_OFFSET
	margin_container.add_theme_constant_override("margin_left", indent_pixels)
	
	margin_container.add_child(copy)
	copy.set_owner(margin_container)
	
	locationToPut.add_child(margin_container)
	margin_container.set_owner(locationToPut)
	
	# Handle loop start blocks - adjust indent after placement
	if "indent_change_value" in copy and copy.indent_change_value > 0:
		current_indent_level += copy.indent_change_value
		current_indent_level = max(0, current_indent_level)

func execute_ScriptPanel(button: Object, _location: Object = null) -> void:
	pass

func const_buttons_ScriptPanel(button: Object, location: Object) -> void:
	var runBtn = location.get_child(0)
	var clearBtn = location.get_child(1)
	
	if button == runBtn:
		runBtn.emit_signal("pressed")
	elif button == clearBtn:
		clearBtn.emit_signal("pressed")
		
func move_node_in_queue(direction: int) -> void:
	if not is_instance_valid(node_to_move):
		is_in_move_mode = false
		return

	# Find the container that needs to be moved
	var container_to_move = node_to_move
	if node_to_move.get_parent() is MarginContainer:
		container_to_move = node_to_move.get_parent()

	var current_index = container_to_move.get_index()
	var new_index = current_index + direction
	
	var parent_container = container_to_move.get_parent()
	var child_count = parent_container.get_child_count()

	if new_index < 0 or new_index >= child_count:
		return
		
	parent_container.move_child(container_to_move, new_index)
	recalculate_all_indentations()
	# Ensure focus stays on the moved item
	await get_tree().process_frame
	if is_instance_valid(node_to_move):
		node_to_move.grab_focus()

func delete_item_from_queue(item_to_delete: Control) -> void:
	var container_to_delete = item_to_delete
	if item_to_delete.get_parent() is MarginContainer:
		container_to_delete = item_to_delete.get_parent()
	
	var parent_container = container_to_delete.get_parent()
	var index = container_to_delete.get_index()

	container_to_delete.queue_free()

	await get_tree().process_frame
	
	recalculate_all_indentations()
	
	# Focus management after deletion
	var child_count = parent_container.get_child_count()
	if child_count > 0:
		var new_focus_index = min(index, child_count - 1)
		var next_container = parent_container.get_child(new_focus_index)
		
		var next_button = get_actual_button(next_container)
		if next_button:
			next_button.grab_focus()
	else:
		resetFocusToInit()

func is_in_script_panel(item: Control, script_panel: Control) -> bool:
	if script_panel.is_ancestor_of(item):
		return true

	if item.get_parent() and script_panel.is_ancestor_of(item.get_parent()):
		return true

	return false

func recalculate_all_indentations() -> void:
	var scriptQuePanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	var temp_indent_level = 0
	
	for container in scriptQuePanel.get_children():
		var button = get_actual_button(container)
		if not button:
			continue
		
		# Process loop end blocks first
		if "indent_change_value" in button and button.indent_change_value < 0:
			temp_indent_level += button.indent_change_value
			temp_indent_level = max(0, temp_indent_level)
		
		# Apply indentation to this block
		var indent_pixels = temp_indent_level * INDENT_OFFSET
		if container is MarginContainer:
			container.add_theme_constant_override("margin_left", indent_pixels)
		
		# Process loop start blocks after positioning
		if "indent_change_value" in button and button.indent_change_value > 0:
			temp_indent_level += button.indent_change_value
			temp_indent_level = max(0, temp_indent_level)

func get_num_blocks():
	return executeQue.size()

func resetFocusToInit() -> void:
	if has_node("HBoxContainer/FunctionPanel/VBoxContainer/Move_Right/Action_Button"):
		$HBoxContainer/FunctionPanel/VBoxContainer/Move_Right/Action_Button.grab_focus()
