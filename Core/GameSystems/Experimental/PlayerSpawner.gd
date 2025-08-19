extends MultiplayerSpawner

@export var spawn_points_path: NodePath = "../SpawnPoints"
@onready var spawn_points = get_node(spawn_points_path).get_children()
var player_scene = preload("res://Core/GameSystems/Experimental/ShipController.tscn")

func _ready():
	var spawn_container = get_node_or_null(spawn_points_path)
	if not spawn_container:
		push_error("SpawnPoints node not found at: " + str(spawn_points_path))
	elif spawn_points.size() == 0:
		push_error("No spawn points defined!")
	spawn_function = Callable(self, "spawn_player")
	spawn_path = "../"
	add_spawnable_scene(player_scene.resource_path)

func spawn_player(data: Dictionary) -> Node:
	if not data.has("id") or not data.has("username"):
		push_error("Invalid spawn data!")
		return null
	var player = player_scene.instantiate()
	player.name = str(data.id)
	player.username = data.username
	player.set_multiplayer_authority(data.id)
	player.set_username(data.username)
	
	var spawn_pos = Vector3.ZERO
	if spawn_points.size() > 0:
		var spawn_point = spawn_points[randi() % spawn_points.size()]
		spawn_pos = spawn_point.global_position
	# Defer setting global_position until node is in the tree
	player.call_deferred("set", "global_position", spawn_pos)
	print("Spawning player ", data.id, " at ", spawn_pos)
	return player
