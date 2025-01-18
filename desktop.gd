extends Node3D

var player_sitting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_mat = $Computer.get_surface_override_material(2)
	#var text: ViewportTexture
	screen_mat.albedo_texture.viewport_path = $ScreenRenderTexture._get_viewport()
	screen_mat.emission_texture.viewport_path = $ScreenRenderTexture._get_viewport()

func _turn_on():
	$Computer/PowerSwitchSound.play()
	$ScreenRenderTexture/SubViewportContainer/SubViewport/Control/Panel.visible = false
	$Computer/ComputerFanSound.play()
	$ScreenRenderTexture.powered_on = true
	
func _turn_off():
	$Computer/PowerSwitchSound.play()
	$ScreenRenderTexture/SubViewportContainer/SubViewport/Control/Panel.visible = true
	$Computer/ComputerFanSound.stop()
	$ScreenRenderTexture/SubViewportContainer/SubViewport/Control/PanelContainer.visible = true
	$ScreenRenderTexture.unlocked = false
	$ScreenRenderTexture.powered_on = false

func _is_powered_on() -> bool:
	return $ScreenRenderTexture.powered_on

func _grab_focus():
	if $ScreenRenderTexture.unlocked:
		$ScreenRenderTexture/SubViewportContainer/SubViewport/Control/LineEdit.grab_focus()
	else:
		$ScreenRenderTexture/SubViewportContainer/SubViewport/Control/PanelContainer/VBoxContainer/PasswordInput.grab_focus()

func _release_focus():
	if $ScreenRenderTexture.unlocked:
		$ScreenRenderTexture/SubViewportContainer/SubViewport/Control/LineEdit.release_focus()
	else:
		$ScreenRenderTexture/SubViewportContainer/SubViewport/Control/PanelContainer/VBoxContainer/PasswordInput.release_focus()


func _on_screen_render_texture_invalid_command() -> void:
	$Computer/ComputerBeepSound.play()


func _on_screen_render_texture_yay() -> void:
	$Computer/YaySound.play()
