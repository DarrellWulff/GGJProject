extends Node

onready var screenSize = get_viewport().size;
onready var updateRadius = screenSize.x / 2.0;
onready var player = get_node("Player");

var lastPosition : Vector2;

signal updateWorldSignal(position);

func _ready():
	player.position = Vector2(0.0, 0.0);
	lastPosition = player.position;
	var canvasTransform = get_viewport().get_canvas_transform();
	canvasTransform[2] = (screenSize / 2) - lastPosition;
	get_viewport().set_canvas_transform(canvasTransform);
	pass

func updateCamera():
	var playerOffset = lastPosition - player.position;
	
	var canvasTransform = get_viewport().get_canvas_transform();
	canvasTransform[2] += playerOffset;
	get_viewport().set_canvas_transform(canvasTransform);
	
	lastPosition = player.position;
	pass

func _physics_process(delta):
	emit_signal("updateWorldSignal", player.position);
	pass
