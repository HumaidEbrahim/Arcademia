extends Node

@export var optimal_blocks:int = 0

@onready var praise = $ColorRect/Praise
@onready var feedback = $ColorRect/Feedback
@onready var starAnim = $ColorRect/Stars
@onready var btn_continue = $ColorRect/Btn_Continue
@onready var btn_retry = $ColorRect/Btn_TryAgain

var message:String
var time_elapsed: float = 0.0
var running: bool = true

func _process(delta: float) -> void:
	if running:
		time_elapsed += delta

func _ready() -> void:
	btn_continue.grab_focus()
	btn_retry.grab_focus()
	var player = get_tree().root.find_child("Player", true, false)
	player.connect("levelWon", Callable(self, "on_win"))
	
	btn_continue.pressed.connect(func():get_tree().change_scene_to_file("res://levels/openworld/FarmMap.tscn"))
	btn_retry.pressed.connect(on_try)
	

func on_win(error) -> void:
	running = false

	await get_tree().create_timer(1).timeout

	var ui = get_tree().root.find_child("MainUI", true, false)
	var blocks_used = ui.get_num_blocks()
	
	var stars = 1
	
	if blocks_used <= optimal_blocks:
		stars += 1
	else:
		message += "Try using less blocks"
		
	if not error:
		stars += 1
	else:
		message += "\nWhoops, you made a few mistakes!" 
			
	self.visible = true
	
	match stars:
		1: 
			praise.text = "Good Job!"
			starAnim.play("oneStar")
		2: 
			praise.text = "Well Done!"
			starAnim.play("twoStar")
		3: 
			praise.text = "Outstanding Work!"
			starAnim.play("threeStar")

	print(message)		
	feedback.text = message
	ProfileDB.update_level_result(get_tree().current_scene.name, stars, time_elapsed)
	
func on_try() -> void:
	Global.populatedExecuteQue.clear() 
	print(Global.populatedExecuteQue)
	print("End of array")
	get_tree().reload_current_scene() 
