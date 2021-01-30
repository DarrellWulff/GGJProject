extends Node

class_name Movement2D

var acceleration : float;
var deceleration : float;
var direction : Vector2;

func _init(accelerationAmount : float, decelerationAmount : float):
	self.acceleration = accelerationAmount;
	self.deceleration = decelerationAmount;
	self.direction.x = 0.0;
	self.direction.y = 0.0;
	pass

func updateMovement(movement : Vector2):
	var updateAmount : float;
	
	if self.direction.length() == 0:
		if movement.length() != 0:
			movement = movement.normalized();
		updateAmount = acceleration;
	elif movement.length() == 0:
		updateAmount = deceleration;
	else:
		movement = movement.normalized();
		updateAmount = (self.direction.dot(movement) + 1.0) / 2.0;
		updateAmount = updateAmount * acceleration + (1.0 - updateAmount) * deceleration;
	
	var updateDirection : Vector2 = movement - self.direction;
	
	if updateDirection.length() <= updateAmount:
		self.direction = movement;
	else:
		self.direction += updateAmount * updateDirection;
		
	if self.direction.length() > 1.0:
		self.direction = self.direction.normalized();
	pass

