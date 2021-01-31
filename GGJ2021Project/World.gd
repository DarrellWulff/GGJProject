extends Node2D

const MIN_SPAWN_DISTANCE : int = 300;
const MAX_SPAWNED_OBJECTS : int = 10;
const MAX_CHECK_COUNT : int = 50;

enum { GRASS, DIRT };

const GRASS_TERRAIN_RATE : int = 64;
const DIRT_TERRAIN_RATE : int = 64;
const TERRAIN_RATE_SUM : int = GRASS_TERRAIN_RATE + DIRT_TERRAIN_RATE;

enum { STICK, LEAF, TAR, BOULDER, TREE, CAMPFIRE, ENEMY };

const GRASS_END_SPAWN_RATE : int = 128;
const GRASS_STICK_SPAWN_RATE : int = 128;
const GRASS_LEAF_SPAWN_RATE : int = 64;
const GRASS_TAR_SPAWN_RATE : int = 0;
const GRASS_BOULDER_SPAWN_RATE : int = 0;
const GRASS_TREE_SPAWN_RATE : int = 128;
const GRASS_CAMPFIRE_SPAWN_RATE : int = 8;
const GRASS_ENEMY_SPAWN_RATE : int = 32;
const GRASS_SPAWN_RATE_SUM : int = GRASS_END_SPAWN_RATE + GRASS_STICK_SPAWN_RATE + GRASS_LEAF_SPAWN_RATE + GRASS_TAR_SPAWN_RATE + GRASS_BOULDER_SPAWN_RATE + GRASS_TREE_SPAWN_RATE + GRASS_CAMPFIRE_SPAWN_RATE + GRASS_ENEMY_SPAWN_RATE;

const DIRT_END_SPAWN_RATE : int = 128;
const DIRT_STICK_SPAWN_RATE : int = 0;
const DIRT_LEAF_SPAWN_RATE : int = 64;
const DIRT_TAR_SPAWN_RATE : int = 128;
const DIRT_BOULDER_SPAWN_RATE : int = 128;
const DIRT_TREE_SPAWN_RATE : int = 0;
const DIRT_CAMPFIRE_SPAWN_RATE : int = 8;
const DIRT_ENEMY_SPAWN_RATE : int = 32;
const DIRT_SPAWN_RATE_SUM : int = DIRT_END_SPAWN_RATE + DIRT_STICK_SPAWN_RATE + DIRT_LEAF_SPAWN_RATE + DIRT_TAR_SPAWN_RATE + DIRT_BOULDER_SPAWN_RATE + DIRT_TREE_SPAWN_RATE + DIRT_CAMPFIRE_SPAWN_RATE + DIRT_ENEMY_SPAWN_RATE;

onready var screenSize = get_viewport().size;
onready var boxSize : int = screenSize.x / 2;
onready var halfBoxSize : int = boxSize / 2;
onready var player = get_node("View").get_node("Player");

onready var startMenu = $CanvasLayer/StartMenu

var visitedBoxes = {};
var lastVisitedBox : int;
var enemies = [];

signal closestCampfire(campfire);

func _ready():
	
	#At very bottom!
	gameEnter()
	
	randomize();
	self.visitedBoxes[0] = [];
	self.lastVisitedBox = 1;
	loadTerrain(0, 0);
	
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

func getRandomTerrain():
	var value = randf();
	
	var sum : float = self.GRASS_TERRAIN_RATE;
	if value <= (sum / self.TERRAIN_RATE_SUM):
		return [load("res://Images//Art//World/ForestGrass.tscn"), GRASS];
	
	sum += self.DIRT_TERRAIN_RATE;
	if value <= (sum / self.TERRAIN_RATE_SUM):
		return [load("res://Images//Art//World/LargeDirtTerrain.tscn"), DIRT];
	
	return [load("res://Images//Art//World/ForestGrass.tscn"), GRASS];

func loadTerrain(layerX : int, layerY : int):
	var terrain = getRandomTerrain();
	
	var object = terrain[0].instance();
	add_child(object);
	object.position = Vector2(layerX * self.boxSize, layerY * self.boxSize);
	
	return terrain[1];

func getRandomGrassObject():
	var value = randf();
	
	var sum : float = self.GRASS_END_SPAWN_RATE;
	if value <= (sum / self.GRASS_SPAWN_RATE_SUM):
		return null;
	
	sum += self.GRASS_STICK_SPAWN_RATE;
	if value <= (sum / self.GRASS_SPAWN_RATE_SUM):
		return [load("res://Objects//Stick.tscn"), STICK];
	
	sum += self.GRASS_LEAF_SPAWN_RATE;
	if value <= (sum / self.GRASS_SPAWN_RATE_SUM):
		return [load("res://Objects//Leaf.tscn"), LEAF];
	
	sum += self.GRASS_TAR_SPAWN_RATE;
	if value <= (sum / self.GRASS_SPAWN_RATE_SUM):
		return [load("res://Objects//Tar.tscn"), TAR];
	
	sum += self.GRASS_BOULDER_SPAWN_RATE;
	if value <= (sum / self.GRASS_SPAWN_RATE_SUM):
		return [load("res://Objects//Boulder.tscn"), BOULDER];
	
	sum += self.GRASS_TREE_SPAWN_RATE;
	if value <= (sum / self.GRASS_SPAWN_RATE_SUM):
		return [load("res://Objects//Tree.tscn"), TREE];
	
	sum += self.GRASS_CAMPFIRE_SPAWN_RATE;
	if value <= (sum / self.GRASS_SPAWN_RATE_SUM):
		return [load("res://Objects//Campfire.tscn"), CAMPFIRE];
	
	sum += self.GRASS_ENEMY_SPAWN_RATE;
	if value <= (sum / self.GRASS_SPAWN_RATE_SUM):
		return [load("res://Entities//Enemy.tscn"), ENEMY];
	
	return null;

func getRandomDirtObject():
	var value = randf();
	
	var sum : float = self.DIRT_END_SPAWN_RATE;
	if value <= (sum / self.DIRT_SPAWN_RATE_SUM):
		return null;
	
	sum += self.DIRT_STICK_SPAWN_RATE;
	if value <= (sum / self.DIRT_SPAWN_RATE_SUM):
		return [load("res://Objects//Stick.tscn"), STICK];
	
	sum += self.DIRT_LEAF_SPAWN_RATE;
	if value <= (sum / self.DIRT_SPAWN_RATE_SUM):
		return [load("res://Objects//Leaf.tscn"), LEAF];
	
	sum += self.DIRT_TAR_SPAWN_RATE;
	if value <= (sum / self.DIRT_SPAWN_RATE_SUM):
		return [load("res://Objects//Tar.tscn"), TAR];
	
	sum += self.DIRT_BOULDER_SPAWN_RATE;
	if value <= (sum / self.DIRT_SPAWN_RATE_SUM):
		return [load("res://Objects//Boulder.tscn"), BOULDER];
	
	sum += self.DIRT_TREE_SPAWN_RATE;
	if value <= (sum / self.DIRT_SPAWN_RATE_SUM):
		return [load("res://Objects//Tree.tscn"), TREE];
	
	sum += self.DIRT_CAMPFIRE_SPAWN_RATE;
	if value <= (sum / self.DIRT_SPAWN_RATE_SUM):
		return [load("res://Objects//Campfire.tscn"), CAMPFIRE];
	
	sum += self.DIRT_ENEMY_SPAWN_RATE;
	if value <= (sum / self.DIRT_SPAWN_RATE_SUM):
		return [load("res://Entities//Enemy.tscn"), ENEMY];
	
	return null;

func isValidPosition(objects : Array, position : Vector2) -> bool:
	for currentObject in objects:
		if (currentObject.position - position).length() < MIN_SPAWN_DISTANCE:
			return false;
	return true;

func getRandomObject(terrainType):
	if terrainType == GRASS:
		return getRandomGrassObject();
	elif terrainType == DIRT:
		return getRandomDirtObject();
	
	return getRandomGrassObject();

func generateRandomObjects(positionMin : Vector2, positionMax : Vector2, terrainType):
	var campfires = [];
	var objects = [];
	var objectSet = getRandomObject(terrainType);
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
		objectSet = getRandomObject(terrainType);
	
	return campfires;

func createWorldBox(layerX : int, layerY : int, boxNum : int):
	var positionMin : Vector2 = Vector2(layerX * self.boxSize - self.halfBoxSize + self.MIN_SPAWN_DISTANCE / 4, layerY * self.boxSize - self.halfBoxSize  + self.MIN_SPAWN_DISTANCE / 4);
	var positionMax : Vector2 = Vector2(layerX * self.boxSize + self.halfBoxSize - self.MIN_SPAWN_DISTANCE / 4, layerY * self.boxSize + self.halfBoxSize - self.MIN_SPAWN_DISTANCE / 4);
	
	var terrainType = loadTerrain(layerX, layerY);
	
	return generateRandomObjects(positionMin, positionMax, terrainType);

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

func _process(delta):
	emit_signal("closestCampfire", getClosestCampfire(self.player.position));
	pass;

#START MENU
func gameEnter():
	get_tree().paused = true
	startMenu.show()

func gameBegin():
	startMenu.hide()
	get_tree().paused = false

func _on_PlayButton_pressed():
	gameBegin()


func _on_Exit_pressed():
	get_tree().quit()
