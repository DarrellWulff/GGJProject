extends StaticBody2D

const DEFAULT_RADIUS = 1.5;

onready var light = get_node("Light");

func set_light_radius(lightRadius : float):
	self.light.set_texture_scale(lightRadius);
	pass;

func _ready():
	set_light_radius(self.DEFAULT_RADIUS);
	pass # Replace with function body.

