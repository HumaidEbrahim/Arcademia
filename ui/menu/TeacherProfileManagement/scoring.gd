# res://ui/menu/TeacherProfileManagement/scoring.gd
extends Control

const UPDATE_PATH := "res://ui/menu/TeacherProfileManagement/update.tscn"

# ---------- Nodes (exact paths) ----------

# Back button (now under Background)
var BtnBack        : BaseButton

# Totals (right card)
var LblTotalStars  : Label
var LblTotalTime   : Label

# Levels (left card) — NOTE: NOT under Background
var LblStudentName : Label
var LblRiverStar   : Label
var LblRiverTime   : Label
var LblTractorStar : Label
var LblTractorTime : Label
var LblBarnStar    : Label
var LblBarnTime    : Label
var LblCowStar     : Label
var LblCowTime     : Label
var LblFlowerStar  : Label
var LblFlowerTime  : Label


func _ready() -> void:
	# --- Resolve nodes using your current tree ---
	BtnBack        = get_node_or_null("Background/BtnBack")
	BtnBack.grab_focus();
	if BtnBack == null:
		BtnBack = get_node_or_null("Background/HeaderPanel/BtnBack")

	LblTotalStars  = get_node_or_null("Background/Card/LblTotalStars/DisTotalStars")
	LblTotalTime   = get_node_or_null("Background/Card/LblTotalTime/DisTotalTime")

	# LEFT PANEL (directly under CardLevel)
	LblStudentName = get_node_or_null("CardLevel/DisStudentName")

	LblRiverStar   = get_node_or_null("CardLevel/LblRiver/DisRiverStar")
	LblRiverTime   = get_node_or_null("CardLevel/LblRiver/DisRiverTime")

	LblTractorStar = get_node_or_null("CardLevel/LblTractor/DisTractorStar")
	LblTractorTime = get_node_or_null("CardLevel/LblTractor/DisTractorTime")

	LblBarnStar    = get_node_or_null("CardLevel/LblBarn/DisBarnStar")
	LblBarnTime    = get_node_or_null("CardLevel/LblBarn/DisBarnTime")

	LblCowStar     = get_node_or_null("CardLevel/LblCow/DisCowStar")
	LblCowTime     = get_node_or_null("CardLevel/LblCow/DisCowTime")

	LblFlowerStar  = get_node_or_null("CardLevel/LblFlower/DisFlowerStar")
	LblFlowerTime  = get_node_or_null("CardLevel/LblFlower/DisFlowerTime")

	# --- Back wiring ---
	if BtnBack:
		BtnBack.pressed.connect(_on_back_pressed)
	else:
		push_warning("Back button not found at Background/BtnBack (or Background/HeaderPanel/BtnBack).")

	# --- Which student to show? ---
	var student_name := Global.PersonToEdit
	if student_name == "" and Global.ActiveStudent != "":
		student_name = Global.ActiveStudent

	# Show name
	if LblStudentName:
		if student_name != "":
			LblStudentName.text = student_name
		else:
			LblStudentName.text = "N/A"

	# Fill scores
	_populate_scoring(student_name)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(UPDATE_PATH)


# ---------------- DATA → UI ----------------
func _populate_scoring(student_name: String) -> void:
	var student := _find_student(student_name)
	if student.is_empty():
		_set_all_to_na()
		return

	var progress: Dictionary = student.get("progress", {})
	var levels: Dictionary = {}
	if progress.has("levels"):
		levels = progress["levels"]

	# Totals (right card)
	if LblTotalStars:
		LblTotalStars.text = str(int(progress.get("total_stars", 0)))
	if LblTotalTime:
		LblTotalTime.text = _fmt_time(float(progress.get("total_time", 0.0)))

	# Per-level (left card)
	_set_level_row(levels, "FarmRiverLevel",   LblRiverStar,   LblRiverTime)
	_set_level_row(levels, "FarmTractor", LblTractorStar, LblTractorTime)
	_set_level_row(levels, "BarnLevel",    LblBarnStar,    LblBarnTime)
	_set_level_row(levels, "CowLevel",     LblCowStar,     LblCowTime)
	_set_level_row(levels, "GardenLevel",  LblFlowerStar,  LblFlowerTime) # Flower row


func _find_student(student_name_param: String) -> Dictionary:
	if student_name_param == "":
		return {}
	for s in ProfileDB.students:
		if String(s.get("name", "")) == student_name_param:
			return s
	return {}


func _set_level_row(levels: Dictionary, level_id: String, star_lbl: Label, time_lbl: Label) -> void:
	if not levels.has(level_id):
		if star_lbl: star_lbl.text = "N/A"
		if time_lbl: time_lbl.text = "N/A"
		return

	var row: Dictionary = levels[level_id]
	if star_lbl:
		star_lbl.text = str(int(row.get("stars", 0)))
	if time_lbl:
		time_lbl.text = _fmt_time(float(row.get("time_taken", 0.0)))


func _set_all_to_na() -> void:
	for lbl in [
		LblStudentName,
		LblTotalStars, LblTotalTime,
		LblRiverStar, LblRiverTime,
		LblTractorStar, LblTractorTime,
		LblBarnStar, LblBarnTime,
		LblCowStar, LblCowTime,
		LblFlowerStar, LblFlowerTime
	]:
		if lbl:
			lbl.text = "N/A"


# seconds(float) -> "mm:ss"
func _fmt_time(seconds_f: float) -> String:
	var secs := int(round(seconds_f))
	var m := int(secs / 60.0)
	var s := secs % 60
	return "%02d:%02d" % [m, s]
