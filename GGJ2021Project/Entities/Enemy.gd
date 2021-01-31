extends KinematicBody2D

const IS_PLAYER = false;

const SPEED : float = 200.0;
const SIGHT_DISTANCE : int = 400;

func updateMovement(delta, player, closestCampfire):
	var direction : Vector2 = player.position - self.position;
	
	if closestCampfire:
		direction = closestCampfire.position - self.position;
		if direction.length() >= self.SIGHT_DISTANCE:
			direction = player.position - self.position;
	else:
		direction = player.position - self.position;
	
	var velocity : Vector2 = self.SPEED * delta * direction.normalized();
	
	if velocity.length() > 0:
		var collision = move_and_collide(velocity);
		if collision:
			if collision.collider.has_method("hit"):
				collision.collider.hit();
			velocity.slide(collision.normal);
			self.position += velocity;
	
	pass;

