extends KinematicBody2D

var close_sheep = {}	# set (dict) to keep track of boids that are nearby. add new boids on_body_entered, and remove on_body_exited
var close_dogs = {}		# keep track of player characters that come near the boids
var close_obstacles = {}# keep track of obstacles that the boids go near

# wolf vision angle parameters
export var boid_peripheral_range = 70
var boid_sight_angle = deg2rad(boid_peripheral_range / 2) setget set_boid_sight_angle, get_boid_sight_angle
var boid_sight_range = 150 setget set_boid_sight_range, get_boid_sight_range
export var dog_peripheral_range = 360
var dog_sight_angle = deg2rad(dog_peripheral_range / 2)


var patrol_speed = 30
var run_speed = 70
var speed = patrol_speed
var target_speed = patrol_speed
var max_speed = 100
var forward = Vector2.UP.rotated(deg2rad(randi() % 360)) #start facing a random direction
var patrol_rotation_rate = deg2rad(60)

var max_acceleration = 10

enum State {PATROL, CHASE, EAT}
var state = State.PATROL

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("walking")
	$SheepProximityDetector/CollisionShape2D.shape.radius = boid_sight_range



func set_boid_sight_range(new_range):
	boid_sight_range = new_range
	
func get_boid_sight_range():
	return boid_sight_range

func set_boid_sight_angle(new_angle):
	boid_sight_angle = new_angle
	
func get_boid_sight_angle():
	return boid_sight_angle

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



# tasks
# avoid obstacles
# avoid dogs
# detect sheep with narrow view cone 
# chase sheep
# show view cone
# eat sheep

func _physics_process(delta):
	#if the wolf is not moving at target speed, have them change speed
	if speed < target_speed:
		speed += max_acceleration * delta
	elif speed > target_speed:
		speed -= max_acceleration * delta
	#prevent the wolf from going faster than the target speed
	speed = clamp(speed, 0, max_speed)
	
	#make the wolf move according to the wolf rules
	apply_wolf_rules(delta)
	#ensure that the wolf is pointed in the direction it is moving
	face_forwards()
	
	#move the kinematic body based on the current velocity
	var velocity = forward * speed
	move_and_collide(velocity * delta)

func apply_wolf_rules(delta):
	#update the velocity vector based on the state
	match state:
		State.PATROL:
			target_speed = patrol_speed
			forward = forward.rotated(patrol_rotation_rate * delta)
			#apply forces/etc.
			
		State.CHASE:
			target_speed = run_speed
			pass
			#apply forces/etc.
		State.EAT:
			target_speed = 0
			pass
			#don't apply forces while eating, since we stay put? but what about sheep dog chasing us away?
	
	avoid_dogs(delta)
	avoid_obstacles(delta)
	chase_sheep(delta)


func avoid_dogs(delta):
	var avoid_factor = 100000
	
	var avoid_force = Vector2(0, 0)
	
	for dog in close_dogs.keys():
		var pos_diff = dog.position - position
		if not forward.angle_to(pos_diff) < dog_sight_angle:
			continue
		var force = pos_diff.normalized() / pos_diff.length()
		if is_nan(force.x) or is_nan(force.y):
			continue
		avoid_force += -force
		
	if speed > 0.1:
		var velocity = forward * speed
		velocity += avoid_force * avoid_factor * delta
		speed = velocity.length()
		forward = velocity.normalized()
		
func avoid_obstacles(delta):
	var avoid_factor = 1000000
	
	var avoid_force = Vector2(0, 0) #accumulate the force applied by nearby boids
	
	for obstacle in close_obstacles.keys():
		var pos_diff = obstacle.position - position
		var force = pos_diff.normalized() / pos_diff.length_squared()
		if is_nan(force.x) or is_nan(force.y):
			continue
			
		avoid_force += -force
	
	if speed > 0.1:
		var velocity = forward * speed
		velocity += avoid_force * avoid_factor * delta
		speed = velocity.length()
		forward = velocity.normalized()
	
func chase_sheep(delta):
	#simply point towards closest sheep
	var best_distance = 99999999999
	var closest_sheep = null
	var sheeps = close_sheep.keys()
	for i in range(sheeps.size()):
		var sheep = sheeps[i]
		var distance = (sheep.position - position).length()
		if distance < best_distance:
			best_distance = distance
			closest_sheep = sheep
	
	#point to the closest sheep if it exists
	if closest_sheep != null:
		if best_distance < 10:
			eat_sheep(closest_sheep)
			#eat sheep
		else:
			forward = (closest_sheep.position - position).normalized() #point toward sheep
		
	
	
func eat_sheep(sheep):
	GameMaster.eat_sheep(sheep)
	
	$AudioStreamPlayer.play()
	
	#reset the game
	if GameMaster.current_sheep == 0:
		GameMaster.game_over()
		



# make the boid face the direction it is moving
func face_forwards():
	forward = forward.normalized()
	rotation = Vector2.UP.angle_to(forward)
	
# signals for detecting proximity to nearby objects (e.g. other boids, dogs, wolves, etc.)
func _on_SheepProximityDetector_body_entered(body):
	#check if the sheep is within the view cone before we add it
	var pos_diff = body.position - position
	if forward.angle_to(pos_diff) < boid_sight_angle: #skip sheep not in the view cone	
		close_sheep[body] = body
		state = State.CHASE
func _on_SheepProximityDetector_body_exited(body):
	close_sheep.erase(body)
	if close_sheep.size() == 0:
		state = State.PATROL
func _on_DogProximityDetector_body_entered(body):
	close_dogs[body] = body
func _on_DogProximityDetector_body_exited(body):
	close_dogs.erase(body)
func _on_ObstacleProximityDetector_body_entered(body):
	close_obstacles[body] = body
func _on_ObstacleProximityDetector_body_exited(body):
	close_obstacles.erase(body)
