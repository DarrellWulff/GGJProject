extends KinematicBody2D

const INPUT_STARTUP = 4;
var input : Input2D = Input2D.new(INPUT_STARTUP);

const SPEED = 300;
const ACCELERATION = 1.0 / 4.0;
const DECELERATION = ACCELERATION * 1.5;
var movement : Movement2D = Movement2D.new(ACCELERATION, DECELERATION);

signal move;

func updateMovement(delta):
	var amountX : float = 0.0;
	if Input.is_key_pressed(KEY_A):
		amountX += -1.0;
	if Input.is_key_pressed(KEY_D):
		amountX += 1.0;
	
	var amountY : float = 0.0;
	if Input.is_key_pressed(KEY_W):
		amountY += -1.0;
	if Input.is_key_pressed(KEY_S):
		amountY += 1.0;
		
	self.input.updateInput(Vector2(amountX, amountY));
	
	#self.movement.updateMovement(self.input.currentInput);
	
	#Moves kinematicbody, but you probably want to calculate 
	#the slide vector since it will hit a collider and slow down with out it.
	#Vector3 class has a method for getting the slide vector!
	move_and_collide(self.input.currentInput)
	
	var deltaSpeed = SPEED * delta;
	if Input.is_key_pressed(KEY_K):
		deltaSpeed *= 2;
	
	var velocity = deltaSpeed * self.movement.direction;
	
	if velocity.length() > 0:
		self.position += velocity;
		emit_signal("move");
	
	pass

# Updates outside of pyhsics step so for faster computers the game goes faster!
func _process(delta):
	#updateMovement(delta);
	pass

#I would use this update function whenever you're doing gameplay code!
func _physics_process(delta):
	updateMovement(delta);
