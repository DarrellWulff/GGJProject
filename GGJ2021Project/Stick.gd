extends Area2D


func _on_Stick_body_entered(body):
	body.stick_collected()
	queue_free()
