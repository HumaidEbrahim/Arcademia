extends Control

const TEACHER_PATH := "res://ui/menu/Login/teacher_login.tscn"
const STUDENT_PATH := "res://ui/menu/Selection/student_selection.tscn"

func _ready():
	# Navigate through Background first
	$Background/Teacher.connect("pressed", Callable(self, "_on_teacher_pressed"))
	$Background/Student.connect("pressed", Callable(self, "_on_student_pressed"))

func _on_teacher_pressed():
	get_tree().change_scene_to_file(TEACHER_PATH)

func _on_student_pressed():
	get_tree().change_scene_to_file(STUDENT_PATH)
