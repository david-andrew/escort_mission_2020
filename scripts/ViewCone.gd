extends Node2D



func _draw():
	
	var sight_range = get_parent().get_boid_sight_range() + 20
	var sight_angle = get_parent().get_boid_sight_angle()
	var from = rad2deg(-sight_angle)
	var to = rad2deg(sight_angle)
	var color = Color(1.0, 0, 0, 0.25)
	draw_circle_arc_poly(Vector2.ZERO, sight_range, from, to, color)

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
