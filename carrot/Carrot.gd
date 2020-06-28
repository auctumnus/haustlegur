extends Node2D

onready var globals = get_node("/root/Globals")
onready var sprite = $Sprite

var growth_stage = 0

func _ready():
	globals.active_crops[position] = {
		"growth_stage": growth_stage,
		"position": position
	}
	globals.connect("grow_crop", self, "_on_grow_crop")
	globals.connect("harvest_crop", self, "_on_harvest_crop")

func grow():
	if(growth_stage < 2):
		globals.active_crops[position].growth_stage += 1
		growth_stage += 1
		sprite.frame += 1

func harvest():
	visible = false
	queue_free()

func _on_grow_crop(target):
	if target == position:
		grow()

func _on_harvest_crop(target):
	if target == position:
		harvest()
