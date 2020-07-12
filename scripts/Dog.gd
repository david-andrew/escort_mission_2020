#extends KinematicBody2D
#
#var max_speed = 500
#var acceleration = 5
#var speed = 0
#var rotation_rate = deg2rad(500)
#var velocity = Vector2.RIGHT
#
#
#var screen_width = ProjectSettings.get_setting('display/window/size/width')
#var screen_height = ProjectSettings.get_setting('display/window/size/height')
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#	$AnimatedSprite.play()
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if Input.is_action_pressed("ui_right"):
#		velocity = velocity.rotated(rotation_rate * delta)
#	elif Input.is_action_pressed("ui_left"):
#		velocity = velocity.rotated(-rotation_rate * delta)
#	elif Input.is_action_pressed("ui_down"):
#		speed -= acceleration
#	elif Input.is_action_pressed("ui_up"):
#		speed += acceleration
#
#	speed = clamp(speed, 0, max_speed)
#
#	if speed > 5:
#		$AnimatedSprite.animation = 'walking'
#	else:
#		$AnimatedSprite.animation = 'idle'
#
#func _physics_process(delta):
#	move_and_collide(velocity * speed * delta)
#	keep_within_bounds(delta)
#	face_forwards()
#
#
## make the boid face the direction it is moving
#func face_forwards():
#	velocity = velocity.normalized()
#	rotation = Vector2.UP.angle_to(velocity)
#
#
#func keep_within_bounds(delta):
#	var margin = 20
#	var turn_factor = 10
#
#	if position.x < margin:
#		velocity = (velocity + Vector2.RIGHT * turn_factor * delta).normalized()
#	if position.x > screen_width - margin:
#		velocity = (velocity + Vector2.LEFT * turn_factor * delta).normalized()
#	if position.y < margin:
#		velocity = (velocity + Vector2.DOWN * turn_factor * delta).normalized()
#	if position.y > screen_height - margin:
#		velocity = (velocity + Vector2.UP * turn_factor * delta).normalized()
#
#
