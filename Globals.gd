extends Node

signal grow_crop
signal harvest_crop

const SimpleAudioPlayer = preload("res://audioplayer/SimpleAudioPlayer.tscn")

const sounds = {
	"step/grass01": preload("res://assets/sound/step/grass01.wav"),
	"step/grass02": preload("res://assets/sound/step/grass02.wav"),
	"step/grass03": preload("res://assets/sound/step/grass03.wav"),
	"dig/dig01": preload("res://assets/sound/dig/dig01.wav"),
	"dig/dig02": preload("res://assets/sound/dig/dig02.wav"),
	"dig/dig03": preload("res://assets/sound/dig/dig03.wav"),
	"plant/plant01": preload("res://assets/sound/plant/plant01.wav"),
	"plant/plant02": preload("res://assets/sound/plant/plant02.wav"),
	"plant/plant03": preload("res://assets/sound/plant/plant03.wav")
}

var created_sounds = []

func play_sound(sound_name, loop=false, pos=null):
	if sounds.has(sound_name):
		var player = SimpleAudioPlayer.instance()
		player.should_loop = loop
		add_child(player)
		created_sounds.append(player)
		player.play_sound(sounds[sound_name], pos)
	else:
		print("Cannot find sound by key \"" + sound_name + "\" !")

var rng = RandomNumberGenerator.new()

func onein(n):
	return randi() % n == 1

func chance(n):
	return randi() % 100 <= n

var active_crops = { }

func _ready():
	var timer = Timer.new()
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.set_wait_time(5)
	timer.set_autostart(true)
	get_node("/root/").call_deferred("add_child", timer)
	

func _on_Timer_timeout():
	var keys = active_crops.keys()
	if len(keys) > 0:
		var grow_target = keys[rng.randi_range(0, len(keys) - 1)]
		var grow_chance = 1.9 * len(keys) + 5
		if chance(grow_chance):
			emit_signal("grow_crop", grow_target)

func harvest_crop(crop_position):
	if active_crops.has(crop_position):
		emit_signal("harvest_crop", crop_position)
		active_crops.erase(crop_position)
		return true
	else:
		return false
