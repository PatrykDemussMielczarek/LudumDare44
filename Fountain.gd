extends Node2D

signal ToPlayer;  
 

var UpDown = false;
var UpDownTimer = 0;
var UpDownTime = 0; 
var MoveStrength = 8;

func _ready():
	UpDownTime = rand_range(0.8, 1.2);
func _process(delta): 
	
	if( UpDownTimer <= 0 ):
		UpDownTimer = UpDownTime;
		UpDown = !UpDown;
	else:
		UpDownTimer -= delta;
		if( UpDown ):
			get_node("Sprite").position += Vector2(0,  MoveStrength * delta);
			get_node("Sprite2").position += Vector2(0, MoveStrength * delta);
		else: 
			get_node("Sprite").position += Vector2(0, -MoveStrength * delta);
			get_node("Sprite2").position += Vector2(0, -MoveStrength * delta);
	 
	if ( get_node("HitBox").get_overlapping_bodies().size() > 0 ):
		emit_signal("ToPlayer"); 
		get_node("Sprite2").rotation_degrees += 720 * delta;
	else:
		get_node("Sprite2").rotation_degrees += 135 * delta;
		