extends Area2D

@onready var label = get_parent().get_node("TextBox/Text")
@onready var player = $Sprite2D
@onready var watering_sound: AudioStreamPlayer2D = get_node("../Player/PlayerWateringSound")
@onready var planting_sound: AudioStreamPlayer2D = get_node("../Player/PlayerPlantingSound")
@onready var walking_sounds = [
	get_node("../Player/PlayerWalkingSound"),
	get_node("../Player/PlayerWalkingSound2"),
	get_node("../Player/PlayerWalkingSound3")
]  # Cycling walking sounds
@onready var _walk_timer: Timer = get_node("../Player/Timer")

signal levelWon(error: bool)

var track = load("res://music/MOOgwenya.mp3")

var area = null
var last_position: Vector2
var completed_areas: Array = []
var success = 0
var error = false
var plant = ""
var water = ""
var is_animating = false

# Walking sound state
var _was_walking: bool = false
var _walk_index: int = 0

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	last_position = position
	
	MusicPlayer.play_stream(track, 2.0)
	
	if Global.SelectedCharacter == 1:
		plant = "Girl_Feed"
		water = "Girl_Water"
	elif Global.SelectedCharacter == 0:
		plant = "Boy_Feed"
		water = "Boy_Water"

	# Connect the timer properly
	_walk_timer.timeout.connect(Callable(self, "_play_next_walk_sound"))

func _process(delta):
	if not is_animating:
		last_position = Utils.update_animation(self, last_position, true)
	
	_check_walking_sound()

func _check_walking_sound():
	if not player:
		return

	var anim_name = player.animation
	var is_walking = anim_name.ends_with("_Walk")

	if is_walking and not _was_walking:
		# Started walking
		_walk_index = 0
		_walk_timer.start()
	elif not is_walking and _was_walking:
		# Stopped walking
		_walk_timer.stop()
		for s in walking_sounds:
			if s.playing:
				s.stop()

	_was_walking = is_walking

func _play_next_walk_sound():
	if walking_sounds.size() == 0:
		return
	var sound = walking_sounds[_walk_index]
	if sound:
		sound.play()
	_walk_index = (_walk_index + 1) % walking_sounds.size()

# --- WATERING ---
func action_water():
	if area and area.name.contains("Full"):
		if area.name not in completed_areas:
			is_animating = true
			player.play(water)
			await player.animation_finished
			is_animating = false
			completed_areas.append(area.name)
			area.action_watered()
			
			if watering_sound:
				watering_sound.play()
				# 🔸 Stop halfway through the sound duration
				var half_duration = watering_sound.stream.get_length() / 2.0
				get_tree().create_timer(half_duration).timeout.connect(func ():
					if watering_sound.playing:
						watering_sound.stop()
				)
			
			success += 1
			check_win()
		else:
			error = true
			label.text = "You've already watered this plant"
	else:
		label.text = "You can only water a pot that has a plant."
		error = true

# --- PLANTING ---
func action_plant(): 
	if area and area.name.contains("Empty"):
		if area.name not in completed_areas:
			is_animating = true
			player.play(plant)
			await player.animation_finished
			is_animating = false
			completed_areas.append(area.name)
			area.action_planted()
			
			if planting_sound:
				planting_sound.play()
			
			success += 1
			check_win()
		else:
			error = true
			label.text = "You've already planted something here"
	else:
		label.text = "You can only plant a new plant in an empty pot."
		error = true

# --- AREA EVENTS ---
func _on_area_entered(area2):
	area = area2

func _on_area_exited(area2):
	if area == area2:
		area = null

# --- HELPERS ---
func get_current_area():
	return area

func check_win():
	if success == 6:
		emit_signal("levelWon", error)
		print("won")
