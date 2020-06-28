extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 800

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var tilemap = get_node("/root/Main/TileMap")
onready var farmmap = get_node("/root/Main/FarmMap")
onready var Globals = get_node("/root/Globals")

var butterfly = preload("res://butterfly/Butterfly.tscn")
var carrot = preload("res://carrot/Carrot.tscn")

var velocity = Vector2.ZERO

const adjacents = [
	Vector2(-1, -1),
	Vector2(0, -1),
	Vector2(1, -1),
	
	Vector2(-1, 0),
	Vector2(1, 0),
	
	Vector2(-1, 1),
	Vector2(0, 1),
	Vector2(1, 1)
]

# Called when the node enters the scene tree for the first time.
func _ready():
	animationTree.active = true
	pass # Replace with function body.

func _process(_delta):
	if Input.is_action_just_pressed("ui_n"):
		var new_butterfly = butterfly.instance()
		new_butterfly.set_position(position)
		get_node("/root/Main").add_child(new_butterfly)
	elif Input.is_action_just_pressed("use"):
		var tilemap_pos = tilemap.world_to_map(position)
		for v in adjacents:
			if(tilemap.get_cellv(tilemap_pos + v) != 1):
				return null
		if tilemap.get_cellv(tilemap_pos) == 1 && farmmap.get_cellv(tilemap_pos) == -1:
			farmmap.set_cellv(tilemap_pos, 0)
			farmmap.update_bitmask_area(tilemap_pos)
			Globals.play_sound("dig/dig0" + String(randi() % 3 + 1))
	elif Input.is_action_just_pressed("plant"):
		var tilemap_pos = tilemap.world_to_map(position)
		var new_carrot_position = (tilemap_pos * 16) + Vector2(8,8)
		if farmmap.get_cellv(tilemap_pos) == 0 && !Globals.active_crops.has(new_carrot_position):
			var new_carrot = carrot.instance()
			new_carrot.set_position((tilemap_pos * 16) + Vector2(8,8))
			get_node("/root/Main").add_child(new_carrot)
			Globals.play_sound("plant/plant0" + String(randi() % 3 + 1))
	elif Input.is_action_just_pressed("harvest"):
		var carrot_pos = (tilemap.world_to_map(position) * 16) + Vector2(8,8)
		if Globals.active_crops.has(carrot_pos):
			Globals.harvest_crop(carrot_pos)

func _physics_process(delta):
	process_move(delta)

func get_input():
	return Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), 
				   Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).normalized()

func process_move(delta):
	var input_vector = get_input()
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Walk/blend_position", input_vector)
		animationState.travel("Walk")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)

func play_step():
	Globals.play_sound("step/grass0" + String(randi() % 3 + 1))
