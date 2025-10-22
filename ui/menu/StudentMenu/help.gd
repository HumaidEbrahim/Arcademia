# res://ui/menu/Help/help_blocks.gd
extends Control

const MAIN_MENU_PATH := "res://ui/menu/StudentMenu/main_menu.tscn"

@onready var BtnBack: BaseButton = get_node_or_null("Background/BtnBack")
@onready var LblDisplay: Label   = get_node_or_null("Background/CardDisplay/LblDisplay")
@export var default_text := "Focus or hover a block to see what it does."

# Pop settings
const POP_SCALE := 1.15
const POP_TIME  := 0.08

# Typed caches
var _base_scales: Dictionary[NodePath, Vector2] = {}
var _tweens: Dictionary[NodePath, Tween] = {}

# Map: node path → help text
var help_texts: Dictionary[String, String] = {
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
	if BtnBack:
		BtnBack.pressed.connect(_on_back_pressed)
		BtnBack.grab_focus()
	if LblDisplay:
		LblDisplay.text = default_text

	# Wire all focusable blocks
	for path in help_texts.keys():
		var n: Node = get_node_or_null(path)
		if n != null and n is Control:
			var c: Control = n as Control
			c.focus_mode = Control.FOCUS_ALL
			_center_pivot(c)
			c.resized.connect(func(): _center_pivot(c)) # keep pivot centered if resized

			# Input events
			c.mouse_entered.connect(func(): _on_focus_enter(c, path))
			c.mouse_exited.connect(func(): _on_focus_exit(c))
			c.focus_entered.connect(func(): _on_focus_enter(c, path))
			c.focus_exited.connect(func(): _on_focus_exit(c))
		else:
			push_warning("Block not found or not a Control: " + path)

func _on_focus_enter(node: Control, path: String) -> void:
	_show_help(path)
	_pop_in(node)

func _on_focus_exit(node: Control) -> void:
	_clear_help()
	_pop_out(node)

func _show_help(path: String) -> void:
	if LblDisplay and help_texts.has(path):
		LblDisplay.text = help_texts[path]

func _clear_help() -> void:
	if LblDisplay:
		LblDisplay.text = default_text

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

# -----------------------
# Pop effect (scale only)
# -----------------------

func _pop_in(node: Control) -> void:
	if not (node is TextureRect):
		return
	var trs: TextureRect = node as TextureRect
	var key: NodePath = trs.get_path()

	# Record base scale once
	if not _base_scales.has(key):
		_base_scales[key] = trs.scale

	_kill_tween(key)
	var tw: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(trs, "scale", _base_scales[key] * POP_SCALE, POP_TIME)
	_tweens[key] = tw

func _pop_out(node: Control) -> void:
	if not (node is TextureRect):
		return
	var trs: TextureRect = node as TextureRect
	var key: NodePath = trs.get_path()
	var base: Vector2 = _base_scales.get(key, trs.scale)

	_kill_tween(key)
	var tw: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(trs, "scale", base, POP_TIME)
	_tweens[key] = tw

func _kill_tween(key: NodePath) -> void:
	if _tweens.has(key):
		var t: Tween = _tweens[key]
		if is_instance_valid(t):
			t.kill()
		_tweens.erase(key)

func _center_pivot(c: Control) -> void:
	# Scale from center so the pop is symmetrical.
	c.pivot_offset = c.size * 0.5
