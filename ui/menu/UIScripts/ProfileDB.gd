# res://ui/menu/UIScripts/ProfileDB.gd
extends Node

const SAVE_PATH: String      = "user://profiles.json"
const DEFAULT_PATH: String   = "res://ui/menu/UIScripts/default_profiles.json"

var students: Array = []    # keep generic for simplicity
var active_student: String = ""

func _ready() -> void:
	load_db()

func load_db() -> void:
	# 1) Try loading from user://
	#if FileAccess.file_exists(SAVE_PATH):
	#	var txt: String = FileAccess.get_file_as_string(SAVE_PATH)
	#	var data: Variant = JSON.parse_string(txt)
	#	if data is Dictionary:
	#		var dict: Dictionary = data
	#		students = dict.get("students", [])
	#		active_student = String(dict.get("active_student", ""))
	#		return

	# 2) If no save, load from default JSON in res://
	if FileAccess.file_exists(DEFAULT_PATH):
		var txt2: String = FileAccess.get_file_as_string(DEFAULT_PATH)
		var data2: Variant = JSON.parse_string(txt2)
		if data2 is Dictionary:
			_load_from_dict(data2)
			_migrate_fill_missing_avatar()
			save_db()
			return
	# 3) Nothing found -> empty list
	students = []
	active_student = ""
	save_db()
	
func _load_from_dict(dict: Dictionary) -> void:
	students = dict.get("students", [])
	active_student = String(dict.get("active_student", ""))
	
# If some students don't have "avatar", default them to 0 (boy)
func _migrate_fill_missing_avatar() -> void:
	for s in students:
		if not s.has("avatar"):
			s["avatar"] = 0
	
func save_db() -> void:
	var data: Dictionary = {
		"students": students,
		"active_student": active_student
	}
	var f := FileAccess.open(DEFAULT_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	f.close()

func add_student(student_name: String, character: int, ) -> void:
	if(!exists(student_name)):
		students.append({
			"name": student_name,
			"avatar": character,
			"created_at": Time.get_unix_time_from_system(),
			"updated_at": ""
		})
	else:
		print("IT EXISTS YOU TWINKY WINKY")
		save_db()
	
func update_student(student_name: String, new_name: String = "", new_avatar: int = -1) -> bool:
	for s in students:
		if s.get("name", "") == student_name:
			if new_name != "":
				s["name"] = new_name
			if new_avatar != -1:
				s["avatar"] = new_avatar
			s["updated_at"] = Time.get_unix_time_from_system()
			save_db()
			return true
	return false  # not found
	
func delete_student(student_name: String) -> bool:
	for i in range(students.size()):
		if students[i].get("name", "") == student_name:
			students.remove_at(i)
			
			if active_student == student_name:
				active_student = ""  # or pick another student if needed
			
			save_db()
			return true  # success
	return false  # not found

func exists(student_name: String) -> bool:
	for s in students:
		if String(s.get("name", "")) == student_name:
			return true
	return false

func set_active(student_name: String) -> void:
	active_student = student_name
	save_db()

func sorted_students() -> Array:
	var arr: Array = students.duplicate()
	arr.sort_custom(func(a, b) -> bool:
		return String(a.get("name", "")).nocasecmp_to(String(b.get("name", ""))) < 0
	)
	return arr
