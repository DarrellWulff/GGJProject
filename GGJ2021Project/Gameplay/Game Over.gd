extends CanvasLayer


func _on_PlayButton_pressed():
	get_tree().reload_current_scene()


func _on_ExitButton_pressed():
	get_tree().quit()
