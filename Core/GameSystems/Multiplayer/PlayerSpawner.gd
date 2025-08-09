extends MultiplayerSpawner

@onready var spawn_points = $SpawnPoints.get_children()
var player_scene = preload("res://Core/GameSystems/Experimental/Player.tscn")

func _ready():
	if spawn_points.size() == 0:
		push_error("No spawn points defined in SpawnPoints node!")
	spawn_function = spawn_player

func spawn_player(data: Dictionary):
	var player = player_scene.instantiate()
	player.name = str(data.id)
	player.username = data.username
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	player.position = spawn_point.global_position
	player.set_username(data.username)
	return player
