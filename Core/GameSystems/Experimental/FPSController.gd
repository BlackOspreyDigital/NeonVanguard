extends CharacterBody3D

var speed = 5.0
var gravity = 9.8  # Added for on-foot physics
var username: String = ""
var in_ship: bool = true

func _ready():
	set_multiplayer_authority(multiplayer.get_unique_id())
	if is_multiplayer_authority():
		var camera = $Camera3D
		if camera:
			camera.current = true
		else:
			push_error("No Camera3D found in FPSController.tscn!")
	else:
		if $Camera3D:
			$Camera3D.current = false

func _physics_process(_delta: float):
	if is_multiplayer_authority():
		var input_dir = Vector3.ZERO
		input_dir.x = Input.get_axis("move_left", "move_right")
		input_dir.z = Input.get_axis("move_forward", "move_backward")
		velocity.x = input_dir.x * speed
		velocity.z = input_dir.z * speed
		velocity.y -= gravity * _delta
		move_and_slide()

func set_username(new_username: String):
	username = new_username
	print("Username set to: ", username)

func exit_ship():
	if in_ship:
		in_ship = false
		print("Exiting ship: ", username)
		# TODO: Swap to on-foot model (this script)
