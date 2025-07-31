extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var interacting_ship = null

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if is_multiplayer_authority():
		$Camera3D.current = true

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Movement
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_backward")
	)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	# Interaction
	if Input.is_action_just_pressed("interact"):
		var ray = $Camera3D/InteractionRay
		if ray.is_colliding() and ray.get_collider().is_in_group("ships"):
			interacting_ship = ray.get_collider()
			rpc("enter_ship", interacting_ship.get_path())

func _input(event):
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI/2, PI/2)

@rpc("any_peer", "call_local")
func enter_ship(ship_path):
	var ship = get_node(ship_path)
	if ship and ship.has_method("enter"):
		ship.enter(self)
		queue_free() # Remove FPS controller after entering ship
