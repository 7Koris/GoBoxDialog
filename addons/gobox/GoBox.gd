@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("DialogBox", "CenterContainer", preload("DialogBox.gd"), preload("res://addons/gobox/textures/pointer.png"))

func _exit_tree():
	remove_custom_type("DialogBox")
