extends StaticBody3D

# Capital ship properties
@export var health: float = 1500000.0
@export var team: String = "TeamA"

func _ready() -> void:
	add_to_group(team)
	print("CapitalShip ", name, " initialized, team: ", team, ", health: ", health)

func take_damage(damage: float) -> void:
	health -= damage
	print("CapitalShip ", name, " took ", damage, " damage, health: ", health)
	if health <= 0:
		print("CapitalShip ", name, " destroyed!")
		queue_free()
		get_tree().call_group("game_manager", "on_capital_ship_destroyed", team)
