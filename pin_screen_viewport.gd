extends Node2D

var passcode = "4412"

signal unlock_door
signal error

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_layer = 0
	$SubViewportContainer/SubViewport/Control/Label.text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _get_viewport():
	return $SubViewportContainer/SubViewport.get_path()

func _add_char(char : String):
	$SubViewportContainer/SubViewport/Control/Label.text += char
	if $SubViewportContainer/SubViewport/Control/Label.text.length() > 3:
		if $SubViewportContainer/SubViewport/Control/Label.text == passcode:
			unlock_door.emit()
		else:
			$SubViewportContainer/SubViewport/Control/Label.text = ""
			error.emit()
