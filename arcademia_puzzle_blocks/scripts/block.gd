extends Control
class_name PuzzleBlock

const Workspace = preload("res://scripts/Workspace.gd")

@export var is_template_block: bool = false   # If true, this block is a template (spawns clones instead of moving itself)
@export var block_type: String = "move_right" # Type of action this block represents
@export var color: Color = Color(1,1,1)       # Visual color of the block

var dragging: bool = false        # True if currently being dragged
var drag_offset: Vector2 = Vector2.ZERO  # Offset between mouse and block origin while dragging
var workspace: Workspace          # Reference to the workspace

func _ready() -> void:
	# Find the workspace node
	workspace = get_parent().get_node("../WorkspaceArea") as Workspace
	if workspace == null:
		push_error("Workspace not found!")

	# Add this block to a group so it can be identified globally
	add_to_group("draggable_blocks")

func _gui_input(event: InputEvent) -> void:
	# Handle mouse clicks
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_template_block:
				# --- Case 1: Template block clicked ---
				# Duplicate the block into the workspace
				var clone: PuzzleBlock = duplicate() as PuzzleBlock
				clone.is_template_block = false   # Clones are real blocks

				# Position clone at mouse cursor relative to workspace
				var global_click_pos = get_global_mouse_position()
				clone.position = global_click_pos - workspace.global_position

				# Add clone to workspace and register it
				workspace.add_child(clone)
				workspace.add_block(clone, false) # Don't snap immediately

				# Start dragging the clone instantly
				clone.dragging = true
				clone.drag_offset = clone.get_local_mouse_position()
			else:
				# --- Case 2: Existing workspace block clicked ---
				# Start dragging this block
				dragging = true
				drag_offset = get_local_mouse_position()
			
			get_viewport().set_input_as_handled()
		else:
			# On mouse release, stop dragging
			if dragging:
				dragging = false
				workspace.snap_block(self)  # Snap into place after drag

func _process(_delta: float) -> void:
	# Update block position while dragging
	if dragging:
		position = get_parent().get_local_mouse_position() - drag_offset
