extends Area2D


func _on_Tar_body_entered(body):
	body.tar_collected()
	queue_free()
