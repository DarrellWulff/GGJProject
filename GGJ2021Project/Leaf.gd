extends Area2D


func _on_Leaf_body_entered(body):
	body.leaf_collected()
	queue_free()
