extends Node2D

onready var screenSize = get_viewport().size;
onready var boxSize : int = screenSize.x;

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
		axis -= boxSize / 2;
		if axis < 0:
			return 0;
		else:
			return (axis / boxSize) + 1;
	else:
		axis += boxSize / 2;
		if axis > 0:
			return 0;
		else:
			return (axis / boxSize) - 1;
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
	#print("min = " + str(positionMin));
	#print("max = " + str(positionMax));
	var randProportion : Vector2 = Vector2(randf(), randf());
	var invProportion : Vector2 = Vector2(1.0, 1.0) - randProportion;
	
	return Vector2(randProportion.x * positionMin.x + invProportion.x * positionMax.x,
		randProportion.y * positionMin.y + invProportion.y * positionMax.y);

func getRandomObject():
	var value = randf();
	
	if value < 0.5:
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

func createWorldBox(position : Vector2, boxNum : int):
	var halfBoxSize = boxSize / 2;
	var positionMin : Vector2 = Vector2(((position.x - halfBoxSize) / boxSize) + halfBoxSize,
		((position.y - halfBoxSize) / boxSize) + halfBoxSize);
	var positionMax : Vector2 = Vector2(((position.x + halfBoxSize) / boxSize) - halfBoxSize,
		((position.y + halfBoxSize) / boxSize) - halfBoxSize);
	
	seed(seedVal + boxNum);
	generateRandomObjects(positionMin, positionMax);
	
	return true;

var lastBox : int = 0;

func updateWorld(position : Vector2):
	
	var boxNum : int = getBoxNum(getLayer(position.x), getLayer(position.y));
	
	if boxNum != lastBox:
		print("position = " + str(position));
		print("box num = " + str(boxNum));
		lastBox = boxNum;
	
	if !self.visitedBoxes.has(boxNum):
		self.visitedBoxes[boxNum] = createWorldBox(position, boxNum);

	pass;



