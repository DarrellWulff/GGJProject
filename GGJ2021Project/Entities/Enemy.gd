extends KinematicBody2D

const SPEED : float = 200.0;
const SIGHT_DISTANCE : int = 200;

signal closestCampfire(position);

func updateMovement(delta):
	var closestCampire = emit_signal("closestCampfire", self.position);
	var direction : Vector2;
	
	if closestCampire:
		direction = closestCampire.position - self.position;
	else:
		direction = Vector2(0.0, 0.0);
		
	var velocity : Vector2 = self.SPEED * delta * direction;
	
	if velocity.length() > 0:
		var collision = move_and_collide(velocity);
		if collision:
			velocity.slide(collision.normal);
			self.position += velocity;
	
	pass;

func _physics_process(delta):
	updateMovement(delta);
	pass;
