extends Control

@onready var username_input = $UsernameInput
@onready var ip_input = $IPInput
@onready var host_button = $HostButton
@onready var join_button = $JoinButton
var multiplayer_manager = preload("res://Core/GameSystems/Multiplayer/MultiplayerManager.tscn").instantiate()

func _ready():
	add_child(multiplayer_manager)
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)

func _on_host_pressed():
	var username = username_input.text if username_input.text != "" else "Player" + str(randi() % 1000)
	multiplayer_manager.host_game(username)
	start_game()

func _on_join_pressed():
	var username = username_input.text if username_input.text != "" else "Player" + str(randi() % 1000)
	var ip = ip_input.text if ip_input.text != "" else "127.0.0.1"
	multiplayer_manager.join_game(ip, 4242, username)
	start_game()

func start_game():
	get_tree().change_scene_to_file("res://Core/GameSystems/Multiplayer/SquadronDeathmatch.tscn")
