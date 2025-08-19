extends CharacterBody3D

var speed = 5.0
var username: String = ""
var in_ship: bool = true  # Declare in_ship here.

func _ready():
	set_multiplayer_authority(multiplayer.get_unique_id())
	if is_multiplayer_authority():
		var camera = $Camera3D
		if camera:
			camera.current = true
		else:
			push_error("No Camera3D found in Player.tscn!")
	else:
		if $Camera3D:
			$Camera3D.current = false  # Disable for non-authoritative players.

func _physics_process(delta: float):
	if is_multiplayer_authority():
		var input_dir = Vector3.ZERO
		input_dir.x = Input.get_axis("ui_left", "ui_right")
		input_dir.z = Input.get_axis("ui_up", "ui_down")
		velocity = input_dir.normalized() * speed
		move_and_slide()

func set_username(new_username: String):
	username = new_username

func exit_ship():
	if in_ship:
		in_ship = false
		print("Exiting ship: ", username)
		# TODO: Swap to on-foot model later.
