extends KinematicBody2D
   
var Suckable = false;

func SetPosition(var newPosition): 
	position = newPosition;

func _ready(): 
	if( rand_range(0,1) > 0.5 ):
		get_node("Sprite").rotation_degrees = 90;
	else:
		get_node("Sprite").rotation_degrees = -90;
	get_node("Sprite").self_modulate = Color(0, 0.25, 0, 1);
	
func _process(delta):
	move_and_slide(Vector2(0,256), Vector2(0,0));

func GetSuckable():
	return Suckable;

func _on_Raisin_mouse_entered():
	Suckable = true; 
func _on_Raisin_mouse_exited():
	Suckable = false;
