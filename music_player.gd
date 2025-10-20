extends Node

@onready var player_a: AudioStreamPlayer2D = $Player1
@onready var player_b: AudioStreamPlayer2D = $Player2

const SILENCE_DB := -80.0
var active_player: AudioStreamPlayer2D
var inactive_player: AudioStreamPlayer2D

func _ready():
	active_player = player_a
	inactive_player = player_b
	active_player.volume_db = 0.0
	inactive_player.volume_db = SILENCE_DB

func play_stream(new_stream: AudioStream, fade_time: float = 1.0):
	if new_stream == null:
		_fade_out_active(fade_time)
		return

	if active_player.stream == new_stream:
<<<<<<< HEAD
		return  # already playing this track

	# Prepare inactive player
=======
		return

>>>>>>> 6c5256bb6f3b143cc7341db727904e7fce2214f0
	inactive_player.stop()
	inactive_player.stream = new_stream
	inactive_player.volume_db = SILENCE_DB
	inactive_player.play()

<<<<<<< HEAD
	# Fade in new track
	var tween_in = create_tween()
	tween_in.tween_property(inactive_player, "volume_db", 0.0, fade_time)

	# Fade out old track
	var tween_out = create_tween()
	tween_out.tween_property(active_player, "volume_db", SILENCE_DB, fade_time)

	# Wait for fade-out to finish
	await tween_out.finished

	# Only stop old player if new track is playing
	if inactive_player.playing:
		active_player.stop()

	# Swap players
=======
	var tween_in = create_tween()
	tween_in.tween_property(inactive_player, "volume_db", 0.0, fade_time)

	var tween_out = create_tween()
	tween_out.tween_property(active_player, "volume_db", SILENCE_DB, fade_time)

	await tween_out.finished
	active_player.stop()

>>>>>>> 6c5256bb6f3b143cc7341db727904e7fce2214f0
	var temp = active_player
	active_player = inactive_player
	inactive_player = temp

func _fade_out_active(fade_time: float):
	var tween = create_tween()
	tween.tween_property(active_player, "volume_db", SILENCE_DB, fade_time)
	await tween.finished
	active_player.stop()
