extends Control


var gameLevel = load("res://World.tscn")



func _on_PlayButton_pressed():
	get_tree().change_scene("res://World.tscn")
