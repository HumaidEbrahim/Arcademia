@tool
extends Control
class_name Block

const Workspace = preload("res://scripts/Workspace.gd")

@export var block_type: String = "Block" # Type of action this block represents
@export var color: Color = Color(1,1,1,1)       # Visual color of the block
@export var target_path: NodePath
@export var action_type: String = ""
@export var block_icon: Texture2D
@export var is_template_block: bool = false   # If true, this block is a template (spawns clones instead of moving itself)
@export var duration :float = 1;

var dragging: bool = false        # True if currently being dragged
var drag_offset: Vector2 = Vector2.ZERO  # Offset between mouse and block origin while dragging
var workspace: Workspace          # Reference to the workspace
var children: Array[Block]
var target:Node

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
				var clone: Block = duplicate() as Block
				clone.is_template_block = false   # Clones are real blocks
				clone.target_path = target_path

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
		
func _get_property_list() -> Array:
	var properties = []
	
	if target_path != NodePath() and has_node(target_path):
		target = get_node(target_path)
		if target:
			var method_names = []
			var target_script = target.get_script()
			
			if target_script:
				# Get only methods defined in the script
				var script_methods = target_script.get_script_method_list()
				for method in script_methods:
					var name = method["name"]
					# Optional: exclude private methods
					if not name.begins_with("_"):
						method_names.append(name)
			
			# Fallback to all methods if no script (less ideal)
			else:
				for method in target.get_method_list():
					var name = method["name"]
					# Filter out common engine methods
					if not name.begins_with("_") and \
					   name != "get" and name != "set" and \
					   name != "notification" and name != "to_string":
						method_names.append(name)
			
			method_names.sort()
			
			if method_names.size() > 0:
				properties.append({
					"name": "action_type",
					"type": TYPE_STRING,
					"hint": PROPERTY_HINT_ENUM,
					"hint_string": ",".join(method_names)
				})
	
	return properties
	
func execute(delta:float) -> void:
	# Ensure target exists
	if target_path:
		target = get_node_or_null(target_path)
	if not target:
		print("Warning: target not found for action_type ", action_type)
		return

	# Ensure action_type is selected
	if action_type == "":
		print("Warning: action_type not selected")
		return

	# Call the method
	if target.has_method(action_type):
		target.call(action_type,delta)
	else:
		print("Warning: target does not have method ", action_type)
