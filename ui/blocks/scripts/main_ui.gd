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
		focusedItem.emit_signal("pressed")
		
	#listen to when S button is pressed
	if Input.is_action_just_pressed("btn_2"):
		pass
	
	#Listen to when D button is pressed
	if Input.is_action_just_pressed("btn_3"):
		pass
	
	#Listen to when F button is pressed
	if Input.is_action_just_pressed("btn_4"):
		pass


func _on_do_something_btn_pressed() -> void:
	#Add to execute que
	toggleShow($HBoxContainer/GameArea/SubViewportContainer/justAPopup)
	

func executeActions() -> void:
	#Loop execute que and do something
	for action in executeQue:
		print("add code to check what and blah blah")
	
	
func toggleShow(itemToToggle: Object) -> void:
	if (itemToToggle.visible == false):
		itemToToggle.show()
	elif (itemToToggle.visible == true):
		itemToToggle.hide()
