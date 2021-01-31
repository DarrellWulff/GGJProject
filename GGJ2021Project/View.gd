extends Node

const WAIT_TIME : float =  1.0 / 16.0;

onready var screenSize = get_viewport().size;
onready var updateRadius = screenSize.x / 2.0;
onready var player = get_node("Player");

var lastPosition : Vector2;

signal updateWorldSignal(position);

func _ready():
	self.player.position = Vector2(0.0, 0.0);
	lastPosition = self.player.position;
	var canvasTransform = get_viewport().get_canvas_transform();
	canvasTransform[2] = (self.screenSize / 2) - self.lastPosition;
	get_viewport().set_canvas_transform(canvasTransform);
	
	var timer = self.player.get_node("decreaseVision");
	timer.set_wait_time(self.WAIT_TIME);
	self.player.set_vision_radius(5.0);
	timer.start();
	
	pass

func updateCamera():
	var playerOffset = self.lastPosition - self.player.position;
	
	var canvasTransform = get_viewport().get_canvas_transform();
	canvasTransform[2] += playerOffset;
	get_viewport().set_canvas_transform(canvasTransform);
	
	self.lastPosition = self.player.position;
	pass

func _process(delta):
<<<<<<< HEAD
	emit_signal("updateWorldSignal", player.position);
=======
	emit_signal("updateWorldSignal", self.player.position);
>>>>>>> c912190a53c45af5e205664b6330a7244350ac1d
	pass

