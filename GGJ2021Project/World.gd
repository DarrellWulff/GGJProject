extends Node2D

const BOX_SIZE : int = 100;

func getLayer(axis : int) -> int:
	if axis > 0:
		axis -= BOX_SIZE / 2;
		if axis < 0:
			return 0;
		else:
			return (axis / BOX_SIZE) + 1;
	else:
		axis += BOX_SIZE / 2;
		if axis > 0:
			return 0;
		else:
			return (axis / BOX_SIZE) - 1;
	pass;

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

func getRowNum(absMaxLayer : int, minLayer : int):
	pass;

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
			return getCorner1(absX) + ;
		else:
			return getCorner3(absX) + ;# remainder
	else:
		if layerY > 0:
			return getCorner2(absY) + ;
		else:
			return getRowNum(absY, );# remainder
	
	layerY
	
func getWorldBox(position : Vector2):
	return getBoxNum(getLayer(position.x), getLayer(position.y));


