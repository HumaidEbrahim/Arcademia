extends Area2D

signal left_safe_area
signal entered_safe_area

var original_position: Vector2

# Use @onready to ensure the node is loaded before it's accessed
# This path is relative to the player node.
@onready var safe_area_node = get_node("../SafeArea")
@onready var main_ui_node = get_node("../main_ui")

func _ready() -> void:
	original_position = self.position
	
	# Connect the signal if the node was found
	if safe_area_node:
		safe_area_node.area_exited.connect(_on_safe_area_area_exited)
		safe_area_node.area_entered.connect(_on_safe_area_area_entered)
	else:
		# This print statement will help you debug if the path is wrong
		print("ERROR: SafeArea node not found!")

func _on_safe_area_area_exited(area: Area2D) -> void:
	if area == self:
		print("Player left the safe area! Returning to origin and clearing queue.")
		self.position = original_position
		emit_signal("left_safe_area")
		
		# Immediately stop the main_ui script by calling its clear function.
		# This stops the sequence of commands without changing main_ui.
		if main_ui_node:
			main_ui_node._on_clear_pressed()

func _on_safe_area_area_entered(area: Area2D) -> void:
	if area == self:
		print("Player entered the safe area.")
		emit_signal("entered_safe_area")
