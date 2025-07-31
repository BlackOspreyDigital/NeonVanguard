extends RigidBody3D

# Projectile properties
@export_enum("Laser", "Missile") var projectile_type: String = "Laser"
@export var damage: float = 10.0
@export var lifetime: float = 5.0
@export var emissive_intensity: float = 2.0  # Intensity of laser glow

func _ready() -> void:
	# Debug projectile type
	print("Projectile type (raw): ", projectile_type)
	
	# Normalize type to avoid case sensitivity 
	var normalized_type = projectile_type.to_lower()
	print("Normalized type: ", normalized_type)
	
	# Configure based on projectile type
	var mesh_instance = $MeshInstance3D
	var material = StandardMaterial3D.new()
	
	if normalized_type == "laser":
		print("Configuring laser")
		mesh_instance.mesh.size = Vector3(0.2, 0.2, 0.2)  
		material.albedo_color = Color(0, 1, 0) 
		material.emission_enabled = true
		material.emission = Color(0, 1, 0)  
		material.emission_energy_multiplier_enabled = false  
		material.emission_intensity = emissive_intensity 
		$CollisionShape3D.shape.extents = Vector3(0.1, 0.1, 0.1)
		damage = 10.0
		print("Laser material: albedo=", material.albedo_color, ", emission=", material.emission, ", emission_intensity=", material.emission_intensity)
	elif normalized_type == "missile":
		print("Configuring missile")
		mesh_instance.mesh.size = Vector3(0.5, 0.5, 0.5)  
		material.albedo_color = Color(0, 0.5, 1) 
		material.emission_enabled = false 
		$CollisionShape3D.shape.extents = Vector3(0.25, 0.25, 0.25)
		damage = 50.0
		print("Missile material: albedo=", material.albedo_color, ", emission_enabled=", material.emission_enabled)
	else:
		push_error("Invalid projectile type: ", normalized_type, ". Defaulting to Laser.")
		mesh_instance.mesh.size = Vector3(0.2, 0.2, 0.2)
		material.albedo_color = Color(0, 1, 0)
		material.emission_enabled = true
		material.emission = Color(0, 1, 0)
		material.emission_energy_multiplier_enabled = true
		material.emission_intensity = emissive_intensity
		$CollisionShape3D.shape.extents = Vector3(0.1, 0.1, 0.1)
		damage = 10.0
		print("Default material: albedo=", material.albedo_color, ", emission=", material.emission, ", emission_intensity=", material.emission_intensity)
	
	mesh_instance.set_surface_override_material(0, material)
	
	# Start lifetime timer
	await get_tree().create_timer(lifetime).timeout
	queue_free()
