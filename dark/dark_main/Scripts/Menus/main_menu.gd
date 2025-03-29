extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://dark_main/Scenes/levels/001_opening_scene.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
