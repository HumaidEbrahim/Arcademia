extends TextureButton

signal finished

@export var target_sprite: NodePath

var sprite: Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spriteAnimation() -> void:
	sprite = get_parent().get_parent().get_parent().find_child("Player") as Area2D
	
	#var sprite = get_node(target_sprite) as Area2D
	sprite.position.x += 50
	
	#add delay
	await get_tree().create_timer(0.5).timeout
	
	#IMPORTANT - Send finished signal so next item in que can start
	emit_signal("finished")

func _on_pressed() -> void:
	spriteAnimation()
