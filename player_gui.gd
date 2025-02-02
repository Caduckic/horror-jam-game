extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.visible = false
	$Note.visible = false
	$EndingPanel.get_theme_stylebox("panel").bg_color = Color(0.0, 0.0, 0.0, 0.0)

func _read_note(text : String):
	$Note.visible = true
	$Note/Text.text = text

func _close_note():
	$Note.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$FPS.text = "FPS: %s" % Engine.get_frames_per_second()

func _set_label(text : String) -> void:
	$Label.visible = true
	$Label.text = text

func _play_ending():
	$AnimationPlayer.play("end_game")

func return_to_menu():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://menu_scene.tscn")
