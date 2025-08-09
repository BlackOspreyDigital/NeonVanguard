extends CharacterBody3D

@onready var camera = $Camera3D
@onready var username_label = $UsernameLabel
@onready var interaction_ray = $Camera3D/InteractionRay
#@onready var chat_box = $CanvasLayer/ChatBox
#@onready var chat_display = $CanvasLayer/ChatDisplay
var username: String = "Player"
var speed = 5.0
var gravity = 9.8
var mouse_sensitivity = 0.002
var is_in_ship = false

func _ready():
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		camera.current = false
	username_label.text = username
	set_multiplayer_authority(multiplayer.get_unique_id())
	#chat_box.text_submitted.connect(_on_chat_submitted)

func _input(event):
	if multiplayer.get_unique_id() == get_multiplayer_authority() and not is_in_ship:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if multiplayer.get_unique_id() == get_multiplayer_authority() and not is_in_ship:
		var input_dir = Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_up", "ui_down")
		)
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		velocity.y -= gravity * delta
		move_and_slide()
		rpc("sync_transform", global_transform)
		
		if interaction_ray.is_colliding() and Input.is_action_just_pressed("interact"):
			var collider = interaction_ray.get_collider()
			if collider and collider.is_in_group("terminal"):
				rpc("request_ship", collider.get_path())

@rpc("any_peer", "call_remote", "unreliable")
func sync_transform(new_transform: Transform3D):
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		global_transform = global_transform.interpolate_with(new_transform, 0.1)

@rpc("any_peer", "call_local", "reliable")
func request_ship(terminal_path: NodePath):
	if multiplayer.is_server():
		var terminal = get_node_or_null(terminal_path)
		if terminal:
			var ship = preload("res://Core/GameSystems/Experimental/ShipController.tscn").instantiate()
			ship.name = "Ship_" + str(multiplayer.get_unique_id())
			ship.position = global_position + Vector3(0, 1, 0)
			ship.team = MultiplayerManager.player_info.get(multiplayer.get_unique_id(), {}).get("team", "TeamA")
			get_node("/root/SquadronDeathmatch").add_child(ship)
			ship.set_multiplayer_authority(multiplayer.get_unique_id())
			rpc("enter_ship", ship.get_path())

@rpc("any_peer", "call_local", "reliable")
func enter_ship(ship_path: NodePath):
	is_in_ship = true
	visible = false
	set_physics_process(false)

@rpc("any_peer", "call_local", "reliable")
func exit_ship():
	is_in_ship = false
	visible = true
	set_physics_process(true)
	var ship = get_node_or_null("/root/SquadronDeathmatch/Ship_" + str(multiplayer.get_unique_id()))
	if ship:
		ship.queue_free()

#func _on_chat_submitted(message: String):
#	if multiplayer.get_unique_id() == get_multiplayer_authority():
#		rpc("send_message", username, message)
#		chat_box.clear()

#@rpc("any_peer", "call_local", "reliable")
#func send_message(sender: String, message: String):
#	chat_display.text += "\n" + sender + ": " + message

func set_username(new_username: String):
	username = new_username
	username_label.text = username
