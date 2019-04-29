extends Node2D

var BloodValue = 0;
var BloodValueMax = 1;
var BloodCost = 0.24;

var Tile = load("res://BloodTile.tscn");
var BloodDrop = load("res://BloodDrop.tscn"); 
var DeadBlood = load("res://DeadBlood.tscn"); 
var Raisin = load("res://Raisin.tscn"); 

var CanSpawnNewBlood = false;

var ControlledRaisin;

var IsCasting = false;

var DamageTakeTimerZombie = 0;
var DamageTakeTimeZombie = 0.2;

var DamageTakeTimerSpike = 0;
var DamageTakeTimeSpike = 0.5;

signal ToMainManger;

signal ToMainMangerReset;

var PotionHeal = 0.34;
var FontainHealing = 0.5;

var TeleportTimer = 3;
var TeleportCanTick = false;
 
var DeadTimer = 3;
var DeadCanTick = false;

var Audio;

func GatePassed():
	get_node("BloodMage").Dead = true;
	TeleportCanTick = true; 

func TakeZombieDamage():
	if( DamageTakeTimerZombie <= 0 ):
		Audio.get_node("HitSound").play();
		DamageTakeTimerZombie = DamageTakeTimeZombie; 
		SpawnDeadBloodAsTakeDamage(3);  
		BloodValue -= 0.05;
		BloodValue = clamp(BloodValue, 0, BloodValueMax);
	
func TakeSpikeDamage(): 
	if( DamageTakeTimerSpike <= 0 ):
		Audio.get_node("HitSound").play();
		DamageTakeTimerSpike = DamageTakeTimeSpike;
		SpawnDeadBloodAsTakeDamage(10);  
		BloodValue -= 0.25;
		BloodValue = clamp(BloodValue, 0, BloodValueMax);

func HealFromFountain():  
	BloodValue += FontainHealing * get_process_delta_time();
	BloodValue = clamp(BloodValue, 0, BloodValueMax);
	
func HealFromPotion():
	Audio.get_node("PotionSound").play();
	BloodValue += PotionHeal
	BloodValue = clamp(BloodValue, 0, BloodValueMax);

func _ready():
	
	Audio = get_node("SoundManager");
	
	BloodValue = BloodValueMax;
	
	for kiddo in get_node("Spikes").get_children(): 
		kiddo.connect("ToPlayer", self, "TakeSpikeDamage");

	for kiddo in get_node("Zombies").get_children(): 
		kiddo.connect("ToPlayer", self, "TakeZombieDamage");
		
	for kiddo in get_node("Potions").get_children(): 
		kiddo.connect("ToPlayer", self, "HealFromPotion");
		
	for kiddo in get_node("Fountains").get_children(): 
		kiddo.connect("ToPlayer", self, "HealFromFountain");
		
func _process(delta):  
	
	if(  !DeadCanTick ):
		if( BloodValue <= 0 || get_node("BloodMage").position.y > 256 ):
			get_node("BloodMage").Dead = true;
			DeadCanTick = true;
			get_node("UI").get_node("Meter").value = 0;
			Audio.get_node("DeadSound").play();
	
	if( TeleportCanTick ):
		if( TeleportTimer <= 0 ):
			emit_signal("ToMainManger");
		else:
			TeleportTimer -= delta;
			get_node("BloodMage").global_position = get_node("Gate").get_node("Center").global_position;
			
			var scaleVal = get_node("BloodMage").scale.x - delta/3;
			get_node("BloodMage").rotation_degrees += delta * 360 * ( 2 - scaleVal ); 
			get_node("BloodMage").scale = Vector2(scaleVal,scaleVal);
			
	if( DeadCanTick ):
		if( DeadTimer <= 0 ):
			emit_signal("ToMainMangerReset");
		else:
			get_node("BloodMage").global_position += Vector2(0, -512 * delta );
			
			if( fmod(DeadTimer, 0.2) < 0.03 ):
				SpawnDeadBloodAsTakeDamage((DeadTimer*10));  
			DeadTimer -= delta; 
			var scaleVal = get_node("BloodMage").scale.x - delta/3;
			get_node("BloodMage").rotation_degrees += delta * 360 * ( 2 - scaleVal ); 
			get_node("BloodMage").scale = Vector2(scaleVal,scaleVal); 
	else:
		get_node("UI").get_node("Meter").value = lerp(get_node("UI").get_node("Meter").value, BloodValue,  clamp(delta * 3, 0, 1));
		
	if( DamageTakeTimerZombie > 0 ):
		DamageTakeTimerZombie -= delta; 
	if( DamageTakeTimerSpike > 0 ):
		DamageTakeTimerSpike -= delta;
		
	    
	IsCasting = false;  
	
	if( get_node("BloodMage").position.distance_to(get_local_mouse_position()) < 128 ):
		if( Input.is_mouse_button_pressed(BUTTON_LEFT)):  
			var Raising = false;
			for raisin in get_node("Raisins").get_children(): 
				if( raisin.GetSuckable() ): 
					ControlledRaisin = raisin; 
					Raising = true;
					break;
			if( Raising ):
				CanSpawnNewBlood = false;
				IsCasting = true;
			elif( get_node("Gate").GetSuckable()): 
				IsCasting = true; 
				BloodValue += get_node("Gate").AddBlood(BloodValueMax * delta, BloodValue);
				BloodValue = clamp(BloodValue, 0, BloodValueMax);
				CanSpawnNewBlood = false;
			elif ( CanSpawnNewBlood ):
				IsCasting = true;
				SpawnNewBloodTile();
				CanSpawnNewBlood = false;
		else:
			CanSpawnNewBlood = true;
			ControlledRaisin = null;
			
		if( Input.is_mouse_button_pressed(BUTTON_RIGHT)):
			var Zombing = false;
			for zombie in get_node("Zombies").get_children(): 
				if( zombie.GetSuckable() ): 
					BloodValue += zombie.RemoveBlood(BloodValueMax * delta);
					BloodValue = clamp(BloodValue, 0, BloodValueMax); 
					Zombing = true;
					break;
			if( Zombing ):
				IsCasting = true;
			elif( get_node("Gate").GetSuckable()): 
				BloodValue += get_node("Gate").RemoveBlood(BloodValueMax * delta);
				BloodValue = clamp(BloodValue, 0, BloodValueMax);
				IsCasting = true;
			else:
				for drop in get_node("BloodDrops").get_children():
					if( drop.position.distance_to(get_local_mouse_position()) < 32): 
						drop.queue_free(); 
						BloodValue = clamp( BloodValue+BloodCost/10, 0, BloodValueMax);
						IsCasting = true;
				for tile in get_node("BloodTiles").get_children():
					if( tile.position.distance_to(get_local_mouse_position()) < 32):
						tile.LifeTimer -= delta * 5; 
						IsCasting = true;
	else:
		 ControlledRaisin = null;
		
	if( !CanSpawnNewBlood ):
		if( ControlledRaisin):  
			ControlledRaisin.SetPosition(get_local_mouse_position());  
		
	get_node("BloodMage").SetCasting(IsCasting);
	
	
func SpawnBloodDrop(var object ):
	for i in 10:
		var NewBlood = BloodDrop.instance();
		NewBlood.position = object.position + Vector2(rand_range(-8,8),rand_range(-8,8)); 
		get_node("BloodDrops").add_child(NewBlood);
	
func SpawnNewBloodTile(): 
	if( BloodValue >= BloodCost ):
		Audio.get_node("BloodTileSound").play();
		BloodValue = clamp( BloodValue-BloodCost, 0, BloodValueMax);
		var NewBloodTile = Tile.instance();
		NewBloodTile.position = get_local_mouse_position();
		get_node("BloodTiles").add_child(NewBloodTile);
		
func SpawnDeadBloodAsTakeDamage(var Amount):
	for i in Amount:
		var NewBlood = DeadBlood.instance();
		NewBlood.position = get_node("BloodMage").position  + Vector2(rand_range(-Amount,Amount),rand_range(-Amount,Amount)); 
		get_node("DeadBloods").add_child(NewBlood);
	
func SpawnDeadBlood(var object): 
	var NewBlood = DeadBlood.instance();
	NewBlood.position = object.position;
	get_node("DeadBloods").add_child(NewBlood);
	
func SpawnRaisin(var object): 
	Audio.get_node("WeeDead").play();
	var NewRaisin = Raisin.instance();
	NewRaisin.position = object.position;
	get_node("Raisins").add_child(NewRaisin);