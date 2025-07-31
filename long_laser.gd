extends RigidBody3D

# Long laser properties
@export var damage: float = 5.0
@export var lifetime: float = 5.0

func _ready() -> void:
	print("LongLaser _ready() called")
	var mesh_instance = $MeshInstance3D
	var material = mesh_instance.get_surface_override_material(0)
	if material:
		print("LongLaser material: albedo=", material.albedo_color, ", emission=", material.emission, ", emission_enabled=", material.emission_enabled)
	else:
		push_error("LongLaser material not found!")
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		var damage_to_deal = 1000.0 if body.is_in_group("TeamA") and body.name == "Spaceship" else damage
		body.take_damage(damage_to_deal)
		print("LongLaser hit ", body.name, ", dealt ", damage_to_deal, " damage")
	queue_free()
