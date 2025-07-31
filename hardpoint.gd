extends Node3D

# Hardpoint properties
@export var projectile_type: String = "LongLaser"
@export var fire_rate: float = 2.0
@export var projectile_speed: float = 50.0
@export var target_team: String = "TeamB"
@export var detection_angle: float = 120.0

@export var laser_scene: PackedScene = preload("res://Laser.tscn")
@export var long_laser_scene: PackedScene = preload("res://LongLaser.tscn")
@export var scatter_laser_scene: PackedScene = preload("res://ScatterLaser.tscn")

var fire_timer: float = 0.0
var turret: Node3D
var capital_ship: StaticBody3D

func _ready() -> void:
	turret = $CS_T1
	capital_ship = get_parent()
	if not turret:
		push_error("CS_T1 turret not found in Hardpoint ", name)
	if not capital_ship or not (capital_ship is StaticBody3D):
		push_error("Hardpoint ", name, " must be child of StaticBody3D")
	if projectile_type not in ["Laser", "LongLaser", "ScatterLaser"]:
		push_error("Invalid projectile_type: ", projectile_type)
		projectile_type = "LongLaser"
	print("Hardpoint ", name, " initialized, target_team: ", target_team, ", facing: ", -turret.global_transform.basis.z)

func _physics_process(delta: float) -> void:
	fire_timer -= delta
	if fire_timer <= 0:
		var target = _get_closest_target()
		if target:
			var direction = (target.global_position - turret.global_position).normalized()
			var basis = Basis.looking_at(direction, Vector3.UP)
			turret.global_transform.basis = basis
			_fire_projectile(target)
			fire_timer = fire_rate
		else:
			print("No targets detected for Hardpoint ", name)

func _get_closest_target() -> Node3D:
	if not capital_ship or not capital_ship.detection_area:
		print("No detection_area for Hardpoint ", name)
		return null
	var bodies = capital_ship.detection_area.get_overlapping_bodies()
	print("Hardpoint ", name, " overlapping bodies: ", bodies.size())
	var closest: Node3D = null
	var min_distance: float = INF
	var forward = -turret.global_transform.basis.z
	var max_cos = cos(deg_to_rad(detection_angle / 2.0))
	for body in bodies:
		if body.is_in_group(target_team) and body != capital_ship:
			var direction = (body.global_position - turret.global_position).normalized()
			var cos_angle = forward.dot(direction)
			if cos_angle > max_cos:
				var distance = global_position.distance_to(body.global_position)
				if distance < min_distance:
					min_distance = distance
					closest = body
	return closest

func _fire_projectile(target: Node3D) -> void:
	var scene = laser_scene if projectile_type == "Laser" else scatter_laser_scene if projectile_type == "ScatterLaser" else long_laser_scene
	var barrels = [turret.get_node_or_null("Barrel1"), turret.get_node_or_null("Barrel2")]
	for barrel in barrels:
		if barrel:
			var projectile = scene.instantiate()
			get_tree().root.add_child(projectile)
			var direction = (target.global_position - barrel.global_position).normalized()
			var spawn_position = barrel.global_position
			projectile.global_position = spawn_position
			var basis = Basis.looking_at(direction, Vector3.UP)
			projectile.global_transform.basis = basis
			projectile.apply_central_impulse(direction * projectile_speed)
			print("Hardpoint ", name, " firing ", projectile_type, " from ", barrel.name, " at ", target.name, ", direction: ", direction)
