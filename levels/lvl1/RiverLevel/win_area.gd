# win_area.gd
extends Area2D

signal player_won  # Declare the new custom signal

func _ready() -> void:
	# Connect the body_entered signal to a function in this script.
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Check if the entering body is the Player.
	if body.name == "Player":
		print("Player has won! Emitting signal.")
		emit_signal("player_won") # Emit the custom signal to listeners
