extends Area2D

func _on_Tar_body_entered(body):
	if body.IS_PLAYER:
		body.tar_collected();
		queue_free();
