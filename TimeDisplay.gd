extends Label

func _process(delta):
	text = get_parent().get_parent().get_parent().get_node("Time/Display").text;