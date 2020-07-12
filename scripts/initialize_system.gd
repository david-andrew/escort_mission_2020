#extends Node2D
#
#
## Declare member variables here. Examples:
## var a = 2
## var b = "text"
#
##system parameters
#var x = []
#var y = []
#var vx = []
#var vy = []
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#	load_initial_conditions()
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta):
##	pass
#
#
##load in the json file
#func load_initial_conditions():
#	#read in the json file with the initial conditions of different orbit initial conditions
#	var file = File.new()
#	file.open('res://initial_conditions.json', File.READ)
#
#	var initial_conditions = JSON.parse(file.get_as_text()).result
#	var inits = initial_conditions['inits']
#
#	#select a random initial condition set
#	var init = inits[randi() % inits.size()]['init']
#
#	#set up bodies at each initial condition 
#	for i in range(3):
#		x[i] = init[i*2]
#		y[i] = init[1 + i*2]
#		vx[i] = init[6 + i*2] 
#		vy[i] = init[7 + i*2]
#
#	pass
#
