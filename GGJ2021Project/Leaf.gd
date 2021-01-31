extends Area2D


func _on_Leaf_body_entered(body):
	if body.IS_PLAYER:
		body.leaf_collected()
	queue_free()
