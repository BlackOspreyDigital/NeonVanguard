extends Node

func _ready():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(4242, 8)
	get_tree().get_multiplayer().multiplayer_peer = peer
	get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)
	get_tree().get_multiplayer().peer_disconnected.connect(_on_peer_disconnected)
	print("Server started on port 4242")

func _on_peer_connected(id):
	print("Player connected: ", id)
	var game = load("res://Core/GameSystems/Multiplayer/SquadronDeathmatch.tscn").instantiate()
	game.name = "Game"
	add_child(game)
	game.spawn_player(id, get_tree().get_nodes_in_group("players").size())

func _on_peer_disconnected(id):
	print("Player disconnected: ", id)
	var player = get_node_or_null(str(id))
	if player:
		player.queue_free()
