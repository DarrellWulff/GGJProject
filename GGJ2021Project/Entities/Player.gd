extends KinematicBody2D

const INPUT_STARTUP = 4;
var input : Input2D = Input2D.new(INPUT_STARTUP);

const SPEED = 300;
const ACCELERATION = 1.0 / 4.0;
const DECELERATION = ACCELERATION * 1.5;
var movement : Movement2D = Movement2D.new(ACCELERATION, DECELERATION);

onready var vision = get_node("Vision");
onready var timer = get_node("decreaseVision");

var visionRadius : float = 5.0;
var lastVisionUpdate : float = visionRadius;

signal move;
	
func set_vision_radius(visionRadiusAmount : float):
	self.visionRadius = visionRadiusAmount;
	vision.set_texture_scale(self.visionRadius);
	pass;

func updateMovement(delta):
	var amountX : float = 0.0;
	if Input.is_action_pressed("Input_Left"):
		amountX += -1.0;
	if Input.is_action_pressed("Input_Right"):
		amountX += 1.0;
	
	var amountY : float = 0.0;
	if Input.is_action_pressed("Input_Up"):
		amountY += -1.0;
	if Input.is_action_pressed("Input_Down"):
		amountY += 1.0;
		
	self.input.updateInput(Vector2(amountX, amountY));
	
	self.movement.updateMovement(self.input.currentInput);
	
	var deltaSpeed = SPEED * delta;
	if Input.is_action_pressed("Input_Run"):
		deltaSpeed *= 2;
	
	var velocity = deltaSpeed * self.movement.direction;
	
	if velocity.length() > 0:
		var collision = move_and_collide(velocity);
		if collision:
			velocity.slide(collision.normal);
			self.position += velocity;
		emit_signal("move");
	
	pass

func _physics_process(delta):
	updateMovement(delta);
	pass

func leaf_collected():
	if visionRadius >= 12.0:
		visionRadius *= 2.0;
		lastVisionUpdate = visionRadius;
		set_vision_radius(visionRadius);
	pass

func stick_collected():
	if lastVisionUpdate <= 20:
		lastVisionUpdate = 20;
	
	if visionRadius >= 12 and visionRadius < 20:
		visionRadius = lastVisionUpdate;
		set_vision_radius(visionRadius);
	pass
	
func tar_collected():
	if	(timer.get_time_left() < 10.0):
		timer.set_wait_time( 10.0 )
	pass

func _on_decreaseVision_timeout():
	if	visionRadius >= 1.0:
		visionRadius -= 1.0 / 64.0;
		set_vision_radius(visionRadius);
	else:
		visionRadius = 1.0;
		lastVisionUpdate = 1.0;
	pass

