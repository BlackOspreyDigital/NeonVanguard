extends Node

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int):
	if multiplayer.is_server():
		var data = {
			"id": id,
			"username": SaveSystem.current_username if id == multiplayer.get_unique_id() else "Player" + str(id)
		}
		var spawner = get_node("/root/sandbox/PlayerSpawner")
		if spawner:
			spawner.spawn_player(data)

func _on_peer_disconnected(id: int):
	if multiplayer.is_server():
		var player_node = get_node_or_null("/root/sandbox/" + str(id))
		if player_node:
			player_node.queue_free()
