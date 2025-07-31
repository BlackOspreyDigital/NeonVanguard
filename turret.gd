extends Node3D

# Turret properties
@export var projectile_type: String = "LongLaser"
@export var fire_rate: float = 2.0
@export var burst_delay: float = 0.05
@export var projectile_speed: float = 50.0
@export var target_team: String = "TeamB"
@export var laser_scene: PackedScene = preload("res://Laser.tscn")
@export var long_laser_scene: PackedScene = preload("res://LongLaser.tscn")

var fire_timer: float = 0.0
var area: Area3D
var turret_body: Node3D
var turret_arms: Node3D

func _ready() -> void:
	area = get_parent().get_node("Area3D")
	turret_body = $TurretBody
	turret_arms = $TurretBody/TurretArms
	if not area:
		push_error("Area3D not found in Hardpoint for Turret ", name)
	else:
		var shape = area.get_node("CollisionShape3D")
		if shape and shape.shape is SphereShape3D:
			print("Turret ", name, " Area3D radius: ", shape.shape.radius, ", mask: ", area.collision_mask)
		else:
			push_error("Invalid Area3D shape in Hardpoint for Turret ", name)
	if not turret_body or not turret_arms:
		push_error("TurretBody or TurretArms not found in Turret ", name)
	if projectile_type not in ["Laser", "LongLaser"]:
		push_error("Invalid projectile_type: ", projectile_type)
		projectile_type = "LongLaser"
	if not long_laser_scene:
		push_error("LongLaser scene not assigned in Turret ", name)
	var capital_ship = get_parent().get_parent()
	print("Turret ", name, " initialized, target_team: ", target_team, ", parent: ", capital_ship.name, ", position: ", global_position)

func _physics_process(delta: float) -> void:
	fire_timer -= delta
	if fire_timer <= 0:
		var target = _get_closest_target()
		if target:
			_aim_at_target(target)
			_fire_burst(target)
			fire_timer = fire_rate
		else:
			print("No targets detected for Turret ", name)

func _get_closest_target() -> Node3D:
	var bodies = area.get_overlapping_bodies()
	print("Turret ", name, " overlapping bodies: ", bodies.size())
	for body in bodies:
		var layer = body.collision_layer
		var groups = body.get_groups()
		var distance = global_position.distance_to(body.global_position)
		print("Body: ", body.name, ", groups: ", groups, ", position: ", body.global_position, ", layer: ", layer, ", distance: ", distance)
	var closest: Node3D = null
	var min_distance: float = INF
	var capital_ship = get_parent().get_parent()
	for body in bodies:
		if body.is_in_group(target_team) and body != capital_ship:
			var distance = global_position.distance_to(body.global_position)
			if distance < min_distance:
				min_distance = distance
				closest = body
				print("Target considered: ", body.name, ", distance: ", distance)
	return closest

func _aim_at_target(target: Node3D) -> void:
	var direction = (target.global_position - global_position).normalized()
	var target_yaw = atan2(direction.x, direction.z)
	var target_pitch = asin(direction.y)
	turret_body.rotation.y = lerp_angle(turret_body.rotation.y, target_yaw, 0.1)
	turret_arms.rotation.x = lerp_angle(turret_arms.rotation.x, target_pitch, 0.1)
	turret_arms.rotation.x = clamp(turret_arms.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _fire_burst(target: Node3D) -> void:
	var scene = laser_scene if projectile_type == "Laser" else long_laser_scene
	var barrels = [$TurretBody/TurretArms/Barrel1, $TurretBody/TurretArms/Barrel2]
	for barrel in barrels:
		if barrel:
			for i in range(3):
				var projectile = scene.instantiate()
				get_tree().root.add_child(projectile)
				var direction = (target.global_position - barrel.global_position).normalized()
				var spawn_position = barrel.global_position
				projectile.global_position = spawn_position
				var target_basis = Basis.looking_at(direction, Vector3.UP)
				projectile.global_transform.basis = target_basis
				projectile.apply_central_impulse(direction * projectile_speed)
				print("Turret ", name, " firing ", projectile_type, " from ", barrel.name, " at ", target.name, ", direction: ", direction)
				if i < 2:
					await get_tree().create_timer(burst_delay).timeout
