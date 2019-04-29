extends KinematicBody2D
 
var Tile = load("res://Terrain.tscn"); 

var GravityVector = Vector2(0, 1);  
var GravityStrength = 512;   

var Velocity = Vector2(0,0);

var VerticalVelocityActual = 0;
var VerticalVelocityGoTo = 0; 
var VerticalVelocityMax = 512;

var HorizontalVelocityActual = 0;
var HorizontalVelocityGoTo = 0;
var HorizontalVelocityJumpForce = -512;
var JumpTimer = 0;
var JumpTime = 0.16;

var Inputs = [];  

var LerpSpeed = 5;
var FeetOnGround = false; 
	
var Owner; 

var IsCasting = false;
var CastingTimer = 0;

var Dead = false;

func _ready():
	Owner = get_parent();
	Inputs = [false, false, false, false]; 
	pass
	
func SetCasting(var isCasting): 
	if( isCasting ):
		CastingTimer = 0.25;

func _process(delta):
	  
	LerpSpeed = 5;
	FeetOnGround = false; 
	
	if( CastingTimer > 0 ):
		IsCasting = true;
		CastingTimer -= delta;
	else:
		IsCasting = false;
	  
	if( get_node("Down").is_colliding() || get_node("Down2").is_colliding() || get_node("Down3").is_colliding()):
		FeetOnGround = true;   
	
	var SpriteScaleBase = 0.128;
	
	if( VerticalVelocityActual > VerticalVelocityMax/100 ):
		get_node("Sprite").scale = Vector2(SpriteScaleBase, SpriteScaleBase);
		if( !IsCasting ):
			get_node("Sprite").animation = "Move";
		else:
			get_node("Sprite").animation = "SpellingMove";
	elif( VerticalVelocityActual < -VerticalVelocityMax/100 ):
		get_node("Sprite").scale = Vector2(-SpriteScaleBase, SpriteScaleBase);
		if( !IsCasting ):
			get_node("Sprite").animation = "Move";
		else:
			get_node("Sprite").animation = "SpellingMove";
	else:
		if( !IsCasting ):
			get_node("Sprite").animation = "Idle";
		else:
			get_node("Sprite").animation = "Spelling";
		
	if( !Dead ):
		if( FeetOnGround ):
			if( Input.is_key_pressed(KEY_D)):
				if( VerticalVelocityActual < 0 ):
					VerticalVelocityActual = 0;
				VerticalVelocityActual += VerticalVelocityMax * delta;
				LerpSpeed = 3;
			else:
				if( VerticalVelocityActual > 0 ):
					VerticalVelocityActual = 0; 
			
			if( Input.is_key_pressed(KEY_A)):
				if( VerticalVelocityActual > 0 ):
					VerticalVelocityActual = 0;
				VerticalVelocityActual += -VerticalVelocityMax * delta;
				LerpSpeed = 3;
			else:
				if( VerticalVelocityActual < 0 ):
					VerticalVelocityActual = 0;
		else:
			if( Input.is_key_pressed(KEY_D)): 
				VerticalVelocityActual += VerticalVelocityMax * delta;
				LerpSpeed = 3; 
			
			if( Input.is_key_pressed(KEY_A)): 
				VerticalVelocityActual += -VerticalVelocityMax * delta;
				LerpSpeed = 3; 
		
		if( FeetOnGround && Input.is_key_pressed(KEY_W)):
			JumpTimer = JumpTime;
			HorizontalVelocityActual = HorizontalVelocityJumpForce;
	
	if( JumpTimer > 0 ):
		JumpTimer -= delta;
		HorizontalVelocityGoTo = HorizontalVelocityJumpForce
	else:
		HorizontalVelocityGoTo = 0; 
		 
	VerticalVelocityActual = lerp( VerticalVelocityActual, 0, clamp(delta * LerpSpeed, 0, 1)); 
	VerticalVelocityActual = clamp( VerticalVelocityActual, -VerticalVelocityMax, VerticalVelocityMax); 
	 
	if( FeetOnGround && abs(VerticalVelocityActual) > VerticalVelocityMax/100 ):
		if( !get_node("Walking").playing ):
			get_node("Walking").playing = true;
	else:
		get_node("Walking").playing = false;
		
	if( !FeetOnGround ):
		HorizontalVelocityGoTo += GravityStrength * delta * 512;
		HorizontalVelocityGoTo = clamp(HorizontalVelocityGoTo, HorizontalVelocityJumpForce, GravityStrength);
		
	HorizontalVelocityActual = lerp( HorizontalVelocityActual, HorizontalVelocityGoTo, delta * 3 );  
	
 
		
	Velocity = Vector2(VerticalVelocityActual, HorizontalVelocityActual); 
	
	move_and_slide_with_snap(Velocity, Vector2(0,0))
	pass 
