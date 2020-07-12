extends KinematicBody2D


var close_boids = {}	# set (dict) to keep track of boids that are nearby. add new boids on_body_entered, and remove on_body_exited
var close_dogs = {}		# keep track of player characters that come near the boids
var close_wolves = {}	# keep track of wolf characters that come near the boids
var close_obstacles = {}# keep track of obstacles that the boids go near

var target_speed = 50 setget set_target_speed, get_target_speed #TBD if we need the setget... perhaps on init only?
var min_velocity = 1
var max_acceleration = 10
var velocity = Vector2() setget set_velocity, get_velocity

export var boid_peripheral_range = 270
var boid_sight_angle = deg2rad(boid_peripheral_range / 2)
export var dog_peripheral_range = 320
var dog_sight_angle = deg2rad(dog_peripheral_range / 2)
export var wolf_peripherial_range = 270
var wolf_sight_angle = deg2rad(wolf_peripherial_range / 2)

var eaten = false setget set_eaten, get_eaten

var screen_width = ProjectSettings.get_setting('display/window/size/width')
var screen_height = ProjectSettings.get_setting('display/window/size/height')


var baah_prob = 0.0001


#setters and getters
func set_target_speed(speed):
	target_speed = speed

func get_target_speed():
	return target_speed
	
func set_velocity(new_velocity):
	velocity = new_velocity

func get_velocity():
	return velocity
	
func set_eaten(new_eaten):
	eaten = new_eaten
	
func get_eaten():
	return eaten

# Called when the node enters the scene tree for the first time.
func _ready():
	#make sure the boids have some initial velocity
	apply_min_velocity()
	
	#set the animation to a random frame
	$AnimatedSprite.frame = randi() % $AnimatedSprite.frames.get_frame_count('walking')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	if not eaten:
		#if the boid is not moving at target speed, have them change speed
		if velocity.length() < target_speed:
			velocity += velocity.normalized() * max_acceleration * delta
		
		#update the boid relative to the boid rules
		apply_boid_rules(delta)
		
		#prevent the boid from going faster than the target speed
		limit_speed()
		
		#ensure that the boid is pointed in the direction it is moving
		face_forwards()
		
		#move the kinematic body based on the current velocity
		move_and_collide(velocity * delta)
		
		baah()
		
func baah():
	if randf() < baah_prob:
		$AudioStreamPlayer.play()

# signals for detecting proximity to nearby objects (e.g. other boids, dogs, wolves, etc.)
func _on_BoidProximityDetector_body_entered(body):
	close_boids[body] = body
func _on_BoidProximityDetector_body_exited(body):
	close_boids.erase(body)
func _on_DogProximityDetector_body_entered(body):
	close_dogs[body] = body
func _on_DogProximityDetector_body_exited(body):
	close_dogs.erase(body)
func _on_ObstacleProximityDetector_body_entered(body):
	close_obstacles[body] = body
func _on_ObstacleProximityDetector_body_exited(body):
	close_obstacles.erase(body)
func _on_WolfProximityDetector_body_entered(body):
	close_wolves[body] = body
func _on_WolfProximityDetector_body_exited(body):
	close_wolves.erase(body)



# make the boid move at some minimum velocity
func apply_min_velocity():
#	var tf = get_transform()
#	velocity = tf.basis_xform(Vector2.UP * min_velocity)
	#point the sheep in a random direction
	velocity = Vector2(randf()*2 -1, randf()*2-1).normalized() * min_velocity


# make the boid face the direction it is moving
func face_forwards():
	if velocity.length() > 0.1:
		rotation = Vector2.UP.angle_to(velocity)
	

func apply_boid_rules(delta):
	#using all the boids in the close boids dict, apply boids rules
	#perhaps may need a global center of mass calculated by the world scene
	fly_towards_center(delta)
	avoid_other_boids(delta)
	match_velocity(delta)
#	keep_within_bounds(delta) #todo->make a sort of bondary mask that says where the boids may exit the screen from
	avoid_dogs(delta)
	avoid_obstacles(delta)
	avoid_wolves(delta)
	escape_map()

func avoid_dogs(delta):
	var avoid_factor = 100000
	
	var avoid_force = Vector2(0, 0)
	
	for dog in close_dogs.keys():
		var pos_diff = dog.position - position
		
		if not velocity.angle_to(pos_diff) < dog_sight_angle:
			continue
		
		var force = pos_diff.normalized() / pos_diff.length()
		
		if is_nan(force.x) or is_nan(force.y):
			continue
		
		avoid_force += -force
		
	velocity += avoid_force * avoid_factor * delta
	
func get_closest_point_to_obstacle(obstacle):
	var collision_rectangle: CollisionShape2D = obstacle.get_child(0)
	var collision_shape: RectangleShape2D = collision_rectangle.shape
	var rotation = collision_rectangle.transform.get_rotation()
	var extents = collision_shape.extents.rotated(rotation)
	var s1 = obstacle.position + extents
	var s2 = obstacle.position - extents
	
	var o_pos = obstacle.position
	var s_pos = position
	
	var closest_point = Geometry.get_closest_point_to_segment_2d(position, s1, s2)
	var alt_extents = Vector2(extents.x, -extents.y)
	var alt_s1 = obstacle.position + alt_extents
	var alt_s2 = obstacle.position - alt_extents
	var alt_closest_point = Geometry.get_closest_point_to_segment_2d(position, alt_s1, alt_s2)
	
	var pos_diff = closest_point - position
	var alt_pos_diff = alt_closest_point - position
	if pos_diff.length_squared() < alt_pos_diff.length_squared():
		return closest_point
	else:
		return alt_closest_point
		
func avoid_obstacles(delta):
	var avoid_factor = 100000

	var avoid_force = Vector2(0, 0) #accumulate the force applied by nearby boids

	for obstacle in close_obstacles.keys():
		var obstacle_position = get_closest_point_to_obstacle(obstacle)
		var pos_diff = obstacle_position - position
		var force = pos_diff.normalized() / pos_diff.length_squared()
		if is_nan(force.x) or is_nan(force.y):
			continue

		avoid_force += -force

	velocity += avoid_force * avoid_factor * delta


func avoid_wolves(delta):
	var avoid_factor = 5000
	var avoid_force = Vector2(0, 0)
	for wolf in close_wolves.keys():
		var pos_diff = wolf.position - position
		if not velocity.angle_to(pos_diff) < dog_sight_angle:
			continue
		var force = pos_diff.normalized() / pos_diff.length()
		if is_nan(force.x) or is_nan(force.y):
			continue
		avoid_force += -force
	velocity += avoid_force * avoid_factor * delta
	pass


func fly_towards_center(delta):
	var centering_factor = 0.01
	
	var CoM = get_parent().get_CoM()
	
	velocity += (CoM - position) * centering_factor * delta
	
	
func avoid_other_boids(delta):
	var avoid_factor = 100000
	
	var avoid_force = Vector2(0, 0) #accumulate the force applied by nearby boids
	
	for boid in close_boids.keys():
		var pos_diff = boid.position - position
		
		#skip boids that are outside of the field of view
		if not velocity.angle_to(pos_diff) < boid_sight_angle:
			continue
		
		#apply an impulse to the velocity
		var force = pos_diff.normalized() / pos_diff.length_squared()
		
		#skip errornous forces
		if is_nan(force.x) or is_nan(force.y):
			continue
		
		avoid_force += -force
	
	velocity += avoid_force * avoid_factor * delta



func match_velocity(delta):
	var matching_factor = 1
	
	var avg_velocity = Vector2(0, 0) #accumulate the velocities of all surrounding boids
	
	var neighbor_count = 0
	for boid in close_boids.keys():
		var pos_diff = boid.position - position
		
		if not velocity.angle_to(pos_diff) < boid_sight_angle:
			continue
			
		avg_velocity += boid.get_velocity()
		neighbor_count += 1
		
	if neighbor_count > 0:
		velocity += avg_velocity / neighbor_count * matching_factor * delta
	
		
		

func limit_speed():
	#clamp the velocity to a max speed
	velocity = velocity.clamped(target_speed)


func escape_map():
	if position.x >= screen_width:
		GameMaster.escape_sheep(self)
		
