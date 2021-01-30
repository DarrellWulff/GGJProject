extends Node2D

onready var screenSize = get_viewport().size;
onready var boxSize : int = screenSize.x;

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
	pass

func getCorner1(absLayer : int):
	var val = 2 * absLayer;
	return val * (val - 1);

func getCorner2(absLayer : int):
	var val = 2 * absLayer;
	return val * val;

func getCorner3(absLayer : int):
	var val = 2 * absLayer;
	return val * (val + 1);

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
	
	pass

func getWorldBox(position : Vector2):
	return getBoxNum(getLayer(position.x), getLayer(position.y));


