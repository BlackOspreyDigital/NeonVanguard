extends Node

var current_username: String = ""
var _save_file = "user://players.save"
var _players: Dictionary = {}  # {username: {password: String, data: Dictionary}}

func _ready():
	_load_players()

func _load_players():
	if FileAccess.file_exists(_save_file):
		var file = FileAccess.open(_save_file, FileAccess.READ)
		_players = file.get_var(true)
		file.close()

func _save_players():
	var file = FileAccess.open(_save_file, FileAccess.WRITE)
	file.store_var(_players, true)
	file.close()

func register(username: String, password: String) -> bool:
	if _players.has(username):
		return false
	_players[username] = { "password": password, "data": {} }
	_save_players()
	return true

func login(username: String, password: String) -> bool:
	if _players.has(username) and _players[username].password == password:
		current_username = username
		return true
	return false

func is_logged_in() -> bool:
	return current_username != "" 
