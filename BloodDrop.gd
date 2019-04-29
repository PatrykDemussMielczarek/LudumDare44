extends Node2D

var ColorBase = 0.5;

func _ready():
	scale = Vector2(0.1, 0.1); 
	
func _process(delta):
	ColorBase -= delta * 1/3;
	ColorBase = clamp(ColorBase, 0, 1);
	get_node("Sprite").self_modulate = Color(ColorBase+0.25, 0, 0, 1);
	
	if( get_node("Area2D").get_overlapping_bodies().size() == 0 ):
		position.y -= delta * - 256;
		
	if( ColorBase == 0 ): 
		get_parent().get_parent().SpawnDeadBlood(self);
		queue_free(); 