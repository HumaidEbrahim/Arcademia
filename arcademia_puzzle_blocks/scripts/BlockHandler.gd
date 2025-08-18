extends Node
class_name Blockhandler

@onready var workspace: Workspace = $WorkspaceArea
@onready var character: Character = $Character
@onready var run_button: Button = $RunButton
@onready var clear_button: Button = $ClearButton

var move_queue: Array[Control] = []   # List of blocks
var executing: bool = false          # Whether the sequence is currently running
var current_index: int = 0           # Current block being executed
var action_timer: float = 0.0 

func _ready() -> void:
	# Connect UI buttons
	run_button.pressed.connect(run_sequence)
	clear_button.pressed.connect(clear_workspace)

# --- Start execution of block sequence ---
func run_sequence() -> void:
	if executing:
		return
	executing = true
	move_queue = workspace.get_sequence()  # Build sequence from blocks (left-to-right order)
	current_index = 0
	action_timer = 0.0   # reset timer
	set_process(true)

func _process(delta: float) -> void:
	if not executing:
		return

	# Sequence finished
	if current_index >= move_queue.size():
		executing = false
		set_process(false)
		return

	# Execute current action
	var currentBlock = move_queue[current_index]
	var target = currentBlock.get_node_or_null(currentBlock.target_path)

	if not target:
		print("Warning: target not found for block ", currentBlock.block_type)
		current_index += 1
		return
	
	#match currentBlock.block_type:
		#"repeat":
			#for i in 5:
				#print("hello")
		#"conditional":
			#if true:
				#print("hello")
				#
		#_:

	currentBlock.execute(delta)

	# Timer logic: hold each action for 0.5 seconds
	action_timer += delta
	if action_timer >= currentBlock.duration:
		action_timer = 0.0
		current_index += 1

# --- Reset workspace and stop execution ---
func clear_workspace() -> void:
	workspace.clear_workspace()
	executing = false
	current_index = 0
	set_process(false)
