extends Area2D

signal player_won

@onready var main_ui_node = get_node("../main_ui")
@onready var win_message_label = get_node("../WinMessage")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		print("Player has won! Emitting signal and showing win message.")
		emit_signal("player_won")
		
		# Stop the command queue by calling the existing clear function.
		if main_ui_node:
			main_ui_node._on_clear_pressed()
			
		# Show the win message.
		if win_message_label:
			win_message_label.visible = true
