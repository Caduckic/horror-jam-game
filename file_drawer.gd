extends Node3D

@export var message = "press e to open"
var open = false

@export var is_locked = false

@onready var outline = ResourceLoader.load("res://outline.material")
@onready var fake_mat = Material.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _check_key(has_key : bool):
	if has_key:
		message = "press e to unlock"

func _unlock():
	is_locked = false
	$Unlock.play()
	message = "press e to open"

func _toggle_open():
	if not is_locked:
		open = !open
		if open:
			message = "press e to close"
			$Open.play()
			$FilingCabinet_Drawer.position = $OpenMarker.position
			$Interaction/OpenCollisionShape.disabled = false
		else:
			message = "press e to open"
			$Close.play()
			$FilingCabinet_Drawer.position = $ClosedMarker.position
			$Interaction/OpenCollisionShape.disabled = true

func _high_light_drawer():
	$FilingCabinetSingle_Case/FilingCabinetSingle_Case.material_overlay = outline
	$FilingCabinet_Drawer/FilingCabinet_Drawer.material_overlay = outline
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if ($FilingCabinetSingle_Case/FilingCabinetSingle_Case.material_overlay):
		$FilingCabinetSingle_Case/FilingCabinetSingle_Case.material_overlay = fake_mat
		$FilingCabinet_Drawer/FilingCabinet_Drawer.material_overlay = fake_mat
