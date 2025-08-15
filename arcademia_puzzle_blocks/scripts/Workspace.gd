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
	var x_pos = 0

	# Calculate x position based on all blocks before it
	for b in blocks:
		if b == block:
			break
		x_pos += b.size.x + horizontal_spacing

	# Place the block at the computed position (y = 0 baseline)
	block.position = Vector2(x_pos, 0)

# --- Build the sequence of actions (for execution) ---
func get_sequence() -> Array[String]:
	var sequence: Array[String] = []

	# Append each block's action type in order
	for block in blocks:
		sequence.append(block.block_type)

	return sequence

# --- Clear all blocks from the workspace ---
func clear_workspace() -> void:
	# Duplicate the array so we can safely free while iterating
	for block in blocks.duplicate():
		block.queue_free()

	# Reset the workspace block list
	blocks.clear()
