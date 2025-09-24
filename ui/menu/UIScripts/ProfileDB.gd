# res://ui/menu/UIScripts/ProfileDB.gd
extends Node

const SAVE_PATH: String      = "user://profiles.json"
const DEFAULT_PATH: String   = "res://ui/menu/UIScripts/default_profiles.json"
const DEFAULT_AVATAR: String = "res://art/avatars/default.png"  # optional

var students: Array = []    # keep generic for simplicity
var active_student: String = ""

func _ready() -> void:
	load_db()

func load_db() -> void:
	# 1) Try loading from user://
	if FileAccess.file_exists(SAVE_PATH):
		var txt: String = FileAccess.get_file_as_string(SAVE_PATH)
		var data: Variant = JSON.parse_string(txt)
		if data is Dictionary:
			var dict: Dictionary = data
			students = dict.get("students", [])
			active_student = String(dict.get("active_student", ""))
			return

	# 2) If no save, load from default JSON in res://
	if FileAccess.file_exists(DEFAULT_PATH):
		var txt2: String = FileAccess.get_file_as_string(DEFAULT_PATH)
		var data2: Variant = JSON.parse_string(txt2)
		if data2 is Dictionary:
			var dict2: Dictionary = data2
			students = dict2.get("students", [])
			active_student = String(dict2.get("active_student", ""))
			# save a copy to user:// so it persists
			save_db()
			return

	# 3) Nothing found -> empty list
	students = []
	active_student = ""
	save_db()

func save_db() -> void:
	var data: Dictionary = {
		"students": students,
		"active_student": active_student
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	f.close()

func add_student(name: String, avatar_path: String = DEFAULT_AVATAR) -> void:
	students.append({
		"name": name,
		"avatar": avatar_path,
		"created_at": Time.get_unix_time_from_system()
	})
	save_db()

func exists(name: String) -> bool:
	for s in students:
		if String(s.get("name", "")) == name:
			return true
	return false

func set_active(name: String) -> void:
	active_student = name
	save_db()

func sorted_students() -> Array:
	var arr: Array = students.duplicate()
	arr.sort_custom(func(a, b) -> bool:
		return String(a.get("name", "")).nocasecmp_to(String(b.get("name", ""))) < 0
	)
	return arr
