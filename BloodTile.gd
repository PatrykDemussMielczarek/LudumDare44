extends StaticBody2D
 
var LifeTimer = 0;
var LifeTime = 3;
var Reddnes = 0.25;

func _ready():
	LifeTimer = LifeTime; 
	pass

func _process(delta): 
	
	Reddnes -= delta * 1/LifeTime;
	Reddnes = clamp(Reddnes, 0, 0.25 );
	get_node("Sprite").self_modulate = Color(0.75 + Reddnes,0,0,1);

	var scaleBonus = LifeTimer/64
	scale = Vector2(scaleBonus+0.1,scaleBonus+0.1);
	LifeTimer -= delta;
	if( LifeTimer < 0 ):
		get_parent().get_parent().SpawnBloodDrop(self);
		queue_free();
	pass;