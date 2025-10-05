extends TextureButton

signal finished

@export var action: String
var sprite: Area2D
var initial_polygon: Polygon2D
var focus_polygon: Polygon2D

func _ready():
	sprite = get_tree().root.find_child("Player", true, false)
	
	# Get visual state polygons
	initial_polygon = $"Initial" 
	focus_polygon = $"Focus"
	
	# Show initial state, hide focus state
	initial_polygon.visible = true
	focus_polygon.visible = false

func call_action():
	if not sprite:
		push_error("Player not assigned")
		return
	if sprite:
		match action.to_lower():
			"pickup":
				sprite.action_pickup()
			"feed":
				sprite.action_feed()
			"water":
				sprite.action_water()
			"plant":
				sprite.action_plant()
			"whistle":
				sprite.action_whistle()
			"opengate":
				sprite.action_openGate()
				
				
			
			
	await get_tree().create_timer(0.2).timeout
	emit_signal("finished")

func _on_pressed():
	await call_action()

func _on_focus_entered() -> void:
	initial_polygon.visible = false
	focus_polygon.visible = true

func _on_focus_exited() -> void:
	initial_polygon.visible = true
	focus_polygon.visible = false
