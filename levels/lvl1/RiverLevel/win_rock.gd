extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	# Make sure the body is the Player
	if body.is_in_group("Player") and body.has_method("win_level"):
		body.win_level(false) # false = no error
