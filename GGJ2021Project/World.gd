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
				getCorner2(absX);
			else:
				getCorner1(absX);
		else:
			if layerY > 0:
				getCorner3(absX);
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

func createRandomObject():
	var value = randf();
	
	if value < 0.5:
		return null;
	else:
		
		
		return;
	
	pass;

func generateRandomObjects(positionMin : Vector2, positionMax : Vector2):
	
	var randObject = createRandomObject();
	
	while randObject:
		var position : Vector2 = getRandomPosition(positionMin, positionMax);
		randObject.position = position;
		randObject = createRandomObject();
	
	pass;

func createWorldBox(position : Vector2, boxNum : int):
	var halfBoxSize = boxSize / 2;
	var positionMin : Vector2 = ((position - halfBoxSize) / boxSize) + halfBoxSize;
	var positionMax : Vector2 = ((position + halfBoxSize) / boxSize) - halfBoxSize;
	
	seed(seedVal + boxNum);
	generateRandomObjects(positionMin, positionMax);
	
	return true;

func updateWorld(position : Vector2):
	var boxNum : int = getBoxNum(getLayer(position.x), getLayer(position.y));
	
	if !self.visitedBoxes.has(boxNum):
		self.visitedBoxes[boxNum] = createWorldBox(position, boxNum);

	pass;



