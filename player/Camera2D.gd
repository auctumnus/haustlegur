extends Camera2D

func _process(_delta):
	if(Input.is_action_pressed("ui_accept")):
		set_zoom(Vector2(4, 4))
	elif(Input.is_action_pressed("ui_cancel")):
		set_zoom(Vector2(1,1))
