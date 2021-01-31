extends StaticBody2D

const DEFAULT_RADIUS = 1.5;

onready var light = get_node("Light");
var lightRadius : float;

func set_light_radius(lightRadius : float):
	self.lightRadius = lightRadius;
	self.light.set_texture_scale(self.lightRadius);
	pass;

func _ready():
	set_light_radius(self.DEFAULT_RADIUS);
	pass;

