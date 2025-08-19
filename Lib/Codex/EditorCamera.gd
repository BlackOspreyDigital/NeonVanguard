extends Node3D

@export var move_speed: float = 10.0
@export var rotate_speed: float = 0.5
@export var zoom_speed: float = 1.5
@onready var camera: Camera3D = $Camera3D
var pivot_point: Vector3 = Vector3.ZERO # Center of grid
var orbit_distance: float = 10.0 # Distance from pivot
var orbit_angle_y: float = 0.0 # Horizontal angle in radians
var orbit_angle_x: float = deg_to_rad(45.0) # Vertical angle in radians
var last_mouse_pos: Vector2 = Vector2.ZERO # Track last mouse position

func _ready() -> void:
	camera.make_current()
	update_camera_position()
	# Initialize last_mouse_pos
	last_mouse_pos = get_viewport().get_mouse_position()

func _process(delta: float) -> void:
	# Move camera (WASD) in XZ plane
	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1

	var move := input_dir.normalized() * move_speed * delta
	global_transform.origin += move.rotated(Vector3.UP, rotation.y)

	# Orbit (right-click drag)
	if Input.is_action_pressed("mouse_right"):
		var current_mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var mouse_delta: Vector2 = current_mouse_pos - last_mouse_pos
		orbit_angle_y -= mouse_delta.x * rotate_speed * delta
		orbit_angle_x -= mouse_delta.y * rotate_speed * delta
		orbit_angle_x = clamp(orbit_angle_x, deg_to_rad(10), deg_to_rad(80))
		update_camera_position()
		last_mouse_pos = current_mouse_pos
	else:
		last_mouse_pos = get_viewport().get_mouse_position() # Update even when not dragging

	# Zoom (scroll wheel)
	if Input.is_action_just_pressed("mouse_scroll_up"):
		orbit_distance -= zoom_speed
	if Input.is_action_just_pressed("mouse_scroll_down"):
		orbit_distance += zoom_speed
	orbit_distance = clamp(orbit_distance, 10.0, 5000.0)
	update_camera_position()

func update_camera_position() -> void:
	# Position camera to orbit around pivot_point
	var offset := Vector3(
		sin(orbit_angle_y) * cos(orbit_angle_x),
		sin(orbit_angle_x),
		cos(orbit_angle_y) * cos(orbit_angle_x)
	) * orbit_distance
	camera.global_transform.origin = pivot_point + offset
	camera.look_at(pivot_point, Vector3.UP)
