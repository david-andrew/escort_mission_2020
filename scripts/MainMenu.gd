extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
#	var score_label = $HUD.get_node("Score")
#	GameMaster.score_label = score_label
	pass


func _on_Button_pressed():
	GameMaster.goto_next_level()
	
func _process(delta):
	#check if user updated volumes? I think signals...
#	AudioServer.
	pass
	



func _on_Music_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)


func _on_SFX_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("FX"), value)
