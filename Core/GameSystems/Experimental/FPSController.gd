extends CharacterBody3D

@onready var camera = $Camera3D
@onready var username_label = $UsernameLabel
var username: String = "Player"

# Movement properties (from your existing controller)
var speed = 5.0
var gravity = 9.8
var mouse_sensitivity = 0.002

func _ready():
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		camera.current = true # Enable camera only for local player
	else:
		camera.current = false
	username_label.text = username
	set_multiplayer_authority(multiplayer.get_unique_id())

func _physics_process(delta):
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		# Your existing movement code
		var input_dir = Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_up", "ui_down")
		)
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		velocity.y -= gravity * delta
		move_and_slide()
		# Sync position and rotation
		rpc("sync_transform", global_transform)

@rpc("any_peer", "call_remote", "unreliable")
func sync_transform(transform: Transform3D):
	global_transform = transform

func set_username(new_username: String):
	username = new_username
	username_label.text = username
