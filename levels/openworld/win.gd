extends Node

@export var optimal_blocks:int = 0

@onready var praise = $ColorRect/Praise
@onready var feedback = $ColorRect/Feedback
@onready var starAnim = $ColorRect/Stars
@onready var btn_continue = $ColorRect/Btn_Continue

var message:String

func _ready() -> void:
	var player = get_tree().root.find_child("Player", true, false)
	player.connect("levelWon", Callable(self, "on_win"))
	
	btn_continue.pressed.connect(func():get_tree().change_scene_to_file("res://levels/openworld/FarmMap.tscn"))

func on_win(error):
	var ui = get_tree().root.find_child("MainUI", true, false)
	var blocks_used = ui.get_num_blocks()
	
	var stars = 1
	
	if blocks_used == optimal_blocks:
		stars += 1
	else:
		message += "Try using less blocks"
		
		
	if not error:
		stars += 1
	else:
		message += "Idiot" 
			
	self.visible = true
	
	match stars:
		1: 
			praise.text = "Good Job!"
			starAnim.play("oneStar")
		2: 
			praise.text = "Well Done!"
			starAnim.play("twoStar")
		3: 
			praise.text = "Outsanding Work!"
			starAnim.play("threeStar")
			
	feedback.text = message
	
