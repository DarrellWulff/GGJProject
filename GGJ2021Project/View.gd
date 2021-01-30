extends Node

onready var screenSize = get_viewport().size;
onready var updateRadius = screenSize.x / 2.0;
onready var player = get_node("Player");
onready var lastPosition : Vector2 = player.position;

func _ready():
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
