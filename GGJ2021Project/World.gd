extends Node2D

const MIN_SPAWN_DISTANCE : int = 200;
const MAX_SPAWNED_OBJECTS : int = 10;
const MAX_CHECK_COUNT : int = 50;

enum { STICK, LEAF, TAR, BOULDER, TREE, CAMPFIRE, ENEMY };
const END_SPAWN_RATE : int = 128;
const STICK_SPAWN_RATE : int = 64;
const LEAF_SPAWN_RATE : int = 64;
const TAR_SPAWN_RATE : int = 64;
const BOULDER_SPAWN_RATE : int = 128;
const TREE_SPAWN_RATE : int = 128;
const CAMPFIRE_SPAWN_RATE : int = 8;
const ENEMY_SPAWN_RATE : int = 32;
const SPAWN_RATE_SUM : int = END_SPAWN_RATE + STICK_SPAWN_RATE + LEAF_SPAWN_RATE + TAR_SPAWN_RATE + BOULDER_SPAWN_RATE + TREE_SPAWN_RATE + CAMPFIRE_SPAWN_RATE + ENEMY_SPAWN_RATE;

onready var screenSize = get_viewport().size;
onready var boxSize : int = screenSize.x / 2;
onready var halfBoxSize : int = boxSize / 2;
onready var player = get_node("View").get_node("Player");

var visitedBoxes = {};
var lastVisitedBox : int;
var enemies = [];

func _ready():
	randomize();
	self.visitedBoxes[0] = [];
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
	
	sum += self.STICK_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return [load("res://Objects//Stick.tscn"), STICK];
	
	sum += self.LEAF_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return [load("res://Objects//Leaf.tscn"), LEAF];
	
	sum += self.TAR_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return [load("res://Objects//Tar.tscn"), TAR];
	
	sum += self.BOULDER_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return [load("res://Objects//Boulder.tscn"), BOULDER];
	
	sum += self.TREE_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return [load("res://Objects//Tree.tscn"), TREE];
	
	sum += self.CAMPFIRE_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return [load("res://Objects//Campfire.tscn"), CAMPFIRE];
	
	sum += self.ENEMY_SPAWN_RATE;
	if value <= (sum / self.SPAWN_RATE_SUM):
		return [load("res://Entities//Enemy.tscn"), ENEMY];
	
	else:
		return null; 
	
	pass;

func isValidPosition(objects : Array, position : Vector2) -> bool:
	for currentObject in objects:
		if (currentObject.position - position).length() < MIN_SPAWN_DISTANCE:
			return false;
	return true;

func generateRandomObjects(positionMin : Vector2, positionMax : Vector2):
	var campfires = [];
	var objects = [];
	var objectSet = getRandomObject();
	var checkCount = 0;
	
	while objectSet:
		var randomPosition : Vector2 = getRandomPosition(positionMin, positionMax);
		
		var validPosition : bool = false;
		
		for i in range(5):
			if isValidPosition(objects, randomPosition):
				validPosition = true;
				break;
			randomPosition = getRandomPosition(positionMin, positionMax);
		
		if !validPosition:
			if checkCount >= MAX_CHECK_COUNT:
				break;
			else:
				checkCount += 1;
				continue;
		
		var object = objectSet[0].instance();
		add_child(object);
		object.position = randomPosition;
		objects.append(object);
		if objectSet[1] == self.CAMPFIRE:
			campfires.append(object);
		elif objectSet[1] == self.ENEMY:
			self.enemies.append(object);
		if len(objects) > MAX_SPAWNED_OBJECTS:
			break;
		objectSet = getRandomObject();
	
	return campfires;

func createWorldBox(layerX : int, layerY : int, boxNum : int):
	var positionMin : Vector2 = Vector2(layerX * self.boxSize - self.halfBoxSize + self.MIN_SPAWN_DISTANCE / 4, layerY * self.boxSize - self.halfBoxSize  + self.MIN_SPAWN_DISTANCE / 4);
	var positionMax : Vector2 = Vector2(layerX * self.boxSize + self.halfBoxSize - self.MIN_SPAWN_DISTANCE / 4, layerY * self.boxSize + self.halfBoxSize - self.MIN_SPAWN_DISTANCE / 4);
	
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

func getClosestCampfireInBox(position : Vector2, layerX : int, layerY : int):
	var boxNum : int = getBoxNum(layerX, layerY);
	var closest = null;
	var distance = 2 * self.boxSize;
	
	if self.visitedBoxes.has(boxNum):
		for campfire in self.visitedBoxes[boxNum]:
			if campfire:
				var currentDistance = (campfire.position - position).length();
				if currentDistance < distance:
					closest = campfire;
					distance = currentDistance;
	
	return [closest, distance];

func getClosestCampfire(position : Vector2):
	var layerX : int = getLayer(position.x);
	var layerY : int = getLayer(position.y);
	
	var closestCampfire = getClosestCampfireInBox(position, layerX, layerY);
	
	if closestCampfire[0]:
		var current = getClosestCampfireInBox(position, layerX, layerY - 1);
		if current[0] && current[1] < closestCampfire[1]:
			closestCampfire = current;
	else:
		closestCampfire = getClosestCampfireInBox(position, layerX, layerY - 1);
	
	if closestCampfire[0]:
		var current = getClosestCampfireInBox(position, layerX + 1, layerY - 1);
		if current[0] && current[1] < closestCampfire[1]:
			closestCampfire = current;
	else:
		closestCampfire = getClosestCampfireInBox(position, layerX + 1, layerY - 1);
	
	if closestCampfire[0]:
		var current = getClosestCampfireInBox(position, layerX + 1, layerY);
		if current[0] && current[1] < closestCampfire[1]:
			closestCampfire = current;
	else:
		closestCampfire = getClosestCampfireInBox(position, layerX + 1, layerY);
	
	if closestCampfire[0]:
		var current = getClosestCampfireInBox(position, layerX + 1, layerY + 1);
		if current[0] && current[1] < closestCampfire[1]:
			closestCampfire = current;
	else:
		closestCampfire = getClosestCampfireInBox(position, layerX + 1, layerY + 1);
	
	if closestCampfire[0]:
		var current = getClosestCampfireInBox(position, layerX, layerY + 1);
		if current[0] && current[1] < closestCampfire[1]:
			closestCampfire = current;
	else:
		closestCampfire = getClosestCampfireInBox(position, layerX, layerY + 1);
	
	if closestCampfire[0]:
		var current = getClosestCampfireInBox(position, layerX - 1, layerY + 1);
		if current[0] && current[1] < closestCampfire[1]:
			closestCampfire = current;
	else:
		closestCampfire = getClosestCampfireInBox(position, layerX - 1, layerY + 1);
	
	if closestCampfire[0]:
		var current = getClosestCampfireInBox(position, layerX - 1, layerY);
		if current[0] && current[1] < closestCampfire[1]:
			closestCampfire = current;
	else:
		closestCampfire = getClosestCampfireInBox(position, layerX - 1, layerY);
	
	if closestCampfire[0]:
		var current = getClosestCampfireInBox(position, layerX - 1, layerY - 1);
		if current[0] && current[1] < closestCampfire[1]:
			closestCampfire = current;
	else:
		closestCampfire = getClosestCampfireInBox(position, layerX - 1, layerY - 1);
	
	return closestCampfire[0];


func _physics_process(delta):
	for enemy in self.enemies:
		enemy.updateMovement(delta, self.player, getClosestCampfire(enemy.position));
	pass;
