extends KinematicBody2D

const INPUT_STARTUP = 4;
var input : Input2D = Input2D.new(INPUT_STARTUP);

const SPEED = 300;
const ACCELERATION = 1.0 / 4.0;
const DECELERATION = ACCELERATION * 1.5;
var movement : Movement2D = Movement2D.new(ACCELERATION, DECELERATION);

const MIN_LIGHT_RADIUS : float = 0.5;
const LIGHT_DECREMENT_AMOUNT : float = 1.0 / 64.0;
const WAIT_TIME : float = 1.0 / 16.0;
onready var vision = get_node("Vision");
onready var outerVision = get_node("outerVision");
onready var timer = get_node("decreaseVision");

var visionRadius : float = 5.0;
var outerVisionRadius : float = visionRadius * 1.2;
var lastVisionUpdate : float = visionRadius;

var alive : bool = true;
var gameOverObject = null;

signal move;

func gameOver():
	if self.alive:
		set_vision_radius(0.0);
		self.lastVisionUpdate = 0.0;
		var gameOver = load("res://Gameplay//Game Over.tscn");
		self.gameOverObject = gameOver.instance();
		add_child(self.gameOverObject);
		self.alive = false;
	pass;

func set_vision_radius(visionRadius : float):
	self.visionRadius = visionRadius;
	vision.set_texture_scale(self.visionRadius);
	self.outerVisionRadius = visionRadius * 1.2;
	outerVision.set_texture_scale(self.outerVisionRadius);
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
	
	var velocity = self.SPEED * delta * self.movement.direction;
	
	if velocity.length() > 0:
		var collision = move_and_collide(velocity);
		if collision:
			velocity.slide(collision.normal);
			self.position += velocity;
		emit_signal("move");
	
	pass;

func leaf_collected():
	if self.visionRadius >= MIN_LIGHT_RADIUS:
		self.visionRadius *= 1.4;
		self.lastVisionUpdate = self.visionRadius;
		set_vision_radius(self.visionRadius);
	pass;

func stick_collected():
	if (self.lastVisionUpdate >= self.visionRadius) and (self.visionRadius > MIN_LIGHT_RADIUS):
		self.visionRadius = self.lastVisionUpdate
		set_vision_radius(self.visionRadius);
	pass;
	
func tar_collected():
	if	(self.timer.get_time_left() < 2.0):
		self.timer.set_wait_time( self.timer.get_time_left() + 0.4 );
		self.timer.start();
	pass;

func _on_decreaseVision_timeout():
	if	self.visionRadius >= self.MIN_LIGHT_RADIUS:
		self.visionRadius -= self.LIGHT_DECREMENT_AMOUNT;
		set_vision_radius(self.visionRadius);
	else:
		gameOver();
		
	if	self.timer.get_time_left() > 2.0:
		self.timer.set_wait_time(1.0 / 16.0);
	pass;

func _physics_process(delta):
	if self.alive:
		updateMovement(delta);
	pass;

func _process(delta):
	if !self.alive:
		if Input.is_key_pressed(KEY_ENTER):
			get_tree().reload_current_scene();
	pass;
