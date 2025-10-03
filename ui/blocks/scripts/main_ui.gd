extends Control

var executeQue: Array = []

# Variables to move commands in the queue
var is_in_move_mode: bool = false
var node_to_move = null

#Toggle for running / resetting
var runReset: bool = false
var runInProgress: bool = false

var current_level: Node
var gameArea: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Grab focus on launch
	resetFocusToInit()
	
	if Global.populatedExecuteQue.size() >= 1:
		rebuildScriptQue()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var scriptQuePanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	var functionsPanel = $HBoxContainer/FunctionPanel/VBoxContainer
	var runClearBtns = $HBoxContainer/ScriptPanel/RunClear
	
	# Handle movement ONLY when in move mode
	if is_in_move_mode:
		if Input.is_action_just_pressed("ui_up"):
			move_node_in_queue(-1) # -1 means move up
		elif Input.is_action_just_pressed("ui_down"):
			move_node_in_queue(1) # 1 means move down
	
	#listen to when A button is pressed to execute commands
	if Input.is_action_just_pressed("btn_1"):
		var focusedItem = get_viewport().gui_get_focus_owner()
		
		if ( focusedItem and functionsPanel.is_ancestor_of(focusedItem) ):
			execute_FunctionsPanel(focusedItem, scriptQuePanel)
			
		elif ( focusedItem and scriptQuePanel.is_ancestor_of(focusedItem) ):
			execute_ScriptPanel(focusedItem)
			
		elif (focusedItem and runClearBtns.is_ancestor_of(focusedItem) ):
			const_buttons_ScriptPanel(focusedItem, runClearBtns)

	#listen to when S button is pressed to enter/exit move mode
	if Input.is_action_just_pressed("btn_2"):
		#if we are already moving something, this button press will "drop" it
		if is_in_move_mode:
			is_in_move_mode = false
			if is_instance_valid(node_to_move):
				node_to_move.modulate = Color(1, 1, 1) # Reset color after selection
			node_to_move = null
		#otherwise, "pick up" the focused item if it's in the script queue
		else:
			var focusedItem = get_viewport().gui_get_focus_owner()
			if focusedItem and scriptQuePanel.is_ancestor_of(focusedItem):
				is_in_move_mode = true
				node_to_move = focusedItem
				# add a highlight to show it's selected for moving ("focused" text not working all that well yet)
				node_to_move.modulate = Color(0.8, 1, 0.8) 
	
	#Listen to when D button is pressed to delete a command from the queue
	if Input.is_action_just_pressed("btn_3"):
		#don't allow deleting while in move mode
		if is_in_move_mode:
			return

		var focusedItem = get_viewport().gui_get_focus_owner()
		
		#check if the focused item is in the script queue panel
		if focusedItem and scriptQuePanel.is_ancestor_of(focusedItem):
			delete_item_from_queue(focusedItem)
	
	#Listen to when F button is pressed
	if Input.is_action_just_pressed("btn_4"):
		pass

func _on_run_pressed() -> void:
	if (runInProgress):
		return
	
	if not runReset:
		runInProgress = true
		populateActionsArray()
		await exeqUserQue()
		runInProgress = false
		runReset = true
	else:
		resetPlayerScene()
		runReset = false

func _on_clear_pressed() -> void:
	var scriptQuePanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	
	for child in scriptQuePanel.get_children():
		scriptQuePanel.remove_child(child)
	
	executeQue.clear()

#Run all execution blocks
func exeqUserQue() -> void:
	if ( executeQue.size() >= 1 ):
		for action in executeQue:
			action._on_pressed()
		
			#Wait for first button to send finished signal
			await action.finished

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
		scriptPanel.remove_child(child)
		child.queue_free()
		
	for saved in Global.populatedExecuteQue:
		scriptPanel.add_child(saved)

#Add children of ScriptPanel container to execution array
func populateActionsArray() -> void:
	var scriptQuePanel = $HBoxContainer/ScriptPanel/ExecQueContainer/ScrollContainer/VBoxContainer
	
	#Stop executeQue from being inflated by repeated runs without clear
	executeQue.clear();
	
	for child in scriptQuePanel.get_children():
		executeQue.append(child)
	
#Toggles visibility of an object
func toggleShow(itemToToggle: Object) -> void:
	if (itemToToggle.visible == false):
		itemToToggle.show()
	elif (itemToToggle.visible == true):
		itemToToggle.hide()

#Happens when Btn_1 is pressed during functions panel focus
func execute_FunctionsPanel( button : Object, locationToPut : Object ) -> void:
	#add to script panel
	var copy = button.duplicate()
	locationToPut.add_child(copy)

#Happens when Btn_1 is pressed during ScriptPanel focus
func execute_ScriptPanel(button : Object, _location : Object = null) -> void:
	pass

#Happens when Btn_1 is pressed on the Run/Clear buttons
func const_buttons_ScriptPanel(button : Object, location : Object) -> void:
	#associate buttons
	var runBtn = location.get_child(0)
	var clearBtn = location.get_child(1)
	
	#Trigger runBtn or ClearBtn
	if (button == runBtn ):
		runBtn.emit_signal("pressed")
	elif (button == clearBtn):
		clearBtn.emit_signal("pressed")
	

func move_node_in_queue(direction: int, selectedButton : Object = null) -> void:
	#make sure we have a valid node to move
	if not is_instance_valid(node_to_move):
		is_in_move_mode = false # Exit move mode if invalid node
		return

	#get the node's current position/index in the list
	var current_index = node_to_move.get_index()
	#calculate where we want to move it
	var new_index = current_index + direction
	
	#get the parent container and number of items in it
	var parent_container = node_to_move.get_parent()
	var child_count = parent_container.get_child_count()

	#prevent moving outside the list boundaries
	if new_index < 0 or new_index >= child_count:
		return
		
	#reordering - Note, this destroys and recreates node
	parent_container.move_child(node_to_move, new_index)
	
	#Grab focus after move
	await get_tree().process_frame
	if is_instance_valid(node_to_move):
		node_to_move.grab_focus()

func delete_item_from_queue(item_to_delete: Control) -> void:
	var parent_container = item_to_delete.get_parent()
	var index = item_to_delete.get_index()

	#remove the node from the scene tree
	item_to_delete.queue_free()

	#wait for one frame for the deletion to complete before we manage focus
	await get_tree().process_frame
	
	#after deletion, focus on the next logical item
	var child_count = parent_container.get_child_count()
	if child_count > 0:
		# Clamp the index to make sure it's valid. This gracefully handles
		# deleting the last item in the list.
		var new_focus_index = min(index, child_count - 1)
		var next_item = parent_container.get_child(new_focus_index)
		next_item.grab_focus()
	elif child_count <= 0:
		#Reset focus if no elements in panel
		resetFocusToInit()

func resetFocusToInit() -> void:
	$HBoxContainer/FunctionPanel.get_child(0).get_child(0).get_child(0).grab_focus()
