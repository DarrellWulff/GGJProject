extends KinematicBody2D

const SPEED = 300;
const ACCELERATION = 1.0 / 4.0;
const DECELERATION = ACCELERATION * 1.5;

var movement : Movement2D = Movement2D.new(ACCELERATION, DECELERATION);
signal move;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func updateMovement(delta):
	var amountX : float = 0.0;
	if Input.is_action_pressed("INPUT_LEFT"):
		amountX += -1.0;
	if Input.is_action_pressed("INPUT_RIGHT"):
		amountX += 1.0;
	
	var amountY : float = 0.0;
	if Input.is_action_pressed("INPUT_UP"):
		amountY += -1.0;
	if Input.is_action_pressed("INPUT_DOWN"):
		amountY += 1.0;
	
	#self.movement.updateMovement(Vector2(amountX, amountY));
	
	move_and_collide(Vector2(amountX, amountY))
	
	var deltaSpeed = SPEED * delta;
	if Input.is_key_pressed(KEY_K):
		deltaSpeed *= 2;
	
	var velocity = deltaSpeed * self.movement.direction;
	
	if velocity.length() > 0:
		self.position += velocity;
		emit_signal("move");
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#updateMovement(delta);
	pass

func _physics_process(delta):
	updateMovement(delta)
