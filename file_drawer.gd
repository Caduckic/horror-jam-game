extends Node3D

@export var message = "press e to open"
var open = false

@export var is_locked = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _check_key(has_key : bool):
	if has_key:
		message = "press e to unlock"

func _unlock():
	is_locked = false
	message = "press e to open"

func _toggle_open():
	if not is_locked:
		open = !open
		if open:
			message = "press e to close"
			$FilingCabinet_Drawer.position = $OpenMarker.position
			$Interaction/OpenCollisionShape.disabled = false
		else:
			message = "press e to open"
			$FilingCabinet_Drawer.position = $ClosedMarker.position
			$Interaction/OpenCollisionShape.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
