extends Node

static func update_animation(area: Area2D, last_pos: Vector2, mainChar:bool, flipped:bool=false):
	
	var anim = area.get_node_or_null("Sprite2D")
	var walk = "Walk"
	var idle = "Idle"
	
	if Global.SelectedCharacter == 0 && mainChar == true:
			walk = "Girl_Walk"
			idle = "Girl_Idle"
	elif Global.SelectedCharacter == 1 && mainChar == true:
			walk = "Boy_Walk"
			idle = "Boy_Idle"
		
	if area.position != last_pos:
		anim.play(walk)
		if !flipped:
			anim.flip_h = area.position.x < last_pos.x
		else:
			anim.flip_h = area.position.x > last_pos.x
	else:
		anim.play(idle)

	return area.position
