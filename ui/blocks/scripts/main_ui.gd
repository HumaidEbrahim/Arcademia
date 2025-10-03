extends Control


@onready var run_button = $HBoxContainer/ScriptPanel/RunClear/Run


# Storage for commands to be executed in sequence

var executeQue: Array = []

# Indentation tracking for visual block hierarchy
var current_indent_level: int = 0
const INDENT_OFFSET: int = 23.5

# Loop execution settings
var loop_iterations: int = 3
var is_executing: bool = false

# Block rearrangement variables
var is_in_move_mode: bool = false
var node_to_move = null

#Toggle for running / resetting
var runReset: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Start with the first movement button focused
	$HBoxContainer/FunctionPanel/VBoxContainer/Move_Right/Action_Button.grab_focus()
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
			pass # Selecting items in the queue is handled by move mode
		elif focusedItem and runClearBtns.is_ancestor_of(focusedItem):
			const_buttons_ScriptPanel(focusedItem, runClearBtns)

	if Input.is_action_just_pressed("btn_2"): # Toggle move mode
		if is_in_move_mode:
			is_in_move_mode = false
			if is_instance_valid(node_to_move):
				node_to_move.modulate = Color(1, 1, 1)
			node_to_move = null
		else:
			var focusedItem = get_viewport().gui_get_focus_owner()
			if focusedItem and is_in_script_panel(focusedItem, scriptQuePanel):
				is_in_move_mode = true
				node_to_move = get_actual_button(focusedItem.get_parent()) # Select the button itself
				node_to_move.modulate = Color(0.8, 1, 0.8)

	if Input.is_action_just_pressed("btn_3"): # Delete
		if is_in_move_mode: return
		var focusedItem = get_viewport().gui_get_focus_owner()
		if focusedItem and is_in_script_panel(focusedItem, scriptQuePanel):
			delete_item_from_queue(focusedItem)

func _on_run_pressed():
	if runReset:
		# If it is, reset the scene and set the state back to "Run".
		resetPlayerScene()
		# Note: The scene reload will automatically handle the rest.
		return

	# If it's not in the "Reset" state, run the sequence.
	run_button.text = "Running..."
	run_button.disabled = true
	
	populateActionsArray()
	await execute_commands(executeQue)

	# --- THIS IS THE KEY CHANGE ---
	# After execution, change the button's text and state for the next click.
	run_button.text = "Reset"
	run_button.disabled = false
	runReset = true

func _on_clear_pressed():
	var scriptQuePanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	for child in scriptQuePanel.get_children():
		child.queue_free()
	executeQue.clear()
	current_indent_level = 0

func rebuildScriptQue():
	var scriptPanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	# Clear the panel before rebuilding
	for child in scriptPanel.get_children():
		child.queue_free()
	# Add the saved commands from the Global singleton
	for saved_container in Global.populatedExecuteQue:
		scriptPanel.add_child(saved_container)

func resetPlayerScene():
	var scriptPanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	Global.populatedExecuteQue.clear()
	# Save a duplicate of each command into the Global singleton
	for child in scriptPanel.get_children():
		Global.populatedExecuteQue.append(child.duplicate())
	# Reload the scene
	get_tree().reload_current_scene()

func execute_commands(commands: Array):
	var player = get_node("HBoxContainer/GameArea/SubViewportContainer/SubViewport/Player")
	var i = 0
	while i < commands.size():
		var container = commands[i]
		var actual_button = get_actual_button(container)
		if not actual_button:
			i += 1
			continue

		if is_top_loop_block(actual_button):
			var loop_end_index = find_matching_loop_end(commands, i)
			if loop_end_index != -1:
				var loop_commands = commands.slice(i + 1, loop_end_index)
				var iterations = actual_button.get_loop_count()
				for loop_count in range(iterations):
					await execute_commands(loop_commands)
				i = loop_end_index + 1
			else: # No matching end block found
				i += 1
		elif is_bottom_loop_block(actual_button):
			i += 1 # Skip end blocks
		else: # Execute regular command
			if "sprite" in actual_button:
				actual_button.sprite = player
			actual_button._on_pressed()
			await actual_button.finished
			i += 1

func populateActionsArray():
	var scriptQuePanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	executeQue.clear()
	for child in scriptQuePanel.get_children():
		executeQue.append(child)

func execute_FunctionsPanel(button: Object, locationToPut: Object):
	var copy = button.duplicate()
	if "indent_change_value" in copy and copy.indent_change_value < 0:
		current_indent_level = max(0, current_indent_level + copy.indent_change_value)
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", current_indent_level * INDENT_OFFSET)
	margin_container.add_child(copy)
	locationToPut.add_child(margin_container)
	if "indent_change_value" in copy and copy.indent_change_value > 0:
		current_indent_level += copy.indent_change_value

func move_node_in_queue(direction: int):
	if not is_instance_valid(node_to_move):
		is_in_move_mode = false
		return
	var container_to_move = node_to_move.get_parent()
	var parent_container = container_to_move.get_parent()
	var current_index = container_to_move.get_index()
	var new_index = clamp(current_index + direction, 0, parent_container.get_child_count() - 1)
	if new_index != current_index:
		parent_container.move_child(container_to_move, new_index)
		recalculate_all_indentations()
		await get_tree().process_frame
		node_to_move.grab_focus()

func delete_item_from_queue(item_to_delete: Control):
	var container_to_delete = item_to_delete.get_parent()
	var parent_container = container_to_delete.get_parent()
	var index = container_to_delete.get_index()
	container_to_delete.queue_free()
	await get_tree().process_frame
	recalculate_all_indentations()
	var child_count = parent_container.get_child_count()
	if child_count > 0:
		var next_container = parent_container.get_child(min(index, child_count - 1))
		get_actual_button(next_container).grab_focus()

func get_actual_button(container):
	if container is MarginContainer and container.get_child_count() > 0:
		return container.get_child(0)
	return container

func const_buttons_ScriptPanel(button: Object, location: Object):
	if button.name == "Run": button.emit_signal("pressed")
	elif button.name == "Clear": _on_clear_pressed()

func is_in_script_panel(item: Control, script_panel: Control):
	return script_panel.is_ancestor_of(item.get_parent())

func is_top_loop_block(action):
	return "indent_change_value" in action and action.indent_change_value > 0

func is_bottom_loop_block(action):
	return "indent_change_value" in action and action.indent_change_value < 0

func find_matching_loop_end(commands: Array, start_index: int):
	var nest_level = 0
	for i in range(start_index + 1, commands.size()):
		var actual_command = get_actual_button(commands[i])
		if actual_command and is_top_loop_block(actual_command):
			nest_level += 1
		elif actual_command and is_bottom_loop_block(actual_command):
			if nest_level == 0: return i
			else: nest_level -= 1
	return -1

func recalculate_all_indentations():
	var scriptQuePanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	var temp_indent_level = 0
	for container in scriptQuePanel.get_children():
		var button = get_actual_button(container)
		if not button: continue
		if "indent_change_value" in button and button.indent_change_value < 0:
			temp_indent_level = max(0, temp_indent_level + button.indent_change_value)
		if container is MarginContainer:
			container.add_theme_constant_override("margin_left", temp_indent_level * INDENT_OFFSET)
		if "indent_change_value" in button and button.indent_change_value > 0:
			temp_indent_level += button.indent_change_value
