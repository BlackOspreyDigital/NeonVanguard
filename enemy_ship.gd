extends RigidBody3D

# Enemy ship properties
@export var health: float = 100.0
@export var speed: float = 15.0
@export var laser_cooldown: float = 0.5
@export var laser_speed: float = 50.0
@export var laser_scene: PackedScene = preload("res://Laser.tscn")
@export var cohesion_weight: float = 0.8
@export var alignment_weight: float = 0.8
@export var separation_weight: float = 1.2
@export var combat_range: float = 500.0
@export var orbit_distance: float = 200.0
var target: Node3D
var laser_timer: float = 0.0
var allies: Array[Node3D] = []

func _ready() -> void:
	add_to_group("TeamB")
	linear_damp = 0.8
	angular_damp = 0.8
	mass = 100.0
	if not laser_scene:
		push_error("Laser scene not assigned in EnemyShip!")
	print("EnemyShip ", name, " initialized, health: ", health)

func _physics_process(delta: float) -> void:
	allies = []
	for node in get_tree().get_nodes_in_group("TeamB"):
		if node != self and node is RigidBody3D and global_position.distance_to(node.global_position) < 200:
			allies.append(node)
	target = _find_target()
	var force = Vector3.ZERO
	var to_target = Vector3.ZERO
	if target:
		laser_timer -= delta
		var distance = global_position.distance_to(target.global_position)
		to_target = (target.global_position - global_position).normalized()
		if distance < combat_range and laser_timer <= 0:
			_fire_laser()
			laser_timer = laser_cooldown
		if distance > orbit_distance:
			force += to_target * speed
		else:
			var tangent = to_target.cross(Vector3.UP).normalized()
			force += tangent * speed * 0.25
	else:
		force += _flock()
		to_target = force.normalized() if force.length() > 0 else -global_transform.basis.z
	force = force.limit_length(speed * 1.5)
	apply_central_force(force * 50)
	var target_basis = Basis.looking_at(to_target, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(target_basis, 0.2)
	print("EnemyShip ", name, " force: ", force.length())

func _find_target() -> Node3D:
	var closest: Node3D = null
	var min_distance: float = INF
	for body in get_tree().get_nodes_in_group("TeamA"):
		var distance = global_position.distance_to(body.global_position)
		if distance < min_distance:
			min_distance = distance
			closest = body
	return closest if min_distance < combat_range else null

func _flock() -> Vector3:
	var cohesion = Vector3.ZERO
	var alignment = Vector3.ZERO
	var separation = Vector3.ZERO
	var count = allies.size()
	if count > 0:
		var center = Vector3.ZERO
		for ally in allies:
			center += ally.global_position
			alignment += ally.linear_velocity
			var diff = global_position - ally.global_position
			if diff.length() < 50:
				separation += diff.normalized() / max(diff.length(), 0.1)
		cohesion = (center / count - global_position).normalized() * speed * cohesion_weight
		alignment = (alignment / count).normalized() * speed * alignment_weight
		separation = separation.normalized() * speed * separation_weight
	var center_force = Vector3(0, 0, 200).normalized() * speed * 0.2
	return (cohesion + alignment + separation + center_force).limit_length(speed)

func _fire_laser() -> void:
	if not laser_scene or not target:
		return
	var projectile = laser_scene.instantiate()
	get_tree().root.add_child(projectile)
	var spawn_position = global_position - global_position - global_transform.basis.z * 2.0
	projectile.global_position = spawn_position
	var direction = (target.global_position - global_position).normalized()
	projectile.global_transform.basis = Basis.looking_at(direction, Vector3.UP)
	projectile.apply_central_impulse(direction * laser_speed)
	print("EnemyShip ", name, " firing Laser at ", target.name)
