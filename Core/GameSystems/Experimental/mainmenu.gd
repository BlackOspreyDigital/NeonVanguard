extends Control

@onready var username_input = $MenuContainer/UsernameInput
@onready var password_input = $MenuContainer/PasswordInput
@onready var login_button = $MenuContainer/LoginButton
@onready var register_button = $MenuContainer/RegisterButton
@onready var status_label = $MenuContainer/StatusLabel
@onready var mode_select_button = $MenuContainer/ModeSelectButton
@onready var mode_select_panel = $ModeSelectPanel
@onready var sandbox_button = $ModeSelectPanel/ModeContainer/SandboxButton
@onready var join_button = $MenuContainer/JoinButton
@onready var ip_input = $MenuContainer/IPInput
@onready var quit_button = $ModeSelectPanel/ModeContainer/QuitButton

func _ready():
	login_button.pressed.connect(_on_login_pressed)
	register_button.pressed.connect(_on_register_pressed)
	mode_select_button.pressed.connect(_on_mode_select_pressed)
	sandbox_button.pressed.connect(_on_sandbox_pressed)
	join_button.pressed.connect(_on_join_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	if SaveSystem.is_logged_in():
		_on_login_success()

func _on_login_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	if username == "" or password == "":
		status_label.text = "Please enter username and password."
		return
	if SaveSystem.login(username, password):
		status_label.text = "Login successful!"
		_on_login_success()
	else:
		status_label.text = "Invalid username or password."

func _on_register_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	if username == "" or password == "":
		status_label.text = "Please enter username and password."
		return
	if SaveSystem.register(username, password):
		status_label.text = "Registration successful! Please login."
	else:
		status_label.text = "Username already taken."

func _on_login_success():
	mode_select_button.disabled = false
	username_input.editable = false
	password_input.editable = false
	login_button.disabled = true
	register_button.disabled = true

func _on_mode_select_pressed():
	mode_select_panel.visible = true
#	menu_container.visible = false

func _on_sandbox_pressed():
	SaveSystem.current_username = username_input.text.strip_edges()
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(9877, 32)
	if error:
		status_label.text = "Failed to host: " + str(error)
		return
	multiplayer.multiplayer_peer = peer
	var scene_path = "res://Core/GameSystems/Multiplayer/sandbox.tscn"
	if not ResourceLoader.exists(scene_path):
		status_label.text = "Error: Scene " + scene_path + " not found!"
		push_error("Cannot load scene: " + scene_path)
		return
	get_tree().change_scene_to_file(scene_path)

func _on_join_pressed():
	var username = username_input.text.strip_edges()
	var ip = ip_input.text.strip_edges()
	if username == "" or ip == "":
		status_label.text = "Enter username and IP!"
		return
	SaveSystem.current_username = username
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, 9877)
	if error:
		status_label.text = "Failed to join: " + str(error)
		return
	multiplayer.multiplayer_peer = peer
	var scene_path = "res://Core/GameSystems/Multiplayer/sandbox.tscn"
	if not ResourceLoader.exists(scene_path):
		status_label.text = "Error: Scene " + scene_path + " not found!"
		push_error("Cannot load scene: " + scene_path)
		return
	get_tree().change_scene_to_file(scene_path)

func _on_quit_pressed():
	get_tree().quit()
