extends Node

class_name Rotation2D

var acceleration : float;
var direction : Vector2;

func _init(updateFrames : int):
	self.acceleration = 1.0 / updateFrames;
	self.direction.x = 0.0;
	self.direction.y = 0.0;
	pass

func updateRotation(movement : Vector2):
	
	if movement.x == 1:
		if self.direction.x < 0.0:
			self.direction.x = 0.0;
		if self.direction.x < 1.0:
			self.direction.x += acceleration;
			if self.direction.x > 1.0:
				self.direction.x = 1.0;
	elif movement.x == 0:
		if self.direction.x > 0.0:
			self.direction.x -= acceleration;
			
	# TODO complete
	
	pass

