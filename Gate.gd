extends Node2D

var Suckable = false;

var AmountOfBlood = 0;
var AmountOfBloodMax = 0.95;

var UpDown = true;
var UpDownTimer = 0.5;
var UpDownTime = 0; 
var MoveStrength = 8;
  
var PortalMaxScale = 0.8;

func _ready(): 
	UpDownTime = rand_range(0.8, 1.2);

func GetSuckable():
	return Suckable

func AddBlood(var amount, var source ):
	if( source < amount ):
		amount = 0;
	AmountOfBlood += amount;
	if( AmountOfBlood >= AmountOfBloodMax ):
		var ReturnVal = AmountOfBloodMax - AmountOfBlood;
		AmountOfBlood = AmountOfBloodMax;
		return -amount-ReturnVal;
	else:
		return -amount;

func RemoveBlood( var amountRequest ): 
	if( AmountOfBlood > 0 ):
		if( AmountOfBlood <= amountRequest):
			var output = AmountOfBlood;
			AmountOfBlood = 0;
			return output;
		else:
			AmountOfBlood -= amountRequest;
			return amountRequest;
	else:
		return 0;
	
func _process(delta):
	
	if( UpDownTimer <= 0 ):
		UpDownTimer = UpDownTime;
		UpDown = !UpDown;
	else:
		UpDownTimer -= delta;
		if( UpDown ):
			get_node("Sprite").position += Vector2(0,  MoveStrength * delta); 
		else: 
			get_node("Sprite").position += Vector2(0, -MoveStrength * delta); 
			
	get_node("SuckSprite").value = AmountOfBlood/AmountOfBloodMax;
	
	if( AmountOfBlood/AmountOfBloodMax >= 1 ):
		get_node("Sprite/Sprite3").rotation_degrees -= delta * 90;
		get_node("Sprite/Sprite4").rotation_degrees += delta * 90;
		get_node("Sprite/Sprite3").visible = true;
		get_node("Sprite/Sprite4").visible = true;
		if( get_node("Sprite/Sprite3").scale.x < PortalMaxScale ): 
			var newScale = delta*PortalMaxScale*2;
			get_node("Sprite/Sprite3").scale += Vector2(newScale,newScale);
			get_node("Sprite/Sprite4").scale += Vector2(newScale,newScale);
		if(get_node("Gate").get_overlapping_bodies().size() > 0 ):
			get_parent().GatePassed();
	else:  
		if( get_node("Sprite/Sprite3").scale.x > 0 ): 
			var newScale = delta*PortalMaxScale*2;
			get_node("Sprite/Sprite3").scale -= Vector2(newScale,newScale);
			get_node("Sprite/Sprite4").scale -= Vector2(newScale,newScale);

func _on_SuckPlace_mouse_entered():
	Suckable = true; 
func _on_SuckPlace_mouse_exited():
	Suckable = false;
