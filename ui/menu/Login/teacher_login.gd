# res://ui/menu/Login/teacher_login.gd
extends Control

const USER_SELECTION_PATH := "res://ui/menu/Selection/user_selection.tscn"
const PROFILE_MANAGEMENT_PATH := "res://ui/menu/ProfileManagement/profile_management.tscn"

@onready var btn_back: BaseButton  = $Background/HeaderPanel2/BtnBack
@onready var btn_enter: BaseButton = $Background/HeaderPanel2/BtnEnter

func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	btn_enter.pressed.connect(_on_enter_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(USER_SELECTION_PATH)

func _on_enter_pressed() -> void:
	get_tree().change_scene_to_file(PROFILE_MANAGEMENT_PATH)
