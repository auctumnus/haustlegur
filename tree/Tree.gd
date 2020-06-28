extends Node2D

onready var globals = get_node("/root/Globals")

const intToOffset = [
	Vector2(-1, -1),
	Vector2(0, -1),
	Vector2(1, -1),
	
	Vector2(-1, 0),
	Vector2(0, 0),
	Vector2(1, 0),
	
	Vector2(-1, 1),
	Vector2(0, 1),
	Vector2(1, 1)
]

func _ready():
	var rand = randi() % 9
	var offset = intToOffset[rand]
	if globals.onein(10):
		offset *= 2
	translate(offset)
