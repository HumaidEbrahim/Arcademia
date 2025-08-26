extends Control

var executeQue:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Grab focus on launch
	$HBoxContainer/FunctionPanel/VBoxContainer/do_something/doSomethingBtn.grab_focus()
	
	#temp feedback item (can be deleted if RUAN says so)
	$HBoxContainer/GameArea/SubViewportContainer/justAPopup.hide();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#listen to when A button is pressed
	if Input.is_action_just_pressed("btn_1"):
		var focusedItem = get_viewport().gui_get_focus_owner()
		var functionsPanel = $HBoxContainer/FunctionPanel/VBoxContainer;
		var scriptQuePanel = $HBoxContainer/ScriptPanel/VBoxContainer
		var runClearBtns = $HBoxContainer/ScriptPanel/RunClear
		
		if ( focusedItem and functionsPanel.is_ancestor_of(focusedItem) ):
			#add to script panel
			var copy = focusedItem.duplicate()
			scriptQuePanel.add_child(copy)
			
		elif ( focusedItem and scriptQuePanel.is_ancestor_of(focusedItem) ):
			pass
			
		elif (focusedItem and runClearBtns.is_ancestor_of(focusedItem) ):
			
			#associate buttons
			var runBtn = runClearBtns.get_child(0)
			var clearBtn = runClearBtns.get_child(1)
			
			#Trigger runBtn or ClearBtn
			if (focusedItem == runBtn ):
				runBtn.emit_signal("pressed")
			elif (focusedItem == clearBtn):
				clearBtn.emit_signal("pressed")
		
	#listen to when S button is pressed
	if Input.is_action_just_pressed("btn_2"):
		pass
	
	#Listen to when D button is pressed
	if Input.is_action_just_pressed("btn_3"):
		pass
	
	#Listen to when F button is pressed
	if Input.is_action_just_pressed("btn_4"):
		pass

func _on_run_pressed() -> void:
	populateActionsArray()
	
	for action in executeQue:
		action.emit_signal("pressed")

func _on_clear_pressed() -> void:
	var scriptQuePanel = $HBoxContainer/ScriptPanel/VBoxContainer
	
	for child in scriptQuePanel.get_children():
		scriptQuePanel.remove_child(child)
	
	executeQue.clear()

#Add children of ScriptPanel container to execution array
func populateActionsArray() -> void:
	var scriptQuePanel = $HBoxContainer/ScriptPanel/VBoxContainer
	
	for child in scriptQuePanel.get_children():
		executeQue.append(child)
	
#Toggles visibility of an object
func toggleShow(itemToToggle: Object) -> void:
	if (itemToToggle.visible == false):
		itemToToggle.show()
	elif (itemToToggle.visible == true):
		itemToToggle.hide()

func _on_do_something_btn_pressed() -> void:
	#Add to execute que
	toggleShow($HBoxContainer/GameArea/SubViewportContainer/justAPopup)
