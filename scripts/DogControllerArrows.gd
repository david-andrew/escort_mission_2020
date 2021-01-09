extends KinematicBody2D

var max_speed = 400

# Called when the node enters the scene tree for the first time.
func _ready():
    $AnimatedSprite.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
    var down = Input.is_key_pressed(KEY_DOWN) # or Input.is_key_pressed(KEY_)
    var up = Input.is_key_pressed(KEY_UP) # or Input.is_key_pressed(KEY_)
    var left = Input.is_key_pressed(KEY_LEFT) # or Input.is_key_pressed(KEY_)
    var right = Input.is_key_pressed(KEY_RIGHT) # or Input.is_key_pressed(KEY_)
    
    if up != down or left != right:
        $AnimatedSprite.animation = 'walking'
        
        var direction = Vector2.ZERO
        if up:
            direction += Vector2.UP
        if down:
            direction += Vector2.DOWN
        if left:
            direction += Vector2.LEFT
        if right:
            direction += Vector2.RIGHT
            
        var velocity = direction.normalized() * max_speed
        rotation = Vector2.UP.angle_to(direction)
        move_and_collide(velocity * delta)
        
        if $AudioStreamPlayer.playing != true:
            $AudioStreamPlayer.play()
        
    else:
        $AnimatedSprite.animation = 'idle'
        if $AudioStreamPlayer.playing != false:
            $AudioStreamPlayer.stop()
