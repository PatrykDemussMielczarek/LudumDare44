extends Node2D

signal ToPlayer;  

func _process(delta):
	if ( get_node("HitBox").get_overlapping_bodies().size() > 0 ):
		emit_signal("ToPlayer");
		queue_free();