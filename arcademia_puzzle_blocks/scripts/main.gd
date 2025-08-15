extends Node
class_name Main

@onready var workspace: Workspace = $WorkspaceArea
@onready var character: Character = $Character
@onready var run_button: Button = $RunButton
@onready var clear_button: Button = $ClearButton

var move_queue: Array[String] = []   # List of block actions (e.g., ["move_left", "move_right"])
var executing: bool = false          # Whether the sequence is currently running
var current_index: int = 0           # Current block being executed

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
	var action = move_queue[current_index]
	match action:
		"move_left":
			character.move_left(delta)
		"move_right":
			character.move_right(delta)

	# Timer logic: hold each action for 0.5 seconds
	if !has_meta("timer"):
		set_meta("timer", 0.0)
	var timer = get_meta("timer")
	timer += delta
	if timer >= 0.5:
		timer = 0.0
		current_index += 1
	set_meta("timer", timer)

# --- Reset workspace and stop execution ---
func clear_workspace() -> void:
	workspace.clear_workspace()
	executing = false
	current_index = 0
	set_process(false)
