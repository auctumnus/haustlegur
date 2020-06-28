extends Node2D

onready var audio_node = $AudioStreamPlayer
onready var globals = get_node("/root/Globals")
var should_loop = false


func _ready():
	audio_node.connect("finished", self, "sound_finished")
	audio_node.stop()

func play_sound(audio_stream, _position=null):
	if audio_stream == null:
		print ("No audio stream passed; cannot play sound")
		globals.created_sounds.remove(globals.created_sounds.find(self))
		queue_free()
		return

	audio_node.stream = audio_stream
	audio_node.play(0.0)

func sound_finished():
	if should_loop:
		audio_node.play(0.0)
	else:
		globals.created_sounds.remove(globals.created_sounds.find(self))
		audio_node.stop()
		queue_free()
