extends Area2D

signal player_exited

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		emit_signal("player_exited", body)
