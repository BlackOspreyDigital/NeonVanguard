extends Control

@onready var username_input = $MenuContainer/UsernameInput
@onready var password_input = $MenuContainer/PasswordInput
@onready var login_button = $MenuContainer/LoginButton
@onready var register_button = $MenuContainer/RegisterButton
@onready var status_label = $MenuContainer/StatusLabel
@onready var mode_select_button = $MenuContainer/ModeSelectButton
@onready var mode_select_panel = $ModeSelectPanel
@onready var sandbox_button = $ModeSelectPanel/ModeContainer/SandboxButton
@onready var quit_button = $ModeSelectPanel/ModeContainer/QuitButton

func _ready():
	login_button.pressed.connect(_on_login_pressed)
	register_button.pressed.connect(_on_register_pressed)
	mode_select_button.pressed.connect(_on_mode_select_pressed)
	sandbox_button.pressed.connect(_on_sandbox_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	# Check if already logged in (e.g., from saved session).
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
	get_tree().change_scene_to_file("res://Core/GameSystems/Multiplayer/sandbox.tscn")

func _on_quit_pressed():
	get_tree().quit()
