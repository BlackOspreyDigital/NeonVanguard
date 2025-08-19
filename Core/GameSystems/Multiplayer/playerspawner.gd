extends MultiplayerSpawner

@export var spawn_points_path: NodePath = "MultiplayerSpawner/SpawnPoints1"  # Adjust in editor.

@onready var spawn_points = get_node(spawn_points_path).get_children()

var player_scene = preload("res://Core/GameSystems/Experimental/Player.tscn")

func _ready():
	var spawn_container = get_node_or_null(spawn_points_path)
	if not spawn_container:
		push_error("SpawnPoints node not found at path: " + str(spawn_points_path))
	elif spawn_points.size() == 0:
		push_error("No spawn points defined in SpawnPoints node!")
	spawn_function = spawn_player

func spawn_player(data: Dictionary):
	if not data.has("id") or not data.has("username"):
		push_error("Invalid spawn data: missing id or username!")
		return null
	
	var player = player_scene.instantiate()
	player.name = str(data.id)
	player.username = data.username
	player.set_multiplayer_authority(data.id)
	
	var spawn_pos = Vector3.ZERO  # Fallback position.
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		spawn_pos = spawn_point.global_position  # For 3D.
	else:
		push_warning("No spawn points available; using default position.")
	
	player.global_position = spawn_pos  # Use global for world-space.
	player.set_username(data.username)
	
	print("Spawning player ", data.id, " at ", spawn_pos)  # Debug log.
	return player
