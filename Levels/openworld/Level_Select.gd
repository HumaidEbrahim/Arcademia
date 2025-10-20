extends Area2D

@export var target_level:String = ""
@export var progress_level = 0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var original_scale: Vector2
var player_inside := false

var current_level_portal: Area2D = null

var track = load("res://music/Bongi Eepy/Bongi Eepy (mastered).mp3")

func _ready():
	MusicPlayer.play_stream(track, 2.5)
	
	original_scale = sprite.scale
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player": 
		player_inside = true
		sprite.modulate = Color(1, 1, 0.5) 
		sprite.scale *= 1.1

func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		sprite.modulate = Color(1, 1, 1)
		sprite.scale = original_scale

func _process(delta):
	if player_inside and Input.is_action_just_pressed("btn_1"):
		# Ensure the target_level is not empty before trying to load it
		if not target_level.is_empty():
			get_tree().change_scene_to_file(target_level)
		else:
			print("Error: target_level is not set for this portal.")
