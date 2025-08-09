extends Node

const DEFAULT_PORT = 4242
const MAX_PLAYERS = 8

var peer = ENetMultiplayerPeer.new()
var player_info = {}

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game(username: String, team: String = "TeamA"):
	player_info[multiplayer.get_unique_id()] = { "username": username, "team": team }
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	print("Hosting game as ", username, ", team: ", team)
	if multiplayer.is_server():
		var spawner = get_node_or_null("/root/SquadronDeathmatch/MultiplayerSpawner")
		if spawner:
			spawner.spawn({ "id": multiplayer.get_unique_id(), "username": username, "team": team })

func join_game(address: String, port: int, username: String, team: String = "TeamA"):
	player_info[multiplayer.get_unique_id()] = { "username": username, "team": team }
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	print("Joining game as ", username, ", team: ", team)

func _on_peer_connected(id: int):
	print("Player connected: ", id)
	if multiplayer.is_server():
		rpc("register_player", id, player_info.get(multiplayer.get_unique_id(), {}).get("username", "Unknown"))
		var spawner = get_node_or_null("/root/SquadronDeathmatch/MultiplayerSpawner")
		if spawner:
			spawner.spawn({ "id": id, "username": player_info.get(id, {}).get("username", "Unknown"), "team": player_info.get(id, {}).get("team", "TeamA") })

func _on_peer_disconnected(id: int):
	print("Player disconnected: ", id)
	player_info.erase(id)
	remove_player(id)

func _on_connected_to_server():
	print("Connected to server as ", player_info[multiplayer.get_unique_id()]["username"])

func _on_connection_failed():
	print("Connection failed")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	print("Disconnected from server")
	multiplayer.multiplayer_peer = null

@rpc("any_peer", "call_local", "reliable")
func register_player(id: int, username: String):
	player_info[id] = { "username": username, "team": player_info.get(multiplayer.get_unique_id(), {}).get("team", "TeamA") }
	print("Registered player: ", id, " as ", username)

func remove_player(id: int):
	var player_node = get_node_or_null("/root/SquadronDeathmatch/" + str(id))
	if player_node:
		player_node.queue_free()
	var ship_node = get_node_or_null("/root/SquadronDeathmatch/Ship_" + str(id))
	if ship_node:
		ship_node.queue_free()
