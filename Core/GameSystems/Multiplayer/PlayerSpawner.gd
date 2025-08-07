extends Node

@onready var spawn_points = $SpawnPoints.get_children()
var player_scene = preload("res://Core/GameSystems/Experimental/Player.tscn")

func _ready():
	if spawn_points.size() == 0:
		push_error("No Spawn points defined in SpawnPoints node!")
		
func spawn_player(data: Dictionary):
	var player = str(data.id)
	player.name = data.username
	# Choose a random spawn point
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	player.postition = spawn_point.global_position
	player.set_username(data,username)
	return player
