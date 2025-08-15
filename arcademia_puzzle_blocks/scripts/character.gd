extends Node2D
class_name Character

@export var move_speed: float = 100.0   # Movement speed in pixels per second

@onready var movement_area: Control = $"../MovementArea"  # The bounding area the character must stay inside
@onready var sprite: Sprite2D = $Sprite2D                 # The visible sprite

# --- Movement functions ---
func move_left(delta: float) -> void:
	global_position.x -= move_speed * delta
	_clamp_to_movement_area()

func move_right(delta: float) -> void:
	global_position.x += move_speed * delta
	_clamp_to_movement_area()

func move_up(delta: float) -> void:
	global_position.y -= move_speed * delta
	_clamp_to_movement_area()

func move_down(delta: float) -> void:
	global_position.y += move_speed * delta
	_clamp_to_movement_area()

# --- Clamp sprite inside movement area ---
func _clamp_to_movement_area() -> void:
	# Get bounding boxes
	var sprite_aabb := _get_sprite_global_aabb()
	var area_rect: Rect2 = movement_area.get_global_rect()

	var dx := 0.0
	var dy := 0.0

	# Clamp horizontally
	if sprite_aabb.position.x < area_rect.position.x:
		dx = area_rect.position.x - sprite_aabb.position.x
	elif sprite_aabb.position.x + sprite_aabb.size.x > area_rect.position.x + area_rect.size.x:
		dx = (area_rect.position.x + area_rect.size.x) - (sprite_aabb.position.x + sprite_aabb.size.x)

	# Clamp vertically
	if sprite_aabb.position.y < area_rect.position.y:
		dy = area_rect.position.y - sprite_aabb.position.y
	elif sprite_aabb.position.y + sprite_aabb.size.y > area_rect.position.y + area_rect.size.y:
		dy = (area_rect.position.y + area_rect.size.y) - (sprite_aabb.position.y + sprite_aabb.size.y)

	# Apply correction
	if dx != 0.0 or dy != 0.0:
		global_position += Vector2(dx, dy)

# --- Utility: compute the sprite’s global bounding box ---
func _get_sprite_global_aabb() -> Rect2:
	if sprite.texture == null:
		return Rect2(global_position, Vector2.ZERO)

	# Local rect already accounts for pivot, region, etc.
	var r: Rect2 = sprite.get_rect()

	# Transform its corners to world space
	var xf: Transform2D = sprite.global_transform
	var p0: Vector2 = xf * r.position
	var p1: Vector2 = xf * (r.position + Vector2(r.size.x, 0))
	var p2: Vector2 = xf * (r.position + r.size)
	var p3: Vector2 = xf * (r.position + Vector2(0, r.size.y))

	# Get min/max to form AABB
	var min_x: float = min(min(p0.x, p1.x), min(p2.x, p3.x))
	var max_x: float = max(max(p0.x, p1.x), max(p2.x, p3.x))
	var min_y: float = min(min(p0.y, p1.y), min(p2.y, p3.y))
	var max_y: float = max(max(p0.y, p1.y), max(p2.y, p3.y))

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
