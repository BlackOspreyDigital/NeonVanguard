extends Node3D

@onready var player_spawner = get_node_or_null("PlayerSpawner")
@onready var spawn_points = get_node_or_null("SpawnPoints")

func _ready():
	if not player_spawner:
		push_error("PlayerSpawner node not found in sandbox.tscn!")
		return
	if not spawn_points:
		push_error("SpawnPoints node not found in sandbox.tscn!")
		return
	var light = get_node_or_null("DirectionalLight3D")
	if not light:
		push_warning("No DirectionalLight3D found; consider adding one.")
	else:
		light.light_energy = 1.0
	
	if SaveSystem.is_logged_in():
		var data = {
			"id": multiplayer.get_unique_id(),
			"username": SaveSystem.current_username
		}
		player_spawner.spawn_player(data)
	else:
		push_error("Not logged in! Cannot spawn player.")

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		print("Sandbox menu would open here (future feature).")
	if event.is_action_pressed("ui_accept"):
		var player = get_node_or_null(str(multiplayer.get_unique_id()))
		if player:
			player.exit_ship()

func exit_ship(player: Node3D):
	print("Player ", player.username, " exited ship (placeholder).")

func enter_starbase(player: Node3D, _starbase: Node3D):
	print("Player ", player.username, " entered starbase (placeholder).")
