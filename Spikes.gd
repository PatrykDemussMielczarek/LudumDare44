extends Node2D

signal ToPlayer; 

func _ready():
	get_node("CollisionFixed").scale = Vector2(0,0);
	get_node("Sprite2").visible = false;

func _process(delta):
	if ( get_node("HitBox").get_overlapping_bodies().size() > 0 ):
		emit_signal("ToPlayer");
	
	if( get_node("RaisinHitbox").get_overlapping_bodies().size() > 0 && !get_node("Sprite2").visible ):
		get_parent().get_parent().ControlledRaisin = null;
		get_node("RaisinHitbox").get_overlapping_bodies()[0].queue_free();
		get_node("CollisionFixed").scale = Vector2(1,1);
		get_node("Sprite2").visible = true;
		get_node("Sound").play();
	