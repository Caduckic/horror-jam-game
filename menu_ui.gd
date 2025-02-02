extends Control

signal play
signal quit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() == "Web":
		$Control/VBoxContainer/QuitButton.process_mode = Node.PROCESS_MODE_DISABLED
		$Control/VBoxContainer/QuitButton.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")


func _on_options_button_pressed() -> void:
	$Control/VBoxContainer.visible = false
	$Control/Options.visible = true


func _on_return_button_pressed() -> void:
	$Control/Options.visible = false
	$Control/VBoxContainer.visible = true


func _on_check_button_button_up() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_check_button_button_down() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
