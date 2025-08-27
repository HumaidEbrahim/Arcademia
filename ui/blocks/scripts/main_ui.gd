extends Control

#Array to store execution commands
var executeQue:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Grab focus on launch
	$HBoxContainer/FunctionPanel/VBoxContainer/do_something/doSomethingBtn.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#listen to when A button is pressed
	if Input.is_action_just_pressed("btn_1"):
		var focusedItem = get_viewport().gui_get_focus_owner()
		var functionsPanel = $HBoxContainer/FunctionPanel/VBoxContainer;
		var scriptQuePanel = $HBoxContainer/ScriptPanel/VBoxContainer
		var runClearBtns = $HBoxContainer/ScriptPanel/RunClear
		
		if ( focusedItem and functionsPanel.is_ancestor_of(focusedItem) ):
			execute_FunctionsPanel(focusedItem, scriptQuePanel)
			
		elif ( focusedItem and scriptQuePanel.is_ancestor_of(focusedItem) ):
			execute_ScriptPanel(focusedItem)
			
		elif (focusedItem and runClearBtns.is_ancestor_of(focusedItem) ):
			const_buttons_ScriptPanel(focusedItem, runClearBtns)
	
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
		
		#Wait for first button to send finished signal
		await action.finished

func _on_clear_pressed() -> void:
	var scriptQuePanel = $HBoxContainer/ScriptPanel/VBoxContainer
	
	for child in scriptQuePanel.get_children():
		scriptQuePanel.remove_child(child)
	
	executeQue.clear()

#Add children of ScriptPanel container to execution array
func populateActionsArray() -> void:
	var scriptQuePanel = $HBoxContainer/ScriptPanel/VBoxContainer
	
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
