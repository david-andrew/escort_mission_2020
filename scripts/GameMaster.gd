extends Node


var current_scene = null

# coordinates where eaten and escaped sheep go
const eaten_coordinates = Vector2(2000, 540)


#Global Game Variables
const sheep_at_start = 80
var current_sheep = sheep_at_start #start the game with 20 sheep
var sheep_eaten = 0
var sheep_escape = 0
var current_scene_i = 0

# stats for title screen
var prev_eaten = 0
var prev_score = 0

#var score_label: Label = null #set by main menu on _ready()

# reset everything back for a new game
func game_over(goto_main_menu=true):
#	if sheep_escape > best_score:
    prev_score = sheep_escape
    prev_eaten = sheep_eaten
    
    current_sheep = sheep_at_start
    sheep_eaten = 0
    sheep_escape = 0
    current_scene_i = 0
    

    if goto_main_menu:
        goto_scene(0) # goto the main menu
    

const scene_paths = [
    'res://scenes/MainMenu.tscn',
    'res://scenes/Level1Easy.tscn',
    'res://scenes/Level2Easy.tscn',
    'res://scenes/Level3Easy.tscn',
    'res://scenes/Level4Easy.tscn',
    'res://scenes/Level5Easy.tscn'
]

# Called when the node enters the scene tree for the first time.
func _ready():
    print('hello from the game master')
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)


func _process(delta):
    #handle swapping between scenes
    var change_scene = false
    
    if Input.is_key_pressed(KEY_F1):
        current_scene_i = 1
        change_scene = true
    elif Input.is_key_pressed(KEY_F2):
        current_scene_i = 2
        change_scene = true
    elif Input.is_key_pressed(KEY_F3):
        current_scene_i = 3
        change_scene = true
    elif Input.is_key_pressed(KEY_F4):
        current_scene_i = 4
        change_scene = true
    elif Input.is_key_pressed(KEY_F5):
        current_scene_i = 5
        change_scene = true
    elif Input.is_key_pressed(KEY_F6):
        current_scene_i = 0 # loop back to main menu
        change_scene = true
        
    if change_scene:
        GameMaster.goto_scene(current_scene_i)

func goto_next_level():
    current_scene_i = (current_scene_i + 1) % scene_paths.size()
    goto_scene(current_scene_i)
    
    
func goto_scene(i):
    # This function will usually be called from a signal callback,
    # or some other function in the current scene.
    # Deleting the current scene at this point is
    # a bad idea, because it may still be executing code.
    # This will result in a crash or unexpected behavior.

    # The solution is to defer the load to a later time, when
    # we can be sure that no code from the current scene is running:
    if i == 0:
        game_over(false)
    
    var path = scene_paths[i]
    call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
    
    
    # It is now safe to remove the current scene
    current_scene.free()

    # Load the new scene.
    var s = ResourceLoader.load(path)

    # Instance the new scene.
    current_scene = s.instance()

    # Add it to the active scene, as child of root.
    get_tree().get_root().add_child(current_scene)

    # Optionally, to make it compatible with the SceneTree.change_scene() API.
    get_tree().set_current_scene(current_scene)
    
    if current_scene_i == 0:
#			#update main menu score
#	if score_label != null:
        var score_label: Label = current_scene.get_child(0).get_child(1)
        score_label.text = "Congratulations! You only lost:\n" + str(prev_eaten) + " sheep"
        score_label.modulate = Color(1,1,1,1)
    



func eat_sheep(sheep):
    #handle placing a sheep in the out of bounds location
    sheep.position = eaten_coordinates
    sheep.set_eaten(true)
    sheep.set_process(false) #disable the sheep	
    GameMaster.sheep_eaten += 1
    GameMaster.current_sheep -= 1
    
func escape_sheep(sheep):
    #handle placing sheep in the escaped location
    sheep.position = eaten_coordinates	
    sheep.set_eaten(true) #force to stop moving
    sheep.set_process(false) #disable the sheep	
    sheep_escape += 1

