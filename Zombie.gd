extends KinematicBody2D

signal ToPlayer;   

var GravityVector = Vector2(0, 1);  
var GravityStrength = 512; 

var Velocity = Vector2(0,0);

var VerticalVelocityActual = 0;
var VerticalVelocityGoTo = 0; 
var VerticalVelocityMax = 0;
var VerticalVelocityMaxTrue = 576;

var HorizontalVelocityActual = 0;
var HorizontalVelocityGoTo = 0;
var HorizontalVelocityJumpForce = 0;
var HorizontalVelocityJumpForceTrue = -728;

var LerpSpeed = 5;
var FeetOnGround = false; 
		
var JumpTimer = 0;
var JumpTime = 0.16;
 
var Owner; 

var Waiting = false; 
var Chasing = false;

var PatrolingDirection = false;
var Patroling = false;

var PatrolTimer = 0;
var PatrolTimeMin = 1;
var PatrolTimeMax = 2;

var Inputs = [];
#0 -> W, 1 -> S, 2 -> A, 3 -> Dn
  
var AmountOfBlood = 0;
var AmountOfBloodMax = 0.25;

var Suckable = false;

var ZombieColor = Color(0.282353, 0.392157, 0.011765);


var RandomWeeTimer = 0;
var RandomWeeTimeMin = 8;
var RandomWeeTimeMax = 16;

func RemoveBlood( var amountRequest ): 
	amountRequest = amountRequest/4; 
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

func _ready():  
	RandomWeeTimer = rand_range(2, RandomWeeTimeMax);

	if( rand_range(0,1) > 0.5 ):
		Waiting = true;
		Patroling = false; 
		Chasing = false;
		
	AmountOfBlood = AmountOfBloodMax;
	Owner = get_parent(); 
	Patroling = true;
	pass
	
func _process(delta): 

	if( RandomWeeTimer > 0 ):
		RandomWeeTimer -= delta;
	else:
		RandomWeeTimer = rand_range(RandomWeeTimeMin, RandomWeeTimeMax);
		get_node("Weee").play();
		
	var AmountOfBloodMulti = AmountOfBlood * 4;
	VerticalVelocityMax = VerticalVelocityMaxTrue * AmountOfBloodMulti;
	HorizontalVelocityJumpForce = HorizontalVelocityJumpForceTrue * AmountOfBloodMulti;
	var colorBonus = 0.25;
	var colorMultiplier = AmountOfBloodMulti * 0.75;
	get_node("Sprite").self_modulate = Color(ZombieColor.r*colorMultiplier, ZombieColor.g*colorMultiplier+colorBonus, ZombieColor.b*colorMultiplier, 1);
	get_node("Sprite").speed_scale = AmountOfBloodMulti;
	var SpriteScaleBase = 0.128;
	
	if( VerticalVelocityActual > VerticalVelocityMax/100 ):
		get_node("Sprite").scale = Vector2(SpriteScaleBase, SpriteScaleBase); 
		get_node("Sprite").animation = "Move"; 
	elif( VerticalVelocityActual < -VerticalVelocityMax/100 ):
		get_node("Sprite").scale = Vector2(-SpriteScaleBase, SpriteScaleBase); 
		get_node("Sprite").animation = "Move"; 
	else: 
		get_node("Sprite").animation = "Idle"; 
	
	if ( get_node("HitBox").get_overlapping_bodies().size() > 0 ):
		emit_signal("ToPlayer");
	
	if( AmountOfBlood > 0):  
		Inputs = [false, false, false, false]; 
		LerpSpeed = 5;
		FeetOnGround = false; 
		
		if( get_node("LeftEyes").is_colliding() ||  get_node("RightEyes").is_colliding()):
			Chasing = true;
		else:
			Chasing = false;
		 
		if( Patroling):
			if( get_node("LeftEyesWall").is_colliding()):
				PatrolTimer = rand_range(PatrolTimeMin, PatrolTimeMax);
				if( get_node("LeftEyesUp").is_colliding() || rand_range(0,1) > 0.75): 
					PatrolingDirection = false;
				else:  
					Inputs[0] = true; 
			elif( get_node("RightEyesWall").is_colliding()):
				PatrolTimer = rand_range(PatrolTimeMin, PatrolTimeMax);
				if(get_node("RightEyesUp").is_colliding() || rand_range(0,1) > 0.75): 
					PatrolingDirection = true;
				else:  
					Inputs[0] = true; 
		
		if( Chasing ):
			if( get_node("LeftEyes").is_colliding()):
				Inputs[2] = true; 
				Inputs[0] = true;
			elif( get_node("RightEyes").is_colliding()):
				Inputs[3] = true; 
				Inputs[0] = true;
		elif( Waiting ):
			pass
		elif( Patroling ):
			if( PatrolTimer > 0 ):
				PatrolTimer -= delta;
				if( PatrolingDirection ):
					Inputs[2] = true; 
				else:
					Inputs[3] = true;
			else:
				PatrolTimer = rand_range(PatrolTimeMin, PatrolTimeMax);
				PatrolingDirection = !PatrolingDirection; 
		 
		  	
		if( get_node("Down").is_colliding() || get_node("Down2").is_colliding() || get_node("Down3").is_colliding()):
			FeetOnGround = true;  
		
		if( FeetOnGround ):
			if( Inputs[3] ):
				if( VerticalVelocityActual < 0 ):
					VerticalVelocityActual = 0;
				VerticalVelocityActual += VerticalVelocityMax * delta;
				LerpSpeed = 3;
			else:
				if( VerticalVelocityActual > 0 ):
					VerticalVelocityActual = 0; 
			
			if( Inputs[2] ):
				if( VerticalVelocityActual > 0 ):
					VerticalVelocityActual = 0;
				VerticalVelocityActual += -VerticalVelocityMax * delta;
				LerpSpeed = 3;
			else:
				if( VerticalVelocityActual < 0 ):
					VerticalVelocityActual = 0;
		else:
			if( Inputs[3] ): 
				VerticalVelocityActual += VerticalVelocityMax * delta * 0.5;
				LerpSpeed = 3; 
			
			if( Inputs[2] ): 
				VerticalVelocityActual += -VerticalVelocityMax * delta * 0.5;
				LerpSpeed = 3; 
		
		if( FeetOnGround && Inputs[0]):
			JumpTimer = JumpTime;
			HorizontalVelocityActual = HorizontalVelocityJumpForce;
		
		if( JumpTimer > 0 ):
			JumpTimer -= delta;
			HorizontalVelocityGoTo = HorizontalVelocityJumpForce
		else:
			HorizontalVelocityGoTo = 0; 
	else: 
		get_node("Radius").visible = false;
		get_parent().get_parent().SpawnRaisin(self);
		queue_free();
		
	VerticalVelocityActual = lerp( VerticalVelocityActual, 0, clamp(delta * LerpSpeed, 0, 1)); 
	VerticalVelocityActual = clamp( VerticalVelocityActual, -VerticalVelocityMax, VerticalVelocityMax);
	  
	HorizontalVelocityActual = lerp( HorizontalVelocityActual, HorizontalVelocityGoTo, delta * 3 ); 
	
	Velocity = Vector2(VerticalVelocityActual, GravityStrength+HorizontalVelocityActual); 
	
	move_and_slide_with_snap(Velocity, Vector2(0,0))
	
	pass 
	
func GetSuckable():
	return Suckable;

func _on_Zombie_mouse_entered(): 
	Suckable = true;
func _on_Zombie_mouse_exited():
	Suckable = false;
