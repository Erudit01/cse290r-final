extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://dark_main/Scenes/levels/dev-testing-room.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
