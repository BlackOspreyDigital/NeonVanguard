extends Node3D

@onready var multiplayer_spawner = $MultiplayerSpawner

func _ready():
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)
		# Spawn host player immediately
		if MultiplayerManager.player_info.has(multiplayer.get_unique_id()):
			var player_data = { "id": multiplayer.get_unique_id(), "username": MultiplayerManager.player_info[multiplayer.get_unique_id()] }
			multiplayer_spawner.spawn(player_data)

func _on_peer_connected(id: int):
	var player_data = { "id": id, "username": MultiplayerManager.player_info.get(id, "Unknown") }
	multiplayer_spawner.spawn(player_data)
