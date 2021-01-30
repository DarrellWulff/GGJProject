extends Node2D

onready var screenSize = get_viewport().size;
onready var boxSize : int = screenSize.x;
onready var halfBoxSize : int = boxSize / 2;

var visitedBoxes = {};
var seedVal : int;

func _ready():
	var seedString : String = "Hello World!";
	if seedString:
		self.seedVal = seedString.hash();
	else:
		randomize();
		self.seedVal = randi();
	pass;

func getLayer(axis : int) -> int:
	if axis > 0:
		axis -= self.halfBoxSize;
		if axis < 0:
			return 0;
		else:
			return (axis / self.boxSize) + 1;
	else:
		axis += self.halfBoxSize;
		if axis > 0:
			return 0;
		else:
			return (axis / self.boxSize) - 1;
	pass;

func getCorner1(absLayer : int):
	var value = 2 * absLayer;
	return value * (value - 1);

func getCorner2(absLayer : int):
	var value = 2 * absLayer;
	return value * value;

func getCorner3(absLayer : int):
	var value = 2 * absLayer;
	return value * (value + 1);

func getCorner4(absLayer : int):
	return 4 * absLayer * (absLayer + 1);

func getBoxNum(layerX : int, layerY : int):
	var absX = abs(layerX);
	var absY = abs(layerY);
	
	if absX == absY:
		if layerX > 0:
			if layerY > 0:
				return getCorner2(absX);
			else:
				return getCorner1(absX);
		else:
			if layerY > 0:
				return getCorner3(absX);
			else:
				return getCorner4(absX);
	elif absX > absY:
		if layerX > 0:
			return getCorner1(absX) + absX + layerY;
		else:
			return getCorner3(absX) + absX - layerY;
	else:
		if layerY > 0:
			return getCorner2(absY) + absY - layerX;
		else:
			return getCorner4(absY - 1) + absY + layerX;
	
	pass;

func getRandomPosition(positionMin : Vector2, positionMax : Vector2) -> Vector2:
	var randProportion : Vector2 = Vector2(randf(), randf());
	var invProportion : Vector2 = Vector2(1.0, 1.0) - randProportion;
	
	return Vector2(randProportion.x * positionMin.x + invProportion.x * positionMax.x,
		randProportion.y * positionMin.y + invProportion.y * positionMax.y);

func getRandomObject():
	var value = randf();
	
	if value < 0.25:
		return null;
	else:
		return load("res://Objects//Boulder.tscn");
	
	pass;

func generateRandomObjects(positionMin : Vector2, positionMax : Vector2):
	
	var randObject = getRandomObject();
	
	while randObject:
		var object = randObject.instance();
		add_child(object);
		var position : Vector2 = getRandomPosition(positionMin, positionMax);
		object.position = position;
		randObject = getRandomObject();
	
	pass;

func createWorldBox(layerX : int, layerY : int, boxNum : int):
	var positionMin : Vector2 = Vector2(layerX * self.boxSize - self.halfBoxSize, layerY * self.boxSize - self.halfBoxSize);
	var positionMax : Vector2 = Vector2(layerX * self.boxSize + self.halfBoxSize, layerY * self.boxSize + self.halfBoxSize);
	
	seed(seedVal + boxNum);
	generateRandomObjects(positionMin, positionMax);
	
	return true;

func updateWorld(position : Vector2):
	var layerX : int = getLayer(position.x);
	var layerY : int = getLayer(position.y);
	var boxNum : int = getBoxNum(layerX, layerY);
	
	if !self.visitedBoxes.has(boxNum):
		self.visitedBoxes[boxNum] = createWorldBox(layerX, layerY, boxNum);

	pass;



