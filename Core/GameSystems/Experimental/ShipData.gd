extends Resource

class_name ShipData

@export var ship_name: String = "Basic Fighter"
@export var thrust_strength: float = 500.0
@export var strafe_strength: float = 200.0
@export var rotation_strength: float = 75.0
@export var max_speed: float = 50.0
@export var health: float = 1000.0
@export var team: String = "TeamA"
@export var mesh_path: PackedScene  # e.g., preload("res://Core/GameSystems/Experimental/FighterMesh.tscn")
@export var weapon_type: String = "Laser"  # For future combat
