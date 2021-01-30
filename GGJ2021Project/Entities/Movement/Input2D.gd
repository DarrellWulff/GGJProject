extends Node

class_name Input2D

var updateFrames : int;
var frameX : int;
var frameY : int;
var inputDirection : Vector2;
var switchInput : Vector2;
var currentInput : Vector2;

func _init(updateFrames : int):
	self.updateFrames = updateFrames;
	self.frameX = 0;
	self.frameY = 0;
	self.inputDirection = Vector2(0.0, 0.0);
	self.switchInput = Vector2(0.0, 0.0);
	self.currentInput = Vector2(0.0, 0.0);
	pass

func updateCurrentInput(desiredInput : Vector2):
	
	if self.frameX >= self.updateFrames:
		self.currentInput.x = desiredInput.x;
	else:
		var completenessX = (self.frameX * 1.0) / self.updateFrames;
		self.currentInput.x = completenessX * desiredInput.x + (1.0 - completenessX) * self.switchInput.x;
		self.frameX += 1;
	
	if self.frameY >= self.updateFrames:
		self.currentInput.y = desiredInput.y;
	else:
		var completenessY = (self.frameY * 1.0) / self.updateFrames;
		currentInput.y = completenessY * desiredInput.y + (1.0 - completenessY) * self.switchInput.y;
		self.frameY += 1;
	
	pass

func updateInput(desiredInput : Vector2):
	
	if desiredInput.x != self.inputDirection.x:
		self.switchInput.x = self.currentInput.x;
		self.inputDirection.x = desiredInput.x;
		frameX = 1;
		
	if desiredInput.y != self.inputDirection.y:
		self.switchInput.y = self.currentInput.y;
		self.inputDirection.y = desiredInput.y;
		frameY = 1;
	
	updateCurrentInput(desiredInput);
	
	pass

