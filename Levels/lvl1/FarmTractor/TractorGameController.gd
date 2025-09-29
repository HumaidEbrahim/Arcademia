extends Node
@onready var label = get_parent().get_node("TextBox/Text")

func _ready() -> void:
	label.text = "Harvest all the corn"
	
func _process(_delta: float) -> void:
	if get_tree().get_nodes_in_group("Mielies").is_empty():
			game_complete()

func game_complete():
	print("All objects destroyed! Level complete!")
