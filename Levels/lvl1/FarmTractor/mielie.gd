extends Area2D


func _ready():
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	if area.name == "Player":
		queue_free()
