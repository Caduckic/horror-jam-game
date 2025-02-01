extends Node3D

#@onready var outline = ResourceLoader.load("res://outline.material")
@onready var fake_mat = Material.new()
var unlocked = false

signal unlock_door

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if ($"Buttons/1".material_overlay):
		$"Buttons/1".material_overlay = fake_mat
		$"Buttons/2".material_overlay = fake_mat
		$"Buttons/3".material_overlay = fake_mat
		$"Buttons/4".material_overlay = fake_mat
		$"Buttons/5".material_overlay = fake_mat
		$"Buttons/6".material_overlay = fake_mat
		$"Buttons/7".material_overlay = fake_mat
		$"Buttons/8".material_overlay = fake_mat
		$"Buttons/9".material_overlay = fake_mat
		$"Buttons/0".material_overlay = fake_mat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_mat = $Screen.get_surface_override_material(0)
	screen_mat.albedo_texture.viewport_path = $PinScreenViewport._get_viewport()
	screen_mat.emission_texture.viewport_path = $PinScreenViewport._get_viewport()


func _on__button_pressed(char: String) -> void:
	if not unlocked:
		$ButtonSound.pitch_scale = 1 + randf_range(-0.03, 0.03)
		$ButtonSound.play()
		$PinScreenViewport._add_char(char)


func _on_pin_screen_viewport_error() -> void:
	$ErrorSound.play()


func _on_pin_screen_viewport_unlock_door() -> void:
	unlocked = true
	var buttons = $Buttons.get_children()
	for button in buttons:
		button.unlocked = true
	unlock_door.emit()
