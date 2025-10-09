extends Control

const TEACHER_PATH := "res://ui/menu/TeacherLogin/teacher_login.tscn"
const STUDENT_PATH := "res://ui/menu/StudentScreens/student_selection.tscn"

@onready var btn_left: Button = $Background/Teacher
@onready var btn_right: Button = $Background/Student

var selected_index: int = 0
var buttons: Array
var track = load("res://music/MagwenyaFields.mp3")


func _ready():
	# Navigate through Background first
	$Background/Teacher.connect("pressed", Callable(self, "_on_teacher_pressed"))
	$Background/Student.connect("pressed", Callable(self, "_on_student_pressed"))
	btn_left.grab_focus()
	
	MusicPlayer.play_stream(track, 2.0)

func _on_teacher_pressed():
	get_tree().change_scene_to_file(TEACHER_PATH)

func _on_student_pressed():
	get_tree().change_scene_to_file(STUDENT_PATH)
