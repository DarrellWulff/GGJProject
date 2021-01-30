extends Node

onready var screenSize = get_viewport().size;

func _ready():
	var canvasTransform = get_viewport().get_canvas_transform();
	canvasTransform[2] = -get_node("Player").position + screenSize / 2;
	get_viewport().set_canvas_transform(canvasTransform);

func updateCamera():
	print("worked");
	pass
