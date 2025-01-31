extends Node3D

@onready var outline = ResourceLoader.load("res://outline.material")
@onready var fake_mat = Material.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if ($Chair.material_overlay):
		$Computer.material_overlay = fake_mat
		$Chair.material_overlay = fake_mat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_mat = $Computer.get_surface_override_material(2)
	#var text: ViewportTexture
	screen_mat.albedo_texture.viewport_path = $ScreenRenderTexture._get_viewport()
	screen_mat.emission_texture.viewport_path = $ScreenRenderTexture._get_viewport()
	

func _set_password(password : String):
	$ScreenRenderTexture.password = password
	
func _set_directory_structure(structure : Dictionary):
	$ScreenRenderTexture.directory_structure = structure

func _turn_on():
	$Computer/PowerSwitchSound.play()
	$ScreenRenderTexture/SubViewportContainer/SubViewport/Control/Panel.visible = false
	$Computer/ComputerFanSound.play()
	$ScreenRenderTexture.powered_on = true
	$Computer/ScreenLight.visible = true
	
func _turn_off():
	$Computer/PowerSwitchSound.play()
	$ScreenRenderTexture/SubViewportContainer/SubViewport/Control/Panel.visible = true
	$Computer/ComputerFanSound.stop()
	$ScreenRenderTexture/SubViewportContainer/SubViewport/Control/PanelContainer.visible = true
	$ScreenRenderTexture.unlocked = false
	$ScreenRenderTexture.powered_on = false
	$Computer/ScreenLight.visible = false

func _is_powered_on() -> bool:
	return $ScreenRenderTexture.powered_on
	
func _is_unlocked() -> bool:
	return $ScreenRenderTexture.unlocked

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

func _high_light_chair():
	$Chair.material_overlay = outline

func _high_light_computer():
	$Computer.material_overlay = outline
	#$Computer.material_overlay.set_shader_parameter("on", true)

func _on_screen_render_texture_invalid_command() -> void:
	$Computer/ComputerBeepSound.play()


func _on_screen_render_texture_yay() -> void:
	$Computer/YaySound.play()
