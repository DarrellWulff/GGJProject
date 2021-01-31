extends Area2D


func _on_Stick_body_entered(body):
	if body.IS_PLAYER:
		body.stick_collected()
	queue_free()
