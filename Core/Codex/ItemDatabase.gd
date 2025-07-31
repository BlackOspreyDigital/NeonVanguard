extends Node

var items: Dictionary = {
	"WPNENT_001": {
		"scene": "res://lib/sockets/HMS_WPNENT/module_dual_scatter_lassercannon.tscn",
		"type": "WEAPON",
		"properties": {"damage": 15.0, "fire_rate": 3.0, "type": "Laser"}
	},
	"WPNENT_002": {
		"scene": "res://lib/sockets/HMS_WPNENT/module_gatling_turret.tscn",
		"type": "WEAPON",
		"properties": {"damage": 8.0, "fire_rate": 10.0, "type": "Gatling"}
	},
	"SUPPORTENT_001": {
		"scene": "res://lib/sockets/HMS_SUPPORTENT/module_shield_generator.tscn",
		"type": "SUPPORT",
		"properties": {"shield_strength": 150.0, "recharge_rate": 10.0}
	},
	"SUPPORTENT_002": {
		"scene": "res://lib/sockets/HMS_SUPPORTENT/module_life_support.tscn",
		"type": "SUPPORT",
		"properties": {"life_support": true, "oxygen_capacity": 1000.0}
	},
	"COMMENT_001": {
		"scene": "res://lib/sockets/HMS_COMMENT/module_comm_array.tscn",
		"type": "COMMUNICATION",
		"properties": {"comm_range": 1000.0, "disruptable": true}
	},
	"ENGENT_001": {
		"scene": "res://lib/sockets/HMS_ENGENT/module_repair_drone.tscn",
		"type": "ENGINEERING",
		"properties": {"repair_rate": 5.0, "repair_range": 10.0}
	},
	"BALLASTENT_001": {
		"scene": "res://lib/sockets/HMS_BALLASTENT/module_missile_launcher.tscn",
		"type": "BALLISTIC",
		"properties": {"explosive_yield": 50.0, "ammo_type": "Missile"}
	},
	"BALLASTENT_002": {
		"scene": "res://lib/sockets/HMS_BALLASTENT/module_torpedo_bay.tscn",
		"type": "BALLISTIC",
		"properties": {"explosive_yield": 100.0, "ammo_type": "Torpedo"}
	}
}

var ships: Dictionary = {
	"ShipVariant1": {"scene": "res://lib/ships/ShipVariant1.tscn", "hardpoints": 3},
	"ShipVariant2": {"scene": "res://lib/ships/ShipVariant2.tscn", "hardpoints": 4},
	"ShipVariant3": {"scene": "res://lib/ships/ShipVariant3.tscn", "hardpoints": 5},
	"ShipVariant4": {"scene": "res://lib/ships/ShipVariant4.tscn", "hardpoints": 3},
	"ShipVariant5": {"scene": "res://lib/ships/ShipVariant5.tscn", "hardpoints": 4},
	"ShipVariant6": {"scene": "res://lib/ships/ShipVariant6.tscn", "hardpoints": 5}
}

func get_item(item_id: String) -> Dictionary:
	return items.get(item_id, {})

func get_ship(ship_id: String) -> Dictionary:
	return ships.get(ship_id, {})
