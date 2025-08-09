extends RigidBody3D

# Movement properties
@export var thrust_strength: float = 500.0
@export var strafe_strength: float = 200.0
@export var rotation_strength: float = 75.0
@export var max_speed: float = 50.0
@export var mouse_sensitivity: float = 0.003
@export var drag_line_distance: float = 150.0
@export var free_look_sensitivity: float = 0.005
@export var free_look_lerp_speed: float = 5.0
@export var zoom_speed: float = 0.5
@export var health: float = 1000.0
@export var team: String = "TeamA"

# Node references
@export var crosshair: Line2D
@export var drag_line: Line2D
@export var camera_rig: Node3D
@export var camera: Camera3D

var mouse_delta: Vector2 = Vector2.ZERO
var viewport_center: Vector2
var is_free_look: bool = false
var camera_target_rotation: Basis = Basis.IDENTITY
var camera_target_z: float

func _ready() -> void:
	set_multiplayer_authority(multiplayer.get_unique_id())
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if camera:
			camera.current = true
	viewport_center = get_viewport().get_visible_rect().size / 2.0
	add_to_group(team)
	if not crosshair or not drag_line or not camera_rig or not camera:
		crosshair = get_node_or_null("HUD/Control/Crosshair")
		drag_line = get_node_or_null("HUD/Control/DragLine")
		camera_rig = get_node_or_null("CameraRig")
		camera = get_node_or_null("CameraRig/Camera3D")
		if not crosshair or not drag_line or not camera_rig or not camera:
			push_error("Crosshair, DragLine, CameraRig, or Camera3D not found!")
	
	linear_damp = 0.5
	angular_damp = 0.5
	_setup_crosshair()
	_setup_drag_line()
	camera_target_z = camera.transform.origin.z if camera else 0.0
	print("Spaceship initialized, team: ", team)

func _physics_process(delta: float) -> void:
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		var forward_input: float = Input.get_axis("thrust_backward", "thrust_forward")
		var strafe_horizontal: float = Input.get_axis("strafe_left", "strafe_right")
		var strafe_vertical: float = Input.get_axis("descend", "ascend")
		var roll_input: float = Input.get_axis("roll_right", "roll_left")
		var thrust: Vector3 = -transform.basis.z * forward_input * thrust_strength
		apply_central_force(thrust)
		var strafe: Vector3 = (transform.basis.x * strafe_horizontal + transform.basis.y * strafe_vertical) * strafe_strength
		apply_central_force(strafe)
		var torque: Vector3 = Vector3.ZERO
		if roll_input != 0:
			torque += transform.basis.z * roll_input * rotation_strength
		if mouse_delta != Vector2.ZERO and crosshair and drag_line and not is_free_look:
			var pitch: float = -mouse_delta.y * mouse_sensitivity * rotation_strength
			var yaw: float = -mouse_delta.x * mouse_sensitivity * rotation_strength
			torque += (transform.basis.x * pitch + transform.basis.y * yaw).limit_length(100.0)
			_update_drag_line()
		apply_torque(torque)
		if not is_free_look and camera_rig:
			camera_rig.transform.basis = camera_rig.transform.basis.slerp(camera_target_rotation, free_look_lerp_speed * delta)
		if camera:
			var current_z = camera.transform.origin.z
			camera.transform.origin.z = lerp(current_z, camera_target_z, free_look_lerp_speed * delta)
			if abs(camera_target_z) > 100.0:
				push_warning("Camera zoom distance is very large (%s)." % camera_target_z)
		
		mouse_delta = Vector2.ZERO
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.normalized() * max_speed
		rpc("sync_transform", global_transform)

@rpc("any_peer", "call_remote", "unreliable")
func sync_transform(new_transform: Transform3D):
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		global_transform = global_transform.interpolate_with(new_transform, 0.1)

func _input(event: InputEvent) -> void:
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		if event.is_action_pressed("free_look"):
			is_free_look = true
		if event.is_action_released("free_look"):
			is_free_look = false
		if event is InputEventMouseMotion:
			mouse_delta = event.relative.limit_length(50.0)
			if is_free_look and camera_rig:
				var pitch: float = -mouse_delta.y * free_look_sensitivity
				var yaw: float = -mouse_delta.x * free_look_sensitivity
				camera_rig.rotate_object_local(Vector3.RIGHT, pitch)
				camera_rig.rotate_object_local(Vector3.UP, yaw)
				var euler = camera_rig.transform.basis.get_euler()
				euler.x = clamp(euler.x, deg_to_rad(-89), deg_to_rad(89))
				camera_rig.transform.basis = Basis.from_euler(euler)
		if is_free_look and event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				camera_target_z -= zoom_speed
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				camera_target_z += zoom_speed
		if event.is_action_pressed("interact"):
			var player = get_node_or_null("/root/SquadronDeathmatch/" + str(multiplayer.get_unique_id()))
			if player:
				player.rpc("exit_ship")

func _setup_crosshair() -> void:
	if crosshair:
		crosshair.width = 2.0
		crosshair.default_color = Color(1, 1, 1, 0.8)
		crosshair.clear_points()
		crosshair.add_point(Vector2(-10, 0))
		crosshair.add_point(Vector2(10, 0))
		crosshair.add_point(Vector2(0, -10))
		crosshair.add_point(Vector2(0, 10))
		crosshair.position = viewport_center

func _setup_drag_line() -> void:
	if drag_line:
		drag_line.width = 10.0
		drag_line.default_color = Color(0.5, 0.5, 1, 0.5)
		drag_line.clear_points()
		drag_line.add_point(Vector2.ZERO)
		drag_line.add_point(Vector2.ZERO)
		drag_line.position = viewport_center

func _update_drag_line() -> void:
	if drag_line:
		var drag_line_pos: Vector2 = mouse_delta * 0.5
		drag_line_pos = drag_line_pos.clamp(Vector2(-drag_line_distance, -drag_line_distance), Vector2(drag_line_distance, drag_line_distance))
		drag_line.set_point_position(0, Vector2.ZERO)
		drag_line.set_point_position(1, drag_line_pos)
