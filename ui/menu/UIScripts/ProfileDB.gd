# res://ui/menu/UIScripts/ProfileDB.gd
extends Node

const PATH := "user://students.json"
const DEFAULT_AVATAR := "res://assets/IngeUI/Student.png"

var students: Array = []            # [{name, avatar, created_at}]
var active_student: String = ""

func _ready() -> void:
	load_db()

func load_db() -> void:
	if FileAccess.file_exists(PATH):
		var txt: String = FileAccess.get_file_as_string(PATH)
		var data: Variant = JSON.parse_string(txt)  # <- typed

		if data is Dictionary:
			var dict := data as Dictionary
			students = (dict.get("students", []) as Array)
			active_student = str(dict.get("active_student", ""))
			return

	# first run (file doesn’t exist or is broken) → start fresh
	students = []
	active_student = ""
	save_db()


func save_db() -> void:
	var data := {"students": students, "active_student": active_student}
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	f.close()

func add_student(name: String, avatar_path: String = DEFAULT_AVATAR) -> void:
	students.append({
		"name": name,
		"avatar": avatar_path,
		"created_at": Time.get_unix_time_from_system()
	})
	save_db()

func set_active(name: String) -> void:
	active_student = name
	save_db()

func exists(name: String) -> bool:
	for s in students:
		if s.get("name","") == name:
			return true
	return false

func sorted_students() -> Array:
	var arr := students.duplicate()
	arr.sort_custom(func(a, b): return a["name"].nocasecmp_to(b["name"]) < 0)
	return arr
