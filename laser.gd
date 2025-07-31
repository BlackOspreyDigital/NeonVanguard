extends RigidBody3D

# Laser properties
@export var damage: float = 10.0
@export var lifetime: float = 5.0

func _ready() -> void:
	print("Laser _ready() called")
	var mesh_instance = $MeshInstance3D
	var material = mesh_instance.get_surface_override_material(0)
	if material:
		print("Laser material: albedo=", material.albedo_color, ", emission=", material.emission, ", emission_enabled=", material.emission_enabled)
	else:
		push_error("Laser material not found!")
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Start lifetime timer
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		print("Laser hit ", body.name, ", dealt ", damage, " damage")
	queue_free()
