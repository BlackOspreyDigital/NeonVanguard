extends Node3D

@onready var multiplayer_spawner = $MultiplayerSpawner
var player_scene = preload("res://Core/GameSystems/Experimental/Player.tscn")

func _ready():
	multiplayer_spawner.spawn_function = spawn_player

func spawn_player(data: Dictionary):
	var player = player_scene.instantiate()
	player.name = str(data.id)
	player.username = data.username
	player.position = Vector3(randi_range(-5, 5), 0, randi_range(-5, 5)) # Random spawn
	player.set_username(data.username)
	return player
