extends Node2D

var packed_boid = preload('res://scenes/Boid.tscn');

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var num_boids = 0	#number of boids to add to the scene at the start
var boids = [] 				# array of all boid objects
#var distances = [] 			# 2D array of the difference vectors between every combination of boids
#
#export var max_sheep_speed = 10
#export var max_sheep_rotation_deg = 10
#export var min_sheep_dist = 40


var CoM = Vector2(0,0) setget set_CoM, get_CoM

func set_CoM(new_CoM):
	CoM = new_CoM
	
func get_CoM():
	return CoM



# Called when the node enters the scene tree for the first time.
func _ready():
	num_boids = GameMaster.current_sheep
#	GameMaster.sheep_at_start = num_boids #tell the game master we are starting a level with 
	create_boids()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# update the boids every physics process delta
func _physics_process(delta):
	update_CoM()
	check_level_complete()


func create_boids():
	#randomly initialize a bunch of boids in the space
	var width = ProjectSettings.get_setting('display/window/size/width')
	var height = ProjectSettings.get_setting('display/window/size/height')
	
	for i in range(num_boids):
		var boid = packed_boid.instance()
		
		#set random positions and rotatiosns for each of the boids
		var spawn_width = 330
		var spawn_height = height - 100
		boid.position = Vector2(randi() % spawn_width, randi() % spawn_height)
		boid.rotation = deg2rad(randi() % 360)
		
		#store the boid object in our array, and also add to this scene
		boids.push_back(boid)
		add_child(boid)
		
		
	
	
#	#initialize the distances vector with the distance between every boid
#	for boid_i in boids:
#		var distances_i = []
#		for boid_j in boids:
#			distances_i.push_back(boid_j.position - boid_i.position)
#		distances.push_back(distances_i)
#


func update_CoM():
	CoM = Vector2.ZERO
	for boid in boids:
		CoM += boid.position
	CoM /= boids.size()


#func update_distances():
#	for i in range(boids.size()):
#		for j in range(boids.size()):
#			var boid_i = boids[i]
#			var boid_j = boids[j]
#			distances[i][j] = boid_j.position - boid_i.position
#
#func fly_towards_center(boid, i):
#	pass
#
#func avoid_other_boids(boid, i):
#	pass
#
#func match_velocity(boid, i):
#	pass
#
#func limit_speed(boid): #this probably should go in the boid object itself
#	pass
#
#func keep_within_bounds(boid): #this also should probably go in the boid object itself
#	pass
#
#
#func update_boid(i):
#	var boid = boids[i]
#	#collect a list of the boids within some threshold distance
#
#func update_boids():
#	for i in range(boids.size()):
#
##		fly_toward_center(boid, i)
##		avoid_other_boids(boid, i)
##		match_velocity(boid, i)
##		limit_speed(boid)
##		keep_within_bounds(boid) #todo->make a sort of bondary mask that says where the boids may exit the screen from
#		pass
#	pass

func check_level_complete():
	if GameMaster.sheep_escape == GameMaster.current_sheep:
		GameMaster.sheep_escape = 0 #reset number of escaped sheep
		GameMaster.goto_next_level()
