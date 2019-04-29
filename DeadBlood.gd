extends Node2D
  
func _ready():
	scale = Vector2(0.1, 0.1);
	get_node("Sprite").self_modulate = Color(0.25, 0, 0, 1);

var updateOnce = false;

func _process(delta): 
	if( updateOnce ):
		if( get_node("Area2D").get_overlapping_bodies().size() == 0 ):
			position.y -= delta * - 256;
	else:
		updateOnce = true;