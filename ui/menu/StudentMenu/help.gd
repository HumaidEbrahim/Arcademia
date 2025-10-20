# res://ui/menu/Help/help_blocks.gd
extends Control

const MAIN_MENU_PATH := "res://ui/menu/StudentMenu/main_menu.tscn"

@onready var BtnBack: BaseButton = get_node_or_null("Background/BtnBack")
@onready var LblDisplay: Label   = get_node_or_null("Background/CardDisplay/LblDisplay")
@export var default_text := "Focus or hover a block to see what it does."

# Map: node path → help text
var help_texts := {
	# Movement
	"Background/CardMovement/MoveUp":    "Move your character one tile up.",
	"Background/CardMovement/MoveDown":  "Move your character one tile down.",
	"Background/CardMovement/MoveLeft":  "Move your character one tile left.",
	"Background/CardMovement/MoveRight": "Move your character one tile right.",

	# Loops
	"Background/CardLoops/Repeat":       "Repeat the blocks placed until EndRepeat.",
	"Background/CardLoops/EndRepeat":    "End of the Repeat loop.",

	# IF Statement
	"Background/CardIFStatement/IfPlant":   "Run the next blocks only if the pot has a plant.",
	"Background/CardIFStatement/IfEmpty":   "Run the next blocks only if the pot is empty.",
	"Background/CardIFStatement/IfCow":     "Run the next blocks only if the animal is a cow.",
	"Background/CardIFStatement/IfNotCow":  "Run the next blocks only if the animal is NOT a cow.",
	"Background/CardIFStatement/IfEnd":     "End of the IF statement.",

	# Actions
	"Background/CardAction/FeedChic":    "Feed the nearby chicken.",
	"Background/CardAction/OpenGate":    "Open the gate so animals can pass.",
	"Background/CardAction/CloseGate":   "Close the gate to keep animals in.",
	"Background/CardAction/WaterSprout": "Water a planted sprout.",
	"Background/CardAction/PlantSprout": "Plant a sprout in an empty pot.",
	"Background/CardAction/PickUp":      "Pick up a nearby item.",
	"Background/CardAction/Whistle":     "Whistle to attract nearby animals."
}

func _ready() -> void:
	# Back button
	if BtnBack:
		BtnBack.pressed.connect(_on_back_pressed)
	else:
		push_warning("Back button not found at Background/BtnBack")

	# Default text
	if LblDisplay:
		LblDisplay.text = default_text
	else:
		push_warning("Label not found at Background/CardDisplay/LblDisplay")

	# Wire all blocks listed above
	for path in help_texts.keys():
		var n := get_node_or_null(path)
		if n and n is Control:
			var c := n as Control
			c.focus_mode = Control.FOCUS_ALL
			c.mouse_entered.connect(func(): _show_help(path))
			c.mouse_exited.connect(_clear_help)
			c.focus_entered.connect(func(): _show_help(path))
			c.focus_exited.connect(_clear_help)
		else:
			push_warning("Block not found or not a Control: " + path)

func _show_help(path: String) -> void:
	if LblDisplay and help_texts.has(path):
		LblDisplay.text = help_texts[path]

func _clear_help() -> void:
	if LblDisplay:
		LblDisplay.text = default_text

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
