extends Control

@onready var username_input = $CanvasLayer/UsernameInput
@onready var ip_input = $CanvasLayer/IPInput
@onready var team_select = $CanvasLayer/TeamSelect
@onready var host_button = $CanvasLayer/HostButton
@onready var join_button = $CanvasLayer/JoinButton

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)

func _on_host_pressed():
	var username = username_input.text if username_input.text != "" else "Player" + str(randi() % 1000)
	var team = "TeamA" if team_select.selected == 0 else "TeamB"
	MultiplayerManager.host_game(username, team)
	start_game()

func _on_join_pressed():
	var username = username_input.text if username_input.text != "" else "Player" + str(randi() % 1000)
	var ip = ip_input.text if ip_input.text != "" else "127.0.0.1"
	var team = "TeamA" if team_select.selected == 0 else "TeamB"
	MultiplayerManager.join_game(ip, 4242, username, team)
	start_game()

func start_game():
	get_tree().change_scene_to_file("res://Core/GameSystems/Multiplayer/SquadronDeathmatch.tscn")
