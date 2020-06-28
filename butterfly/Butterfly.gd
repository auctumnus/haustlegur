extends Node2D

export (int) var speed = 15

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

onready var timer = $Timer
onready var player = get_node("/root/Main/Player")

func getRandomDirection():
	return Vector2(randf(), randf()).normalized()

func getRunDirection(player_vector):
	return position.direction_to(player_vector) * -1

var current_direction = getRandomDirection()
var is_player_in_area = false

func _ready():
	animationState.travel("flap")
	timer.start()

func _process(delta):
	if is_player_in_area:
		current_direction = getRunDirection(player.position)
		speed = max(75 - position.distance_to(player.position), 15)
	animationTree["parameters/flap/blend_position"] = current_direction
	position += current_direction * speed * delta

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		is_player_in_area = true
		timer.set_paused(true)

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		is_player_in_area = false
		timer.set_paused(false)
		speed = 15

func _on_Timer_timeout():
	current_direction = getRandomDirection()
