extends Control

@onready var username_input = $VBoxContainer/UsernameInput
@onready var host_button = $VBoxContainer/HostButton
@onready var join_button = $VBoxContainer/JoinButton
@onready var ip_input = $VBoxContainer/IPInput
@onready var status_label = $VBoxContainer/StatusLabel

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_host_pressed():
	var username = username_input.text.strip_edges()
	if username == "":
		status_label.text = "Enter a username!"
		return
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(9877, 32)  # Port 9877, max 24 players.
	if error:
		status_label.text = "Failed to host: " + str(error)
		return
	multiplayer.multiplayer_peer = peer
	status_label.text = "Hosting game... Waiting for players."
	load_game(username)

func _on_join_pressed():
	var username = username_input.text.strip_edges()
	var ip = ip_input.text.strip_edges()
	if username == "" or ip == "":
		status_label.text = "Enter username and IP!"
		return
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, 9877)
	if error:
		status_label.text = "Failed to join: " + str(error)
		return
	multiplayer.multiplayer_peer = peer
	status_label.text = "Connecting..."

func _on_connected_to_server():
	var username = username_input.text.strip_edges()
	status_label.text = "Connected! Loading game."
	load_game(username)

func _on_connection_failed():
	status_label.text = "Connection failed."
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	status_label.text = "Server disconnected."
	get_tree().change_scene_to_file("res://Core/GameSystems/Experimental/Lobby.tscn")  # Reload lobby.

func load_game(username: String):
	# Pass username or other data if needed.
	#Global.username = username  # Assuming you have a Global autoload for shared data.
	get_tree().change_scene_to_file("res://Core/GameSystems/Experimental/SquadronDeathmatch.tscn")
