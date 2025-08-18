extends Control
class_name Workspace

# Spacing between blocks in the workspace
@export var horizontal_spacing: int = 10

# Holds references to all blocks currently inside the workspace
var blocks: Array[Control] = []

# --- Add a block to the workspace ---
func add_block(block: Control, snap: bool = true) -> void:
	# Only add if not already in the list
	if not blocks.has(block):
		blocks.append(block)
		block.add_to_group("draggable_blocks")
		
		# Optionally snap it into position
		if snap:
			snap_block(block)

# --- Remove a block from the workspace ---
func remove_block(block: Control) -> void:
	blocks.erase(block)
	block.remove_from_group("draggable_blocks")

# --- Snap a block into sequence (left to right) ---
func snap_block(block: Control) -> void:
	blocks.sort_custom(func(a, b):
		return a.position.x < b.position.x
	)

	# Now re-align visually
	var x_pos = 0
	for b in blocks:
		b.position = Vector2(x_pos, 0)
		x_pos += b.size.x + horizontal_spacing


# --- Build the sequence of actions (for execution) ---
func get_sequence() -> Array[Control]:
	return blocks.duplicate()

# --- Clear all blocks from the workspace ---
func clear_workspace() -> void:
	# Duplicate the array so we can safely free while iterating
	for block in blocks.duplicate():
		block.queue_free()

	# Reset the workspace block list
	blocks.clear()
