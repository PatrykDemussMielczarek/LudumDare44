extends Node2D

var maps = [load("res://MapaLevelStart.tscn"),load("res://MapaLevel1.tscn"),load("res://MapaLevel2.tscn"),load("res://MapaLevel3.tscn"), load("res://Mapa.tscn"), load("res://MapaLevel4.tscn"), load("res://MapaLevelEnd.tscn")];

var MapIndex = 0
var RPressed = false;

var GameTimer = 0;

var NewMap;

func _ready(): 
	get_node("Background").playing = true;
	get_node("Background").play();# = true;
	SpawnMap();
	
func NextMap():
	MapIndex += 1;
	if( MapIndex < maps.size()): 
		SpawnMap();
	else:
		print("No more maps");
		
func SpawnMap():
	for kid in get_node("Maps").get_children():
		kid.queue_free();
	NewMap = maps[MapIndex].instance(); 
	get_node("Maps").add_child(NewMap);
	NewMap.connect("ToMainManger", self, "NextMap");
	NewMap.connect("ToMainMangerReset", self, "ReloadMap");
	
func ReloadMap():
	SpawnMap();
	
func _process(delta): 
	
	if( MapIndex > 0 && MapIndex < maps.size()-1):
		GameTimer += delta; 
			
	var secondsValue = GameTimer;
	var hour = int(secondsValue/3600);
	secondsValue -= 3600 * hour;
	var minutes = int(secondsValue/60);
	secondsValue -= 60 * minutes;
	var seconds = int(secondsValue);
	
	var minutesPrefix = ""
	if( minutes < 10 ):
		minutesPrefix = "0"
		
	var secondsPrefix = ""
	if( seconds < 10 ):
		secondsPrefix = "0"
		
	get_node("Time/Display").text = str(hour) + ":" + minutesPrefix +  str(minutes) + ":" + secondsPrefix +  str(seconds);
 

	if( Input.is_key_pressed(KEY_R)): 
		if( !RPressed ):
			ReloadMap();
			RPressed = true;
	else:
		RPressed = false;