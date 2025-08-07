extends Node3D

@onready var multiplayer_spawner = $MultiplayerSpawner

func _ready():
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(id: int):
	# Server spawns the new player
	var player_data = { "id": id, "username": MultiplayerManager.player_info[id] }
	multiplayer_spawner.spawn(player_data)
