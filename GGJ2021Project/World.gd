extends Node2D

const MIN_SPAWN_DISTANCE : int = 75;
const MAX_SPAWNED_OBJECTS : int = 20;

const END_SPAWN_RATE : int = 64;
const BOULDER_SPAWN_RATE : int = 64;
const STICK_SPAWN_RATE : int = 64;
const LEAF_SPAWN_RATE : int = 32
const TAR_SPAWN_RATE : int = 32;
const TREE_SPAWN_RATE : int = 64;
<<<<<<< HEAD
const CAMPFIRE_SPAWN_RATE : int = 64;
const SPAWN_RATE_SUM : int = END_SPAWN_RATE + BOULDER_SPAWN_RATE + STICK_SPAWN_RATE + TAR_SPAWN_RATE + TREE_SPAWN_RATE + CAMPFIRE_SPAWN_RATE;
=======
const FIRE_SPAWN_RATE : int = 16;
const SPAWN_RATE_SUM : int = END_SPAWN_RATE + BOULDER_SPAWN_RATE + STICK_SPAWN_RATE + LEAF_SPAWN_RATE + TAR_SPAWN_RATE + TREE_SPAWN_RATE + FIRE_SPAWN_RATE;
>>>>>>> Jon

onready var screenSize = get_viewport().size;
onready var boxSize : int = screenSize.x / 2;
onready var halfBoxSize : int = boxSize / 2;

var visitedBoxes = {};
var lastVisitedBox : int;

func _ready():
	randomize();
	self.visitedBoxes[0] = true;
	self.lastVisitedBox = 1;
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
	
	var sum : float = self.END_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return null;
	
	sum += self.BOULDER_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return [load("res://Objects//Boulder.tscn"), false];
	
	sum += self.STICK_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
<<<<<<< HEAD
		return [load("res://Objects//Stick.tscn"), false];
=======
		return load("res://Objects//Stick.tscn");
		
	sum += self.LEAF_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return load("res://Objects//Leaf.tscn");
>>>>>>> Jon
	
	sum += self.TAR_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return [load("res://Objects//Tar.tscn"), false];
	
	sum += self.TREE_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
<<<<<<< HEAD
		return [load("res://Objects//Tree.tscn"), false];
	
	sum += self.CAMPFIRE_SPAWN_RATE;
	if value <= (sum / self.CAMPFIRE_SPAWN_RATE):
		return [load("res://Objects//Campfire.tscn"), true];
=======
		return load("res://Objects//Tree.tscn");
		
	sum += self.FIRE_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return load("res://Objects//Campfire.tscn");
>>>>>>> Jon
	
	else:
		return null; 
	
	pass;

func isValidPosition(objects : Array, position : Vector2) -> bool:
	for currentObject in objects:
		if (currentObject.position - position).length() < MIN_SPAWN_DISTANCE:
			return false;
	return true;

func generateRandomObjects(positionMin : Vector2, positionMax : Vector2):
	var storedObjects = [];
	var objects = [];
	var objectSet = getRandomObject();
	
	while objectSet:
		var randomPosition : Vector2 = getRandomPosition(positionMin, positionMax);
		
		var validPosition : bool = false;
		
		for i in range(5):
			if isValidPosition(objects, randomPosition):
				validPosition = true;
				break;
			randomPosition = getRandomPosition(positionMin, positionMax);
		
		if !validPosition:
			continue;
		
		var object = objectSet[0].instance();
		add_child(object);
		object.position = randomPosition;
		objects.append(object);
		if objectSet[1]:
			storedObjects.append(object);
		if len(objects) > MAX_SPAWNED_OBJECTS:
			return storedObjects;
		objectSet = getRandomObject();
	
	return storedObjects;

func createWorldBox(layerX : int, layerY : int, boxNum : int):
	var positionMin : Vector2 = Vector2(layerX * self.boxSize - self.halfBoxSize, layerY * self.boxSize - self.halfBoxSize);
	var positionMax : Vector2 = Vector2(layerX * self.boxSize + self.halfBoxSize, layerY * self.boxSize + self.halfBoxSize);
	
	return generateRandomObjects(positionMin, positionMax);

func generateBox(layerX : int, layerY : int):
	var boxNum : int = getBoxNum(layerX, layerY);
	
	if !self.visitedBoxes.has(boxNum):
		self.visitedBoxes[boxNum] = createWorldBox(layerX, layerY, boxNum);
	
	pass;

func generateLocalBoxes(layerX : int, layerY : int):
	
	generateBox(layerX, layerY - 1);
	generateBox(layerX + 1, layerY - 1);
	generateBox(layerX + 1, layerY);
	generateBox(layerX + 1, layerY + 1);
	generateBox(layerX, layerY + 1);
	generateBox(layerX - 1, layerY + 1);
	generateBox(layerX - 1, layerY);
	generateBox(layerX - 1, layerY - 1);
	
	pass;

func updateWorld(positionUpdate : Vector2):
	var layerX : int = getLayer(positionUpdate.x);
	var layerY : int = getLayer(positionUpdate.y);
	var boxNum : int = getBoxNum(layerX, layerY);
	
	if boxNum != self.lastVisitedBox:
		generateLocalBoxes(layerX, layerY);
		self.lastVisitedBox = boxNum;

	pass;

func getClosestCampfire(position : Vector2):
	var boxNum : int = getBoxNum(getLayer(position.x), getLayer(position.y));
	var closest = null;
	var distance = 2 * self.boxSize;
	
	for campfire in self.visitedBoxes[boxNum]:
		var currentDistance = (campfire.position - position).length();
		if currentDistance <= distance:
			closest = campfire;
			distance = currentDistance;
	
	return closest;


